# .funcs/env.sh
#
# Custom shell functions and aliases that can be sourced from
# bash or zsh.
#
# Brandon Amos
# http://bamos.github.io
# 2015/04/27

die() { echo $@; exit -1; }

FUNCS_DIR=$(dirname $0)
source $FUNCS_DIR/android.sh
source $FUNCS_DIR/git.sh
source $FUNCS_DIR/misc.sh

# OS and distro-specific aliases.
# Sourced at the end in case they need to over-ride anything above.
case $(uname) in
  "Linux")
    source $FUNCS_DIR/if-linux.sh
    if command -v lsb_release &> /dev/null; then
      case $(lsb_release -s -i) in
        "Arch")
          source $FUNCS_DIR/if-linux-arch.sh
        ;;
        "Ubuntu")
          source $FUNCS_DIR/if-linux-ubuntu.sh
        ;;
      esac
    fi
  ;;
  "Darwin")
   source $FUNCS_DIR/if-osx.sh
  ;;
esac

unset -f die
