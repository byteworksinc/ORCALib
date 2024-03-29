         keep  obj/stdlib
         mcopy stdlib.macros
         case  on

****************************************************************
*
*  StdLib - Standard Library Utility Functions
*
*  This code implements the tables and subroutines needed to
*  support the standard C library STDLIB.
*
*  December 1988
*  Mike Westerfield
*
*  Copyright 1988
*  Byte Works, Inc.
*
* Note: Portions of this library appear in SysFloat
*
****************************************************************
*
StdLib   start                          dummy segment
         copy  equates.asm

         end

****************************************************************
*
*  void abort()
*
*  Stop the program.
*
****************************************************************
*
abort    start

         ph2   #SIGABRT
         jsl   raise
         lda   #-1
         brl   ~C_QUIT
         end

****************************************************************
*
*  int abs(int i)
*
*  Return the absolute value of i.
*
*  Inputs:
*        i - argument
*
*  Outputs:
*        Returns abs(i).
*
****************************************************************
*
abs      start
i        equ   4                        position of argument on stack

         lda   i,S                      A := i
         bpl   lb1                      if A < 0 then
         eor   #$FFFF                     A := -A
         inc   A
lb1      tay                            return A
         lda   2,S
         sta   4,S
         pla
         sta   1,S
         tya
         rtl
         end

****************************************************************
*
* void *aligned_alloc(size_t alignment, size_t size)
*
* Allocate memory with specified alignment.
*
*  Inputs:
*        alignment - alignment to use (only value allowed is 1)
*        size - bytes of memory to allocate
*
*  Outputs:
*        Returns pointer to allocated memory, or NULL on error.
*
****************************************************************
*
aligned_alloc start
         csubroutine (4:alignment,4:size),0

         lda   alignment                check that alignment==1
         dec   a
         ora   alignment+2
         beq   good
         stz   size                     return NULL on error
         stz   size+2
         lda   #EINVAL
         sta   >errno
         bra   ret
        
good     ph4   <size                    call malloc
         jsl   malloc
         sta   size
         stx   size+2

ret      creturn 4:size
         end

****************************************************************
*
*  int atexit(func)
*        void (*func)();
*
*  This function is used to build a list of functions that will
*  be called as part of the exit processing.
*
*  Inputs:
*        func - address of the function to call on exit
*
*  Outputs:
*        Returns 0 if successful, -1 if not.
*
****************************************************************
*
atexit   start
ptr      equ   1                        work pointer
rval     equ   5                        return value

         csubroutine (4:func),6

         lda   #-1                      assume we will fail
         sta   rval                     assume we will fail
         dec4  func                     we need the addr-1, not the addr
         ph4   #8                       get space for the record
         jsl   malloc
         stx   ptr+2
         sta   ptr
         ora   ptr+2                    quit now if we failed
         beq   lb1
         ldy   #2                       place the record in the exit list
         lda   >~EXITLIST
         sta   [ptr]
         lda   >~EXITLIST+2
         sta   [ptr],Y
         lda   ptr
         sta   >~EXITLIST
         lda   ptr+2
         sta   >~EXITLIST+2
         iny                            place the function address in the record
         iny
         lda   func
         sta   [ptr],Y
         iny
         iny
         lda   func+2
         sta   [ptr],Y
         inc   rval                     success...

lb1      creturn 2:rval
         end

****************************************************************
*
*  int at_quick_exit(func)
*        void (*func)();
*
*  This function is used to build a list of functions that will
*  be called as part of the quick exit processing.
*
*  Inputs:
*        func - address of the function to call on quick exit
*
*  Outputs:
*        Returns 0 if successful, -1 if not.
*
****************************************************************
*
at_quick_exit start
ptr      equ   1                        work pointer
rval     equ   5                        return value

         csubroutine (4:func),6

         lda   #-1                      assume we will fail
         sta   rval                     assume we will fail
         dec4  func                     we need the addr-1, not the addr
         ph4   #8                       get space for the record
         jsl   malloc
         stx   ptr+2
         sta   ptr
         ora   ptr+2                    quit now if we failed
         beq   lb1
         ldy   #2                       place the record in the exit list
         lda   >~QUICKEXITLIST
         sta   [ptr]
         lda   >~QUICKEXITLIST+2
         sta   [ptr],Y
         lda   ptr
         sta   >~QUICKEXITLIST
         lda   ptr+2
         sta   >~QUICKEXITLIST+2
         iny                            place the function address in the record
         iny
         lda   func
         sta   [ptr],Y
         iny
         iny
         lda   func+2
         sta   [ptr],Y
         inc   rval                     success...

lb1      creturn 2:rval
         end


****************************************************************
*
*  atof - convert a string to a float
*
*  Inputs:
*        str - pointer to the string
*
*  Outputs:
*        X-A - pointer to converted number
*
****************************************************************
*
atof     start

         ph4   #0                       no pointer returned
         lda   10,S                     pass the string addr on
         pha
         lda   10,S
         pha
         jsl   strtod                   convert the string
         tay                            fix the stack
         lda   2,S
         sta   6,S
         pla
         sta   3,S
         pla
         tya
         rtl
         end

