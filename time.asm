         keep  obj/time
         mcopy time.macros
         case  on

****************************************************************
*
*  Time - Time and date libraries for C
*
*  This code implements the tables and subroutines needed to
*  support the standard C library TIME.
*
*  January 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
* Note: Portions of this library appear in SysFloat
*
****************************************************************
*
Time     start                          dummy segment
         end

****************************************************************
*
*  TimeCommon - common variables for the time library
*
****************************************************************
*
TimeCommon privdata
;
;  For conversion to/from seconds since 1970
;
year     ds    4                        year    0..99
month    ds    4                        month   1..12
day      ds    4                        day     1..31
hour     ds    4                        hour    0..23
minute   ds    4                        minute  0..59
second   ds    4                        second  0..59
count    ds    4                        seconds since 1 Jan 1970
t1       ds    4                        work variable
t2       ds    4                        work variable

lasttime ds    4                        last time_t value returned by time()
lastDST  dc    i2'-1'                   tm_isdst value for lasttime
         end

****************************************************************
*
*  clock_t __clocks_per_sec()
*
*  Outputs:
*        X-A - the number of clock ticks per second (50 or 60)
*
****************************************************************
*
__clocks_per_sec start
LANGSEL  equ   $E1C02B                  LANGSEL soft switch

         short I,M
         ldy   #60
         ldx   #0
         lda   >LANGSEL
         and   #$10                     test NTSC/PAL bit of LANGSEL
         beq   lb1
         ldy   #50
lb1      long  I,M
         tya
         rtl
         end

****************************************************************
*
*  char *asctime(struct tm *ts)
*
*  Inputs:
*        ts - time record to create string for
*
*  Outputs:
*        returns a pointer to the time string
*
****************************************************************
*
asctime  start

         csubroutine (4:ts),0
         phb
         phk
         plb

         brl   ~ctime2
         end

****************************************************************
*
*  clock_t clock()
*
*  Outputs:
*        X-A - tick count
*
****************************************************************
*
clock    start

         pha
         pha
         _GetTick
         pla
         plx
         rtl
         end

****************************************************************
*
*  char *ctime(timeptr)
*        time_t *timptr;
*
*  Inputs:
*        timeptr - time to create string for
*
*  Outputs:
*        returns a pointer to the time string
*
****************************************************************
*
ctime    start
tm_sec   equ   0                        displacements into the time record
tm_min   equ   2
tm_hour  equ   4
tm_mday  equ   6
tm_mon   equ   8
tm_year  equ   10
tm_wday  equ   12

         csubroutine (4:timeptr),0
         phb
         phk
         plb

         ph4   timeptr                  convert to a time record
         jsl   localtime
         sta   timeptr
         stx   timeptr+2
~ctime2  entry
         ldy   #tm_wday                 convert the week day to a string
         lda   [timeptr],Y
         asl   a
         asl   a
         tax
         lda   weekDay,X
         sta   str
         lda   weekDay+1,X
         sta   str+1
         ldy   #tm_mon                  convert the month to a string
         lda   [timeptr],Y
         asl   a
         asl   a
         tax
         lda   monthStr,X
         sta   str+4
         lda   monthStr+1,X
         sta   str+5
         ldy   #tm_mday                 convert the day to a string
         lda   [timeptr],Y
         jsr   mkstr
         bit   #$00CF                   check for leading '0'
         bne   lb1
         and   #$FFEF                   convert leading '0' to ' '
lb1      sta   str+8
         ldy   #tm_hour                 convert the hour to a string
         lda   [timeptr],Y
         jsr   mkstr
         sta   str+11
         ldy   #tm_min                  convert minutes to a string
         lda   [timeptr],Y
         jsr   mkstr
         sta   str+14
         ldy   #tm_sec                  convert seconds to a string
         lda   [timeptr],Y
         jsr   mkstr
         sta   str+17
         ldy   #tm_year                 convert the year to a string
         lda   [timeptr],Y
         ldy   #19
         sec
