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
         copy  equates.asm
         end

****************************************************************
*
*  MathCommon2 - common work areas for the math library
*
****************************************************************
*
MathCommon2 privdata
;
;  temporary work space/return value
;
t1       ds    10
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

****************************************************************
*
*  int __signbit(long double x);
*
*  Get the sign bit of a floating-point value
*
*  Inputs:
*        val - the number 
*
*  Outputs:
*        0 if positive, non-zero if negative
*
****************************************************************
*
__signbit start

         csubroutine (10:val),0
         
         lda   val+8
         and   #$8000
         sta   val
         
         creturn 2:val
         end

****************************************************************
*
*  int __fpcompare(long double x, long double y, short mask);
*
*  Compare two floating-point values, not signaling invalid
*  if they are unordered.
*
*  Inputs:
*        x,y - values to compare
*        mask - mask of bits as returned in X register from FCMP
*
*  Outputs:
*        1 if x and y have one of the relations specified by mask
*        0 otherwise
*
****************************************************************
*
__fpcompare start

         csubroutine (10:x,10:y,2:mask),0
         
         tdc
         clc
         adc   #x
         pea   0
         pha
         tdc
         clc
         adc   #y
         pea   0
         pha
         FCMPX
         txa
         and   mask
         beq   lb1
         lda   #1
lb1      sta   mask
         
         creturn 2:mask
         end

****************************************************************
*
*  double cbrt(double x);
*
*  Returns x^(1/3) (the cube root of x).
*
****************************************************************
*
cbrt     start
cbrtf    entry
cbrtl    entry
         using MathCommon2

         phb                            place the number in a work area
         plx                              (except exponent/sign word)
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla                            get exponent/sign word
         phy
         phx
         
         pha                            save original sign
         and   #$7FFF
         sta   t1+8                     force sign to +

         ph4   #onethird                compute abs(x)^(1/3)
         ph4   #t1
         FXPWRY
         
         pla                            if sign of x was -
         bpl   ret
         lda   t1+8
         ora   #$8000
         sta   t1+8                       set sign of result to -
         
ret      plb
         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl

onethird dc    e'0.33333333333333333333'
         end

****************************************************************
*
*  double copysign(double x, double y);
*
*  Returns a value with the magnitude of x and the sign of y.
*
****************************************************************
*
copysign start
copysignf entry
copysignl entry
         using MathCommon2

         phb                            place x in a work area...
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         asl   a                          ...with the sign bit shifted off
         sta   t1+8
         
         pla                            remove y
         pla
         pla
         pla
         pla
         asl   a                        get sign bit of y
         ror   t1+8                     give return value that sign
         
         phy
         phx
         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double exp2(double x);
*
*  Returns 2^x.
*
****************************************************************
*
exp2     start
exp2f    entry
exp2l    entry
         using MathCommon2

         phb                            place the number in a work area
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         sta   t1+8
         phy
         phx
         plb

         ph4   #t1                      compute the value
         FEXP2X
         
         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double expm1(double x);
*
*  Returns e^x - 1.
*
****************************************************************
*
expm1    start
expm1f   entry
expm1l   entry
         using MathCommon2

         phb                            place the number in a work area
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         sta   t1+8
         phy
         phx
         plb

         ph4   #t1                      compute the value
         FEXP1X
         
         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  int ilogb(double x);
*
*  Returns the binary exponent of x (a signed integer value),
*  treating denormalized numbers as if they were normalized.
*  Handles inf/nan/0 cases specially.
*
****************************************************************
*
ilogb    start
ilogbf   entry
ilogbl   entry

         csubroutine (10:x),0

         tdc                            check for special cases
         clc
         adc   #x
         pea   0
         pha
         FCLASSX
         ldy   #$7FFF
         txa
         and   #$FF
         cmp   #$FE                     if x is INF
         beq   special                    return INT_MAX
         lsr   a
         beq   do_logb                  if x is 0 or NAN
         iny                              return INT_MIN
special  sty   x
         bra   ret

do_logb  tdc                            compute logb(x)
         clc
         adc   #x
         pea   0
         pha
         FLOGBX
         
         tdc                            convert to integer
         clc
         adc   #x
         pea   0
         pha
         pea   0
         pha
         FX2I
         
ret      creturn 2:x                    return it
         rtl
         end