****************************************************************
*
*  atoi - convert a string to an int
*  atol - convert a string to a long
*
*  Inputs:
*        str - pointer to the string
*
*  Outputs:
*        X-A - converted number
*
****************************************************************
*
atoi     start
atol     entry

         ph2   #10                      base 10
         ph4   #0                       no pointer returned
         lda   12,S                     pass the string addr on
         pha
         lda   12,S
         pha
         jsl   strtol                   convert the string
         tay                            fix the stack
         lda   2,S
         sta   6,S
         pla
         sta   3,S
         pla
         tya
         rtl
         end

****************************************************************
*
*  atoll - convert a string to a long long
*
*  Inputs:
*        str - pointer to the string
*
*  Outputs:
*        converted number
*
****************************************************************
*
atoll    start

         ph2   #10                      base 10
         ph4   #0                       no pointer returned
         lda   12,S                     pass the string addr on
         pha
         lda   12,S
         pha                            note: x reg is unchanged
         jsl   strtoll                  convert the string
         lda   2,S                      fix the stack
         sta   6,S
         pla
         sta   3,S
         pla
         rtl
         end

****************************************************************
*
*  char *bsearch(key, base, count, size, compar)
*        void *key, *base;
*        size_t count, size;
*        int (*compar)(const void *, const void *)
*
*  Inputs:
*        key - pointer to element to search for
*        base - start address of the array to search
*        count - # elements in the array
*        size - size of each array element
*        compar - function that compares array elements
*
*  Outputs:
*        Returns a pointer to the array element found; NULL if
*        no match was found.
*
****************************************************************
*
bsearch  start
left     equ   1                        left index
right    equ   5                        right index
test     equ   9                        test index
addr     equ   13                       address of array element of index test

         csubroutine (4:key,4:base,4:count,4:size,4:compar),16

         lda   count                    if count is 0 then
         ora   count+2
         jeq   lb5                        just return a null pointer

         lda   compar                   patch the call address
         sta   >jsl+1
         lda   compar+1
         sta   >jsl+2
         stz   left                     left = 0
         stz   left+2
         sub4  count,#1,right           right = count-1
lb1      clc                            test = (left+right)/2
         lda   left
         adc   right
         sta   test
         lda   left+2
         adc   right+2
         lsr   A
         sta   test+2
         ror   test
         mul4  test,size,addr           addr = test*size + base
         add4  addr,base
         ph4   <addr                    compare the array elements
         ph4   <key
jsl      jsl   jsl
         tax                            quit if *addr = *key
         beq   lb6
         bmi   lb2                      if *key > *addr then
         add4  test,#1,left               left = test+1
         bra   lb3                      else
lb2      sub4  test,#1,right              right = test-1
lb3      lda   right+2                  loop if right >= left
         bmi   lb5
         cmp   left+2
         bne   lb4
         lda   right
         cmp   left
lb4      bge   lb1

lb5      stz   addr                     no match - return null
         stz   addr+2

lb6      creturn 4:addr
         end

****************************************************************
*
*  div_t div(n,d)
*        int n,d;
*
*  Inputs:
*        n - numerator
*        d - denominator
*
*  Outputs:
*        div_t - contains result & remainder
*
****************************************************************
*
div      start
addr     equ   1

         csubroutine (2:n,2:d),4

         phb                            use local data
         phk
         plb
         lda   n                        do the divide
         ldx   d
         jsl   ~DIV2
         sta   div_t                    save the results
         stx   div_t+2
         lda   n                        if the numerator is negative then
         bpl   lb1
         sub2  #0,div_t+2,div_t+2         make the remainder negative
lb1      lla   addr,div_t               return the address
         plb

         creturn 4:addr

div_t    ds    4
         end

****************************************************************
*
*  void exit(int status);
*
*  void _exit(int status);
*
*  void _Exit(int status);
*
*  void quick_exit(int status);
*
*  Stop the program.  Exit cleans up, _exit does not.  Status
*  is the status returned to the shell.
*
*  Inputs:
*        status - exit code
*
****************************************************************
*
exit     start

         jsr   ~EXIT
_exit    entry
_Exit    entry
         lda   4,S
         brl   ~C_QUIT
         end

quick_exit start

         jsr   ~QUICKEXIT
         lda   4,S
         brl   ~C_QUIT
         end

****************************************************************
*
*  char *getenv(const char *name)
*
*  Returns a pointer to a shell variable.  If the shell variable
*  has no value, a null is returned.
*
*  Inputs:
*        namePtr - pointer to the name of the shell variable
*
*  Outputs:
*        Returns a pointer to the shell variable
*
****************************************************************
*
getenv   start
ptr      equ   1                        pointer to the shell variable

         csubroutine (4:namePtr),4

         phb                            use local addressing
         phk
         plb
         lla   ptr,0                    initialize the pointer to null
         short I,M                      copy the variable name to the buffer
         ldy   #0
