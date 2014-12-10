# These things are also easily available outside interactive Bash sessions,
# like non-interactive Bash sessions,
# other command line shells sessions and even the graphical shell/desktop environment.
# The .profile file should be loaded on login on Linux setups

# Add some more custom software to PATH.
PATH=$PATH:~/usr/bin
export PATH
 
# Make sure pkg-config can find self-compiled software
# and libraries (installed to ~/usr)
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:~/usr/lib/pkgconfig
export PKG_CONFIG_PATH
 
# Add custom compiled libraries to library search path.
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/usr/lib
export LD_LIBRARY_PATH
 
# Add custom compiled libraries to library run path.
LD_RUN_PATH=$LD_RUN_PATH:~/usr/lib
export LD_RUN_PATH
 
# Add custom Python modules to the Python path.
PYTHONPATH=$PYTHONPATH:~/slippenspythonlib
PYTHONPATH=$PYTHONPATH:~/usr/lib/python2.5/site-packages
export PYTHONPATH
 
# Java;s CLASSPATH customization
CLASSPATH=$CLASSPATH:~/foo/bar.jar
export CLASSPATH
