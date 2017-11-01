         keep  obj/setjmp
         case  on

****************************************************************
*
*  SetJmp - Set jump library
*
*  This code implements the subroutines needed to support the
*  standard C library SETJMP.
*
*  January 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************
*
SetJmp   start                          dummy segment

         end

****************************************************************
*
*  int setjmp(env)
*        jmp_buf env;
*
*  Inputs:
*        env - pointer to the environment array
*
*  Outputs:
*        Returns 0.
*
****************************************************************
*
setjmp   start
env      equ   4                        pointer to array
ret      equ   1                        return address

         tsc                            set up addressing
         phd
         tcd
         clc                            save the correct stack pointer
         adc   #4
         sta   [env]
         ldy   #2                       save D
         lda   1,S
         sta   [env],Y
         ldy   #4                       save the return address
         lda   ret-1
         sta   [env],Y
         iny
         iny
         lda   ret+1
         sta   [env],Y
         pld                            repair the stack
         phb
         plx
         ply
         pla
         pla
         phy
         phx
         plb
         lda   #0                       return 0
         rtl
         end

****************************************************************
*
*  void longjmp(env,status)
*        jmp_buf env;
*        int status;
*
*  Inputs:
*        env - pointer to the environment array
*        status - status to return
*
****************************************************************
*
longjmp  start
env      equ   4                        environment pointer
status   equ   8                        status to return

         tsc                            set up the local stack frame
         tcd
         phb
         phk
         plb
         ldx   status                   get the status
         bne   lb1
         inx
lb1      ldy   #6                       get the env record
lb2      lda   [env],Y
         sta   lenv,Y
         dey
         dey
         bpl   lb2
         plb
         lda   >stackPtr                reset the stack pointer
         tcs
         lda   >ret+2                   reset the return address
         sta   2,S
         lda   >ret
         sta   0,S
         lda   >dp                      reset the dp
         tcd
         txa                            return the status
         rtl

lenv     anop                           local copy of *env
stackPtr ds    2
dp       ds    2
ret      ds    4
         end