****************************************************************
*
*  double log1p(double x);
*
*  Returns ln(1+x).
*
****************************************************************
*
log1p    start
log1pf   entry
log1pl   entry
         using MathCommon2

         phb                            place the number in a work area
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         sta   t1+8
         phy
         phx
         plb

         ph4   #t1                      compute the value
         FLN1X
         
         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double log2(double x);
*
*  Returns log2(x) (the base-2 logarithm of x).
*
****************************************************************
*
log2     start
log2f    entry
log2l    entry
         using MathCommon2

         phb                            place the number in a work area
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         sta   t1+8
         phy
         phx
         plb

         ph4   #t1                      compute the value
         FLOG2X
         
         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double logb(double x);
*
*  Returns the binary exponent of x (a signed integer value),
*  treating denormalized numbers as if they were normalized.
*
****************************************************************
*
logb     start
logbf    entry
logbl    entry
         using MathCommon2

         phb                            place the number in a work area
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         sta   t1+8
         phy
         phx
         plb

         ph4   #t1                      compute the value
         FLOGBX
         
         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  long lrint(double x);
*
*  Rounds x to an integer using current rounding direction
*  and returns it as a long (if representable).
*
****************************************************************
*
lrint    start
lrintf   entry
lrintl   entry

         csubroutine (10:x),0

         tdc                            convert to integer
         clc
         adc   #x
         pea   0
         pha
         pea   0
         pha
         FX2L
         
ret      creturn 4:x                    return it
         rtl
         end

****************************************************************
*
*  float modff(float x, float *iptr);
*
*  Splits x into integer and fractional parts.  Returns the
*  fractional part and stores integer part as a float in *iptr.
*
****************************************************************
*
modff    start
         using MathCommon2
         
         csubroutine (10:x,4:iptr),0

         phb
         phk
         plb

         lda   x                        copy x to t1
         sta   t1
         lda   x+2
         sta   t1+2
         lda   x+4
         sta   t1+4
         lda   x+6
         sta   t1+6
         lda   x+8
         sta   t1+8

         asl   a                        check for infinity or nan
         cmp   #32767|1
         bne   finite
         lda   x+6
         asl   a
         ora   x+4
         ora   x+2
         ora   x
         bne   storeint                 if value is nan, return it as-is
         stz   t1                       if value is +-inf, fractional part is 0
         stz   t1+2
         stz   t1+4
         stz   t1+6
         stz   t1+8
         bra   storeint
         
finite   tdc                            truncate x to an integer
         clc
         adc   #x
         pea   0
         pha
         FTINTX
         
         tdc                            t1 := t1 - x
         clc
         adc   #x
         pea   0
         pha
         ph4   #t1
         FSUBX
         
storeint tdc                            copy x to *iptr, converting to float
         clc
         adc   #x
         pea   0
         pha
         pei   iptr+2
         pei   iptr
         FX2S

copysign asl   t1+8                     copy sign of x to t1
         asl   x+8
         ror   t1+8

         lda   #^t1                     return t1 (fractional part)
         sta   iptr+2
         lda   #t1
         sta   iptr
         plb
         creturn 4:iptr
         end

****************************************************************
*
*  long double modfl(long double x, long double *iptr);
*
*  Splits x into integer and fractional parts.  Returns the
*  fractional part and stores the integer part in *iptr.
*
****************************************************************
*
modfl    start
         using MathCommon2
         
         csubroutine (10:x,4:iptr),0
         
         phb
         phk
         plb
         
         lda   x                        copy x to *iptr and t1
         sta   [iptr]
         sta   t1
         ldy   #2
         lda   x+2
         sta   [iptr],y
         sta   t1+2
         iny
         iny
         lda   x+4
         sta   [iptr],y
         sta   t1+4
         iny
         iny
         lda   x+6
         sta   [iptr],y
         sta   t1+6
         iny
         iny
         lda   x+8
         sta   [iptr],y
         sta   t1+8
         
         asl   a                        check for infinity or nan
         cmp   #32767|1
         bne   finite
         lda   x+6
         asl   a
         ora   x+4
         ora   x+2
         ora   x
         bne   ret                      if value is nan, return it as-is
         stz   t1                       if value is +-inf, fractional part is 0
         stz   t1+2
         stz   t1+4
         stz   t1+6
         stz   t1+8
         bra   copysign

finite   pei   iptr+2                   if value is finite
         pei   iptr
         FTINTX                           truncate *iptr to an integer
         
         pei   iptr+2                     t1 := t1 - *iptr
         pei   iptr
         ph4   #t1
         FSUBX

