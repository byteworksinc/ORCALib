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
         sta   str+8
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
	lda	#'91'
	sta	str+20
         lda   [timeptr],Y
	cmp	#100
	blt	lb1
	ldx	#'02'
	stx	str+20
	sec
	sbc	#100
lb1      jsr   mkstr
         sta   str+22
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
	pha		determine if it's daylight savings
	ph2	#$5E
	_ReadBParam
	pla
	lsr	A
	and	#$0001
	eor	#$0001
	sta	tm_isdst

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
tm_isdst ds    2	daylight savings? 1 = yes, 0 = no
         end

****************************************************************
*
*  time_t mktime(tmptr)
*        struct tm *tmptr
*
*  Inputs:
*        tmptr - poiner to a time record
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
         inc   A
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

lb1      move4 count,tptr
         plb
         creturn 4:tptr
         end
