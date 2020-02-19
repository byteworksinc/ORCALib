         keep  obj/vars
         mcopy vars.macros
         case  on
****************************************************************
*
*  VARS.ASM
*
*  This module contains the global variables used by C.  When
*  using the large memory module, these variables are replaced by
*  GVARS.ASM, which places the variables in the ~GLOBALS
*  segment.
*
****************************************************************
*
Dummy    start                          (dummy root segment)

         copy  equates.asm
         end

****************************************************************
*
*  Global variables used by C
*
****************************************************************
*
CVars    start

errno    entry                          library error number
         ds    2
_ownerid entry                          user ID (C)
~USER_ID entry                          user ID (Pascal, libraries)
         ds    2
__cleanup entry                         function to clean up files at exit
         dc    i4'0'
_toolErr entry                          last error in a tool call (C)
~TOOLERROR entry                        last error in a tool call (Pascal)
         ds    2
         end
