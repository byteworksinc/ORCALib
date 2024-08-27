This package contains a special version of ORCALib intended for use with
the GNO multitasking environment.  This version of ORCALib is specific to
GNO and should only be used if you are running ORCA/C under GNO 2.0.6.

For those library functions that it implements, this version of ORCALib
contains the same updates and changes as the standard version of ORCALib
included with ORCA/C 2.2.1.  However, under GNO, some portions of the C
standard library are implemented by GNO's libc rather than by ORCALib, and
so updating ORCALib will not affect those library functions.  This applies
to all of <stdio.h>, as well as to certain other functions.

To install the ORCA/C 2.2.1 libraries for use under GNO, you should copy
the following three libraries into the /lib directory of your GNO
installation in the order shown, replacing any previous versions:

1) ORCALib (from this package)
2) SysFloat (from the Libraries directory of your ORCA/C installation)
3) SysLib (from the Libraries directory of your ORCA/C installation)