copysign asl   t1+8                     copy sign of x to t1
         asl   x+8
         ror   t1+8

ret      lda   #^t1                     return t1 (fractional part)
         sta   iptr+2
         lda   #t1
         sta   iptr
         plb
         creturn 4:iptr
         end

****************************************************************
*
*  double remainder(double x, double y);
*
*  Returns x REM y as specified by IEEE 754: r = x - ny,
*  where n is the integer nearest to the exact value of x/y.
*  When x/y is halfway between two integers, n is even.
*  If r = 0, its sign is that of x.
*
****************************************************************
*
remainder start
remainderf entry
remainderl entry
         using MathCommon2

         phb                            place x in a work area
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         sta   t1+8
         phy
         phx
         
         tsc                            compute the value
         clc
         adc   #5
         pea   0
         pha
         ph4   #t1
         FREMX
         
         pla                            move return address
         sta   9,s
         pla
         sta   9,s
         tsc
         clc
         adc   #6
         tcs
         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double remquo(double x, double y, int *quo);
*
*  Returns x REM y as specified by IEEE 754 (like remainder).
*  Also, sets *quo to a value whose sign is the same as x/y
*  and whose magnitude gives the low-order 7 bits of the
*  magnitude of the integer quotient x/y.
*
****************************************************************
*
remquo   start
remquof  entry
remquol  entry
         using MathCommon2

         phb                            place x in a work area
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         sta   t1+8
         phy
         phx
         
         tsc                            compute the value
         clc
         adc   #5
         pea   0
         pha
         ph4   #t1
         FREMX

         phd
         php                            save sign flag
         tsc
         tcd
         txa                            calculate value to store in *quo
         and   #$007F
         plp
         bpl   setquo
         eor   #$FFFF
         inc   a
setquo   sta   [18]                     store it
         pld
         
         pla                            move return address
         sta   13,s
         pla
         sta   13,s
         tsc
         clc
         adc   #10
         tcs
         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double rint(double x);
*
*  Rounds x to an integer using current rounding direction.
*
****************************************************************
*
rint     start
rintf    entry
rintl    entry
         using MathCommon2

         phb                            place the number in a work area
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         sta   t1+8
         phy
         phx
         plb

         ph4   #t1                      compute the value
         FRINTX
         
         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double scalbn(double x, int n);
*
*  Returns x * 2^n.
*
****************************************************************
*
scalbn   start
scalbnf  entry
scalbnl  entry
         using MathCommon2

         phb                            place x in a work area
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         sta   t1+8

         pla                            get n
         phy
         phx

         pha                            compute the value
         ph4   #t1
         FSCALBX

         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double trunc(double x);
*
*  Truncates x to an integer (discarding fractional part).
*
****************************************************************
*
trunc    start
truncf   entry
truncl   entry
         using MathCommon2

         phb                            place the number in a work area
         plx
         ply
         phk
         plb
         pla
         sta   t1
         pla
         sta   t1+2
         pla
         sta   t1+4
         pla
         sta   t1+6
         pla
         sta   t1+8
         phy
         phx
         plb

         ph4   #t1                      compute the value
         FTINTX
         
         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  float and long double versions of functions in SysFloat
*
****************************************************************
*
acosf    start
acosl    entry
         jml   acos
         end

asinf    start
asinl    entry
         jml   asin
         end

atanf    start
atanl    entry
         jml   atan
         end

atan2f   start
atan2l   entry
         jml   atan2
         end

ceilf    start
ceill    entry
         jml   ceil
         end

cosf     start
cosl     entry
         jml   cos
         end

coshf    start
coshl    entry
         jml   cosh
         end

expf     start
expl     entry
         jml   exp
         end

fabsf    start
fabsl    entry
         jml   fabs
         end

floorf   start
floorl   entry
         jml   floor
         end

fmodf    start
fmodl    entry
         jml   fmod
         end

frexpf   start
frexpl   entry
         jml   frexp
         end

ldexpf   start
ldexpl   entry
         jml   ldexp
         end

logf     start
logl     entry
         jml   log
         end

log10f   start
log10l   entry
         jml   log10
         end

powf     start
powl     entry
         jml   pow
         end

sinf     start
sinl     entry
         jml   sin
         end

sinhf    start
sinhl    entry
         jml   sinh
         end

sqrtf    start
sqrtl    entry
         jml   sqrt
         end

tanf     start
tanl     entry
         jml   tan
         end

tanhf    start
tanhl    entry
         jml   tanh
         end