yr1      iny
         sbc   #100
         bpl   yr1
         clc
yr2      dey
         adc   #100
         bmi   yr2
         jsr   mkstr
         sta   str+22
         tya
         jsr   mkstr
         sta   str+20
         lla   timeptr,str

         plb
         creturn 4:timeptr

weekDay  dc    c'Sun Mon Tue Wed Thu Fri Sat'
monthStr dc    c'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'
str      dc    c'Sun Jan 00 00:00:00 1900',i1'10,0'
;
;  mkstr - convert a number to a string
;
mkstr    ldx   #-1
mk1      inx
         sec
         sbc   #10
         bcs   mk1
         clc
         adc   #10
         xba
         pha
         txa
         ora   1,S
         ora   #$3030
         plx
         rts
         end

****************************************************************
*
*  factor - compute the seconds since 1 Jan 1970 from date
*
*  Inputs:
*        year,month,day,hour,minute,second - time to convert
*
*  Outputs:
*        count - seconds since 1 Jan 1970
*
****************************************************************
*
factor   private
         using TimeCommon
;
;  compute the # of days since 1 Jan 1970
;
         mul4  year,#365,count          count := 365*year + day + 31*(month-1)
         add4  count,day
         mul4  month,#31,t1
         add4  count,t1
         sub4  count,#31
         move4 year,t2                  t2 := year
         lda   month                    if January or February then
         cmp   #3
         bge   lb1
         dec   t2                         year := year-1
         bra   lb2                      else
lb1      mul4  month,#4,t1                count := count - (month*4+23) div 10
         add4  t1,#23
         div4  t1,#10
         sub4  count,t1
lb2      lda   t2                       count := count + year div 4
         lsr   A
         lsr   A
         clc
         adc   count
         sta   count
         bcc   lb3
         inc   count+2
lb3      add4  t2,#300                  count := count -
         div4  t2,#100                    ((300+year) div 100+1)*3 div 4
         inc4  t2
         mul4  t2,#3
         div4  t2,#4
         sub4  count,t2
         sub4  count,#25516             subtract off days between 1 Jan 00 and
!                                        1 Jan 70
;
;  Convert to seconds and add in time of day in seconds
;
         mul4  count,#24*60*60          convert to seconds
         mul4  hour,#3600,t1            add in hours*3600
         add4  count,t1
         mul4  minute,#60,t1            add in minutes*60
         add4  count,t1
         add4  count,second             add in seconds
         rts
         end

****************************************************************
*
*  struct tm *localtime(t)
*        time_t *t;
*
*  Inputs:
*        t - # seconds since 1 Jan 1970
*
*  Outputs:
*        returns a pointer to a time record
*
****************************************************************
*
localtime start
gmtime   entry
         using TimeCommon

         csubroutine (4:t),0
         phb
         phk
         plb

         ldy   #2                       dereference the pointer
         lda   [t],Y
         tax
         lda   [t]
         sta   t
         stx   t+2

         ldy   #-1                      default DST setting = -1 (unknown)
         cmp   lasttime                 determine DST setting, if we can
         bne   lb0
         cpx   lasttime+2
         bne   lb0
         ldy   lastDST
lb0      sty   tm_isdst

         lda   #69                      find the year
         sta   year
         lda   #1
         sta   month
         sta   day
         stz   hour
         stz   minute
         stz   second
lb1      inc   year
         jsr   factor
         lda   count+2
         cmp   t+2
         bne   lb1a
         lda   count
         cmp   t
lb1a     ble   lb1
         dec   year
lb2      inc   month                    find the month
         jsr   factor
         lda   count+2
         cmp   t+2
         bne   lb2a
         lda   count
         cmp   t
