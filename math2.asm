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

INVALID    gequ $0001                   exceptions
UNDERFLOW  gequ $0002
OVERFLOW   gequ $0004
DIVBYZERO  gequ $0008
INEXACT    gequ $0010

TONEAREST  gequ 0                       rounding directions
UPWARD     gequ 1
DOWNWARD   gequ 2 
TOWARDZERO gequ 3

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
*  double acosh(double x);
*
*  Returns the inverse hyperbolic cosine of x.
*
****************************************************************
*
acosh    start
acoshf   entry
acoshl   entry
         using MathCommon2
         
         csubroutine (10:x),0
         
         phb
         phk
         plb
         
         pha                            save env & set to default
         tsc
         inc   a
         pea   0
         pha
         FPROCENTRY
         
         lda   x                        y = sqrt(x-1)
         sta   y
         lda   x+2
         sta   y+2
         lda   x+4
         sta   y+4
         lda   x+6
         sta   y+6
         lda   x+8
         sta   y+8
         ph4   #one
         ph4   #y
         FSUBI
         ph4   #y
         FSQRTX

         lda   x                        t1 = sqrt(x+1)
         sta   t1
         lda   x+2
         sta   t1+2
         lda   x+4
         sta   t1+4
         lda   x+6
         sta   t1+6
         lda   x+8
         sta   t1+8
         ph4   #one
         ph4   #t1
         FADDI
         ph4   #t1
         FSQRTX

         ph4   #y                       t1 = ln(1+y*(y+t1))
         ph4   #t1
         FADDX
         ph4   #y
         ph4   #t1
         FMULX
         ph4   #t1
         FLN1X
         
         lda   t1+8                     if t1 = +inf
         cmp   #32767
         bne   ret
         lda   t1+6
         asl   a
         ora   t1+4
         ora   t1+2
         ora   t1
         bne   ret
         
         pea   0                          clear exceptions
         FSETENV
         lda   x                          t1 = ln(x) + ln(2)
         sta   t1
         lda   x+2
         sta   t1+2
         lda   x+4
         sta   t1+4
         lda   x+6
         sta   t1+6
         lda   x+8
         sta   t1+8
         ph4   #t1
         FLNX
         ph4   #ln2
         ph4   #t1
         FADDX

ret      FPROCEXIT                      restore env & raise any new exceptions
         plb
         lda   #t1                      return t1
         sta   x
         lda   #^t1
         sta   x+2
         creturn 4:x

y        ds    10                       temporary variable
one      dc    i'1'                     constants
ln2      dc    e'0.69314718055994530942'
         end

****************************************************************
*
*  double asinh(double x);
*
*  Returns the inverse hyperbolic sine of x.
*
****************************************************************
*
asinh    start
asinhf   entry
asinhl   entry
         using MathCommon2
         
         csubroutine (10:x),0
         
         phb
         phk
         plb
         
         pha                            save env & set to default
         tsc
         inc   a
         pea   0
         pha
         FPROCENTRY

         pei   x+8                      save sign of x
         asl   x+8                      x = abs(x)
         lsr   x+8
         
         lda   x                        t1 = y = z = x
         sta   y
         sta   z
         sta   t1
         lda   x+2
         sta   y+2
         sta   z+2
         sta   t1+2
         lda   x+4
         sta   y+4
         sta   z+4
         sta   t1+4
         lda   x+6
         sta   y+6
         sta   z+6
         sta   t1+6
         lda   x+8
         sta   y+8
         sta   z+8
         sta   t1+8

         lda   x                        if value is zero (or typical inf)
         ora   x+2
         ora   x+4
         ora   x+6
         beq   skipcalc                   return the input value

         lda   x+8                      else if x is very small
         cmp   #-33+16383
         bge   calc
         pea   INEXACT                    raise "inexact" exception
         FSETXCP
skipcalc brl   setsign                    return the input value

calc     cmp   #16383/2+16383           else if x is very large (or nan)
         blt   notbig
         ph4   #z                         z = ln(x) + ln(2)
         FLNX
         ph4   #ln2
         ph4   #z
         FADDX
         brl   setsign                  else
         
notbig   pea   -2                         t1 = 1 / (t1 * t1)
         ph4   #t1
         FXPWRI
         
         ph4   #one                       t1 = 1 + t1
         ph4   #t1
         FADDI

         ph4   #t1                        t1 = sqrt(t1)
         FSQRTX

         pea   -1                         y = 1 / y
         ph4   #y
         FXPWRI

         ph4   #y                         t1 = t1 + y
         ph4   #t1
         FADDX

         ph4   #t1                        z = z / t1
         ph4   #z
         FDIVX

         tdc                              z = z + x
         clc
         adc   #x
         pea   0
         pha
         ph4   #z
         FADDX

         ph4   #z                         z = ln(1+z)
         FLN1X
         
setsign  asl   z+8                      sign of z = original sign of x
         pla
         asl   a
         ror   z+8

         FPROCEXIT                      restore env & raise any new exceptions
         plb
         lda   #z                       return z
         sta   x
         lda   #^z
         sta   x+2
         creturn 4:x

y        ds    10                       temporary variables
z        ds    10
one      dc    i'1'                     constants
ln2      dc    e'0.69314718055994530942'
         end

****************************************************************
*
*  double atanh(double x);
*
*  Returns the inverse hyperbolic tangent of x.
*
****************************************************************
*
atanh    start
atanhf   entry
atanhl   entry
         using MathCommon2
         
         csubroutine (10:x),0
         
         phb
         phk
         plb
         
         pha                            save env & set to default
         tsc
         inc   a
         pea   0
         pha
         FPROCENTRY

         pei   x+8                      save sign of x
         asl   x+8                      x = abs(x)
         lsr   x+8
         
         lda   x                        t1 = x
         sta   t1
         lda   x+2
         sta   t1+2
         lda   x+4
         sta   t1+4
         lda   x+6
         sta   t1+6
         lda   x+8
         sta   t1+8

         lda   x+8                      if x is very small
         cmp   #-33+16383
         bge   calc
         lda   x                          if value is not zero
         ora   x+2
         ora   x+4
         ora   x+6
         beq   skipcalc
         pea   INEXACT                      raise "inexact" exception
         FSETXCP
skipcalc bra   setsign                    skip next steps (return input value)