lb1      lda   [namePtr],Y
         beq   lb2
         iny
         sta   name,Y
         bne   lb1
         dey
lb2      sty   name
         long  I,M
         Read_Variable rdRec            read the shell variable
         bcs   lb3                      if there was no error then
         lda   var                        if the variable was set then
         and   #$00FF
         beq   lb3
         short I,M                          set the null terminator
         ldx   var
         stz   var+1,X
         long  I,M
         lla   ptr,var+1                    set the pointer to return

lb3      plb                            restore B
         creturn 4:ptr

rdRec    dc    a4'name,var'             read variable record

name     ds    256                      shell variable name
var      ds    257                      shell variable value
         end

****************************************************************
*
*  long labs(long i)
*
*  Return the absolute value of i.
*
*  Inputs:
*        i - argument
*
*  Outputs:
*        Returns abs(i).
*
****************************************************************
*
labs     start

         csubroutine (4:i),0

         lda   i+2
         bpl   lb1
         sub4  #0,i,i

lb1      creturn 4:i
         end

****************************************************************
*
*  long long llabs(long long i)
*
*  Return the absolute value of i.
*
*  Inputs:
*        i - argument
*
*  Outputs:
*        Returns abs(i).
*
****************************************************************
*
llabs    start
imaxabs  entry
retptr   equ   1

         csubroutine (8:i),4
         stx   retptr
         stz   retptr+2
         
         ph8   <i
         jsl   ~ABS8
         pla
         sta   [retptr]
         ldy   #2
         pla
         sta   [retptr],y
         iny
         iny
         pla
         sta   [retptr],y
         iny
         iny
         pla
         sta   [retptr],y
         
         creturn
         end

****************************************************************
*
*  ldiv_t ldiv(n,d)
*        long n,d;
*
*  Inputs:
*        n - numerator
*        d - denominator
*
*  Outputs:
*        ldiv_t - contains result & remainder
*
****************************************************************
*
ldiv     start
addr     equ   1

         csubroutine (4:n,4:d),4

         phb                            use local addressing
         phk
         plb
         ph4   <n                       do the divide
         ph4   <d
         jsl   ~DIV4
         pl4   div_t
         pl4   div_t+4
         lda   n+2                      if the numerator is negative then
         bpl   lb1
         sub4  #0,div_t+4,div_t+4         make the remainder negative
lb1      lla   addr,div_t               return the result
         plb

         creturn 4:addr

div_t    ds    8
         end

****************************************************************
*
*  lldiv_t lldiv(long long n, long long d)
*
*  Inputs:
*        n - numerator
*        d - denominator
*
*  Outputs:
*        lldiv_t - contains result & remainder
*
****************************************************************
*
lldiv    start
imaxdiv  entry
addr     equ   1

         csubroutine (8:n,8:d),4
         phb                            use local addressing
         phk
         plb
         ph8   <n                       do the divide
         ph8   <d
         jsl   ~CDIV8
         pl8   lldiv_t
         pl8   lldiv_t+8
         lla   addr,lldiv_t             return the result
         plb

         creturn 4:addr

lldiv_t  ds    16
         end

****************************************************************
*
*  int mblen(const char *s, size_t n)
*
*  Inputs:
*        s - NULL or pointer to character
*        n - maximum number of bytes to inspect
*
*  Outputs:
*        If s is NULL, returns 0, indicating encodings are not
*        state-dependent.  Otherwise, returns 0 if s points to a
*        null character, -1 if the next n or fewer bytes do not
*        form a valid character, or the number of bytes forming
*        a valid character.
*
*  Note: This implementation assumes we do not support actual
*        multi-byte or state-dependent character encodings.
*
****************************************************************
*
mblen    start

         csubroutine (4:s,4:n)
         ldx   #0
         lda   s                        if s == NULL
         ora   s+2
         beq   ret                        return 0
         lda   n                        if n == 0
         ora   n+2
         bne   readchar
         dex                              return -1
         bra   ret
readchar lda   [s]                      if *s == '\0'
         and   #$00FF
         beq   ret                        return 0
         inx                            else return 1

ret      stx   n
         creturn 2:n
         end

****************************************************************
*
*  void qsort(base, count, size, compar)
*        void *base;
*        size_t count, size;
*        int (*compar)(const void *, const void *)
*
*  Inputs:
*        base - start address of the array to sort
*        count - # elements in the array
*        size - size of each array element
*        compar - function that compares array elements
*
*  Outputs:
*        The array is sorted on exit.
*
****************************************************************
*
qsort    start

         csubroutine (4:base,4:count,4:size,4:compar),0

         lda   count                    nothing to do if count is 0
         ora   count+2
         beq   done

         phb
         phk
         plb
         dec4  count                    set count to the addr of the last entry
         mul4  count,size
         add4  count,base
         move4 size,lsize               save size in a global var
         lda   compar                   set the jsl addresses
         sta   jsl1+1
         sta   jsl2+1
         lda   compar+1
         sta   jsl1+2
         sta   jsl2+2
         plb

         ph4   <count                   do the sort
         ph4   <base
         jsl   rsort

