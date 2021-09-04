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
         adc     #4
         ldy     #0
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
         adc     #4
         ldy     #0
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
****************************************************************
*
~CompPrecision start
         tsc
         clc
         adc     #4
         ldy     #0
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
         rtl
         end