calc     ph4   #one                     x = x - 1
         tdc
         clc
         adc   #x
         pea   0
         pha
         FSUBI
         
         tdc                            t1 = t1 / x
         clc
         adc   #x
         pea   0
         pha
         ph4   #t1
         FDIVX
         
         lda   t1+8                     if t1 is inf/nan
         asl   a
         cmp   #32767*2
         beq   setsign                    skip next steps (so atanh(1) = +inf)
         
         ph4   #minustwo                t1 = t1 * -2
         ph4   #t1
         FMULI
         
         ph4   #t1                      t1 = ln(1+t1)
         FLN1X
         
         ph4   #minustwo                t1 = t1 / -2
         ph4   #t1
         FDIVI
         
setsign  asl   t1+8                     sign of t1 = original sign of x
         pla
         asl   a
         ror   t1+8

         FPROCEXIT                      restore env & raise any new exceptions
         plb
         lda   #t1                      return t1
         sta   x
         lda   #^t1
         sta   x+2
         creturn 4:x

one      dc    i'1'                     constants
minustwo dc    i'-2'
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
scale    equ   1
         
         csubroutine (10:x),2
         
         phb
         phk
         plb

         stz   scale                    scale by 0 by default (for inf/nan)

         lda   x+8
         pha                            save original sign
         and   #$7FFF
         sta   x+8                      force sign to +
         cmp   #32767                   skip scaling for inf/nan
         beq   do_calc
         
         ldx   x+6                      if number is denormalized
         bmi   div_exp
         bne   normaliz
         ldx   x+4
         bne   normaliz
         ldx   x+2
         bne   normaliz
         ldx   x
         beq   div_exp

normaliz dec   a                          normalize it and adjust exponent
         asl   x
         rol   x+2
         rol   x+4
         rol   x+6
         bpl   normaliz
         
div_exp  pha                            calculate exponent/3
         pha
         pha
         pea   3
         _SDivide
         pla                            a = quotient
         plx                            x = remainder
         cpx   #2                       adjust remainder of 2 to -1
         bne   setscale
         ldx   #-1
         inc   a
         
setscale sec                            calculate amount to scale result by
         sbc   #16383/3
         sta   scale
         txa                            use remainder as exponent for calc.
         clc
         adc   #16383
do_calc  sta   t1+8

         lda   x                        place mantissa in work area
         sta   t1
         lda   x+2
         sta   t1+2
         lda   x+4
         sta   t1+4
         lda   x+6
         sta   t1+6

         ph4   #onethird                compute val^(1/3)
         ph4   #t1
         FXPWRY
         
         clc                            apply scaling
         lda   t1+8
         adc   scale
         sta   t1+8
         
         asl   t1+8                     set sign of result to orig. sign of x
         pla
         asl   a
         ror   t1+8

         plb
         lda   #t1                      return t1
         sta   x
         lda   #^t1
         sta   x+2
         creturn 4:x

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
*  double erf(double x);
*
*  Returns the error function of x.
*
*  double erfc(double x);
*
*  Returns the complementary error function of x, 1 - erf(x).
*
*  This implementation is based on W. J. Cody's article 
*  "Rational Chebyshev Approximations for the Error Function."
*
****************************************************************
*
erf      start
erff     entry
erfl     entry
         using MathCommon2
x_offset equ   9                        stack offset of x (in most of the code)

         clc
         bra   lb1

erfc     entry
erfcf    entry
erfcl    entry

         sec

lb1      phb                            save & set data bank
         phk
         plb

         pha                            make space for saved SANE environment
         
         lda   x_offset-2+8,s
         ror   a                        save erf/erfc flag (high bit)
         pha                              and original sign (next bit)

         rol   a                        t1 := |x|
         rol   a
         lsr   a
         sta   t1+8
         lda   x_offset+6,s
         sta   t1+6
         lda   x_offset+4,s
         sta   t1+4
         lda   x_offset+2,s
         sta   t1+2
         lda   x_offset,s
         sta   t1

         tsc                            save env & set to default
         clc
         adc   #3
         pea   0
         pha
         FPROCENTRY
;
; Computation using approximation of erf, for small enough x values
;
         ph4   #threshold               if |x| <= 0.5 then
         ph4   #t1
         FCMPS
         jmi   use_erfc
         
         ph4   #t1                        t1 := x^2
         ph4   #t1
         FMULX

         ph4   #y                         y := P1(t1)
         pea   4
         ph4   #P1
         jsl   poly

         ph4   #z                         z := Q1(t1)
         pea   4
         ph4   #Q1
         jsl   poly

         ph4   #z                         y := y/z
         ph4   #y
         FDIVX

         tsc                              y := x * y
         clc
         adc   #x_offset
         pea   0
         pha
         ph4   #y
         FMULX

         pla
         jpl   clearxcp                   if computing erfc then
         
         ph4   #one                         y := y - 1
         ph4   #y
         FSUBX
         brl   flipsign                     y := -y
;
; Computation using approximations of erfc, for larger x values
;
use_erfc ph4   #four                    else
         ph4   #t1
         FCMPI
         jmi   big_erfc                   if |x| <= 4 then

         ph4   #y                           y := P2(t1)
         pea   8
         ph4   #P2
         jsl   poly

         ph4   #z                           z := Q2(t1)
         pea   8
         ph4   #Q2
         jsl   poly

         ph4   #z                           y := y/z
         ph4   #y
         FDIVX

         ph4   #t1                          t1 := e^(-x^2)
         ph4   #t1
         FMULX
         lda   t1+8
         eor   #$8000
         sta   t1+8
         ph4   #t1
         FEXPX
         
         ph4   #t1                          y := t1 * y
         ph4   #y
         FMULX
         
         brl   end_erfc                   else (if |x| > 4 or NAN)

