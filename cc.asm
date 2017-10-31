         keep  obj/cc
         mcopy cc.macros
****************************************************************
*
*  CC - C Specific Run Time Libraries
*
*  October 1988
*  Mike Westerfield
*
*  Copyright 1988
*  Byte Works, Inc.
*
****************************************************************
*
CC       start                          dummy routine

         end

****************************************************************
*
*  ~CopyBF - Copy a bit field
*  ~SaveBF - Save a bit field
*
*  Inputs:
*        addr - address to copy to
*        bitDisp - displacement past the address
*        bitNum - number of bits
*        val - value to copy
*
****************************************************************
*
~CopyBF  start
ret      equ   2                        return address
val      equ   5                        value to copy
bitNum   equ   9                        number of bits
bitDisp  equ   11                       displacement past the address
addr     equ   13                       address to copy to

         lda   #0                       set the call type
         bra   lb1
~SaveBF  entry
         lda   #1
lb1      phb
         phk
         plb
         sta   isSave
         tsc                            set up the stack frame
         phd
         tcd

         move4 val,lval                 save the value (for copybf only)
         stz   mask+2                   set up the and mask
         ldx   bitNum
         lda   #0
lb2      sec
         rol   A
         rol   mask+2
         dex
         bne   lb2
         sta   mask
         and   val                      and out extra bits in the mask
         sta   val
         lda   mask+2
         and   val+2
         sta   val+2
         ldx   bitDisp                  shift the mask and value
         beq   lb4
         lda   mask
lb3      asl   A
         rol   mask+2
         asl   val
         rol   val+2
         dex
         bne   lb3
         sta   mask
lb4      ldy   #2                       place the bits in memory
         lda   mask
         eor   #$FFFF
         and   [addr]
         ora   val
         sta   [addr]
         lda   mask+2
         eor   #$FFFF
         and   [addr],Y
         ora   val+2
         sta   [addr],Y

         lda   isSave                   branch based on call type
         beq   lb5

         lda   ret+1                    return from save
         sta   addr+2
         lda   ret
         sta   addr+1
         pld
         plb
         tsc
         clc
         adc   #12
         tcs
         rtl

lb5      move4 lval,addr                place the value back on the stack
         lda   ret+1                    return from copy
         sta   bitDisp
         lda   ret
         sta   bitDisp-1
         pld
         plb
         tsc
         clc
         adc   #8
         tcs
         rtl
;
;  local data
;
mask     ds    4                        bit mask
isSave   ds    2                        is the call a save? (or copy?)
lval     ds    4                        temp storage for val
         end

****************************************************************
*
*  ~C_ShutDown - do shut down peculiar to the C language
*
*  Inputs:
*        A - shell return code
*
****************************************************************
*
~C_ShutDown start

         pha                            save the return code
         jsr   ~Exit                    do exit processing
         pla                            quit
         jml   ~Quit
         end

****************************************************************
*
*  ~C_ShutDown2 - do shut down peculiar to the C language
*
*  Inputs:
*        A - shell return code
*
****************************************************************
*
~C_ShutDown2 start

         pha                            save the return code
         jsr   ~Exit                    do exit processing
         pla                            quit
         jml   ~RTL
         end

****************************************************************
*
*  ~C_StartUp - do startup peculiar to the C language
*
****************************************************************
*
~C_StartUp start
argv     equ   11                       argument vector
argc     equ   9                        argument count
cLine    equ   1                        command line address

TAB      equ   9                        TAB key code

         phb                            remove our return address
         phk
         plb
         plx
         ply
         pea   0                        make room for argc, argv
         pea   0
         pea   0
         phy                            put the return addr back on the stack
         phx
         ph4   ~CommandLine             create some work space
         tsc                            set up our stack frame
         phd
         tcd

         stz   ~ExitList                no exit routines, yet
         stz   ~ExitList+2
         case  on
         jsl   ~InitIO                  reset standard I/O
         case  off

         lda   cLine                    if cLine == 0 then
         ora   cLine+2
         jeq   rtl                        exit

         add4  cLine,#8                 skip the shell identifier
         ldx   #0                       count the arguments
         txy
         short M