lb2a     ble   lb2
         dec   month
         jsr   factor                   recompute the factor
         lda   year                     set the year
         sta   tm_year
         lda   month                    set the month
         dec   A
         sta   tm_mon
         sub4  t,count                  find the number of seconds
         move4 t,t1
         div4  t,#60
         mul4  t,#60,t2
         sub4  t1,t2
         lda   t1
         sta   tm_sec
         move4 t,t1                     find the number of minutes
         div4  t,#60
         mul4  t,#60,t2
         sub4  t1,t2
         lda   t1
         sta   tm_min
         move4 t,t1                     find the number of hours
         div4  t,#24
         mul4  t,#24,t2
         sub4  t1,t2
         lda   t1
         sta   tm_hour
         lda   t                        set the day
         inc   A
         sta   tm_mday
         ph4   #tm_sec                  set the day of week/year
         jsl   mktime
         lla   t,tm_sec
         plb
         creturn 4:t

tm_sec   ds    2                        seconds         0..59
tm_min   ds    2                        minutes         0..59
tm_hour  ds    2                        hours           0..23
tm_mday  ds    2                        day             1..31
tm_mon   ds    2                        month           0..11
tm_year  ds    2                        year            70..200 (1900=0)
tm_wday  ds    2                        day of week     0..6    (Sun = 0)
tm_yday  ds    2                        day of year     0..365
tm_isdst ds    2                        daylight savings? 1 = yes, 0 = no
         end

****************************************************************
*
*  time_t mktime(tmptr)
*        struct tm *tmptr
*
*  Inputs:
*        tmptr - pointer to a time record
*
*  Outputs:
*        tmptr->wday - day of week
*        tmptr->yday - day of year
*        returns the ime in seconds since 1 Jan 1970
*
****************************************************************
*
mktime   start
         using TimeCommon
temp     equ   1                        temp variable
temp2    equ   5                        temp variable

         csubroutine (4:tmptr),8
         phb
         phk
         plb

         lla   temp,-1                  assume we can't do it
         ldy   #10                      error if year < 70
         lda   [tmptr],Y
         sta   year
         cmp   #70
         jlt   lb1
         dey                            set the other time parameters
         dey
         lda   [tmptr],Y
         inc   A
         sta   month
         dey
         dey
         lda   [tmptr],Y
         sta   day
         dey
         dey
         lda   [tmptr],Y
         sta   hour
         dey
         dey
         lda   [tmptr],Y
         sta   minute
         lda   [tmptr]
         sta   second
         jsr   factor                   compute seconds since 1970
         move4 count,temp               save the value for later return
         lda   #1                       compute the days since the start of the
         sta   month                     year
         sta   day
         jsr   factor
         sub4  temp,count,count
         div4  count,#60*60*24
         ldy   #14                      set the days
         lda   count
         sta   [tmptr],Y
         div4  temp,#60*60*24,temp2     compute the day of week
         add4  temp2,#4
         mod4  temp2,#7
         lda   temp2                    set the day of week
         ldy   #12
         sta   [tmptr],Y

lb1      plb
         creturn 4:temp
         end

****************************************************************
*
*  time_t time(tptr)
*        time_t *tptr;
*
*  Outputs:
*        tptr - if non-null, the value it points to is set
*        time - returns the value
*
****************************************************************
*
time     start
         using TimeCommon

         csubroutine (4:tptr),0

         phb
         phk
         plb
;
;  get the current time
;
         pha                            get the current time
         pha
         pha
         pha
         _ReadTimeHex
         lda   5,S                      set the day
         and   #$00FF
         inc   A
         sta   day
         lda   5,S                      set the month
         and   #$FF00
         xba
         inc   A
         sta   month
         lda   3,S                      set the year
         and   #$FF00
         xba
         sta   year
         lda   3,S                      set the hour
         and   #$00FF
         sta   hour
         lda   1,S                      set the minute
         xba
         and   #$00FF
         sta   minute
         pla                            set the second
         and   #$00FF
         sta   second
         pla                            clean up the stack
         pla
         pla
         jsr   factor                   convert the seconds
         lda   tptr                     if tptr <> nil then
         ora   tptr+2
         beq   lb1
         ldy   #2                         place the result there
         lda   count
         sta   [tptr]
         lda   count+2
         sta   [tptr],Y