big_erfc pea   -2                           t1 := 1 / x^2
         ph4   #t1
         FXPWRI

         ph4   #y                           y := P3(t1)
         pea   5
         ph4   #P3
         jsl   poly

         ph4   #z                           z := Q3(t1)
         pea   5
         ph4   #Q3
         jsl   poly

         ph4   #z                           y := y/z
         ph4   #y
         FDIVX
         
         ph4   #t1                          y := t1 * y
         ph4   #y
         FMULX
         
         ph4   #one_over_sqrt_pi            y := 1/sqrt(pi) + y
         ph4   #y
         FADDX
         
         lda   x_offset+8,s                 y := y / |x|
         and   #$7fff
         sta   x_offset+8,s
         tsc
         clc
         adc   #x_offset
         ldx   #0
         phx                                (push operands of below calls)
         pha
         phx
         pha
         phx
         pha
         phx
         pha
         phx
         pha
         ph4   #y
         FDIVX

         FMULX                              y := e^(-x^2) * y
         lda   x_offset+8+8,s
         eor   #$8000
         sta   x_offset+8+8,s
         FEXPX       
         ph4   #y
         FMULX

end_erfc pla
         bpl   erf_from_erfc              if computing erfc then

         ldx   #$1300                       (set allowed exception mask)
         asl   a
         bpl   rstr_env                     if x < 0
         
         ph4   #two                           y := y - 2
         ph4   #y
         FSUBI
         bra  flipsign                        y :=  -y
         
erf_from_erfc anop
         pha
         ph4   #one                       if computing erf then
         ph4   #y
         FSUBX                              y := y - 1
         
         pla
         asl   a
         bmi   clearxcp                     if x > 0 then

flipsign lda   y+8                            y := -y
         eor   #$8000
         sta   y+8

clearxcp ldx   #$1100                   ignore overflow, div-by-zero
rstr_env stx   z                        (& underflow unless doing erfc for x>.5)
         FGETENV
         txa
         and   z
         ora   1,s
         sta   1,s
         FSETENV                        unless computing erfc for x > 4

         pla                            clean up stack
         sta   9,s
         pla
         sta   9,s
         tsc
         clc
         adc   #6
         tcs
         plb
         ldx   #^y                      return a pointer to the result
         lda   #y
         rtl

threshold dc   f'0.5'                   threshold for computing erf or erfc

; constants
two      dc    i2'2'
four     dc    i2'4'
one_over_sqrt_pi dc e'0.564189583547756286924'
; coefficients for erf calculation, |x| <= .5
P1       dc    e'1.857777061846031526730e-1'
         dc    e'3.161123743870565596947e+0'
         dc    e'1.138641541510501556495e+2'
         dc    e'3.774852376853020208137e+2'
         dc    e'3.209377589138469472562e+3'
one      anop
Q1       dc    e'1.0'
         dc    e'2.360129095234412093499e+1'
         dc    e'2.440246379344441733056e+2'
         dc    e'1.282616526077372275645e+3'
         dc    e'2.844236833439170622273e+3'
; coefficients for erfc calculation, .46875 <= x <= 4
P2       dc    e'2.15311535474403846343e-8'
         dc    e'5.64188496988670089180e-1'
         dc    e'8.88314979438837594118e+0'
         dc    e'6.61191906371416294775e+1'
         dc    e'2.98635138197400131132e+2'
         dc    e'8.81952221241769090411e+2'
         dc    e'1.71204761263407058314e+3'
         dc    e'2.05107837782607146532e+3'
         dc    e'1.23033935479799725272e+3'
Q2       dc    e'1.0'
         dc    e'1.57449261107098347253e+1'
         dc    e'1.17693950891312499305e+2'
         dc    e'5.37181101862009857509e+2'
         dc    e'1.62138957456669018874e+3'
         dc    e'3.29079923573345962678e+3'
         dc    e'4.36261909014324715820e+3'
         dc    e'3.43936767414372163696e+3'
         dc    e'1.23033935480374942043e+3'
; coefficients for erfc calculation, x >= 4
P3       dc    e'-1.63153871373020978498e-2'
         dc    e'-3.05326634961232344035e-1'
         dc    e'-3.60344899949804439429e-1'
         dc    e'-1.25781726111229246204e-1'
         dc    e'-1.60837851487422766278e-2'
         dc    e'-6.58749161529837803157e-4'
Q3       dc    e'1.0'
         dc    e'2.56852019228982242072e+0'
         dc    e'1.87295284992346047209e+0'
         dc    e'5.27905102951428412248e-1'
         dc    e'6.05183413124413191178e-2'
         dc    e'2.33520497626869185443e-3'
;                                        temporaries / return values
y        ds    10
z        ds    10
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
*  double fdim(double x, double y);
*
*  Returns x - y if x > y, or +0 if x <= y.
*
****************************************************************
*
fdim     start
fdimf    entry
fdiml    entry
         using MathCommon2

         phb
         phk
         plb

         tsc                            compare x and y
         clc
         adc   #5
         pea   0
         pha
         adc   #10
         pea   0
         pha
         FCMPX
         bmi   x_le_y
         beq   x_le_y
         
         tsc                            if x > y (or unordered)
         clc
         adc   #5+10
         pea   0
         pha
         sbc   #10-1                      (carry is clear)
         pea   0
         pha
         FSUBX                            x = x - y
         lda   5,s                        t1 = x
         sta   t1
         lda   5+2,s
         sta   t1+2
         lda   5+4,s
         sta   t1+4
         lda   5+6,s
         sta   t1+6
         lda   5+8,s
         sta   t1+8
         bra   ret                      else

x_le_y   stz   t1                         t1 = +0.0
         stz   t1+2
         stz   t1+4
         stz   t1+6
         stz   t1+8

ret      plx                            clean up stack
         ply
         tsc
         clc
         adc   #20
         tcs
         phy
         phx
         plb
         
         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double fmax(double x, double y);
*
*  Returns the maximum numeric value of x or y.
*  If one is a NaN, returns the other.
*
****************************************************************
*
fmax     start
fmaxf    entry
fmaxl    entry
         using MathCommon2

         phb
         phk
         plb
         phd
         
         tsc                            set up direct page
         clc
         adc   #7
         tcd
         
         pea   0                        compare x and y
         pha
         clc
         adc   #10
         pea   0
         pha
         FCMPX

         bmi   use_y                    if x < y, return y
         bvs   use_x                    if x >= y, return x
         beq   use_x

         pea   0                        if x,y are unordered
         phd
         FCLASSX
         txa
         and   #$00FE
         cmp   #$00FC                     if x is not a nan, return x
         beq   use_y                      else return y

use_x    ldx   #0
         bra   copyit

use_y    ldx   #10

