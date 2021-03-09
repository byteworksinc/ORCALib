         keep  obj/math2
         mcopy math2.macros
         case  on

****************************************************************
*
*  Math2 - additional math routines
*
*  This code provides additional functions from <math.h>
*  (including internal helper functions used by macros),
*  supplementing the ones in SysFloat.
*
****************************************************************

math2    private                        dummy segment
         end

****************************************************************
*
*  int __fpclassifyf(float x);
*
*  Classify a float value
*
*  Inputs:
*        val - the number to classify 
*
*  Outputs:
*        one of the FP_* classification values
*
****************************************************************
*
__fpclassifyf start

         csubroutine (10:val),0
         
         tdc
         clc
         adc   #val
         ldy   #0
         phy
         pha
         phy
         pha
         phy
         pha
         FX2S
         FCLASSS
         txa
         and   #$00FF
         cmp   #$00FC
         bne   lb1
         inc   a
lb1      sta   val
         
         creturn 2:val
         end

****************************************************************
*
*  int __fpclassifyd(double x);
*
*  Classify a double value
*
*  Inputs:
*        val - the number to classify 
*
*  Outputs:
*        one of the FP_* classification values
*
****************************************************************
*
__fpclassifyd start

         csubroutine (10:val),0
         
         tdc
         clc
         adc   #val
         ldy   #0
         phy
         pha
         phy
         pha
         phy
         pha
         FX2D
         FCLASSD
         txa
         and   #$00FF
         cmp   #$00FC
         bne   lb1
         inc   a
lb1      sta   val
         
         creturn 2:val
         end

****************************************************************
*
*  int __fpclassifyl(long double x);
*
*  Classify a long double value
*
*  Inputs:
*        val - the number to classify 
*
*  Outputs:
*        one of the FP_* classification values
*
****************************************************************
*
__fpclassifyl start

         csubroutine (10:val),0
         
         tdc
         clc
         adc   #val
         pea   0
         pha
         FCLASSX
         txa
         and   #$00FF
         cmp   #$00FC
         bne   lb1
         inc   a
lb1      sta   val
         
         creturn 2:val
         end