lb1      lda   count
         sta   tptr
         sta   lasttime
         lda   count+2
         sta   tptr+2
         sta   lasttime+2
         pha                            determine if it's daylight savings
         ph2   #$5E
         _ReadBParam
         pla
         lsr   A
         and   #$0001
         eor   #$0001
         sta   lastDST
         plb
         creturn 4:tptr
         end

****************************************************************
*
*  size_t strftime(
*        char * restrict s,
*        size_t maxsize,
*        const char * restrict format,
*        const struct tm * restrict timeptr);
*
*  Inputs:
*        s - pointer to output buffer
*        maxsize - max number of bytes to write
*        format - format string
*        timeptr - the time/date
*
*  Outputs:
*        s - formatted string representation of the time/date
*        returns length of s (not including terminating null),
*          or 0 if maxsize is too small
*
****************************************************************
*
strftime start

         csubroutine (4:s,4:maxsize,4:format,4:timeptr),14
substfmt equ   1                        substitute format str (used if non-null)
s_orig   equ   substfmt+2               original s pointer (start of output str)
overflow equ   s_orig+4                 overflow flag
numstr   equ   overflow+2               string representation of a number

numstr_len equ 6                        length of numstr

tm_sec   equ   0                        displacements into the time record
tm_min   equ   2
tm_hour  equ   4
tm_mday  equ   6
tm_mon   equ   8
tm_year  equ   10
tm_wday  equ   12
tm_yday  equ   14
tm_isdst equ   16

         phb                            set data bank = program bank
         phk
         plb

;initialization of local variables
         stz   substfmt                 substfmt = 0
         lda   s                        s_orig = s
         sta   s_orig
         lda   s+2
         sta   s_orig+2
         stz   overflow                 overflow = false

;main loop to process the format string
fmtloop  jsr   nextch                   get next character in format
         cmp   #'%'                     if it is not '%'
         beq   dosubst
nonfmt   jsr   writech                    write it to the output
         bra   fmtloop                    continue format loop
dosubst  jsr   nextch                   get next character in format
         cmp   #'E'                     if it is 'E' or 'O'
         beq   skipalt
         cmp   #'O'
         bne   dofmt
skipalt  jsr   nextch                     skip it
dofmt    cmp   #'%'                     if format character is '%'
         beq   nonfmt                     write it like an ordinary character
         cmp   #'@'                     if fmt chr is outside valid range
         blt   fmtloop                    skip it
         cmp   #'z'+1
         bge   fmtloop
         and   #$003f                   if we are here, fmt chr is in ['@'..'z']
         asl   a                        convert to jump table position
         asl   a
         tax
         lda   fmttbl+2,x               if there is a substitution
         beq   fmtcall
         sta   substfmt                   do the substitution
         bra   fmtloop
fmtcall  jsr   (fmttbl,x)               otherwise, call the format routine
         bra   fmtloop                  continue format loop


;subroutine to get next character in format string (call only from main loop)
;returns with character in a, or exits via strftime_return if character is 0
nextch   lda   substfmt                 if there is a substitute format string
         beq   nosubst
         lda   (substfmt)                 get next character from it
         inc   substfmt                   advance subst string pointer
         and   #$00FF
         bne   retchar                    if at end of substitute format string
         stz   substfmt                     go back to using main format string
nosubst  lda   [format]                 get next character from main fmt string
         and   #$00FF
         beq   strftime_return          if char is '\0', return from strftime
         inc4  format                   advance fmt string pointer
retchar  rts                            return from nextch

;code to return from strftime
strftime_return anop
         jsr   writech                  write '\0' to output
         pla                            discard nextch return address
         lda   overflow                 if there was an overflow
         beq   ret_good
         stz   maxsize                    maxsize = 0
         stz   maxsize+2
         bra   ret