copyit   lda   0,x                      copy result to t1
         sta   t1
         lda   2,x
         sta   t1+2
         lda   4,x
         sta   t1+4
         lda   6,x
         sta   t1+6
         lda   8,x
         sta   t1+8
         
         pld                            clean up stack
         plx
         ply
         tsc
         clc
         adc   #20
         tcs
         phy
         phx
         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double fmin(double x, double y);
*
*  Returns the minimum numeric value of x or y.
*  If one is a NaN, returns the other.
*
****************************************************************
*
fmin     start
fminf    entry
fminl    entry
         using MathCommon2

         phb
         phk
         plb
         phd
         
         tsc                            set up direct page
         clc
         adc   #7
         tcd
         
         pea   0                        compare x and y
         pha
         clc
         adc   #10
         pea   0
         pha
         FCMPX

         bmi   use_x                    if x < y, return x
         bvs   use_y                    if x >= y, return y
         beq   use_y

         pea   0                        if x,y are unordered
         phd
         FCLASSX
         txa
         and   #$00FE
         cmp   #$00FC                     if x is not a nan, return x
         beq   use_y                      else return y

use_x    ldx   #0
         bra   copyit

use_y    ldx   #10

copyit   lda   0,x                      copy result to t1
         sta   t1
         lda   2,x
         sta   t1+2
         lda   4,x
         sta   t1+4
         lda   6,x
         sta   t1+6
         lda   8,x
         sta   t1+8
         
         pld                            clean up stack
         plx
         ply
         tsc
         clc
         adc   #20
         tcs
         phy
         phx
         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double hypot(double x, double y);
*
*  Returns the square root of x^2 + y^2, without undue overflow
*  or underflow.
*
****************************************************************
*
hypot    start
hypotf   entry
hypotl   entry
         using MathCommon2
scale    equ   1                        scaling factor

         csubroutine (10:x,10:y),2
         
         phb
         phk
         plb

         pha                            save env & set to default
         tsc
         inc   a
         pea   0
         pha
         FPROCENTRY
         
         stz   scale                    no scaling by default
         
         asl   x+8                      x = abs(x)
         lsr   x+8
         asl   y+8                      y = abs(y)
         lsr   y+8
         
         tdc                            if x < y
         clc
         adc   #x
         pea   0
         pha
         adc   #y-x
         pea   0
         pha
         FCMPX
         bpl   sorted
         
         ldx   #8                         exchange x and y
xchgloop lda   x,x
         ldy   y,x
         sta   y,x
         sty   x,x
         dex
         dex
         bpl   xchgloop
sorted   anop                           at this point, 0 <= y <= x (if ordered)

         lda   x+8                      if x or y is nan or inf
         ldy   y+8
         cpy   #32767
         beq   naninf
         cmp   #32767
         beq   naninf                     skip exponent manipulation

         cmp   #8190+16383+1            if exponent of x > 8190
         blt   chksmall
         sec                              scale x and y down by 2^8300
         sbc   #8300
         sta   x+8
         lda   #8300
         sta   scale
         lda   y+8
         sec
         sbc   #8300
         sta   y+8
         bpl   compute
         stz   y                          (zero out y if needed)
         stz   y+2
         stz   y+4
         stz   y+6
         stz   y+8
         bra   compute
         
chksmall cmp   #-8100+16383             else if exponent of x < -8100
         bge   compute
         clc                              scale x and y up by 2^8300
         adc   #8300
         sta   x+8
         lda   y+8
         clc
         adc   #8300
         sta   y+8
         lda   #-8300
         sta   scale

compute  tdc                            x = x*x
         clc
         adc   #x
         pea   0
         pha
         pea   0
         pha
         FMULX

         tdc                            y = y*y
         clc
         adc   #y
         pea   0
         pha
         pea   0
         pha
         FMULX

naninf   anop                           (we skip to here if x or y is nan/inf)
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
         
         tdc                            t1 = x*x + y*y
         clc
         adc   #y
         pea   0
         pha
         ph4   #t1
         FADDX
         
         ph4   #t1                      t1 = sqrt(t1)
         FSQRTX

         lda   scale                    if scaling is needed
         beq   done
         pha                              do it
         ph4   #t1
         FSCALBX

done     FPROCEXIT                      restore env
         lda   #^t1                     return t1
         sta   x+2
         lda   #t1
         sta   x
         plb
         creturn 4:x
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
*  long long llrint(double x);
*
*  Rounds x to an integer using current rounding direction
*  and returns it as a long long (if representable).
*
*  Note: This avoids calling FX2C on negative numbers,
*  because it is buggy for certain values.
*
****************************************************************
*
llrint   start
llrintf  entry
llrintl  entry
retptr   equ   1

         csubroutine (10:x),4
         stx   retptr
         stz   retptr+2
         
         tdc
         clc
         adc   #x
         pea   0                        push src address for fcpxx
         pha
         pea   llmin|-16                push dst address for fcpxx
         pea   llmin
         pea   0                        push operand address for frintx
         pha
         FRINTX                         round
         FCPXX                          compare with LLONG_MIN
         bne   convert
         
         lda   #$8000                   if it is LLONG_MIN, use that value
         ldy   #6
         sta   [retptr],y
         asl   a
         dey
         dey
         sta   [retptr],y
         dey
         dey
         sta   [retptr],y
         sta   [retptr]
         bra   done                     otherwise

convert  pei   x+8                        save sign of x
         asl   x+8                        x = abs(x)
         lsr   x+8
         tdc
         clc
         adc   #x
         pea   0                          push src address for fx2c
         pha
         pei   retptr+2                   push dst address for fx2c
         pei   retptr
         FX2C                             convert x
         
         pla                              if x was negative
         bpl   done
         sec
         lda   #0                           negate result
         sbc   [retptr]
         sta   [retptr]
         ldy   #2
         lda   #0
         sbc   [retptr],y
         sta   [retptr],y
         iny
         iny
         lda   #0
         sbc   [retptr],y
         sta   [retptr],y
         iny
         iny
         lda   #0
         sbc   [retptr],y
         sta   [retptr],y

done     creturn

llmin    dc    e'-9223372036854775808'
         end

