         keep  obj/fcntl
         mcopy fcntl.macros
         case  on

****************************************************************
*
*  fcntl - UNIX primitive input/output facilities
*
*  This code implements the tables and subroutines needed to
*  support a subset of the UNIX library FCNTL.
*
*  October 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************
*
FCNTL    start                          dummy segment
         copy  equates.asm
strSize  gequ  255                      max size of a GS/OS path name

         end

****************************************************************
*
*  ctoosstr - convert a C string to a GS/OS input string
*
*  Inputs:
*        cstr - pointer to the c string
*
*  Outputs:
*        returns a pointer to the OS string
*
*  Notes:
*        If the C string is longer than strSize bytes, the
*        string is truncated without warning.
*
****************************************************************
*
ctoosstr private
osptr    equ   1                        os string pointer

         csubroutine (4:cstr),4

         phb                            use a local B reg
         phk
         plb
         short M                        copy over the characters
         ldy   #0
lb1      lda   [cstr],Y
         beq   lb2
         sta   osstr+2,Y
         iny
         cpy   #strSize
         bne   lb1
lb2      sty   osstr                    set the string length
         long  M
         lla   osptr,osstr              set the address of the string
         plb                            restore caller's B

         creturn 4:osptr                return osptr

osstr    ds    2+strSize                GS/OS string buffer
         end

****************************************************************
*
*  int chmod(char *path, int mode);
*
*  Changes the access bits.
*
*  Inputs:
*        path - name of the file
*        mode - zero or more flags to set:
*              0x0100 - read
*              0x0080 - write
*              0x1000 - delete
*              0x2000 - rename
*              0x4000 - backup
*              0x8000 - invisible
*
*  Outputs:
*        returns 0 if successful; else -1
*        errno - set if an error occurred
*
****************************************************************
*
chmod    start
err      equ   1                        error return code

         csubroutine (4:path,2:mode),2

         phb                            use local B
         phk
         plb
         stz   err                      err = 0 {no error}
         lda   mode                     convert mode to ProDOS format
         jsr   unixtoprodos
         sta   siAccess
         ph4   path                     set the path name
         jsl   ctoosstr
         sta   siPathname
         stx   siPathname+2
         OSSet_File_Info siRec          set the access bits
         bcs   lb1
         lda   siAccess                 if the backup bit is clear then
         and   #$0020
         bne   lb2
         move4 siPathname,cbPathname      clear the backup bit
         OSClear_Backup cbRec
         bcc   lb2
lb1      lda   #ENOENT                  flag an error
         sta   >errno
         dec   err
lb2      plb

         creturn 2:err

cbRec    dc    i'1'                     ClearBackup record
cbPathname ds  4

siRec    dc    i'2'                     SetFileInfo record
siPathname ds  4
siAccess ds    2
         end

****************************************************************
*
*  int close(int filds);
*
*  Close a file.
*
*  Inputs:
*        filds - file ID of the file to close
*
*  Outputs:
*        returns 0 if successful; else -1
*        errno - set if an error occurred
*
****************************************************************
*
close    start
err      equ   1                        error return code

         csubroutine (2:filds),2

         stz   err                      err = 0 {no error}
         lda   filds                    error if there are too many open files
         bmi   lb2
         cmp   #OPEN_MAX
         bge   lb2
         asl   A                        get the file reference number
         asl   A
         tax
         lda   >files,X
         beq   lb2
         sta   >clRefnum
         lda   #0                       free the file record
         sta   >files,X
         ldx   #OPEN_MAX*4-4            for each file record do
         lda   >clRefnum                  if the file is a duplicate then
lb1      cmp   >files,X
         beq   lb3                          skip the close
         dex
         dex
         dex
         dex
         bpl   lb1
         OSClose clRec                  close the file
         bcc   lb3

lb2      lda   #EBADF                   an error occurred - set errno
         sta   >errno
         dec   err                      err = -1

lb3      creturn 2:err

clRec    dc    i'1'                     close record
clRefnum ds    2
         end