lb2      lda   [cLine],Y
         beq   lb6
         cmp   #' '
         beq   lb3
         cmp   #'"'
         beq   lb3
         cmp   #TAB
         bne   lb4
lb3      iny
         bra   lb2
lb4      inx
lb5      lda   [cLine],Y
         beq   lb6
         cmp   #' '
         beq   lb2
         cmp   #'"'
         beq   lb2
         cmp   #TAB
         beq   lb2
         iny
         bra   lb5
lb6      long  M
         txa                            we need (X+1)*4 + strlen(cLine)+1 bytes
         inc   A
         asl   A
         asl   A
         sta   start
         phy
         sec
         adc   1,S
         ply
         pha
         pha
         pea   0
         pha
         ph2   >~User_ID
         ph2   #$C008
         ph4   #0
         _NewHandle
         bcc   lb7
         puts  #'Out of memory',cr=t,errout=t
         lda   #-1
         jml   ~Quit

lb7      pl4   argv                     get the pointer to the area
         ldy   #2
         lda   [argv],Y
         tax
         lda   [argv]
         sta   targv
         stx   targv+2
         clc                            get a pointer to the command line string
         adc   start
         bcc   lb8
         inx
lb8      sta   argv
         stx   argv+2
         short M                        move the command line string
         ldy   #0
lb9      lda   [cLine],Y
         sta   [argv],Y
         beq   lb10
         iny
         bra   lb9
lb10     long  M
         move4 argv,cLine               save the pointer
         move4 targv,argv               set up the pointer to argv

av1      lda   [cLine]                  skip leading spaces
         and   #$00FF
         beq   av8
         cmp   #' '
         beq   av2
         cmp   #TAB
         bne   av3
av2      inc4  cLine
         bra   av1
av3      tax                            save the argument
         cmp   #'"'                     if the argument is quoted then
         bne   av4
         inc4  cLine                      skip the quote
av4      ldy   #2                       save the address in argv
         lda   cLine
         sta   [argv]
         lda   cLine+2
         sta   [argv],Y
         add4  argv,#4
         inc   argc                     inc the # of arguments
         cpx   #'"'                     if the string is quoted then
         bne   av6
av5      lda   [cLine]                    skip to the next quote
         and   #$00FF
         beq   av8
         cmp   #'"'
         beq   av7
         inc4  cLine
         bra   av5                      else
av6      lda   [cLine]                    skip to the next whitespace char
         and   #$00FF
         beq   av8
         cmp   #' '
         beq   av7
         cmp   #TAB
         beq   av7
         inc4  cLine
         bra   av6
av7      short M                        null terminate the parameter
         lda   #0
         sta   [cLine]
         long  M
         bra   av2                      get the next parameter
av8      lda   #0                       null terminate the arg list
         sta   [argv]
         ldy   #2
         sta   [argv],Y
         move4 targv,argv               set up the pointer to argv

rtl      pld                            return
         pla
         pla
         plb
         rtl

targv    ds    4
start    ds    2                        start of the command line string
         end

****************************************************************
*
*  ~C_StartUp2 - do C startup for RTL pragma programs
*
****************************************************************
*
~C_StartUp2 start

         phb                            remove our return address
         phk
         plb
         plx
         ply
         pea   0                        set argc, argv to 0
         pea   0
         pea   0
         phy                            put the return addr back on the stack
         phx

         stz   ~ExitList                no exit routines, yet
         stz   ~ExitList+2

         plb                            return
         rtl
         end

****************************************************************
*
*  ~Exit - call exit routines and clean up open files
*
*  Inputs:
*        ~ExitList - list of exit routines
*
****************************************************************
*
~Exit    start
ptr      equ   3                        pointer to exit routines
;
;  Set up our stack frame
;
         phb
         phk
         plb
         ph4   ~ExitList                set up our stack frame
         phd
         tsc
         tcd
;
;  Call the exit functions
;
lb1      lda   ptr                      if the pointer is non-nil then
         ora   ptr+2
         beq   lb3
         pea   +(lb2-1)|-8              call the function
         pea   +(lb2-1)|8
         phb
         pla
         ldy   #5
         lda   [ptr],Y
         pha
         dey
         dey
         lda   [ptr],Y
         pha
         phb
         pla
         rtl
