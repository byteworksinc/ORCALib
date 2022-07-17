         keep  obj/fpextra
         mcopy fpextra.macros

****************************************************************
*
*  FPextra - extra floating-point routines
*
*  This code provides routines dealing with floating-point
*  numbers that are used only by ORCA/C, supplementing the
*  ones in SysFloat.
*
****************************************************************
*
fpextra  private                        dummy segment
         end

****************************************************************
*
*  ~SinglePrecision - limit fp value to single precision & range
*
*  Inputs:
*        extended-format real on stack
*
****************************************************************
*
~SinglePrecision start
         tsc
         clc
         adc   #4
         ldy   #0
         phy
         pha
         phy
         pha
         phy
         pha
         phy
         pha
         FX2S
         FS2X
         rtl
         end

****************************************************************
*
*  ~DoublePrecision - limit fp value to double precision & range
*
*  Inputs:
*        extended-format real on stack
*
****************************************************************
*
~DoublePrecision start
         tsc
         clc
         adc   #4
         ldy   #0
         phy
         pha
         phy
         pha
         phy
         pha
         phy
         pha
         FX2D
         FD2X
         rtl
         end

****************************************************************
*
*  ~CompPrecision - limit fp value to comp precision & range
*
*  Inputs:
*        extended-format real on stack
*
*  Note: This avoids calling FX2C on negative numbers,
*  because it is buggy for certain values.
*
****************************************************************
*
~CompPrecision start
         tsc                            round to integer
         clc
         adc   #4
         pea   0
         pha
         FRINTX
         lda   4+8,s
         pha                            save original sign
         asl   a                        force sign to positive
         lsr   a
         sta   6+8,s
         tsc                            limit precision
         clc
         adc   #6
         ldy   #0
         phy
         pha
         phy
         pha
         phy
         pha
         phy
         pha
         FX2C
         FC2X
         pla                            restore original sign
         bpl   ret
         lda   4+8,s
         ora   #$8000
         sta   4+8,s
ret      rtl
         end