****************************************************************
*
*  long long llround(double x);
*
*  Rounds x to the nearest integer, rounding halfway cases away
*  from 0, and returns it as a long long (if representable).
*
*  Note: This avoids calling FX2C on negative numbers,
*  because it is buggy for certain values.
*
****************************************************************
*
llround  start
llroundf entry
llroundl entry
retptr   equ   1

         csubroutine (10:x),4
         stx   retptr
         stz   retptr+2

         pha                            save env & set to default
         tsc
         inc   a
         pea   0
         pha
         FPROCENTRY

         tdc                            if x == LLONG_MIN
         clc
         adc   #x
         pea   0
         pha
         ph4   #llmin
         FCMPX
         beq   retllmin                   return LLONG_MIN
         tdc                            else if x == LLONG_MIN+0.5
         clc
         adc   #x
         pea   0
         pha
         ph4   #llminp05
         FCPXX
         bne   convert
         
         pea   INEXACT                    raise "inexact" exception
         FSETXCP
retllmin lda   #$8000                     return LLONG_MIN
         ldy   #6
         sta   [retptr],y
         asl   a
         dey
         dey
         sta   [retptr],y
         dey
         dey
         sta   [retptr],y
         sta   [retptr]
         brl   ret                      else

convert  pei   x+8                        save sign of x
         asl   x+8                        x = abs(x)
         lsr   x+8

         tdc                              round to integer
         clc
         adc   #x
         pea   0
         pha
         pei   retptr+2
         pei   retptr
         FX2C

         pea   INEXACT
         FTESTXCP                         if there was no inexact exception
         beq   chk_neg                      we're done: x was an integer/nan/inf
         
         FGETENV                          else
         txa
         ora   #TOWARDZERO*$4000            round toward zero
         pha
         FSETENV

         ph4   #onehalf                     x = x + 0.5 (rounded toward 0)
         tdc
         clc
         adc   #x
         pea   0
         pha
         FADDS
         tdc                                round to integer
         clc
         adc   #x
         pea   0
         pha
         pei   retptr+2
         pei   retptr
         FX2C

chk_neg  pla                              if x was negative
         bpl   ret
         sec
         lda   #0                           negate result
         sbc   [retptr]
         sta   [retptr]
         ldy   #2
         lda   #0
         sbc   [retptr],y
         sta   [retptr],y
         iny
         iny
         lda   #0
         sbc   [retptr],y
         sta   [retptr],y
         iny
         iny
         lda   #0
         sbc   [retptr],y
         sta   [retptr],y

ret      FPROCEXIT                      restore env & raise any new exceptions
         creturn

llmin    dc    e'-9223372036854775808'
llminp05 dc    e'-9223372036854775807.5'
onehalf  dc    f'0.5'
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
*  Note: This avoids calling FX2L or FX2C on negative numbers,
*  because they are buggy for certain values.
*
****************************************************************
*
lrint    start
lrintf   entry
lrintl   entry

         csubroutine (10:x),0

         pei   x+8                      save sign of x

         tdc
         clc
         adc   #x
         pea   0
         pha
         pea   0
         pha
         pea   0
         pha
         FRINTX                         round x to integer
         asl   x+8                      x = abs(x)
         lsr   x+8
         FX2C                           convert to comp

         lda   x+4                      if x is out of range of long
         ora   x+6
         bne   flag_inv
         cmpl  x,#$80000000
         blt   chk_neg
         bne   flag_inv
         lda   1,s
         bmi   chk_neg
flag_inv pea   INVALID                    raise "invalid" exception
         FSETXCP

chk_neg  pla                            if x was negative
         bpl   ret
         sub4  #0,x,x                     negate result
         
ret      creturn 4:x                    return it
         rtl
         end

****************************************************************
*
*  long lround(double x);
*
*  Rounds x to the nearest integer, rounding halfway cases
*  away from 0, and returns it as a long (if representable).
*
*  Note: This avoids calling FX2L or FX2C on negative numbers,
*  because they are buggy for certain values.
*
****************************************************************
*
lround   start
lroundf  entry
lroundl  entry
result   equ   1                        result value

         csubroutine (10:x),8

         pha                            save env & set to default
         tsc
         inc   a
         pea   0
         pha
         FPROCENTRY

         pei   x+8                      save sign of x
         asl   x+8                      x = abs(x)
         lsr   x+8

         tdc                            round to integer with default rounding
         clc
         adc   #x
         pea   0
         pha
         adc   #result-x
         pea   0
         pha
         FX2C

         pea   INEXACT
         FTESTXCP                       if there was no inexact exception
         beq   chkrange                   we are done: x was an integer/nan/inf
         
         FGETENV
         txa
         ora   #TOWARDZERO*$4000        set rounding direction to "toward zero"
         pha
         FSETENV

         ph4   #onehalf                 x = x + 0.5 (rounded toward 0)
         tdc
         clc
         adc   #x
         pea   0
         pha
         FADDS
         tdc                            round to integer
         clc
         adc   #x
         pea   0
         pha
         adc   #result-x
         pea   0
         pha
         FX2C
         
chkrange lda   result+4                 if x is out of range of long
         ora   result+6
         bne   flag_inv
         cmpl  result,#$80000000
         blt   chk_neg
         bne   flag_inv
         lda   1,s
         bmi   chk_neg
flag_inv pea   INVALID                    raise "invalid" exception
         FSETXCP

chk_neg  pla                            if x was negative
         bpl   ret
         sub4  #0,result,result           negate result
         
ret      FPROCEXIT                      restore env & raise any new exceptions
         creturn 4:result               return the result

onehalf  dc    f'0.5'
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
*  double nan(const char *tagp);
*
*  Returns a quiet NaN, with NaN code determined by the
*  argument string.
*
****************************************************************
*
nan      start
nanf     entry
nanl     entry
         using MathCommon2
         
         csubroutine (4:tagp)
         
         phb
         phk
         plb
         
         stz   t1+6                     initial code is 0
         
loop     lda   [tagp]                   do
         and   #$00FF                     get next character
         beq   loopdone                   if end of string, break
         cmp   #'0'
         blt   no_code
         cmp   #'9'+1
         bge   no_code                    if not a digit, treat as no code
         and   #$000F
         asl   t1+6                       code = code*10 + digit
         clc
         adc   t1+6
         asl   t1+6
         asl   t1+6
         clc
         adc   t1+6
         sta   t1+6
         inc4  tagp                       tagp++
         bra   loop                     while true
         
