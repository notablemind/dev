
repos := $(patsubst %/.git,%,$(wildcard */.git))

setup:
	./make.js clone
	./make.js link

reload: clean setup

clean:
	./make.js rm

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

link:
	./make.js link


