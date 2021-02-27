This is an updated version of the ORCALib library suitable for use with
GNO 2.0.6.  For those library functions that it implements, it contains
the same updates and fixes as the standard version of ORCALib included
with ORCA/C 2.2.0 B5.  However, under GNO, some portions of the C standard
library are implemented by GNO's libc rather than by ORCALib, and so
updating ORCALib will not affect those library functions.  This applies
to all of <stdio.h>, as well as to certain other functions.

This library update is intended for use with ORCA/C 2.2.0 B5, but it
should also be compatible with ORCA/C versions back to 2.1.

To install the update, copy the new version of ORCALib into the /lib
directory, replacing the version provided with GNO 2.0.6.