****************************************************************
*
*  int creat(char *path, int mode);
*
*  Create a file.
*
*  Inputs:
*        path - name of the file
*        mode - zero or more flags to set:
*              0x0100 - read
*              0x0080 - write
*              0x1000 - delete
*              0x2000 - rename
*              0x4000 - backup
*              0x8000 - invisible
*
*  Outputs:
*        returns 0 if successful; else -1
*        errno - set if an error occurred
*
****************************************************************
*
creat    start
err      equ   1                        error return code

         csubroutine (4:path,2:mode),2

         ph2   #O_WRONLY+O_TRUNC+O_CREAT
         ph2   mode
         ph4   path
         jsl   openfile
         sta   err

         creturn 2:err
         end

****************************************************************
*
*  int dup(int old);
*
*  Duplicate a file descriptor
*
*  Inputs:
*        old - existing file descriptor
*
*  Outputs:
*        returns 0 if successful; else -1
*        errno - set if an error occurred
*
****************************************************************
*
dup      start
err      equ   1                        error return code

         csubroutine (2:old),2

         ph2   #0
         ph2   #F_DUPFD
         ph2   old
         jsl   fcntl
         sta   err

         creturn 2:err
         end

****************************************************************
*
*  int fcntl(int filds, int cmd, int arg);
*
*  Open file control
*
*  Inputs:
*        filds - file ID of file
*        cmd - command; F_DUPD is the only one accepted
*        arg - lowest acceptable returned file ID
*
*  Outputs:
*        returns -1 for an error; new filds for success
*        errno - set if an error occurred
*
****************************************************************
*
fcntl    start
err      equ   1                        error return code
refnum   equ   3                        reference number
flags    equ   5                        file flags

         csubroutine (2:filds,2:cmd,2:arg),6

         stz   err                      err = 0 {no error}
         lda   cmd                      the command must be F_DUPFD
         cmp   #F_DUPFD
         beq   lb1
         dec   err
         lda   #EINVAL
         sta   >errno
         bra   lb7

lb1      lda   filds                    error if there are too many open files
         bmi   lb2
         cmp   #OPEN_MAX
         bge   lb2
         asl   A                        get the file reference number
         asl   A
         tax
         lda   >files,X
         bne   lb3
lb2      dec   err                      flag an invalid filds error
         lda   #EBADF
         sta   >errno
         bra   lb7
lb3      sta   refnum
         lda   >files+2,X               get the file flags
         sta   flags

         lda   arg                      find a new filds
         bmi   lb5
         cmp   #OPEN_MAX
         bge   lb5
         asl   A
         asl   A
lb4      lda   >files,X
         beq   lb6
         inx
         inx
         inx
         inx
         cpx   #OPEN_MAX*4
         bne   lb4
lb5      dec   err                      none are available -- flag the error
         lda   #EMFILE
         sta   >errno
         bra   lb7
lb6      lda   refnum                   set the new refnum
         sta   >files,X
         lda   flags                    set the new flags
         sta   >files+2,X
         txa                            return the filds
         lsr   A
         lsr   A
         sta   err

lb7      creturn 2:err
         end

****************************************************************
*
*  files - array of file records
*
*  There are OPEN_MAX elements, each with the following format:
*
*        bytes use
*        ----- ---
*        2     file reference number; 0 if element is free
*        2     flags; set by open command
*
*  Notes:  Array calculations throughout the module depend on
*          a record size within the array of exactly 4 bytes.
*
****************************************************************
*
files    private

         ds    4*OPEN_MAX
         end

****************************************************************
*
*  long lseek(int filds, long offset, int whence);
*
*  Set the file mark
*
*  Inputs:
*        filds - file ID of file
*        offset - new file mark
*        whence - set the mark in relation to:
*              0 - file start
*              1 - current mark
*              2 - file end
*
*  Outputs:
*        returns file pointer if successful; -1 for an error
*        errno - set if an error occurred
*
****************************************************************
*
lseek    start
mark     equ   1                        new file mark

         csubroutine (2:filds,4:offset,2:whence),4

         lda   #$FFFF                   assume we will get an error
         sta   mark
         sta   mark+2
         lda   filds                    get the file refnum
         bmi   lb1
         cmp   #OPEN_MAX
         bge   lb1
         asl   A
         asl   A
         tax
         lda   >files,X
         bne   lb2
