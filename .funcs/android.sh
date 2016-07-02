# .funcs/android.sh
#
# Android shell functions and aliases.
# Source this directly or source env.sh for everything.
#
# Brandon Amos
# http://bamos.github.io
# 2015/04/27

musicToAndroid() {
  { adb devices | grep "device$" &> /dev/null } \
    || { echo "No devices found."; return; }
  if [[ $(uname) == "Linux" ]]; then SORT=sort;
  else SORT=gsort; fi
  while read SONG; do
    echo "Syncing $SONG."
    #TODO - Get relative directory.
    adb push $SONG /sdcard/Music &> /dev/null
    [[ $? != 0 ]] && echo " + Failed."
  done < <(find $* | $SORT -R)
  unset SORT
}
alias m2a='musicToAndroid'

alias pullimages="adb pull /storage/sdcard0/DCIM/Camera ."