done     creturn
         end

****************************************************************
*
*  rand - get a random number
*
*  Outputs:
*        A - random number
*
****************************************************************
*
rand     start

         lda   >~srand                  if no initialization then
         bne   lb1
         ph2   #1                         initialize with a value of 1
         jsl   srand
lb1      jsl   ~RANX                    find the random number
         lda   >~SEED
         and   #$7FFF
         rtl

~srand   entry
         dc    i'0'
         end

****************************************************************
*
*  rsort - recursive sort for qsort
*
*  Inputs:
*        first - first array element to sort
*        last - last array element to sort
*
****************************************************************
*
rsort    private
left     equ   1                        left address
right    equ   5                        right address

         csubroutine (4:first,4:last),8

sr0      phb
         phk
         plb
         lda   last+2                   if last <= first then quit
         bmi   sr1a
         cmp   first+2
         bne   sr1
         lda   last
         cmp   first
sr1      bgt   sr1b
sr1a     plb
         creturn

sr1b     move4 last,right               right = last
         move4 first,left               left = first
         bra   sr3
sr2      add4  left,lsize               inc left until *left >= *last
sr3      plb
         ph4   <last
         ph4   <left
jsl1     entry
         jsl   jsl1
         phb
         phk
         plb
         tax
         bmi   sr2
sr4      lda   right                    quit if right = first
         cmp   first
         bne   sr4a
         lda   right+2
         cmp   first+2
         beq   sr4b
sr4a     sub4  right,lsize              dec right until *right <= *last
         plb
         ph4   <last
         ph4   <right
jsl2     entry
         jsl   jsl2
         phb
         phk
         plb
         dec   A
         bpl   sr4
sr4b     ph4   <left                    swap left/right entries
         ph4   <right
         jsr   swap
         lda   left+2                   loop if left < right
         cmp   right+2
         bne   sr5
         lda   left
         cmp   right
sr5      blt   sr2
         ph4   <right                   swap left/right entries
         ph4   <left
         jsr   swap
         ph4   <left                    swap left/last entries
         ph4   <last
         jsr   swap
         sub4  left,lsize,right         calculate bounds of subarrays
         add4  left,lsize                 (first..right and left..last)
         add4  first,last,mid           calculate midpoint of range being sorted
         lsr   mid+2
         ror   mid
         cmpl  right,mid                if right < mid then
         bge   sr6
         plb
         ph4   <right                     sort left subarray recursively
         ph4   <first
         jsl   rsort
         move4 left,first                 sort right subarray via tail call
         brl   sr0
sr6      plb                            else
         ph4   <last                      sort right subarray recursively
         ph4   <left
         jsl   rsort
         move4 right,last                 sort left subarray via tail call
         brl   sr0
;
;  swap - swap two entries
;
l        equ   3                        left entry
r        equ   7                        right entry

swap     tsc                            set up addressing
         phd
         tcd
         lda   lsize+2                  move 64K chunks
         beq   sw2
         sta   banks
         ldy   #0
sw1      lda   [l],Y
         tax
         lda   [r],Y
         sta   [l],Y
         txa
         sta   [r],Y
         dey
         dey
         bne   sw1
         inc   l+2
         inc   r+2
         dec   banks
         bne   sw1
sw2      lda   lsize                    if there are an odd number of bytes then
         lsr   A
         bcc   sw3
         short M                          move one byte
         lda   [l]
         tax
         lda   [r]
         sta   [l]
         txa
         sta   [r]
         long  M
         inc4  l
         inc4  r
         lda   lsize
         lsr   A
sw3      asl   A                        quit if there are no more bytes
         beq   sw6
         tay
         bra   sw5
sw4      lda   [l],Y                    move the bytes
         tax
         lda   [r],Y
         sta   [l],Y
         txa
         sta   [r],Y
sw5      dey
         dey
         bne   sw4
         lda   [l]
         tax
         lda   [r]
         sta   [l]
         txa
         sta   [r]
sw6      pld
         plx
         tsc
         clc
         adc   #8
         tcs
         phx
         rts
;
;  local data
;
lsize    entry
         ds    4                        local copy of size
banks    ds    2                        number of whole banks to swap
mid      ds    4                        midpoint of the elements being sorted
         end

****************************************************************
*
*  srand - seed the random number generator
*
*  Inputs:
*        4,S - random number seed
*
****************************************************************
*
srand    start

         lda   #1
         sta   >~srand
         phb
         plx
         ply
         pla
         phy
         phx
         plb
         brl   ~RANX2
         end

