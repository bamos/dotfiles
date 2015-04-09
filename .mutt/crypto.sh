#!/usr/bin/env bash
# ~/.mutt/crypto.sh
#
# ---
#
# Note: This script is deprecated thanks to mutt's gpgme integration, which
# I discoved through Henry Todd's (http://github.com/hjst) post:
# http://henrytodd.org/notes/2014/simpler-gnupg-mutt-config-with-gpgme/
#
# ---
#
# Provide crypto functionality to mutt when used between
# multiple computers with conflicting GnuPG versions.
#
# 2015-03-20
# Brandon Amos
# http://github.com/bamos
#
# -----
#
# Of 2015-03-20 mutt's wiki's MuttGuide/UseGPG page at
# http://dev.mutt.org/trac/wiki/MuttGuide/UseGPG
# provides example config options to use mutt with GnuPG,
# but is incompatible with GnuPG>=2.1.0.
#
# GnuPG 2.1.0 requires use of gpg-agent and pinentry and
# breaks backwards compatibility.
# To pipe the passphrase over stdin with mutt, one fix is
# to enable the loopback pinentry mode in the gpg-agent
# configuration and update the mutt commands to use the
# `--pinentry-mode loopback` flag as described in
# https://wiki.archlinux.org/index.php/GnuPG#Unattended_passphrase.
#
# However, I version-control my non-private mutt configuration
# at https://github.com/bamos/dotfiles and use it between multiple computers
# with conflicting gpg versions.
# This script will provide the appropriate gpg flags to mutt
# regardless of the gpg version being used.
#
# This shell script should be put in the same location on each machine
# and sourced in your mutt configuration with `source '~/.mutt/crypto.sh|`
# as described in the manual at
# http://www.mutt.org/doc/manual/manual-3.html.
#
# ----
#
# Set the following in your mutt config to automatically encrypt messages
# to `user@domain.com`.
# If you're using https://github.com/bamos/dotfiles, this works
# well in `~/.mutt/private`.
#
#    send-hook "!~l ~t user@domain\\.com" "set crypt_autoencrypt crypt_autosign"


# Set the following to your key.
# This script should be modified if you use multiple keys.
YOUR_KEY=0xB72D6B6F

set -e # Exit and return nonzero if any command returns nonzero.

# If gpg supports `pinentry-mode`, set it to loopback.
PINENTRY_MODE=''
gpg --pinentry-mode loopback --gpgconf-test &> /dev/null \
  && PINENTRY_MODE+='--pinentry-mode loopback'

function mutt_set {
  # Output mutt's variable assignment statement.
  local VAR=$1
  shift
  local CMD=$@
  printf 'set %s = "%s"\n' "$VAR" "$CMD"
}

# Convenience variables
PASSFD='--passphrase-fd 0'
NOV_B_O='--no-verbose --batch --output'

mutt_set pgp_decode_command \
         gpg $PINENTRY_MODE %?p?$PASSFD? $NOV_B_O - %f
mutt_set pgp_verify_command \
         gpg $NOV_B_O - --verify %s %f
mutt_set pgp_decrypt_command \
         gpg $PINENTRY_MODE $PASSFD $NOV_B_O - %f
mutt_set pgp_sign_command \
         gpg $PINENTRY_MODE $NOV_B_O - \
         $PASSFD --armor --detach-sign --textmode %?a?-u %a? %f
mutt_set pgp_clearsign_command \
         gpg $PINENTRY_MODE $NOV_B_O - \
         $PASSFD --armor --textmode --clearsign %?a?-u %a? %f
mutt_set pgp_encrypt_only_command \
         pgpewrap gpg \
         --quiet $NOV_B_O - \
         --encrypt --textmode --armor --always-trust \
         --encrypt-to $YOUR_KEY -- -r %r -- %f
mutt_set pgp_encrypt_sign_command \
         pgpewrap gpg $PINENTRY_MODE $PASSFD \
         --batch --quiet --no-verbose \
         --textmode --output - --encrypt --sign %?a?-u %a? --armor \
         --always-trust --encrypt-to 0xB72D6B6F -- -r %r -- %f
mutt_set pgp_import_command \
         gpg --no-verbose --import -v %f
mutt_set pgp_export_command \
         gpg --no-verbose --export --armor %r
mutt_set pgp_verify_key_command \
         gpg --no-verbose --batch --fingerprint --check-sigs %r
mutt_set pgp_list_pubring_command \
         gpg --no-verbose --batch --with-colons --list-keys %r
mutt_set pgp_list_secring_command \
         gpg --no-verbose --batch --with-colons --list-secret-keys %r

cat<<EOF
set pgp_sign_as=$YOUR_KEY

set pgp_timeout=6000
set pgp_good_sign="^gpg: Good signature from"

set crypt_autosign
set crypt_replysign

set crypt_replyencrypt=yes
set crypt_replysignencrypted=yes

set crypt_verify_sig=yes

send-hook . 'reset pgp_autoencrypt'

set pgp_auto_decode
EOF