lb1      lda   #EBADF                   bad refnum error
         sta   >errno
         bra   lb4

lb2      sta   >smRefnum                set the file refnum
         sta   >gmRefnum
         lda   whence                   convert from UNIX whence to GS/OS base
         beq   lb3
         eor   #$0003
         cmp   #4
         bge   lb2a
         cmp   #2
         bne   lb3
         sta   >smBase
         lda   offset+2
         bpl   lb3a
         sub4  #0,offset,offset
         lda   #3
         bra   lb3
lb2a     lda   #EINVAL                  invalid whence flag
         sta   >errno
         bra   lb4
lb3      sta   >smBase                  save the base parameter
lb3a     lda   offset                   set the displacement
         sta   >smDisplacement
         lda   offset+2
         sta   >smDisplacement+2
         OSSet_Mark smRec               set the file mark
         bcs   lb1
         OSGet_Mark gmRec               get the new mark
         bcs   lb1
         lda   >gmDisplacement
         sta   mark
         lda   >gmDisplacement+2
         sta   mark+2

lb4      creturn 4:mark

smRec    dc    i'3'                     SetMark record
smRefnum ds    2
smBase   ds    2
smDisplacement ds 4

gmRec    dc    i'2'                     GetMark record
gmRefnum ds    2
gmDisplacement ds 4
         end

****************************************************************
*
*  int open(char *path, int oflag);
*
*  Open a file
*
*  Inputs:
*        path - name of the file
*        oflag - output flags
*
*  Outputs:
*        returns 0 if successful; else -1
*        errno - set if an error occurred
*
****************************************************************
*
open     start
err      equ   1                        error return code

         csubroutine (4:path,2:oflag),2

         ph2   oflag
         ph2   #$7180
         ph4   path
         jsl   openfile
         sta   err

         creturn 2:err
         end

****************************************************************
*
*  int openfile(char *path, int mode, int oflag);
*
*  Open a file
*
*  Inputs:
*        path - name of the file
*        mode - zero or more flags to set:
*              0x0100 - read
*              0x0080 - write
*              0x1000 - delete
*              0x2000 - rename
*              0x4000 - backup
*              0x8000 - invisible
*        oflag - output flags
*
*  Outputs:
*        returns 0 if successful; else -1
*        errno - set if an error occurred
*
****************************************************************
*
openfile private
err      equ   1                        error return code
index    equ   3                        index into the files array

BIN      equ   $06                      BIN file type
TXT      equ   $04                      TXT file type


         csubroutine (4:path,2:mode,2:oflag),6

         phb                            use local B
         phk
         plb
         stz   err                      err = 0 {no error}

         ldx   #0                       find a free file entry
lb1      lda   files,X
         beq   lb2
         inx
         inx
         inx
         inx
         cpx   #OPEN_MAX*4
         bne   lb1
         dec   err                      flag the open file error
         lda   #EMFILE
         sta   >errno
         brl   lb11
lb2      stx   index                    save the index to the file

         ph4   path                     convert the path to an OS string
         jsl   ctoosstr
         sta   opPathname
         stx   opPathname+2
         sta   giPathname
         stx   giPathname+2
         sta   crPathname
         stx   crPathname+2

         lda   mode                     set the access bits for the create call
         jsr   unixtoprodos
         sta   crAccess
         lda   oflag                    set the flags in the files array
         ldx   index
         sta   files+2,X
         and   #O_BINARY                if the file is binary then
         beq   lb3
         lda   #BIN                       set the create file type to BIN
         bra   lb4                      else
lb3      lda   #TXT                       set the create file type to TXT
lb4      sta   crFileType

         OSGet_File_Info giRec          if the file exists then
         bcs   lb5
         lda   oflag                      if O_EXCL is set then
         and   #O_EXCL
         beq   lb4a
         dec   err                          flag the error
         lda   #ENOENT
         sta   >errno
         bra   lb11
lb4a     ph2   mode                       set the access bits
         ph4   path
         jsl   chmod
         bra   lb8                      else
lb5      lda   oflag                      if O_CREAT is not set then
         and   #O_CREAT
         bne   lb7
         dec   err                          flag the error
         lda   #EEXIST
         sta   >errno
         bra   lb11