lb2      ldy   #2                         dereference the pointer
         lda   [ptr],Y
         tax
         lda   [ptr]
         sta   ptr
         stx   ptr+2
         bra   lb1
;
;  Close (and flush) any open files
;
         case  on
lb3      lda   >stderr+6                while there is a next file
         ora   >stderr+4
         beq   lb4
         ph4   >stderr+4                  close it
         dc    h'22'                      (jsl fclose, soft reference)
         dc    s3'fclose'
         bra   lb3
         case  off
;
;  return
;
lb4      pld                            return
         pla
         pla
         plb
         rts
         end

****************************************************************
*
*  ~ExitList - list of exit routines
*
****************************************************************
*
~ExitList start
         ds    4
         end

****************************************************************
*
*  ~IntChkC - check for integer math error
*
*  Inputs:
*        V - set for error
*
****************************************************************
*
~IntChkC start

         bvc   lb1                      branch if no error
         php
         pha
         phx
         phy
         error #9                       integer math error
         ply
         plx
         pla
         plp
lb1      rtl
         end

****************************************************************
*
*  ~LoadBF - load a bit field
*
*  Inputs:
*        addr - address to load from
*        bitDisp - displacement past the address
*        bitNum - number of bits
*
****************************************************************
*
~LoadBF  start
mask     equ   1                        bit mask
sign     equ   5                        sign mask

         csubroutine (2:bitNum,2:bitDisp,4:addr),8

         ldy   #2                       get the value
         lda   [addr],Y
         tax
         lda   [addr]
         sta   addr
         stx   addr+2
         ldx   bitDisp                  normalize the value
         beq   lb2
lb1      lsr   addr+2
         ror   addr
         dex
         bne   lb1
lb2      stz   mask                     form the bit and sign mask
         lda   #-1
         sta   sign
         sta   sign+2
         lda   #0
         ldx   bitNum
lb3      sec
         rol   A
         rol   mask
         asl   sign
         rol   sign+2
         dex
         bne   lb3
         sec                            adjust the sign flag
         ror   sign+2
         ror   sign
         and   addr                     and out the extra bits
         sta   addr
         lda   mask
         and   addr+2
         sta   addr+2
         lda   addr                     if the value is negative then
         and   sign
         bne   lb4
         lda   addr+2
         and   sign+2
         beq   lb5
lb4      lda   addr                       or in the sign bits
         ora   sign
         sta   addr
         lda   addr+2
         ora   sign+2
         sta   addr+2

lb5      creturn 4:addr
         end

****************************************************************
*
*  ~LoadStruct - load a long value onto the stack
*
*  Inputs:
*        addr - address of the structure to load
*        size - size of the structure
*
****************************************************************
*
~LoadStruct start

         phb                            save the caller's data bank
         pl4   >ret                     get the return address
         plx                            get the transfer size
         pla                            get the absolute save addr
         sta   >ad1+1
         sta   >ad2+1
         plb                            set the data bank
         phb                            remove the data bank & extra addr byte
         pla

         txa                            quit if there are no bytes to move
         beq   lb3

         lsr   a                        branch if the # of bytes is even
         bcc   lb1
         dex                            move one byte
         short M
ad1      lda   ad1,X
         pha
         long  M
         txa
         beq   lb3

lb1      dex                            move the words
         dex
         bmi   lb3
ad2      lda   ad2,X
         pha
         bra   lb1

lb3      ph4   >ret                     return to the caller
         plb
         rtl
;
;  Local data
;
ret      ds    4
         end

****************************************************************
*
*  ~LoadUBF - load an unsigned bit field
*
*  Inputs:
*        addr - address to load from
*        bitDisp - displacement past the address
*        bitNum - number of bits
*
****************************************************************
*
~LoadUBF start
mask     equ   1                        msw of bit mask

         csubroutine (2:bitNum,2:bitDisp,4:addr),2

         ldy   #2                       get the value
         lda   [addr],Y
         tax
         lda   [addr]
         sta   addr
         stx   addr+2
         ldx   bitDisp                  normalize the value
         beq   lb2
lb1      lsr   addr+2
         ror   addr
         dex
         bne   lb1
lb2      stz   mask                     form the bit mask
         lda   #0
         ldx   bitNum