no_code  stz   t1+6                     if no code specified, default to 0

loopdone lda   t1+6
         and   #$00FF                   use low 8 bits as NaN code
         bne   codeok                   if code is 0
         lda   #21                        use NANZERO
codeok   ora   #$4000                   set high bit of f for quiet NaN
         sta   t1+6
         
         lda   #32767                   e=32767 for NaN
         sta   t1+8
         stz   t1+4                     set rest of fraction field to 0
         stz   t1+2
         stz   t1
         
         lda   #^t1                     return a pointer to the result
         sta   tagp+2
         lda   #t1
         sta   tagp
         plb
         creturn 4:tagp
         end

****************************************************************
*
*  double nearbyint(double x);
*
*  Rounds x to an integer using current rounding direction,
*  never raising the "inexact" exception.
*
****************************************************************
*
nearbyint start
nearbyintf entry
nearbyintl entry
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

         FGETENV                        save environment
         phx
         ph4   #t1                      compute the value
         FRINTX
         FSETENV                        restore environment
         
         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double nextafter(double x, double y);
*
*  Returns next representable value (in double format)
*  after x in the direction of y.  Returns y if x equals y. 
*
****************************************************************
*
nextafter start
         using MathCommon2

         tsc                            x = (double) x
         clc
         adc   #4
         pea   0
         pha
         pea   0
         pha
         FX2D
         lda   4,s                      save low bits of x
         sta   4+8,s

         tsc                            y = (double) y
         clc
         adc   #4+10
         pea   0
         pha
         pea   0
         pha
         FX2D
         
         tsc                            push address of y
         clc
         adc   #4+10
         pea   0
         pha
         sbc   #10-1                    push address of x
         pea   0
         pha
         FNEXTD                         x = nextafter x toward y

         tsc                            store x (as extended) in t1
         clc
         adc   #4
         pea   0
         pha
         ph4   #t1
         FD2X

         phb
         lda   4+8+1,s                  if original x might be 0 then
         bne   ret
         tsc
         clc
         adc   #4+10+1
         pea   0
         pha
         ph4   #t1
         FCPXD
         bne   ret                        if t1 == y then
         phk
         plb
         asl   t1+8                         sign of t1 = sign of y
         lda   4+10+1+6,s
         asl   a
         ror   t1+8
         
ret      plx                            move return address
         ply
         tsc
         clc
         adc   #20
         tcs
         phy
         phx
         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  float nextafterf(float x, float y);
*
*  Returns next representable value (in float format)
*  after x in the direction of y.  Returns y if x equals y. 
*
****************************************************************
*
nextafterf start
         using MathCommon2

         tsc                            x = (float) x
         clc
         adc   #4
         pea   0
         pha
         pea   0
         pha
         FX2S
         lda   4,s                      save low bits of x
         sta   4+8,s

         tsc                            y = (float) y
         clc
         adc   #4+10
         pea   0
         pha
         pea   0
         pha
         FX2S
         
         tsc                            push address of y
         clc
         adc   #4+10
         pea   0
         pha
         sbc   #10-1                    push address of x
         pea   0
         pha
         FNEXTS                         x = nextafter x toward y

         tsc                            store x (as extended) in t1
         clc
         adc   #4
         pea   0
         pha
         ph4   #t1
         FS2X

         phb
         lda   4+8+1,s                  if original x might be 0 then
         bne   ret
         tsc
         clc
         adc   #4+10+1
         pea   0
         pha
         ph4   #t1
         FCPXS
         bne   ret                        if t1 == y then
         phk
         plb
         asl   t1+8                         sign of t1 = sign of y
         lda   4+10+1+2,s
         asl   a
         ror   t1+8
         
ret      plx                            move return address
         ply
         tsc
         clc
         adc   #20
         tcs
         phy
         phx
         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  long double nextafterl(long double x, long double y);
*  long double nexttowardl(long double x, long double y);
*
*  Returns next representable value (in extended format)
*  after x in the direction of y.  Returns y if x equals y. 
*
****************************************************************
*
nextafterl start
nexttowardl entry
         using MathCommon2

         tsc                            push address of x
         clc
         adc   #4
         pea   0
         pha
         adc   #10                      push address of y
         pea   0
         pha
         FCPXX
         bne   getnext                  if x == y then
         tsc
         clc
         adc   #4+10                      return y
         bra   storeval                 else
         
getnext  tsc                              push address of y
         clc
         adc   #4+10
         pea   0
         pha
         sbc   #10-1                      push address of x
         pea   0
         pha
         FNEXTX                           x = nextafter x toward y

         tsc                              return x
         clc
         adc   #4
storeval pea   0                        store return value to t1
         pha
         ph4   #t1
         FX2X

         phb                            move return address
         plx
         ply
         tsc
         clc
         adc   #20
         tcs
         phy
         phx
         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl
         end

****************************************************************
*
*  double nexttoward(double x, long double y);
*
*  Returns next representable value (in double format)
*  after x in the direction of y.  Returns y if x equals y. 
*
****************************************************************
*
nexttoward start
         using MathCommon2

         tsc                            x = (double) x
         clc
         adc   #4
         pea   0
         pha
         pea   0
         pha
         FX2D

         tsc                            push address of x
         clc
         adc   #4
         pea   0
         pha
         adc   #10                      push address of y
         pea   0
         pha
         FCPXD                          compare x and y
         
         bvs   x_gt_y
         bmi   x_lt_y
         beq   x_eq_y
         
         tsc                            x,y unordered case: do nextafter(x,y)
         clc
         adc   #4+10
         pea   0
         pha
         pea   0
         pha
         pea   0
         pha
         FX2D
         bra   getnext

x_gt_y   ph4   #minusinf                x > y case: do nextafter(x,-inf)
         bra   getnext

x_lt_y   ph4   #plusinf                 x < y case: do nextafter(x,+inf)
         bra   getnext

x_eq_y   phb
         phk
         plb
         lda   4+10+1,s                 x == y case: return y
         sta   t1
         lda   4+10+1+2,s
         sta   t1+2
         lda   4+10+1+4,s
         sta   t1+4
         lda   4+10+1+6,s
         sta   t1+6
         lda   4+10+1+8,s
         sta   t1+8
         bra   ret