lb7      OSCreate crRec                   create the file
         bcs   lb9
lb8      anop

         OSOpen opRec                   open the file
         bcs   lb9
         lda   oflag                    if the O_TRUNC flag is set then
         and   #O_TRUNC
         beq   lb10
         lda   opRefnum                   set the EOF to 0
         sta   efRefnum
         OSSet_EOF efRec
         bcc   lb10
lb9      dec   err                        flag an I/O error
         lda   #EACCES
         sta   >errno
         bra   lb11

lb10     lda   opRefnum                 save the reference number
         ldx   index
         sta   files,X
         txa                            set the return file index
         lsr   A
         lsr   A
         sta   err

lb11     plb                            restore the caller's B

         creturn 2:err

crRec    dc    i'3'                     Create record
crPathname ds  4
crAccess ds    2
crFileType ds  2

giRec    dc    i'2'                     GetFileInfo record
giPathname ds  4
         ds    2

opRec    dc    i'2'                     Open record
opRefnum ds    2
opPathname ds  4

efRec    dc    i'3'                     SetEOF record
efRefnum ds    2
         dc    i'0'
         dc    i4'0'
         end

****************************************************************
*
*  int read(int filds, char *buf, int n);
*
*  Read from a file
*
*  Inputs:
*        filds - file ID of file
*        buf - file buffer
*        n - # of bytes to read
*
*  Outputs:
*        returns 0 if successful; else -1
*        errno - set if an error occurred
*
****************************************************************
*
read     start
err      equ   1                        error return code

         csubroutine (2:filds,4:buf,2:n),2

         stz   err                      err = 0 {no error}

         phb                            use our B
         phk
         plb
         lda   filds                    error if the file has not been opened
         bmi   lb0
         cmp   #OPEN_MAX
         bge   lb0
         asl   A                        get the file reference number
         asl   A
         tax
         lda   files,X
         beq   lb0
         sta   rdRefnum
         stx   filds
         lda   files+2,X                make sure the file is open for reading
         and   #O_RDONLY+O_RDWR
         bne   lb0a

lb0      lda   #EBADF                   errno = EBANF
         sta   >errno
         dec   err                      return = -1
         bra   lb5

lb0a     move4 buf,rdDataBuffer         set the location to read to
         lda   n                        set the number of bytes to read
         sta   rdRequestCount
         OSRead rdRec                   read the bytes
         bcc   lb1                      if an error occurred
         cmp   #$4C                       and it was not EOF then
         beq   lb1
         lda   #EIO                       errno = EIO
         sta   >errno
         dec   err                        return -1
         bra   lb5
lb1      ldy   rdTransferCount          return the bytes read
         sty   err
         beq   lb5
lb2      ldx   filds                    if the file is not binary then
         lda   files+2,X
         and   #O_BINARY
         bne   lb5
         dey                              for each byte do
         beq   lb4a
         short M
lb3      lda   [buf],Y                      if the byte is \r then
         cmp   #13
         bne   lb4
         lda   #10                            change it to \n
         sta   [buf],Y
lb4      dey                              next byte
         bne   lb3
lb4a     lda   [buf]                      if the first byte is \r then
         cmp   #13
         bne   lb4b
         lda   #10                          change it to \n
         sta   [buf]
lb4b     long  M

lb5      plb                            restore B
         creturn 2:err

rdRec    dc    i'4'                     Read record
rdRefnum ds    2
rdDataBuffer ds 4
rdRequestCount ds 4
rdTransferCount ds 4
         end

****************************************************************
*
*  unixtoprodos - Convert UNIX access flags to ProDOS access flags
*
*  Inputs:
*        A - UNIX access flags
*
*  Outputs:
*        A - ProDOS access flags
*
****************************************************************
*
unixtoprodos private
bits     equ   3                        ProDOS bits

         pea   0                        set ProDOS bits to 0
         phd                            set up a stack frame
         tax
         tsc
         tcd
         txa

         bit   #$1000                   if unix delete bit is set then
         beq   lb1
         sec                              set the ProDOS delete bit
         rol   bits