lb3      sec
         rol   A
         rol   mask
         dex
         bne   lb3
         and   addr                     and out the extra bits
         sta   addr
         lda   mask
         and   addr+2
         sta   addr+2

         creturn 4:addr
         end

****************************************************************
*
*  ~LongMove2 - move some bytes
*
*  Inputs:
*        source - pointer to source bytes
*        dest - pointer to destination bytes
*        len - number of bytes to move
*
*  Notes:
*        This subroutine leaves the destination address on the
*        stack.  It is used by C for multiple assignment of
*        arrays and structures.  It differs from ~Move2 in that
*        it can move 64K or more.
*
****************************************************************
*
~LongMove2 start

         csubroutine (4:len,4:source),0
dest     equ   source+4

         ldx   len+2                    move whole banks
         beq   lm2
         ldy   #0
lm1      lda   [source],Y
         sta   [dest],Y
         dey
         dey
         bne   lm1
         inc   source+2
         inc   dest+2
         dex
         bne   lm1
lm2      lda   len                      move one byte if the move length is odd
         lsr   a
         bcc   lb1
         short M
         lda   [source]
         sta   [dest]
         long  M
         inc4  source
         inc4  dest
         dec   len
lb1      ldy   len                      move the bytes
         beq   lb4
         dey
         dey
         beq   lb3
lb2      lda   [source],Y
         sta   [dest],Y
         dey
         dey
         bne   lb2
lb3      lda   [source]
         sta   [dest]
lb4      creturn
         end

****************************************************************
*
*  ~LShr4 - Shift an unsigned long value right
*
*  Inputs:
*        A - value to shift
*        X - # bits to shift by
*
*  Outputs:
*        A - result
*
****************************************************************
*
~LShr4   start
num1     equ   8                        number to shift
num2     equ   4                        # bits to shift by

         tsc                            set up DP
         phd
         tcd
         lda   num2+2                   if num2 < 0 then
         bpl   lb2
         cmp   #$FFFF                     shift left
         bne   zero
         ldx   num2
         cpx   #-34
         blt   zero
lb1      asl   num1
         rol   num1+2
         inx
         bne   lb1
         bra   lb4
zero     stz   num1                       (result is zero)
         stz   num1+2
         bra   lb4
lb2      bne   zero                     else shift right
         ldx   num2
         beq   lb4
         cpx   #33
         bge   zero
lb3      lsr   num1+2
         ror   num1
         dex
         bne   lb3

lb4      lda   0                        fix stack and return
         sta   num2
         lda   2
         sta   num2+2
         pld
         pla
         pla
         rtl
         end

****************************************************************
*
*  ~Move2 - move some bytes
*
*  Inputs:
*        source - pointer to source bytes
*        dest - pointer to destination bytes
*        len - number of bytes to move
*
*  Notes:
*        This subroutine leaves the destination address on the
*        stack.  It is used by C for multiple assignment of
*        arrays and structures.
*
****************************************************************
*
~Move2   start

         csubroutine (2:len,4:source),0
dest     equ   source+4

         lda   len                      move one byte if the move length is odd
         lsr   a
         bcc   lb1
         short M
         lda   [source]
         sta   [dest]
         long  M
         inc4  source
         inc4  dest
         dec   len
lb1      ldy   len                      move the bytes
         beq   lb4
         dey
         dey
         beq   lb3
lb2      lda   [source],Y
         sta   [dest],Y
         dey
         dey
         bne   lb2
lb3      lda   [source]
         sta   [dest]
lb4      creturn
         end

****************************************************************
*
*  extern pascal PDosInt(int callNum, void *parm)
*
*  Make a ProDOS or shell call
*
*  Inputs:
*        callNum - ProDOS call number
*        parm - address of the parameter block
*
****************************************************************
*
PDOSINT  start
ProDOS   equ   $E100A8

         csubroutine (4:parm,2:callNum),0

         lda   callNum
         sta   >lb1
         lda   parm
         sta   >lb2
         lda   parm+2
         sta   >lb2+2
         jsl   ProDOS
lb1      ds    2
lb2      ds    4
         sta   >~TOOLERROR

         creturn
         end

