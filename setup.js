#!/usr/bin/env node

var fs = require('fs')
  , child = require('child_process')
  , path = require('path')
  , exec = child.exec
  , execFile = child.execFile
  , Batch = require('batch')
  , program = require('commander')
  , debug = require('debug')('runner')
  
  , repoPath = path.join(__dirname, '../repos');

function clone(child, next) {
  fs.exists(child.name, function (exists) {
    if (exists) {
      debug('Repo exists:', child.full);
      return next();
    }
    debug('Cloning', child.full);
    var ex = exec('git clone git@github.com:' + child.full + '.git', function () {
      var ex = exec('cd ' + child.name + ' && component install --dev', next);
    });
  });
}

function link(repo, child, next) {
  var toPath = path.join(repo.name, 'components', child.component);
  next = next || function(){};
  var link = function () {
    debug('Linking', child.name, toPath);
    fs.symlink('../../' + child.name, toPath, function(err) {
      if (err) {
        debug('Failed to link', child.name, toPath, err);
        return next(err);
      }
      next();
    });
  };
  fs.exists(toPath, function (exists) {
    if (exists) {
      rmrf(toPath, link);
    } else {
      // not linking, not needed
    }
  });
}

var rmrf = function(directories, callback) {
  debug('Removing', directories);
  var args = ['-rf', directories];
  execFile('rm', args, {env:process.env}, function(err, stdout, stderr) {
    callback.apply(this, arguments);
  });
};

function getRepos(next) {
  fs.readFile(repoPath, function (err, data) {
    if (err) return next(err)
    var lines = data.toString('utf8').split('\n');
    next(null, lines.map(function(line){
      line = line.trim();
      if (!line) return;
      var parts = line.split('/');
      return {
        name: parts[1],
        component: parts.join('-'),
        full: line,
        user: parts[0]
      };
    }).filter(function(x){return !!x;}));
  });
}

var cmds = {
  clone: function (batch, err, repos) {
    if (err) throw new Error(err);
    repos.forEach(function(repo) {
      batch.push(clone.bind(null, repo));
    });
  },
  link: function (batch, err, repos) {
    if (err) throw new Error(err);
    repos.forEach(function(repo) {
      repos.forEach(function(sub) {
        if (repo.full === sub.full) return;
        batch.push(link.bind(null, repo, sub));
      });
    });
  },
  rm: function (batch, err, repos) {
    if (err) throw new Error(err);
    repos.forEach(function(repo) {
      batch.push(rmrf.bind(null, repo.name));
    });
  }
}

program
  .version('0.0.1')
  .parse(process.argv);

if (process.argv.length < 3 || !cmds[process.argv[2]]) {
  program.outputHelp();
} else {
  var batch = new Batch;
  getRepos(function (err, repos) {
    cmds[process.argv[2]](batch, err, repos);
    batch.end(function (err, res) {
      debug('finished');
    });
  });
}