getnext  tsc                            compute nextafter(x,...)
         clc
         adc   #4+4
         pea   0
         pha
         FNEXTD

         tsc                            store x (as extended) in t1
         clc
         adc   #4
         pea   0
         pha
         ph4   #t1
         FD2X

         phb                            move return address
ret      plx
         ply
         tsc
         clc
         adc   #20
         tcs
         phy
         phx
         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl

plusinf  dc    d'+inf'
minusinf dc    d'-inf'
         end

****************************************************************
*
*  float nexttowardf(float x, long double y);
*
*  Returns next representable value (in float format)
*  after x in the direction of y.  Returns y if x equals y. 
*
****************************************************************
*
nexttowardf start
         using MathCommon2

         tsc                            x = (double) x
         clc
         adc   #4
         pea   0
         pha
         pea   0
         pha
         FX2S

         tsc                            push address of x
         clc
         adc   #4
         pea   0
         pha
         adc   #10                      push address of y
         pea   0
         pha
         FCPXS                          compare x and y
         
         bvs   x_gt_y
         bmi   x_lt_y
         beq   x_eq_y
         
         tsc                            x,y unordered case: do nextafter(x,y)
         clc
         adc   #4+10
         pea   0
         pha
         pea   0
         pha
         pea   0
         pha
         FX2S
         bra   getnext

x_gt_y   ph4   #minusinf                x > y case: do nextafter(x,-inf)
         bra   getnext

x_lt_y   ph4   #plusinf                 x < y case: do nextafter(x,+inf)
         bra   getnext

x_eq_y   phb
         phk
         plb
         lda   4+10+1,s                 x == y case: return y
         sta   t1
         lda   4+10+1+2,s
         sta   t1+2
         lda   4+10+1+4,s
         sta   t1+4
         lda   4+10+1+6,s
         sta   t1+6
         lda   4+10+1+8,s
         sta   t1+8
         bra   ret

getnext  tsc                            compute nextafter(x,...)
         clc
         adc   #4+4
         pea   0
         pha
         FNEXTS

         tsc                            store x (as extended) in t1
         clc
         adc   #4
         pea   0
         pha
         ph4   #t1
         FS2X

         phb                            move return address
ret      plx
         ply
         tsc
         clc
         adc   #20
         tcs
         phy
         phx
         plb

         ldx   #^t1                     return a pointer to the result
         lda   #t1
         rtl

plusinf  dc    f'+inf'
minusinf dc    f'-inf'
         end

****************************************************************
*
*  poly: evaluate a polynomial
*
*  Evaluates sum from i=0 to n of K_i * x^i
*  
*  Inputs:
*        coeffs: array of coefficients, K_n down to K_0
*        n: degree of polynomial
*        result: pointer to location for result
*        t1: x value
*
*  Note: The coeffs array is assumed not to cross banks.
*
****************************************************************
*
poly     private
         using MathCommon2

         csubroutine (4:coeffs,2:n,4:result),0
         
         ldy   #8                       val := K_n
loop1    lda   [coeffs],y
         sta   [result],y
         dey
         dey
         bpl   loop1

loop2    lda   coeffs                   for i := n-1 downto 0
         clc
         adc   #10
         sta   coeffs

         ph4   #t1                        val := val * x
         ph4   <result
         FMULX
         
         ph4   <coeffs                    val := val + K_i
         ph4   <result
         FADDX
         
         dec   n
         bne   loop2
         
         creturn
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
*  double round(double x);
*
*  Rounds x to the nearest integer, rounding halfway cases
*  away from 0.
*
****************************************************************
*
round    start
roundf   entry
roundl   entry
         using MathCommon2

         csubroutine (10:x),0
         
         phb
         phk
         plb

         pha                            save env & set to default
         tsc
         inc   a
         pea   0
         pha
         FPROCENTRY

         lda   x                        t1 = x
         sta   t1
         lda   x+2
         sta   t1+2
         lda   x+4
         sta   t1+4
         lda   x+6
         sta   t1+6
         lda   x+8
         sta   t1+8

         ph4   #t1                      round to integer with default rounding
         FRINTX

         pea   INEXACT
         FTESTXCP                       if there was no inexact exception
         beq   ret                        we are done: x was an integer/nan/inf
         
         FGETENV
         txa
         ora   #TOWARDZERO*$4000        set rounding direction to "toward zero"
         pha
         FSETENV
         
         lda   x                        t1 = abs(x)
         sta   t1
         lda   x+2
         sta   t1+2
         lda   x+4
         sta   t1+4
         lda   x+6
         sta   t1+6
         lda   x+8
         and   #$7fff
         sta   t1+8
         
         ph4   #onehalf                 t1 = t1 + 0.5 (rounded toward 0)
         ph4   #t1
         FADDS
         ph4   #t1                      round to integer
         FRINTX
         asl   t1+8                     restore sign from x
         asl   x+8
         ror   t1+8
         
ret      FPROCEXIT                      restore env & raise any new exceptions
         plb
         
         lda   #^t1                     return a pointer to the result
         sta   x+2
         lda   #t1
         sta   x
         creturn 4:x

onehalf  dc    f'0.5'
         end

****************************************************************
*
*  double scalbln(double x, long n);
*
*  Returns x * 2^n.
*
****************************************************************
*
scalbln  start
scalblnf entry
scalblnl entry
         using MathCommon2
         
         csubroutine (10:x,4:n),0
         
         phb
         phk
         plb

         lda   x                        place x in a work area
         sta   t1
         lda   x+2
         sta   t1+2
         lda   x+4
         sta   t1+4
         lda   x+6
         sta   t1+6
         lda   x+8
         sta   t1+8

loop     cmp4  n,#32767+1               if n > INT_MAX
         blt   notbig
         pea   32767                      scale by INT_MAX
         pea   0
         bra   adjust_n
notbig   cmp4  n,#-32768                else if n < INT_MIN
         bge   notsmall
         pea   -32768+64                  scale by INT_MIN
         pea   -1

adjust_n sec                            if n is out of range of int
         lda   n                          subtract scale factor from n
         sbc   3,s
         sta   n
         lda   n+2
         sbc   1,s
         sta   n+2
         pla
         bra   do_scalb                 else
notsmall pei   n                          scale by n
         stz   n                          remaining amount to scale by is 0
         stz   n+2

