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
sys_nerr entry                          # of error messages
         dc    i'12'
_toolErr entry                          last error in a tool call (C)
~TOOLERROR entry                        last error in a tool call (Pascal)
         ds    2
         end

****************************************************************
*
*  ~InitIO - initialize the standad I/O files
*
****************************************************************
*
~InitIO  start

         ldx   #24                      set up the file records
lb1      lda   stderr+34,X
         sta   stderr+8,X
         lda   stdin+34,X
         sta   stdin+8,X
         lda   stdout+34,X
         sta   stdout+8,X
         dex
         dex
         bpl   lb1
         lla   stderr,stderr+4          set up the file pointers
         lla   stdin,stdin+4
         lla   stdout,stdout+4
         rtl
         end

****************************************************************
*
*  stderr - error out file
*
****************************************************************
*
stderr   start

         dc    a4'lb1'

lb1      dc    a4'0'                    next file
         dc    a4'0'                    next location to write to
         dc    a4'0'                    first byte of buffer
         dc    a4'0'                    end of the file buffer
         dc    i4'0'                    size of the file buffer
         dc    i4'0'                    count
         dc    i'EOF'                   putback buffer
         dc    i'_IONBF+_IOWRT+_IOTEXT' no buffering; allow writes; text file
         dc    i'stderrID'              error out

         dc    a4'0'                    next location to write to
         dc    a4'0'                    first byte of buffer
         dc    a4'0'                    end of the file buffer
         dc    i4'0'                    size of the file buffer
         dc    i4'0'                    count
         dc    i'EOF'                   putback buffer
         dc    i'_IONBF+_IOWRT+_IOTEXT' no buffering; allow writes; text file
         dc    i'stderrID'              error out
         end

****************************************************************
*
*  stdin - standard in file
*
****************************************************************
*
stdin    start

         dc    a4'lb1'

lb1      dc    a4'stdout+4'             next file
         dc    a4'0'                    next location to write to
         dc    a4'0'                    first byte of buffer
         dc    a4'0'                    end of the file buffer
         dc    i4'0'                    size of the file buffer
         dc    i4'0'                    count
         dc    i'EOF'                   putback buffer
         dc    i'_IONBF+_IOREAD+_IOTEXT' no buffering; allow reads; text file
         dc    i'stdinID'               standard in

         dc    a4'0'                    next location to write to
         dc    a4'0'                    first byte of buffer
         dc    a4'0'                    end of the file buffer
         dc    i4'0'                    size of the file buffer
         dc    i4'0'                    count
         dc    i'EOF'                   putback buffer
         dc    i'_IONBF+_IOREAD+_IOTEXT' no buffering; allow reads; text file
         dc    i'stdinID'               standard in
         end

****************************************************************
*
*  stdout - standard out file
*
****************************************************************
*
stdout   start

         dc    a4'lb1'

lb1      dc    a4'stderr+4'             next file
         dc    a4'0'                    next location to write to
         dc    a4'0'                    first byte of buffer
         dc    a4'0'                    end of the file buffer
         dc    i4'0'                    size of the file buffer
         dc    i4'0'                    count
         dc    i'EOF'                   putback buffer
         dc    i'_IONBF+_IOWRT+_IOTEXT' no buffering; allow writes; text file
         dc    i'stdoutID'              standard out

         dc    a4'0'                    next location to write to
         dc    a4'0'                    first byte of buffer
         dc    a4'0'                    end of the file buffer
         dc    i4'0'                    size of the file buffer
         dc    i4'0'                    count
         dc    i'EOF'                   putback buffer
         dc    i'_IONBF+_IOWRT+_IOTEXT' no buffering; allow writes; text file
         dc    i'stdoutID'              standard out
         end
