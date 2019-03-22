#! /usr/bin/env bash

# Get the name of the first remote repository
# after sorting them by number of usages. Typically, "origin".
function gorigin {
    git remote -v | cut -f1 | uniq -c | sort -rn | head -1 \
            | sed 's/^ *[0-9]* *//'
}

function gdel {
    local line
    local cur_br
    local zencmd
    local at_least_one
    
    cur_br=$(
        git rev-parse --abbrev-ref HEAD 2> /dev/null
    )
    
    zencmd=(
        zenity --list --checklist
        --title 'Delete local branches'
        --text "Choose branches to delete.$(
            if [ "$cur_br" ]
            then
                echo "\n(Currently on “${cur_br}”.)"
            fi
        )"
        --width 1100 --height 750
        --separator $'\n'
        --column 'Delete?' --column 'Branch name'
    )
    while read -r line
    do
        # Skip if current.
        test "$line" = "$cur_br" && continue
        
        zencmd+=('' "$line")
        at_least_one=1
    done < <(git branch --list | sed 's/^[* ] //')
    
    if [ "$at_least_one" ]
    then
        "${zencmd[@]}" 2> /dev/null \
                | xargs --no-run-if-empty -n 1 \
                git branch -D
    else
        echo 'Nothing to delete.' >&2
    fi
}

# Args are passed to git push, so you can do “gpush -f”.
function gpush {
    local cur_br
    local origin
    local cmd
    
    cur_br=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    origin=$(gorigin)
    : ${cur_br:?} ${origin:?}
    
    cmd=(git push "$@" "$origin" "$cur_br")
    printf 'Running: '
    printf ' %q' "${cmd[@]}"
    echo
    "${cmd[@]}"
}

# Merge with distant branch of the same name
# only if fast-forward is possible.
function gff {
    local cur_br
    local origin
    local cmd
    
    git fetch -p
    
    cur_br=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    origin=$(gorigin)
    : ${cur_br:?} ${origin:?}
    
    cmd=(git merge --ff-only "$origin"/"$cur_br")
    printf '“%s” ' "${cmd[@]}"
    echo
    "${cmd[@]}"
}

function grename {
    local name
    
    name=$1
    if ! [ "$name" ]
    then
        read -ep 'Name? ' name
    fi
    
    git branch -m "${name:?Please give a branch name.}" &&
    echo 'Branch successfully renamed.'
}

alias gfetch='git fetch --all -p && echo && git status'

alias gnew='gfetch && git checkout -b to-be-renamed-"$RANDOM" origin/develop && grename'

alias glog='git log --pretty=oneline --abbrev-commit'

alias conflicts='grep -rIn '"'"'\(^\|[^<]\)<<<<<<<\($\|[^<]\)\|\(^\|[^=]\)=======\($\|[^=]\)\|\(^\|[^>]\)>>>>>>>\($\|[^>]\)'"'"

alias gsave='git stash save'
alias gpop='git stash pop'