****************************************************************
*
*  ~UDiv4 - Four byte unsigned integer divide
*
*  Inputs:
*        num1 - numerator
*        X-A - denominator
*
*  Outputs:
*        ans - result
*
****************************************************************
*
~UDiv4   start
num1     equ   12                       arguments
ans      equ   1                        answer
rem      equ   5                        remainder
return   equ   9
;
;  Initialize
;
         tay                            place the values in the correct spot
         pea   0                         on the stack frame
         pea   0
         lda   10,S
         pha
         lda   10,S
         pha
         tsc                            set up DP
         phd
         tcd
         sty   num1
         stx   num1+2
         tya                            check for division by zero
         ora   num1+2
         beq   dv10

         lda   num1+2                   do 16 bit divides separately
         ora   ans+2
         beq   dv5
;
;  32 bit divide
;
         ldy   #32                      32 bits to go
dv3      asl   ans                      roll up the next number
         rol   ans+2
         rol   ans+4
         rol   ans+6
         sec                            subtract for this digit
         lda   ans+4
         sbc   num1
         tax
         lda   ans+6
         sbc   num1+2
         bcc   dv4                      branch if minus
         stx   ans+4                    turn the bit on
         sta   ans+6
         inc   ans
dv4      dey                            next bit
         bne   dv3
         bra   dv9                      go do the sign
;
;  16 bit divide
;
dv5      lda   #0                       initialize the remainder
         ldy   #16                      16 bits to go
dv6      asl   ans                      roll up the next number
         rol   a
         sec                            subtract the digit
         sbc   num1
         bcs   dv7
         adc   num1                     digit is 0
         dey
         bne   dv6
         bra   dv8
dv7      inc   ans                      digit is 1
         dey
         bne   dv6

dv8      sta   ans+4                    save the remainder
;
;  Return the result
;
dv9      move4 ans,num1                 move answer
dv10     pld                            return
         tsc
         clc
         adc   #8
         tcs
         rtl
         end

****************************************************************
*
*  ~UMod4 - Four byte unsigned integer remainder
*
*  Inputs:
*        num1 - numerator
*        X-A - denominator
*
*  Outputs:
*        ans - result
*
****************************************************************
*
~UMod4   start
num1     equ   12                       arguments
ans      equ   1                        answer
rem      equ   5                        remainder
return   equ   9
;
;  Initialize
;
         tay                            place the values in the correct spot
         pea   0                         on the stack frame
         pea   0
         lda   10,S
         pha
         lda   10,S
         pha
         tsc                            set up DP
         phd
         tcd
         sty   num1
         stx   num1+2
         tya                            check for division by zero
         ora   num1+2
         beq   dv10

         lda   num1+2                   do 16 bit divides separately
         ora   ans+2
         beq   dv5
;
;  32 bit divide
;
         ldy   #32                      32 bits to go
dv3      asl   ans                      roll up the next number
         rol   ans+2
         rol   ans+4
         rol   ans+6
         sec                            subtract for this digit
         lda   ans+4
         sbc   num1
         tax
         lda   ans+6
         sbc   num1+2
         bcc   dv4                      branch if minus
         stx   ans+4                    turn the bit on
         sta   ans+6
         inc   ans
dv4      dey                            next bit
         bne   dv3
         bra   dv9                      go do the sign
;
;  16 bit divide
;
dv5      lda   #0                       initialize the remainder
         ldy   #16                      16 bits to go
dv6      asl   ans                      roll up the next number
         rol   a
         sec                            subtract the digit
         sbc   num1
         bcs   dv7
         adc   num1                     digit is 0
         dey
         bne   dv6
         bra   dv8
dv7      inc   ans                      digit is 1
         dey
         bne   dv6

dv8      sta   ans+4                    save the remainder
;
;  Return the result
;
dv9      move4 ans+4,num1               move answer
dv10     pld                            return
         tsc
         clc
         adc   #8
         tcs
         rtl
         end

****************************************************************
*
*  ~Zero - zero an area of direct page memory
*
*  Inputs:
*	addr - address of the memory
*	size - number of bytes to zero (must be > 1)
*
****************************************************************
*
~Zero	start

         csubroutine (2:size,4:addr),0

	lda	#0
	sta	[addr]
	ldx	addr
	txy
	iny
	lda	size
	dea
	dea
	phb
	mvn	0,0
	plb
            
         creturn
	end
