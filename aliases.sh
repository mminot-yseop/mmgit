alias gfetch='git fetch --all -p && echo && git status'

alias gnew='gfetch && git checkout -b to-be-renamed-"$RANDOM" origin/develop && grename'

alias glog='git log --pretty=oneline --abbrev-commit'

alias conflicts='grep --exclude-dir=node_modules/ -rIn '"'"'\(^\|[^<]\)<<<<<<<\($\|[^<]\)\|\(^\|[^=]\)=======\($\|[^=]\)\|\(^\|[^>]\)>>>>>>>\($\|[^>]\)'"'"

alias gsave='git stash push'
alias gpop='git stash pop'
