# .funcs/misc.sh
#
# Miscellaneous shell functions and aliases.
# Source this directly or source env.sh for everything.
#
# Brandon Amos
# http://bamos.github.io
# 2015/04/27

rand-cd() {
  local DIRS; DIRS=$(find . -maxdepth 1 -type d | sed 's/\(.*\)/"\1"/g')
  local NUM_DIRS=$(echo $DIRS | wc -l)
  [[ $NUM_DIRS == 1 ]] && die "Error: No directories found."
  cd "$(echo $DIRS | xargs -n $NUM_DIRS shuf -n1 -e)"
}
alias rcd='rand-cd'

bcatmd() {
  markdown $* | bcat
}

wget-rec() {
  wget --recursive \
    --page-requisites \
    --html-extension \
    --convert-links \
    --no-parent \
    $*
}

d2h() { # diff2html
  local TMP_FILE=$(mktemp -t hdiff.XXXX)
  diff2html $@ > $TMP_FILE
  chromium $TMP_FILE
}

mkdircd() { mkdir -p $@ && cd ${@:${#@}}; }
alias mcd='mkdircd'

# Netjoin - Block until a network connection is obtained.
nj() {
  while true; do
    ping -c 1 8.8.8.8 &> /dev/null && break
    sleep 1
  done
}

# Thread functions.
ps-threads() { ps -C $1 -L -opsr,pid,ppid,lwp,state }
watch-threads() { watch -n 1 ps -C $1 -L -opsr,pid,ppid,lwp,state }

# Allow crontab in dotfiles.
[ -z "${CRONTABCMD+x}" ] && export CRONTABCMD=$(which crontab)
# [ -z "${CRONTABFILE+x}" ] && export CRONTABFILE=$HOME/.crontab.$HOST
[ -z "${CRONTABFILE+x}" ] && export CRONTABFILE=$HOME/.crontab
crontab() {
  if [[ $@ == "-e" ]]; then vim $CRONTABFILE && $CRONTABCMD $CRONTABFILE
  else $CRONTABCMD $@; fi
}

function stopwatch(){
  case $(uname) in
    "Linux") DATE=date ;;
    "Darwin") DATE=gdate ;;
  esac
  local BEGIN=`$DATE +%s`
  while true; do
    echo -ne "$($DATE -u --date @$((`$DATE +%s` - $BEGIN)) +%H:%M:%S)\r";
  done
}

sys-find() {
  find / -name $@ 2>/dev/null
}

dump-packages() {
  yaourt -Qe | cut -d ' ' -f 1 | sed 's/^.*\///'
}

mkdir-mv() {
  [[ $# == 2 ]] || return -1
  mkdir -p $(dirname $2) && mv $1 $2
}

mkdir-cp() {
  [[ $# == 2 ]] || return -1
  mkdir -p $(dirname $2) && cp $1 $2
}

# http://stackoverflow.com/a/21096209/1381755
ls-by-files() {
  find . -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -n
}

# http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}


alias c='clear'
alias chax='chmod a+x'
alias h='hostname'
alias i-ext='curl icanhazip.com'
alias li='libreoffice'
alias rh='rehash'
alias sudo='nocorrect sudo'
alias xa='xrandr --auto'
alias xax='xrandr --auto; exit'
alias dx='dual; exit'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias grive='grive -p ~/grive'
alias wh='which'
alias j='jobs'

# alias mu='mutt'
# mu() {
#   echo "Is this important?"
#   read REPLY
#   [[ $REPLY =~ ^[Yy]$ ]] && mutt $*
# }

alias rsyncdir='rsync -azv --progress'
alias bup='vim +BundleInstall +qall'
alias bcl='vim +BundleClean +qall'

alias pw='pwgen --numerals --symbols --ambiguous 15 1'

alias tmux='tmux -2'
alias ts='tmux split-window'
alias tsh='tmux split-window -h'

alias f='sudo $(fc -ln -1)'

alias emacsd='emacs --daemon'
alias e='emacsclient -a "" -c'
alias enq='emacsclient -nq'

alias psg='ps aux | grep'
alias psgrep='ps aux | grep'

alias clauncher='chromium --show-app-list'

alias random-mac="openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'"

alias remove-tags='eyeD3 --remove-all'
alias add-tags='picard'
alias get-tags='exiftool -json'

alias mcm='make clean; make'

alias recreate-tmux-sockets='pgrep tmux | xargs -I {} kill -SIGUSR1 {}'

# from https://gist.github.com/karpathy/1dd0294ef9567971c1e4348a90d69285
gcm() {
    if git diff --cached --quiet; then
        echo "Error: No staged changes found."
        return 1
    fi

    # Function to generate commit message
    generate_commit_message() {
        git diff --cached | llm "
Below is a diff of all staged changes, coming from the command:
\`\`\`
git diff --cached
\`\`\`
Please generate a concise, one-line commit message for these changes."
    }

    # Function to read user input compatibly with both Bash and Zsh
    read_input() {
        if [ -n "$ZSH_VERSION" ]; then
            echo -n "$1"
            read -r REPLY
        else
            read -p "$1" -r REPLY
        fi
    }

    # Main script
    echo "Generating AI-powered commit message..."
    commit_message=$(generate_commit_message)

    while true; do
        echo -e "\nProposed commit message:"
        echo "$commit_message"

        read_input "Do you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? "
        choice=$REPLY

        case "$choice" in
            a|A )
                if git commit -m "$commit_message"; then
                    echo "Changes committed successfully!"
                    return 0
                else
                    echo "Commit failed. Please check your changes and try again."
                    return 1
                fi
                ;;
            e|E )
                read_input "Enter your commit message: "
                commit_message=$REPLY
                if [ -n "$commit_message" ] && git commit -m "$commit_message"; then
                    echo "Changes committed successfully with your message!"
                    return 0
                else
                    echo "Commit failed. Please check your message and try again."
                    return 1
                fi
                ;;
            r|R )
                echo "Regenerating commit message..."
                commit_message=$(generate_commit_message)
                ;;
            c|C )
                echo "Commit cancelled."
                return 1
                ;;
            * )
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}