****************************************************************
*
*  strtof - convert a string to a float
*  strtold - convert a string to a long double
*
*  Inputs:
*        str - pointer to the string
*        ptr - pointer to a pointer; a pointer to the first
*              char past the number is placed here.  If ptr is
*              nil, no pointer is returned
*
*  Outputs:
*        X-A - pointer to result
*
*  Note: These are currently implemented by just calling strtod
*        (in SysFloat).  As such, all of these function really
*        return values in the SANE extended format.
*
****************************************************************
*
strtold  start
strtof   entry
         jml   strtod
         end

****************************************************************
*
*  strtol - convert a string to a long
*
*  Inputs:
*        str - pointer to the string
*        ptr - pointer to a pointer; a pointer to the first
*              char past the number is placed here.  If ptr is
*              nil, no pointer is returned
*        base - base of the number
*
*  Outputs:
*        X-A - converted number
*
****************************************************************
*
strtol   start
base     equ   18                       base
ptr      equ   14                       *return pointer
str      equ   10                       string pointer
rtl      equ   7                        return address

val      equ   3                        value
negative equ   1                        is the number negative?

         lda   #0
         pha                            make room for & initialize val
         pha
         pha                            make room for & initialize negative
         tsc                            set up direct page addressing
         phd
         tcd
;
;  Skip any leading whitespace
;
         lda   ptr                      if ptr in non-null then
         ora   ptr+2
         beq   sw1
         lda   str                        initialize it to str
         sta   [ptr]
         ldy   #2
         lda   str+2
         sta   [ptr],Y

sw1      lda   [str]                    skip the white space
         and   #$00FF
         tax
         lda   >__ctype+1,X
         and   #_space
         beq   cn0
         inc4  str
         bra   sw1
;
;  Convert the number
;
cn0      lda   [str]                    if the next char is '-' then
         and   #$00FF
         cmp   #'-'
         bne   cn1
         inc   negative                   negative := true
         bra   cn2                        ++str
cn1      cmp   #'+'                     else if the char is '+' then
         bne   cn3
cn2      inc4  str                        ++str

cn3      ph4   <str                     save the starting string
         ph2   <base                    convert the unsigned number
         ph4   <ptr
         ph4   <str
         jsl   ~strtoul
         stx   val+2
         sta   val
         txy                            see if we have an overflow
         bpl   rt1
         ldy   negative                   allow -2147483648 as legal value
         beq   ov0
         cpx   #$8000
         bne   ov0
         tay
         beq   rt1
;
;  Overflow - flag the error
;
ov0      lda   #ERANGE                  errno = ERANGE
         sta   >errno
         ldx   #$7FFF                   return value = LONG_MAX
         ldy   #$FFFF
         lda   negative                 if negative then
         beq   ov1
         inx                              return value = LONG_MIN
         iny
ov1      sty   val
         stx   val+2
;
;  return the results
;
rt1      pla                            remove the original value of str from
         pla                             the stack
         lda   negative                 if negative then
         beq   rt2
         sub4  #0,val,val                 val = -val

rt2      ldx   val+2                    get the value
         ldy   val
         lda   rtl                      fix the stack
         sta   base-1
         lda   rtl+1
         sta   base
         pld
         tsc
         clc
         adc   #16
         tcs
         tya                            return
         rtl
         end

****************************************************************
*
*  strtoul - convert a string to an unsigned long
*  ~strtoul - alt entry point that does not parse leading
*             white space and sign
*
*  Inputs:
*        str - pointer to the string
*        ptr - pointer to a pointer; a pointer to the first
*              char past the number is placed here.  If ptr is
*              nil, no pointer is returned
*        base - base of the number
*
*  Outputs:
*        X-A - converted number
*
****************************************************************
*
strtoul  start
base     equ   22                       base
ptr      equ   18                       *return pointer
str      equ   14                       string pointer
rtl      equ   11                       return address

rangeOK  equ   9                        was the number within range?
negative equ   7                        was there a minus sign?
val      equ   3                        value
foundOne equ   1                        have we found a number?

         ldx   #0
         bra   init

~strtoul entry                          alt entry point called from strtol
         ldx   #1

init     pea   1                        make room for & initialize rangeOK
         lda   #0
         pha                            make room for & initialize negative
         pha                            make room for & initialize val
         pha
         pha                            make room for & initialize foundOne
         tsc                            set up direct page addressing
         phd
         tcd
;
;  Skip any leading whitespace
;
         txa                            just process number if called from strtol
         bne   db1c

         lda   ptr                      if ptr in non-null then
         ora   ptr+2
         beq   sw1
         lda   str                        initialize it to str
         sta   [ptr]
         ldy   #2
         lda   str+2
         sta   [ptr],Y

sw1      lda   [str]                    skip the white space
         and   #$00FF
         tax
         lda   >__ctype+1,X
         and   #_space
         beq   db1
         inc4  str
         bra   sw1
;
;  Deduce the base
;
db1      lda   [str]                    if the next char is '-' then
         and   #$00FF
         cmp   #'-'
         bne   db1a
         inc   negative                   negative := true
         bra   db1b
db1a     cmp   #'+'                     skip any leading '+'
         bne   db1c
