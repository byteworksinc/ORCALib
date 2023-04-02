         keep  obj/fenv
         mcopy fenv.macros
         case  on

****************************************************************
*
*  Fenv - Floating-point environment access
*
*  This code provides routines to query and modify the
*  floating-point environment.
*
*  Note: This relies on and only works with SANE.
*
****************************************************************
*
fenv     private                        dummy segment
         end

FE_ALL_EXCEPT gequ $001F

****************************************************************
*
*  int feclearexcept(int excepts);
*
*  Clear floating-point exceptions
*
*  Inputs:
*        excepts - floating-point exceptions to clear
*
*  Outputs:
*        Returns 0 if successful, non-zero otherwise
*
****************************************************************
*
feclearexcept start

         csubroutine (2:excepts),0
         
         FGETENV                               get current environment
         phx
         
         lda   excepts
         and   #FE_ALL_EXCEPT
         eor   #$FFFF                          mask off excepts to clear
         xba
         and   1,S
         sta   1,S
         FSETENV                               clear them

         creturn 2:#0
         end

****************************************************************
*
*  int fegetexceptflag(fexcept_t *flagp, int excepts);
*
*  Get floating-point exception flags.
*
*  Inputs:
*        flagp - pointer to location to store exception flags
*        excepts - floating-point exceptions to get
*
*  Outputs:
*        Returns 0 if successful, non-zero otherwise
*
****************************************************************
*
fegetexceptflag start

         csubroutine (4:flagp,2:excepts),0
         
         FGETENV                               get current environment
         tya
         and   excepts                         get desired exceptions
         and   #FE_ALL_EXCEPT
         sta   [flagp]                         store them in *flagp
         
         creturn 2:#0
         end

****************************************************************
*
*  int feraiseexcept(int excepts);
*
*  Raise floating-point exceptions
*
*  Inputs:
*        excepts - floating-point exceptions to raise
*
*  Outputs:
*        Returns 0 if successful, non-zero otherwise
*
****************************************************************
*
feraiseexcept start

         csubroutine (2:excepts),0
         
         lda   excepts
         and   #FE_ALL_EXCEPT
         beq   done
         pha
         FSETXCP                        raise exceptions
         
done     creturn 2:#0
         end

****************************************************************
*
*  int fesetexceptflag(fexcept_t *flagp, int excepts);
*
*  Set (but do not raise) floating-point exception flags
*
*  Inputs:
*        flagp - pointer to stored exception flags
*        excepts - floating-point exceptions to set
*
*  Outputs:
*        Returns 0 if successful, non-zero otherwise
*
****************************************************************

fesetexceptflag start

         csubroutine (4:flagp,2:excepts),0
         
         FGETENV                        get env with excepts masked off
         phx
         lda   excepts
         and   #FE_ALL_EXCEPT
         eor   #$FFFF
         xba
         and   1,S
         sta   1,S
         
         lda   [flagp]                  set new exceptions
         and   excepts
         and   #FE_ALL_EXCEPT
         xba
         ora   1,S
         sta   1,S
         FSETENV
         
         creturn 2:#0
         end

****************************************************************
*
*  int fetestexcept(int excepts);
*
*  Test if floating-point exception flags are set
*
*  Inputs:
*        excepts - floating-point exceptions to test for
*
*  Outputs:
*        Bitwise or of exceptions that are set
*
****************************************************************
*
fetestexcept start

         csubroutine (2:excepts),0
         
         FGETENV                        get exception flags
         tya
         and   excepts                  mask to just the ones we want
         and   #FE_ALL_EXCEPT
         sta   excepts
         
         creturn 2:excepts
         end

****************************************************************
*
*  int fegetround(void);
*
*  Get the current rounding direction
*
*  Outputs:
*        The current rounding direction
*
****************************************************************
*
fegetround start
         FGETENV                        get high word of environment
         tya
         and   #$00C0                   just rounding direction
         rtl
         end

****************************************************************
*
*  int fesetround(int round);
*
*  Set the current rounding direction
*
*  Inputs:
*        round - the rounding direction to set
*
*  Outputs:
*        Returns 0 if successful, non-zero otherwise
*
****************************************************************
*
fesetround start

         csubroutine (2:round),0

         lda   round                    flip words
         xba
         sta   round
         and   #$3FFF                   do nothing if not a valid rounding dir
         bne   done

         FGETENV                        set the rounding direction
         txa
         and   #$3FFF
         ora   round
         pha
         FSETENV

         stz   round
done     creturn 2:round
         end

****************************************************************
*
*  int fegetenv(fenv_t *envp);
*
*  Get the current floating-point environment
*
*  Inputs:
*        envp - pointer to location to store environment
*
*  Outputs:
*        Returns 0 if successful, non-zero otherwise
*
****************************************************************
*
fegetenv start

         csubroutine (4:envp),0
         
         FGETENV                        get the environment
         txa
         sta   [envp]                   store it in *envp
         
         creturn 2:#0
         end

****************************************************************
*
*  int feholdexcept(fenv_t *envp);
*
*  Get environment, then clear status flags and disable halts
*
*  Inputs:
*        envp - pointer to location to store environment
*
*  Outputs:
*        Returns 0 if successful, non-zero otherwise
*
****************************************************************
*
feholdexcept start

         csubroutine (4:envp),0
         
         FGETENV                        get the environment
         txa
         sta   [envp]                   store it in *envp
         
         and   #$E0E0                   clear exception flags and disable halts
         pha
         FSETENV                        set the new environment
         
         creturn 2:#0
         end

****************************************************************
*
*  int fesetenv(const fenv_t *envp);
*
*  Set the floating-point environment
*
*  Inputs:
*        envp - pointer to environment to set
*
*  Outputs:
*        Returns 0 if successful, non-zero otherwise
*
****************************************************************
*
fesetenv start

         csubroutine (4:envp),0

         lda   [envp]                   set the environment
         pha
         FSETENV

         creturn 2:#0
         end

****************************************************************
*
*  int feupdateenv(const fenv_t *envp);
*
*  Save exceptions, set environment, then re-raise exceptions
*
*  Inputs:
*        envp - pointer to environment to set
*
*  Outputs:
*        Returns 0 if successful, non-zero otherwise
*
****************************************************************
*
feupdateenv start

         csubroutine (4:envp),0

         lda   [envp]                   set the environment
         pha
         FPROCEXIT

         creturn 2:#0
         end

****************************************************************
*
*  Default floating-point environment
*
****************************************************************
*
__FE_DFL_ENV start
         dc i2'0'
         end

****************************************************************
*
*  int __get_flt_rounds(void);
*
*  Get the value of FLT_ROUNDS, accounting for rounding mode
*
*  Outputs:
*        Current value of FLT_ROUNDS
*
****************************************************************
*
__get_flt_rounds start
         FGETENV
         tya                            get rounding direction in low bits of A
         asl   a
         asl   a
         xba
         inc   a                        convert to values used by FLT_ROUNDS
         and   #$0003
         rtl
         end