ret_good clc                            else
         lda   s                          maxsize = s - s_orig - 1
         sbc   s_orig
         sta   maxsize
         lda   s+2
         sbc   s_orig+2
         sta   maxsize+2
ret      plb                            restore program bank
         creturn 4:maxsize              return maxsize


;subroutine to write a character to the output
;input: character in low-order byte of a (high-order byte is ignored)
;leaves x unchanged
writech  ldy   maxsize                  if remaining size is 0
         bne   writeok
         ldy   maxsize+2
         bne   writeok
         lda   #1                         set overflow flag
         sta   overflow
         rts                              return
writeok  short M                        write the character to s
         sta   [s]
         long  M
         inc4  s                        s++
         dec4  maxsize                  maxsize--
         rts                            return


;table of formatting routines or substitutions for the conversion specifiers
;first ptr is a routine, second is a subst string - only one should be non-zero
fmttbl   anop
         dc    a2'fmt_invalid,0'        @
         dc    a2'fmt_A,0'              A
         dc    a2'fmt_B,0'              B
         dc    a2'fmt_C,0'              C
         dc    a2'0,subst_D'            D
         dc    a2'fmt_invalid,0'        E
         dc    a2'0,subst_F'            F
         dc    a2'fmt_G,0'              G
         dc    a2'fmt_H,0'              H
         dc    a2'fmt_I,0'              I
         dc    a2'fmt_invalid,0'        J
         dc    a2'fmt_invalid,0'        K
         dc    a2'fmt_invalid,0'        L
         dc    a2'fmt_M,0'              M
         dc    a2'fmt_invalid,0'        N
         dc    a2'fmt_invalid,0'        O
         dc    a2'fmt_invalid,0'        P
         dc    a2'fmt_invalid,0'        Q
         dc    a2'0,subst_R'            R
         dc    a2'fmt_S,0'              S
         dc    a2'0,subst_T'            T
         dc    a2'fmt_U,0'              U
         dc    a2'fmt_V,0'              V
         dc    a2'fmt_W,0'              W
         dc    a2'0,subst_X'            X
         dc    a2'fmt_Y,0'              Y
         dc    a2'fmt_Z,0'              Z
         dc    a2'fmt_invalid,0'        [
         dc    a2'fmt_invalid,0'        \
         dc    a2'fmt_invalid,0'        ]
         dc    a2'fmt_invalid,0'        ^
         dc    a2'fmt_invalid,0'        _
         dc    a2'fmt_invalid,0'        `
         dc    a2'fmt_a,0'              a
         dc    a2'fmt_b,0'              b
         dc    a2'0,subst_c'            c
         dc    a2'fmt_d,0'              d
         dc    a2'fmt_e,0'              e
         dc    a2'fmt_invalid,0'        f
         dc    a2'fmt_g,0'              g
         dc    a2'fmt_h,0'              h
         dc    a2'fmt_invalid,0'        i
         dc    a2'fmt_j,0'              j
         dc    a2'fmt_invalid,0'        k
         dc    a2'fmt_invalid,0'        l
         dc    a2'fmt_m,0'              m
         dc    a2'fmt_n,0'              n
         dc    a2'fmt_invalid,0'        o
         dc    a2'fmt_p,0'              p
         dc    a2'fmt_invalid,0'        q
         dc    a2'0,subst_r'            r
         dc    a2'fmt_invalid,0'        s
         dc    a2'fmt_t,0'              t
         dc    a2'fmt_u,0'              u
         dc    a2'fmt_invalid,0'        v
         dc    a2'fmt_w,0'              w
         dc    a2'0,subst_x'            x
         dc    a2'fmt_y,0'              y
         dc    a2'fmt_z,0'              z

;%a - abbreviated weekday name
fmt_a    ldy   #tm_wday
         lda   [timeptr],y
         asl   a
         tay
         ldx   weekdays,y
         lda   |0,x
         jsr   writech
         lda   |1,x
         jsr   writech
         lda   |2,x
         brl   writech
         
;%A - full weekday name
fmt_A    ldy   #tm_wday
         lda   [timeptr],y
         asl   a
         tay
         ldx   weekdays,y
A_loop   lda   |0,x
         and   #$00FF
         beq   A_ret
         jsr   writech
         inx
         bra   A_loop
A_ret    rts

;%b - abbreviated month name
fmt_b    ldy   #tm_mon
         lda   [timeptr],y
         asl   a
         tay
         ldx   months,y
         lda   |0,x
         jsr   writech
         lda   |1,x
         jsr   writech
         lda   |2,x
         brl   writech

;%B - full month name
fmt_B    ldy   #tm_mon
         lda   [timeptr],y
         asl   a
         tay
         ldx   months,y
B_loop   lda   |0,x
         and   #$00FF
         beq   A_ret
         jsr   writech
         inx
         bra   A_loop
B_ret    rts

;%c - date and time
subst_c  dc    c'%a %b %e %H:%M:%S %Y',i1'0'

;%C - century
fmt_C    jsr   format_year
         ldx   #0
C_loop   lda   numstr,x
         and   #$00FF
         cmp   #' '
         beq   C_skip
         jsr   writech
C_skip   inx
         cpx   #numstr_len-2
         blt   C_loop
         rts

;%d - day of the month (01-31)
fmt_d    ldy   #tm_mday
         brl   print2digits_of_field

;%D - equivalent to %m/%d/%y
subst_D  dc    c'%m/%d/%y',i1'0'

;%e - day of the month (1-31, padded with space if a single digit)
fmt_e    ldy   #tm_mday
         lda   [timeptr],y
         ldy   #2
         cmp   #10
         bge   e_print
         tax
         lda   #' '
         jsr   writech
         txa
         ldy   #1
e_print  brl   printdigits

;%F - equivalent to %Y-%m-%d
subst_F  dc    c'%Y-%m-%d',i1'0'

;%g - last two digits of week-based year
fmt_g    jsr   week_number_V
         jsr   format_year_altbase
         brl   write_year_2digit

;%G - week-based year
fmt_G    jsr   week_number_V
         jsr   format_year_altbase
         brl   write_year

;%h - equivalent to %b
fmt_h    brl   fmt_b

;%H - hour (24-hour clock, 00-23)
fmt_H    ldy   #tm_hour
         brl   print2digits_of_field

;%I - hour (12-hour clock, 01-12)
fmt_I    ldy   #tm_hour
         lda   [timeptr],y
         bne   I_adjust
         lda   #12
I_adjust cmp   #12+1
         blt   I_print
         sbc   #12
I_print  brl   print2digits

;%j - day of the year (001-366)
fmt_j    ldy   #tm_yday
         lda   [timeptr],y
         inc   a
         ldy   #3
         brl   printdigits

;%m - month number
fmt_m    ldy   #tm_mon
         lda   [timeptr],y
         inc   a
         brl   print2digits

;%M - minute
fmt_M    ldy   #tm_min
         brl   print2digits_of_field

;%n - new-line character
fmt_n    lda   #$0A
         brl   writech

;%p - AM/PM
fmt_p    ldy   #tm_hour
         lda   [timeptr],y
         cmp   #12
         bge   p_pm
         lda   #'A'
         bra   p_write
p_pm     lda   #'P'
p_write  jsr   writech
         lda   #'M'
         brl   writech

;%r - time (using 12-hour clock)
subst_r  dc    c'%I:%M:%S %p',i1'0'

;%R - equivalent to %H:%M
subst_R  dc    c'%H:%M',i1'0'

;%S - seconds
fmt_S    ldy   #tm_sec
         brl   print2digits_of_field

;%t - horizontal tab character
fmt_t    lda   #$09
         brl   writech

;%T - equivalent to %H:%M:%S
subst_T  dc    c'%H:%M:%S',i1'0'

;%u - weekday number (1-7, Monday=1)
fmt_u    ldy   #tm_wday
         lda   [timeptr],y
         bne   u_print
         lda   #7
u_print  ldy   #1
         brl   printdigits

;%U - week number of the year (first Sunday starts week 01)
fmt_U    ldy   #tm_yday
         lda   [timeptr],y
         clc
         adc   #7
         sec
         ldy   #tm_wday
         sbc   [timeptr],y
         jsr   div7
         tya
         brl   print2digits

;%V - ISO 8601 week number
fmt_V    jsr   week_number_V
         txa
         brl   print2digits

;%w - weekday number (0-6, 0=Sunday)
fmt_w    ldy   #tm_wday
         lda   [timeptr],y
         ldy   #1
         brl   printdigits

;%W - week number of the year (first Monday starts week 01)
fmt_W    jsr   week_number_W
         tya
         brl   print2digits

;%x - date
subst_x  dc    c'%m/%d/%y',i1'0'

;%X - time
subst_X  dc    c'%T',i1'0'

;%y - last two digits of year
fmt_y    jsr   format_year
write_year_2digit anop
         lda   numstr+4
         jsr   writech
         lda   numstr+5
         brl   writech

;%Y - year
fmt_Y    jsr   format_year
write_year anop
         ldx   #0
Y_loop   lda   numstr,x
         and   #$00FF
         cmp   #' '
         beq   Y_skip
         jsr   writech
Y_skip   inx
         cpx   #numstr_len
         blt   Y_loop
         rts

;%z - offset from UTC, if available
;we print nothing, because time zone info is not available
fmt_z    rts

;%Z - time zone name or abbreviation, if available
;we print nothing, because time zone info is not available
fmt_Z    rts

fmt_invalid rts


;get decimal representation of the year in numstr
;the string is adjusted to have at least four digits
format_year anop
         lda   #1900
format_year_altbase anop                alt entry point using year base in a
         ldx   #1                       default to signed
         clc
         ldy   #tm_year
         adc   [timeptr],y
         bvc   year_ok
         ldx   #0                       use unsigned if signed value overflows
year_ok  jsr   int2dec
         short M,I
         ldx   #4
yr_adjlp lda   numstr,x                 adjust year to have >= 4 digits
         cmp   #'-'
         bne   yr_adj1
         sta   numstr-1,x
         bra   yr_adj2
yr_adj1  cmp   #' '
         bne   yr_adj3
yr_adj2  lda   #'0'
         sta   numstr,x
yr_adj3  dex
         cpx   #2
         bge   yr_adjlp
         long  M,I
         rts


;get the week number as for %W (first Monday starts week 1)
;output: week number in y
week_number_W anop
         ldy   #tm_wday
         lda   [timeptr],y
         beq   W_yday
         sec 
         lda   #7
         sbc   [timeptr],y
W_yday   sec
         ldy   #tm_yday
         adc   [timeptr],y
         brl   div7
         

;get the ISO 8601 week number (as for %V) and corresponding year adjustment
;output: week number in x, adjusted year base in a (1900-1, 1900, or 1900+1)
week_number_V anop
         jsr   week_number_W            get %W-style week number (kept in x)
         tyx
         ldy   #tm_wday                 calculate wday for Jan 1 (kept in a)
         lda   [timeptr],y
         sec
         ldy   #tm_yday
         sbc   [timeptr],y
         clc
         adc   #53*7
         jsr   div7
         cmp   #2                       if Jan 1 was Tue/Wed/Thu
         blt   V_adjust
         cmp   #4+1
         bge   V_adjust
         inx                              inc week (week 1 started in last year)
V_adjust txy
         bne   V_not0                   week 0 is really 52 or 53 of last year:
         ldx   #52                        assume 52
         cmp   #5                         if Jan 1 is Fri
         bne   V_0notfr
         inx                                last year had week 53
         bra   V_0done
V_0notfr cmp   #6                         else if Jan 1 is Sat
         bne   V_0done
         ldy   #tm_year
         lda   [timeptr],y
         dec   a
         jsr   leapyear                     if last year was a leap year
         bne   V_0done 
         inx                                  last year had week 53
V_0done  lda   #-1+1900                   year adjustment is -1
         bra   V_done
V_not0   cpx   #53                      week 53 might be week 1 of next year:
         bne   V_noadj 
         cmp   #4                         if Jan 1 was Thu
         beq   V_noadj                      it is week 53
         cmp   #3                         else if Jan 1 was Wed
         bne   V_53is1                      
         ldy   #tm_year
         lda   [timeptr],y
         jsr   leapyear                     and this is a leap year
         beq   V_noadj                        it is week 53
V_53is1  ldx   #1                         otherwise, it is really week 1
         lda   #1+1900                      and year adjustment is +1
         rts
V_noadj  lda   #0+1900                  if we get here, year adjustment is 0
V_done   rts


;check if a year is a leap year
;input: tm_year value in a
;output: z flag set if a leap year, clear if not; x,y unmodified
leapyear and   #$0003                   not multiple of 4 => not leap year
         bne   ly_done
         clc                            calculate year mod 400
         adc   #1900-1600
         bpl   ly_lp400
         clc
         adc   #32800
         sec
ly_lp400 sbc   #400
         bcs   ly_lp400
         adc   #400
         beq   ly_done                  multiple of 400 => leap year
         sec
ly_lp100 sbc   #100
         bcs   ly_lp100
         cmp   #-100
         bne   ly_leap
         dec   a                        other multiple of 100 => not leap year
         rts
ly_leap  lda   #0                       other multiple of 4 => leap year
ly_done  rts


;divide a number (treated as unsigned) by 7
;input: dividend in a
;output: quotient in y, remainder in a, x unmodified
div7     ldy   #-1
         sec
sublp    iny
         sbc   #7
         bcs   sublp
         adc   #7
         rts


;print the low-order two digits of a field of struct tm
;(with leading zeros, if any)
;input: offset of field in y
print2digits_of_field anop
         lda   [timeptr],y               load the field

;print the low-order two digits of a number (with leading zeros, if any)
;input: number in a
print2digits anop
         ldy   #2                       print two digits

;print the low-order digits of a number (with leading zeros, if any)
;input: number in a, how many digits to print in y
printdigits anop
pd1      phy                            save number of digits to print
         ldx   #0                       treat as signed
         jsr   int2dec                  convert to decimal string
         sec                            calculate where to print from
         lda   #numstr_len
         sbc   1,s
         ply
         tax
pd_loop  lda   numstr,x                 print the digits
         and   #$00FF
         cmp   #' '                     change padding spaces to zeros
         bne   pd_write
         lda   #'0'
pd_write jsr   writech
         inx
         cpx   #numstr_len
         blt   pd_loop
         rts


;get decimal representation of a number, placed in numstr
;input: number in a, signed flag in y
int2dec  pha                            number to convert
         pea   0000                     pointer to string buffer
         tdc
         clc
         adc   #numstr
         pha
         pea   numstr_len               length of string buffer
         phx                            signed flag
         _Int2Dec
         rts


weekdays dc    a2'sun,mon,tue,wed,thu,fri,sat'
sun      dc    c'Sunday',i1'0'
mon      dc    c'Monday',i1'0'
tue      dc    c'Tuesday',i1'0'
wed      dc    c'Wednesday',i1'0'
thu      dc    c'Thursday',i1'0'
fri      dc    c'Friday',i1'0'
sat      dc    c'Saturday',i1'0'

months   dc    a2'jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec'
jan      dc    c'January',i1'0'
feb      dc    c'February',i1'0'
mar      dc    c'March',i1'0'
apr      dc    c'April',i1'0'
may      dc    c'May',i1'0'
jun      dc    c'June',i1'0'
jul      dc    c'July',i1'0'
aug      dc    c'August',i1'0'
sep      dc    c'September',i1'0'
oct      dc    c'October',i1'0'
nov      dc    c'November',i1'0'
dec      dc    c'December',i1'0'
         end
