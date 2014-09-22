
# Setting PATH for Python 3.4
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.4/bin:${PATH}"
export PATH

##
# Your previous /Users/thaddeusdiamond/.bash_profile file was backed up as /Users/thaddeusdiamond/.bash_profile.macports-saved_2014-09-21_at_19:36:24
##

# MacPorts Installer addition on 2014-09-21_at_19:36:24: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/lib/postgresql93/bin:/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
