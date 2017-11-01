         keep  obj/signal
         mcopy signal.macros
         case  on

****************************************************************
*
*  signal - Asyncronous event signal handler
*
*  April 1990
*  Mike Westerfield
*
*  Copyright 1990
*  Byte Works, Inc.
*
****************************************************************
*
SIGNAL   start                          dummy segment
         copy  equates.asm
SIG_DFL  gequ  -3
SIG_IGN  gequ  -2
SIG_ERR  gequ  -1

SIGMAX   gequ  6                        maximum number of signals
         end

****************************************************************
*
*  void (*signal(int sig, void (*func) (int)))(int);
*
*  Set the interupt handler
*
*  Inputs:
*        sig - signal number
*        func - signal handler
*
*  Returns:
*        Pointer to the last signal handler; SIG_ERR if sig
*        is out of range.
*
****************************************************************
*
signal   start
         using signalCommon
ptr      equ   1                        old sugnal handler

         csubroutine (2:sig,4:func),4

         lla   ptr,SIG_ERR              assume we will find an error
         lda   sig                      if (!sig in [1..6])
         beq   lb1
         cmp   #SIGMAX+1
         blt   lb2
lb1      lda   #ERANGE                    errno = ERANGE
         sta   >errno
         bra   lb3

lb2      asl   A                        get the old signal handler address
         asl   A
         tax
         lda   >subABRT-4,X
         sta   ptr
         lda   >subABRT-2,X
         sta   ptr+2
         lda   func                     set the new signal handler address
         sta   >subABRT-4,X
         lda   func+2
         sta   >subABRT-2,X

lb3      creturn 4:ptr
         end

****************************************************************
*
*  int raise(int sig);
*
*  Raise a signal.
*
*  Inputs:
*        sig - signal number
*
*  Returns:
*        0 if successful, -1 if sig is out of range
*
****************************************************************
*
raise    start
         using signalCommon
val      equ   1                        value to return

         csubroutine (2:sig),2

         stz   val                      no error
         lda   sig                      if (!sig in [1..6])
         beq   lb1
         cmp   #SIGMAX+1
         blt   lb2
lb1      lda   #-1                        val = -1
         sta   val
         lda   #ERANGE                    errno = ERANGE
         sta   >errno
         bra   lb3

lb2      asl   A                        get the signal handler address
         asl   A
         tax
         lda   >subABRT-4,X
         tay
         lda   >subABRT-2,X
         bmi   lb3                      skip if it is SIG_DFL or SIG_IGN
         short M                        set up the call address
         sta   >jsl+3
         long  M
         tya
         sta   >jsl+1
         ph2   sig                      call the user signal handler
jsl      jsl   jsl

lb3      creturn 2:val
         end

****************************************************************
*
*  signalCommon - data area for the signal unit
*
****************************************************************
*
signalCommon privdata

subABRT  dc    a4'SIG_DFL'
subFPE   dc    a4'SIG_DFL'
subILL   dc    a4'SIG_DFL'
subINT   dc    a4'SIG_DFL'
subSEGV  dc    a4'SIG_DFL'
subTERM  dc    a4'SIG_DFL'
         end