do_scalb ph4   #t1                      scale the number
         FSCALBX

         lda   n                        if no more scaling to do
         ora   n+2
         beq   done                       we are done
         
         ph4   #t1                      else if value is nan/inf/zero
         FCLASSX
         txa
         and   #$FE
         bne   done                       stop: more scaling would not change it
         brl   loop                     else scale by remaining amount

done     lda   #^t1                     return a pointer to the result
         sta   n+2
         lda   #t1
         sta   n
         plb
         creturn 4:n
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
*  double tgamma(double x);
*
*  Computes the gamma function of x.
*
****************************************************************
*
tgamma   start
tgammaf  entry
tgammal  entry
         using MathCommon2

         csubroutine (10:x),0

         phb
         phk
         plb

         pha                            save env & set to default
         tsc
         inc   a
         pea   0
         pha
         FPROCENTRY

* For x < 0.5, use Gamma(x) = pi / (sin(x * pi) * Gamma(1 - x))
         stz   reflect
         ph4   #one_half                if x < 0.5 then
         tdc
         clc
         adc   #x
         pea   0
         pha
         FCMPS
         bvc   lb1
         inc   reflect

         ldx   #8                         orig_x := x
lp0      lda   x,x
         sta   fracpart,x
         sta   orig_x,x
         dex
         dex
         bpl   lp0
         
         ph4   #two                       fracpart := x REM 2
         ph4   #fracpart
         FREMI

         ph4   #one                       x := x-1
         tdc
         clc
         adc   #x
         pea   0
         pha
         FSUBX
         
         lda   x+8
         eor   #$8000
         sta   x+8

* For 0 <= x <= 9.375, use the identity Gamma(x) = Gamma(x+1)/x
lb1      ldy   #8                       denom := 1
lp1      lda   one,y
         sta   denom,y
         dey
         dey
         bpl   lp1

lp2      ph4   #cutoff                  while x < 9.375 then
         tdc
         clc
         adc   #x
         pea   0
         pha
         FCMPS
         bvc   stirling
         
         tdc                              denom := denom * x
         clc
         adc   #x
         pea   0
         pha
         ph4   #denom
         FMULX

         ph4   #one                       x := x + 1
         tdc
         clc
         adc   #x
         pea   0
         pha
         FADDX
         bra   lp2
         
* For x >= 9.375, calculate Gamma(x) using a Stirling series approximation
stirling lda   x                        t1 := x
         sta   y                        y := x
         sta   z                        z := x
         sta   t1
         lda   x+2
         sta   y+2
         sta   z+2
         sta   t1+2
         lda   x+4
         sta   y+4
         sta   z+4
         sta   t1+4
         lda   x+6
         sta   y+6
         sta   z+6
         sta   t1+6
         lda   x+8
         sta   y+8
         sta   z+8
         sta   t1+8

         ph4   #e                       z := x/e
         ph4   #z
         FDIVX
         ph4   #one_half                y := x - 1/2
         ph4   #y
         FSUBS
         ph4   #y                       z := (x/e)^(x-1/2)
         ph4   #z
         FXPWRY

         pea   -1                       t1 := 1/x
         ph4   #t1
         FXPWRI
         ph4   #y                       y := P(t1)
         pea   17
         ph4   #P
         jsl   poly
         
         ph4   #y                       z := z * y * sqrt(2*pi/e)
         ph4   #z
         FMULX
         ph4   #sqrt_2pi_over_e
         ph4   #z
         FMULX

* Adjust result as necessary for small or negative x values
         ph4   #denom                   z := z / denom
         ph4   #z                         (for cases where initial x was small)
         FDIVX

         lda   reflect                  if doing reflection
         jeq   done

         ph4   #pi                        fracpart := sin(x*pi)
         ph4   #fracpart
         FMULX
         ph4   #fracpart
         FSINX

         ph4   #fracpart                  if sin(x*pi)=0 (i.e. x was an integer)
         FCLASSX
         txa
         inc   a
         and   #$00ff
         bne   lb2
         
         asl   fracpart+8                   take sign from original x (for +-0)
         asl   orig_x+8
         ror   fracpart+8
         
         lda   orig_x                       if original x was not 0
         ora   orig_x+2
         ora   orig_x+4
         ora   orig_x+6
         beq   lb2
         
         lda   #32767                         force NAN result
         sta   z+8
         sta   z+6
         
         pea   $0100                          raise "invalid" exception (only)
         FSETENV

lb2      ph4   #z                         z := pi / (fracpart * z)
         ph4   #fracpart
         FMULX
         
         ph4   #pi
         ph4   #z
         FX2X
         
         ph4   #fracpart
         ph4   #z
         FDIVX

done     FPROCEXIT                      restore env & raise any new exceptions
         plb

         lda   #^z                      return a pointer to the result
         sta   x+2
         lda   #z
         sta   x
         creturn 4:x

cutoff   dc    f'9.375'                 cutoff for using Stirling approximation

one_half dc    f'0.5'
two      dc    i2'2'
e        dc    e'2.7182818284590452353602874713526624977572'
pi       dc    e'3.1415926535897932384626433'
sqrt_2pi_over_e dc e'1.520346901066280805611940146754975627'

P        anop                           Stirling series constants
         dc    e'+1.79540117061234856108e-01'
         dc    e'-2.48174360026499773092e-03'
         dc    e'-2.95278809456991205054e-02'
         dc    e'+5.40164767892604515180e-04'
         dc    e'+6.40336283380806979482e-03'
         dc    e'-1.62516262783915816899e-04'
         dc    e'-1.91443849856547752650e-03'
         dc    e'+7.20489541602001055909e-05'
         dc    e'+8.39498720672087279993e-04'
         dc    e'-5.17179090826059219337e-05'
         dc    e'-5.92166437353693882865e-04'
         dc    e'+6.97281375836585777429e-05'
         dc    e'+7.84039221720066627474e-04'
         dc    e'-2.29472093621399176955e-04'
         dc    e'-2.68132716049382716049e-03'
         dc    e'+3.47222222222222222222e-03'
         dc    e'+8.33333333333333333333e-02'
one      dc    e'+1.00000000000000000000e+00'

y        ds    10
z        ds    10
denom    ds    10
fracpart ds    10

reflect  ds    2                        flag: do reflection?
orig_x   ds    10                        original x value
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
