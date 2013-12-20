
repos := $(patsubst %/.git,%,$(wildcard */.git))
toget := $(shell cat repos | tr '\n' ' ')

setup: clone link

mbuild:
	@for repo in $(toget); do\
		name=`echo $$repo | sed 's/[^/]*\///'`;\
		if [ -d $$name ]; then\
			cd $$name; [ -f Makefile ] && make; cd ..; \
		fi; \
	done

clone:
	@for repo in $(toget); do\
		if [ -d `echo $$repo | sed 's/[^/]*\///'` ];\
	    then\
			echo "$$repo already exists";\
		else\
			git clone https://github.com/$$repo; \
		fi\
		done

link:
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir && npm link; cd ../; \
	done
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir;\
		for sub in $(repos); do\
			if [ -d node_modules/$$sub ]; then\
				npm link $$sub;\
			fi;\
		done;\
	done

component-reinstall:
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir;\
		rm -rf components;\
		component install;\
		cd ../;\
	done

component-install:
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir;\
		component install;\
		cd ../;\
	done

c-link:
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir;\
		if [ -f component.json ]; then\
			component install;\
			if [ -d components ]; then\
				cd components;\
				for repo in $(toget); do\
					fullname=`echo $$repo | sed 's/\//-/'`;\
					name=`echo $$repo | sed 's/[^/]*\///'`;\
					if [ -d $$fullname ];\
					then\
						rm -rf $$fullname && ln -s ../../$$name $$fullname;\
					fi;\
				done;\
				cd ..;\
			fi;\
		fi;\
		cd ..;\
	done


reload: clean setup

status: 
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir && git status; cd ../; \
	done

graphs: 
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir && component graph -t dot -o ../$$dir.png; cd ../; \
	done

examples: 
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir && make example; cd ../; \
	done

pull: 
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir && git pull; cd ../; \
	done

push: pull
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir && git push; cd ../; \
	done

comp:
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir;\
		component install --dev;\
		cd ..;\
	done

build:
	@for dir in $(repos); do\
	    zsh -c 'echo -e "\e[32m--> '$$dir'\e[0m"';\
		cd $$dir;\
		component build --dev;\
		cd ..;\
	done


