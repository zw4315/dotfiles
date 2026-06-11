# gtags (GNU Global) configuration
# Loaded by ~/.profile via profile.d mechanism

# Use Universal Ctags plug-in parser for broader language support
# (native-pygments requires /usr/bin/ctags-exuberant which is often missing;
# universal-ctags handles C/C++/Python/Go/etc. out of the box.)
export GTAGSLABEL='universal-ctags'
export GTAGSCONF="$HOME/.global/gtags.conf"