db1b     inc4  str
db1c     lda   base                     if the base is zero then
         bne   db2
         lda   #10                        assume base 10
         sta   base
         lda   [str]                      if the first char is 0 then
         and   #$00FF
         cmp   #'0'
         bne   cn1
         lda   #8                           assume base 8
         sta   base
         ldy   #1                           if the second char is 'X' or 'x' then
         lda   [str],Y
         and   #$00DF
         cmp   #'X'
         bne   cn1
         asl   base                           base 16
         bra   db3
db2      cmp   #16                      if the base is 16 then
         bne   db4
         lda   [str]                      if the first two chars are 0x or 0X then
         and   #$DFFF
         cmp   #'X0'
         bne   cn1
db3      add4  str,#2                       skip them
         bra   cn1
db4      cmp   #37                      check for invalid base value
         bge   cn6
         dec   a
         beq   cn6
;
;  Convert the number
;
cn1      lda   [str]                    get a (possible) digit
         and   #$00FF
         cmp   #'0'                     branch if it is not a digit
         blt   cn5
         cmp   #'9'+1                   branch if it is a numeric digit
         blt   cn2
         and   #$00DF                   convert lowercase to uppercase
         cmp   #'A'                     branch if it is not a digit
         blt   cn5
         cmp   #'Z'+1                   branch if it is not a digit
         bge   cn5
         sbc   #'A'-11                  convert "alpha" digit to value
         bra   cn3                      go test the digit

cn2      and   #$000F                   convert digit to value
cn3      cmp   base                     branch if the digit is too big
         bge   cn5

         ldx   #1                       note that we have found a number
         stx   foundOne
         pha                            save the digit
         pha                            val = val*base
         pha
         pha
         pha
         ph4   <val
         pea   0
         ph2   <base
         _LongMul
         pl4   val
         pla                            branch if there was an error
         ora   1,S
         plx
         ply
         tax
         beq   cn3a
         stz   rangeOK
cn3a     clc                            add in the new digit
         tya
         adc   val
         sta   val
         bcc   cn4
         inc   val+2
         bne   cn4
         stz   rangeOK
cn4      inc4  str                      next char
         bra   cn1

cn5      lda   foundOne                 if no digits were found, flag the error
         bne   rt1
cn6      lda   #EINVAL
         sta   >errno
         bra   rt2a
;
;  return the results
;
rt1      lda   ptr                      if ptr is non-null then
         ora   ptr+2
         beq   rt1a
         lda   str                        set it to str
         sta   [ptr]
         ldy   #2
         lda   str+2
         sta   [ptr],Y

rt1a     lda   rangeOK                  check if number was out of range
         bne   rt2
         lda   #ERANGE                  errno = ERANGE
         sta   >errno
         ldx   #$FFFF                   return value = ULONG_MAX
         txy
         bra   rt3
rt2      lda   negative                 if negative then
         beq   rt2a
         sub4  #0,val,val                 val = -val
rt2a     ldx   val+2                    get the value
         ldy   val
rt3      lda   rtl                      fix the stack
         sta   base-1
         lda   rtl+1
         sta   base
         pld
         tsc
         clc
         adc   #20
         tcs
         tya                            return
         rtl
         end

****************************************************************
*
*  strtoll - convert a string to a long long
*
*  Inputs:
*        str - pointer to the string
*        ptr - pointer to a pointer; a pointer to the first
*              char past the number is placed here.  If ptr is
*              nil, no pointer is returned
*        base - base of the number
*
*  Outputs:
*        converted number
*
****************************************************************
*
strtoll  start
strtoimax entry
base     equ   26                       base
ptr      equ   22                       *return pointer
str      equ   18                       string pointer
rtl      equ   15                       return address

retptr   equ   11                       pointer to location for return value
val      equ   3                        value
negative equ   1                        is the number negative?

         lda   #0
         pha                            make room for & initialize retptr
         phx
         pha                            make room for & initialize val
         pha
         pha
         pha
         pha                            make room for & initialize negative
         tsc                            set up direct page addressing
         phd
         tcd
;
;  Skip any leading whitespace
;
         lda   ptr                      if ptr in non-null then
         ora   ptr+2
         beq   sw1
         lda   str                        initialize it to str
         sta   [ptr]
         ldy   #2
         lda   str+2
         sta   [ptr],Y

sw1      lda   [str]                    skip the white space
         and   #$00FF
         tax
         lda   >__ctype+1,X
         and   #_space
         beq   cn0
         inc4  str
         bra   sw1
;
;  Convert the number
;
cn0      lda   [str]                    if the next char is '-' then
         and   #$00FF
         cmp   #'-'
         bne   cn1
         inc   negative                   negative := true
         bra   cn2                        ++str
cn1      cmp   #'+'                     else if the char is '+' then
         bne   cn3
cn2      inc4  str                        ++str