lb1      bit   #$2000                   if unix rename bit is set then
         beq   lb2
         sec                              set the ProDOS rename bit
         bra   lb3                      else
lb2      clc                              clear the ProDOS rename bit
lb3      rol   bits

         bit   #$4000                   if unix backup bit is set then
         beq   lb4
         sec                              set the ProDOS backup bit
         bra   lb5                      else
lb4      clc                              clear the ProDOS backup bit
lb5      rol   bits

         rol   bits                     roll in the two unused bit fields
         rol   bits

         bit   #$8000                   if unix invisible bit is set then
         beq   lb6
         sec                              set the ProDOS invisible bit
         bra   lb7                      else
lb6      clc                              clear the ProDOS invisible bit
lb7      rol   bits

         bit   #$0080                   if unix write bit is set then
         beq   lb8
         sec                              set the ProDOS write bit
         bra   lb9                      else
lb8      clc                              clear the ProDOS write bit
lb9      rol   bits

         bit   #$0100                   if unix read bit is set then
         beq   lb10
         sec                              set the ProDOS read bit
         bra   lb11                     else
lb10     clc                              clear the ProDOS read bit
lb11     rol   bits

         pld                            return the new flags
         pla
         rts
         end

****************************************************************
*
*  int write(filds, char *buf, unsigned n);
*
*  Write to a file
*
*  Inputs:
*        filds - file ID of file
*        buf - file buffer
*        n - # of bytes to write
*
*  Outputs:
*        returns 0 if successful; else -1
*        errno - set if an error occurred
*
****************************************************************
*
write    start
err      equ   1                        error return code
nbuff    equ   3                        new buffer pointer

         csubroutine (2:filds,4:buf,2:n),6

         stz   err                      err = 0 {no error}

         phb                            use our B
         phk
         plb
         lda   filds                    error if the file has not been opened
         bmi   lb0
         cmp   #OPEN_MAX
         bge   lb0
         asl   A                        get the file reference number
         asl   A
         tax
         lda   files,X
         beq   lb0
         sta   wrRefnum
         stx   filds
         lda   files+2,X                make sure the file is open for writing
         and   #O_WRONLY+O_RDWR
         bne   lb0a

lb0      lda   #EBADF                   errno = EBADF
         sta   >errno
         dec   err                      return = -1
         brl   lb5

lb0a     move4 buf,wrDataBuffer         set the location to write from
         lda   n                        set the number of bytes to read
         sta   wrRequestCount

         stz   nbuff                    nbuff == nil
         stz   nbuff+2
         ldx   filds                    if the file is not binary then
         lda   files+2,X
         and   #O_BINARY
         bne   lb0g
         pea   0                          reserve a file buffer
         ph2   n
         jsl   malloc
         sta   nbuff
         stx   nbuff+2
         ora   nbuff+2
         bne   lb0b
         dec   err                        flag an out of memory error
         lda   #ENOSPC
         sta   >errno
         bra   lb5
lb0b     ldy   n                          move the bytes to the new buffer,
         beq   lb0f                         converting \n chars to \r chars
         dey                                in the process
         beq   lb0da
         short M
lb0c     lda   [buf],Y
         cmp   #10
         bne   lb0d
         lda   #13
lb0d     sta   [nbuff],Y
         dey
         bne   lb0c
lb0da    lda   [buf]
         cmp   #10
         bne   lb0e
         lda   #13
lb0e     sta   [nbuff]
         long  M
lb0f     move4 nbuff,wrDataBuffer         set the data buffer start

lb0g     OSWrite wrRec                  write the bytes
         bcc   lb1                      if an error occurred then
         lda   #EIO                       errno = EIO
         sta   >errno
         dec   err                        return -1
         bra   lb5
lb1      ldy   wrTransferCount          return the bytes read
         sty   err

         lda   nbuff                    if nbuff <> NULL then
         ora   nbuff+2
         beq   lb2
         ph4   nbuff                      dispose of the buffer
         jsl   free
lb2      anop

lb5      plb                            restore B
         creturn 2:err

wrRec    dc    i'4'                     Write record
wrRefnum ds    2
wrDataBuffer ds 4
wrRequestCount ds 4
wrTransferCount ds 4
         end