cn3      ph4   <str                     save the starting string
         ph2   <base                    convert the unsigned number
         ph4   <ptr
         ph4   <str
         tdc
         clc
         adc   #val
         tax
         jsl   ~strtoull
         lda   val+6          
         bpl   rt1                      see if we have an overflow
         ldy   negative                   allow LLONG_MIN as legal value
         beq   ov0
         cmp   #$8000
         bne   ov0
         lda   val
         ora   val+2
         ora   val+4
         beq   rt1
;
;  Overflow - flag the error
;
ov0      lda   #ERANGE                  errno = ERANGE
         sta   >errno
         ldx   #$7FFF                   return value = LLONG_MAX
         ldy   #$FFFF
         lda   negative                 if negative then
         beq   ov1
         inx                              return value = LLONG_MIN
         iny
ov1      sty   val
         sty   val+2
         sty   val+4
         stx   val+6
;
;  return the results
;
rt1      pla                            remove the original value of str from
         pla                             the stack
         lda   negative                 if negative then
         beq   rt2
         negate8 val                      val = -val

rt2      lda   val                      get the value
         sta   [retptr]
         ldy   #2
         lda   val+2
         sta   [retptr],y
         iny
         iny
         lda   val+4
         sta   [retptr],y
         iny
         iny
         lda   val+6
         sta   [retptr],y
         lda   rtl                      fix the stack
         sta   base-1
         lda   rtl+1
         sta   base
         pld
         tsc
         clc
         adc   #24
         tcs
         tya                            return
         rtl
         end

****************************************************************
*
*  strtoull - convert a string to an unsigned long long
*  ~strtoull - alt entry point that does not parse leading
*              white space and sign
*
*  Inputs:
*        str - pointer to the string
*        ptr - pointer to a pointer; a pointer to the first
*              char past the number is placed here.  If ptr is
*              nil, no pointer is returned
*        base - base of the number
*
*  Outputs:
*        converted number
*
****************************************************************
*
strtoull start
strtoumax entry
base     equ   30                       base
ptr      equ   26                       *return pointer
str      equ   22                       string pointer
rtl      equ   19                       return address

retptr   equ   15                       pointer to location for return value
rangeOK  equ   13                       was the number within range?
negative equ   11                       was there a minus sign?
val      equ   3                        value
foundOne equ   1                        have we found a number?

         ldy   #0
         bra   init

~strtoull entry                         alt entry point called from strtoll
         ldy   #1

init     lda   #0
         pha                            make room for & initialize retptr
         phx
         pea   1                        make room for & initialize rangeOK
         pha                            make room for & initialize negative
         pha                            make room for & initialize val
         pha
         pha
         pha
         pha                            make room for & initialize foundOne
         tsc                            set up direct page addressing
         phd
         tcd
;
;  Skip any leading whitespace
;
         tya                            just process number if called from strtol
         bne   db1c

         lda   ptr                      if ptr in non-null then
         ora   ptr+2
         beq   sw1
         lda   str                        initialize it to str
         sta   [ptr]
         ldy   #2
         lda   str+2
         sta   [ptr],Y

sw1      lda   [str]                    skip the white space
         and   #$00FF
         tax
         lda   >__ctype+1,X
         and   #_space
         beq   db1
         inc4  str
         bra   sw1
;
;  Deduce the base
;
db1      lda   [str]                    if the next char is '-' then
         and   #$00FF
         cmp   #'-'
         bne   db1a
         inc   negative                   negative := true
         bra   db1b
db1a     cmp   #'+'                     skip any leading '+'
         bne   db1c
db1b     inc4  str
db1c     lda   base                     if the base is zero then
         bne   db2
         lda   #10                        assume base 10
         sta   base
         lda   [str]                      if the first char is 0 then
         and   #$00FF
         cmp   #'0'
         bne   cn1
         lda   #8                           assume base 8
         sta   base
         ldy   #1                           if the second char is 'X' or 'x' then
         lda   [str],Y
         and   #$00DF
         cmp   #'X'
         bne   cn1
         asl   base                           base 16
         bra   db3
db2      cmp   #16                      if the base is 16 then
         bne   db4
         lda   [str]                      if the first two chars are 0x or 0X then
         and   #$DFFF
         cmp   #'X0'
         bne   cn1
db3      add4  str,#2                       skip them
         bra   cn1
db4      cmp   #37                      check for invalid base value
         jge   cn6
         dec   a
         jeq   cn6
;
;  Convert the number
;
cn1      lda   [str]                    get a (possible) digit
         and   #$00FF
         cmp   #'0'                     branch if it is not a digit
         blt   cn5
         cmp   #'9'+1                   branch if it is a numeric digit
         blt   cn2
         and   #$00DF                   convert lowercase to uppercase
         cmp   #'A'                     branch if it is not a digit
         blt   cn5
         cmp   #'Z'+1                   branch if it is not a digit
         bge   cn5
         sbc   #'A'-11                  convert "alpha" digit to value
         bra   cn3                      go test the digit

cn2      and   #$000F                   convert digit to value
cn3      cmp   base                     branch if the digit is too big
         bge   cn5

         ldx   #1                       note that we have found a number
         stx   foundOne
         pha                            save the digit
         ph8   <val                     val = val*base
         pea   0
         pea   0
         pea   0
         ph2   <base
         jsl   ~UMUL8
         pl8   val
         pla                            get the saved digit
         txy                            branch if there was an error
         beq   cn3a
         stz   rangeOK
cn3a     clc                            add in the new digit
         adc   val
         sta   val
         bcc   cn4
         inc   val+2
         bne   cn4
         inc   val+4
         bne   cn4
         inc   val+6
         bne   cn4
         stz   rangeOK
cn4      inc4  str                      next char
         bra   cn1

cn5      lda   foundOne                 if no digits were found, flag the error
         bne   rt1
cn6      lda   #EINVAL
         sta   >errno
         bra   rt2a
;
;  return the results
;
rt1      lda   ptr                      if ptr is non-null then
         ora   ptr+2
         beq   rt1a
         lda   str                        set it to str
         sta   [ptr]
         ldy   #2
         lda   str+2
         sta   [ptr],Y

rt1a     lda   rangeOK                  check if number was out of range
         bne   rt2
         lda   #ERANGE                  errno = ERANGE
         sta   >errno
         lda   #$FFFF                   return value = ULLONG_MAX
         sta   [retptr]
         ldy   #2
         sta   [retptr],y
         iny
         iny
         sta   [retptr],y
         iny
         iny
         sta   [retptr],y
         bra   rt3
rt2      lda   negative                 if negative then
         beq   rt2a
         negate8 val                      val = -val
rt2a     lda   val                      get the value
         sta   [retptr]
         ldy   #2
         lda   val+2
         sta   [retptr],y
         iny
         iny
         lda   val+4
         sta   [retptr],y
         iny
         iny
         lda   val+6
         sta   [retptr],y
rt3      lda   rtl                      fix the stack
         sta   base-1
         lda   rtl+1
         sta   base
         pld
         tsc
         clc
         adc   #28
         tcs
         tya                            return
         rtl
         end

****************************************************************
*
*  int system(command)
*        char *command;
*
*  Executes the command steam as an exec file.
*
*  Inputs:
*        command - command string
*
*  Outputs:
*        Returns the status of the command
*
****************************************************************
*
system   start

         phb                            get the addr of the string from the
         phk                             stack
         plb
         plx
         ply
         pla
         sta   exComm
         pla
         sta   exComm+2
         ora   exComm
         sta   empty
         bne   lb1                      if calling system(NULL)
         lda   #empty                     use empty command string
         sta   exComm
         lda   #^empty
         sta   exComm+2
lb1      phy                            execute the command
         phx
         Execute ex
         ldy   empty
         bne   ret                      if doing system(NULL)
         tya
         bcs   ret                        error => no command processor
         inc   a                           (& vice versa)                
ret      plb
         rtl

ex       dc    i'$8000'
exComm   ds    4

empty    ds    2
         end

****************************************************************
*
*  void __record_va_info(va_list ap);
*
*  Record that a traversal of variable arguments has finished.
*  Data is recorded in the internal va info that will be used
*  to remove variable arguments at the end of the function.
*
*  Inputs:
*        ap - the va_list
*
****************************************************************
*
__record_va_info start
va_info_ptr equ 1                       pointer to the internal va info

         csubroutine (4:ap),4
         ldy   #4                       get pointer to internal va info
         lda   [ap],y
         sta   va_info_ptr
         stz   va_info_ptr+2

         lda   [ap]                     update end of variable arguments
         cmp   [va_info_ptr]
         blt   ret
         sta   [va_info_ptr]

ret      creturn
         end

****************************************************************
*
*  void __va_end(internal_va_info *list);
*
*  Remove variable length arguments from the stack.
*
*  Inputs:
*        list - Pointer to an array.  The second element is a
*              pointer to the first variable argument, while
*              the first is a pointer to the first byte past
*              the argument list.
*
*  Notes:
*        1. The number of bytes to remove must be even.
*        2. D is incremented by the # of bytes removed.
*
****************************************************************
*
__va_end   start
list     equ   7                        pointer to the array
D        equ   1                        caller's DP

         phb                            save the caller's data bank
         phd                            save the caller's D reg
         tsc                            set up our stack frame
         tcd
         sec                            calculate the # of bytes to be removed
         ldy   #4
         lda   [list]
         sbc   [list],Y
         sta   >toRemove
         clc                            update the caller's DP
         adc   D
         sta   D

         lda   [list],Y                 set the source address
         tax
         dex
         lda   [list]                   set the destination address
         tay
         dey
         sec                            set the # of bytes to move - 1
         tsc
         sbc   [list]
         eor   #$FFFF
         mvp   0,0                      move the bytes

         clc                            update out stack ptr
         tsc
         adc   >toRemove
         tcs
         pld                            restore the caller's DP
         plx                            remove the parameter from the stack
         ply
         pla
         pla
         phy
         phx
         plb                            restore the caller's data bank
         rtl

toRemove ds    2                        # bytes to remove
         end
