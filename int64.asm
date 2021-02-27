         keep  obj/int64
         mcopy int64.macros
         case  off

****************************************************************
*
*  Int64 - 64-bit integer math routines.
*
*  This code implements routines called by ORCA/C generated
*  code for operations on 64-bit integers.
*
****************************************************************
*
Int64    private                        dummy segment
         end

****************************************************************
*
*  ~UMUL8 - Eight Byte Unsigned Integer Multiply
*
*  Inputs:
*        NUM1,NUM2 - operands
*
*  Outputs:
*        NUM2 - result
*        X - next 16 bits of true result (bits 64-79)
*
****************************************************************
*
~UMUL8   START

ANS      EQU   3
RETURN   EQU   ANS+16
NUM1     EQU   RETURN+3
NUM2     EQU   NUM1+8

         LDA   #0                       set up initial working value
         PHA
         PHA
         PHA
         PHA
         LDA   18,s                     initially, ANS = NUM1
         PHA
         LDA   18,s
         PHA
         LDA   18,s
         PHA
         LDA   18,s
         PHA
         PHD
         TSC
         TCD        
;
;  Do a 64 bit by 64 bit multiply.
;
         LDY   #64                      64 bit multiply
ML1      LDA   ANS
         LSR   A
         BCC   ML2
         CLC                            add multiplicand to the partial product
         LDA   ANS+8
         ADC   NUM2
         STA   ANS+8
         LDA   ANS+10
         ADC   NUM2+2
         STA   ANS+10
         LDA   ANS+12
         ADC   NUM2+4
         STA   ANS+12
         LDA   ANS+14
         ADC   NUM2+6
         STA   ANS+14
ML2      ROR   ANS+14                   shift the interim result
         ROR   ANS+12
         ROR   ANS+10
         ROR   ANS+8
         ROR   ANS+6
         ROR   ANS+4
         ROR   ANS+2
         ROR   ANS
         DEY                            loop until done
         BNE   ML1

         move4 ANS,NUM2                 move return value and address
         move4 ANS+4,NUM2+4
         move4 RETURN-1,NUM1+4
         LDX   ANS+8                    set X to next 16 bits of result
         PLD                            fix stack, DP
         TSC
         CLC
         ADC   #24
         TCS
         RTL
         END

****************************************************************
*
*  ~CDIV8 - Eight Byte Signed Integer Divide,
*           with C-style remainder computation
*
*  Inputs:
*        NUM1 - numerator
*        NUM2 - denominator
*
*  Outputs:
*        ANS - result
*        REM - remainder
*        V - set for division by zero
*
*  Notes
*        1) Uses ~SIG8.
*
****************************************************************
*
~CDIV8   START
SIGN     EQU   1                        sign of answer
NUM1     EQU   36
NUM2     EQU   28
ANS      EQU   9                        answer
REM      EQU   17                       remainder
RETURN   EQU   25
;
;  Initialize
;
         TSC                            set up DP
         SEC
         SBC   #24
         TCS
         PHD
         TCD
         LDA   NUM2                     check for division by zero
         ORA   NUM2+2
         ORA   NUM2+4
         ORA   NUM2+6
         BNE   DV1

         PLD                            division by zero
         TSC
         CLC
         ADC   #24
         TCS
         SEP   #%01000000
         RTL

DV1      JSL   ~SIG8                    convert to positive numbers
;
;  64 BIT DIVIDE
;
         LDY   #64                      64 bits to go
DV3      ASL   ANS                      roll up the next number
         ROL   ANS+2
         ROL   ANS+4
         ROL   ANS+6
         ROL   ANS+8
         ROL   ANS+10
         ROL   ANS+12
         ROL   ANS+14
         SEC                            subtract for this digit
         LDA   ANS+8
         SBC   NUM2
         TAX
         LDA   ANS+10
         SBC   NUM2+2
         STA   SIGN+2
         LDA   ANS+12
         SBC   NUM2+4
         STA   SIGN+4
         LDA   ANS+14
         SBC   NUM2+6
         BCC   DV4                      branch if minus
         STX   ANS+8                    save partial numerator
         STA   ANS+14
         LDA   SIGN+2
         STA   ANS+10
         LDA   SIGN+4
         STA   ANS+12
         INC   ANS                      turn the bit on
DV4      DEY                            next bit
         BNE   DV3
;
;  SET SIGN
;
         LDA   SIGN                     branch if positive
         BEQ   DV10
         SEC                            negate the result
         LDA   #0
         SBC   ANS
         STA   ANS
         LDA   #0
         SBC   ANS+2
         STA   ANS+2
         LDA   #0
         SBC   ANS+4
         STA   ANS+4
         LDA   #0
         SBC   ANS+6
         STA   ANS+6
DV10     LDA   NUM1+6                   if numerator is negative
         BPL   DV11
         SEC                              negate the remainder
         LDA   #0
         SBC   REM
         STA   REM
         LDA   #0
         SBC   REM+2
         STA   REM+2
         LDA   #0
         SBC   REM+4
         STA   REM+4
         LDA   #0
         SBC   REM+6
         STA   REM+6
DV11     LDX   #14                      move answer, remainder to stack
DV12     LDA   ANS,X
         STA   NUM2,X
         DEX
         DEX
         BPL   DV12
         CLV
         PLD                            fix stack, DP
         TSC
         CLC
         ADC   #24
         TCS
         RTL
         END

****************************************************************
*
*  ~UDIV8 - Eight Byte Unsigned Integer Divide
*
*  Inputs:
*        NUM1 - numerator
*        NUM2 - denominator
*
*  Outputs:
*        ANS - result
*        REM - remainder
*        V - set for division by zero
*
****************************************************************
*
~UDIV8   START
TEMP     EQU   1
NUM1     EQU   32
NUM2     EQU   24
ANS      EQU   5                        answer
REM      EQU   13                       remainder
RETURN   EQU   21
;
;  Initialize
;
         TSC                            set up DP
         SEC
         SBC   #20
         TCS
         PHD
         TCD
         LDA   NUM2                     check for division by zero
         ORA   NUM2+2
         ORA   NUM2+4
         ORA   NUM2+6
         BNE   DV1

         PLD                            division by zero
         TSC
         CLC
         ADC   #20
         TCS
         SEP   #%01000000
         RTL

DV1      STZ   REM                      initialize REM to 0
         STZ   REM+2
         STZ   REM+4
         STZ   REM+6
         move4 NUM1,ANS                 initialize ANS to NUM1
         move4 NUM1+4,ANS+4
;
;  64 BIT DIVIDE
;
         LDY   #64                      64 bits to go
DV3      ASL   ANS                      roll up the next number
         ROL   ANS+2
         ROL   ANS+4
         ROL   ANS+6
         ROL   ANS+8
         ROL   ANS+10
         ROL   ANS+12
         ROL   ANS+14
         SEC                            subtract for this digit
         LDA   ANS+8
         SBC   NUM2
         TAX
         LDA   ANS+10
         SBC   NUM2+2
         STA   TEMP
         LDA   ANS+12
         SBC   NUM2+4
         STA   TEMP+2
         LDA   ANS+14
         SBC   NUM2+6
         BCC   DV4                      branch if minus
         STX   ANS+8                    save partial numerator
         STA   ANS+14
         LDA   TEMP
         STA   ANS+10
         LDA   TEMP+2
         STA   ANS+12
         INC   ANS                      turn the bit on
DV4      DEY                            next bit
         BNE   DV3

DV10     LDX   #14                      move answer, remainder to stack
DV11     LDA   ANS,X
         STA   NUM2,X
         DEX
         DEX
         BPL   DV11
         CLV
         PLD                            fix stack, DP
         TSC
         CLC
         ADC   #20
         TCS
         RTL
         END

****************************************************************
*
*  ~SCMP8 - Eight Byte Signed Integer Compare
*
*  Inputs:
*        NUM1 - first argument
*        NUM2 - second argument
*
*  Outputs:
*        C - set if NUM1 >= NUM2, else clear
*        Z - set if NUM1 = NUM2, else clear
*
****************************************************************
*
~SCMP8   START
NUM1     EQU   12                       first argument
NUM2     EQU   4                        second argument
RETURN   EQU   0                        P reg and return addr

         TDC                            set up DP
         TAX
         TSC
         TCD
         LDA   NUM1+6                   if numbers are of opposite sign then
         EOR   NUM2+6
         BPL   LB1
         LDA   NUM2+6                     reverse sense of compare
         CMP   NUM1+6
         BRA   LB2                      else
LB1      LDA   NUM1+6                     compare numbers
         CMP   NUM2+6
         BNE   LB2
         LDA   NUM1+4
         CMP   NUM2+4
         BNE   LB2
         LDA   NUM1+2
         CMP   NUM2+2
         BNE   LB2
         LDA   NUM1
         CMP   NUM2
LB2      ANOP                           endif
         PHP                            save result
         LDA   RETURN                   move P and return addr
         STA   NUM1+4
         LDA   RETURN+2
         STA   NUM1+6
         CLC                            remove 16 bytes from stack
         TSC
         ADC   #16
         TCS
         TXA                            restore DP
         TCD
         PLP                            restore P
         RTL                            return
         END

****************************************************************
*
*  ~LShr8 - Shift an unsigned long long value right
*
*  Inputs:
*        num1 - value to shift
*        A - # of bits to shift by
*
*  Outputs:
*        num1 - result
*
****************************************************************
*
~LShr8   start
num1     equ   4

         tax                            save shift count
         beq   rtl                      return if it is 0

         tsc
         phd
         tcd
         
         txa
loop0    cmp   #16                      shift by 16s first
         blt   loop1
         ldy   num1+2
         sty   num1
         ldy   num1+4
         sty   num1+2
         ldy   num1+6
         sty   num1+4
         stz   num1+6
;        sec
         sbc   #16
         bne   loop0
         bra   rt0
         
loop1    lsr   num1+6                   do the remaining shift
         ror   num1+4
         ror   num1+2
         ror   num1
         dec   a
         bne   loop1
         
rt0      pld
rtl      rtl
         end

****************************************************************
*
*  ~AShr8 - Shift a signed long long value right
*
*  Inputs:
*        num1 - value to shift
*        A - # of bits to shift by
*
*  Outputs:
*        num1 - result
*
****************************************************************
*
~AShr8   start
num1     equ   4

         tax                            save shift count
         beq   rtl                      return if it is 0

         tsc
         phd
         tcd
         
loop1    lda   num1+6                   do the shift
         asl   a
         ror   num1+6
         ror   num1+4
         ror   num1+2
         ror   num1
         dex
         bne   loop1
         
         pld
rtl      rtl
         end

****************************************************************
*
*  ~Shl8 - Shift a signed long long value left
*
*  Inputs:
*        num1 - value to shift
*        A - # of bits to shift by
*
*  Outputs:
*        num1 - result
*
****************************************************************
*
~Shl8    start
num1     equ   4

         tax                            save shift count
         beq   rtl                      return if it is 0

         tsc
         phd
         tcd
         
         txa
loop0    cmp   #16                      shift by 16s first
         blt   loop1
         ldy   num1+4
         sty   num1+6
         ldy   num1+2
         sty   num1+4
         ldy   num1
         sty   num1+2
         stz   num1
;        sec
         sbc   #16
         bne   loop0
         bra   rt0
         
loop1    asl   num1                     do the remaining shift
         rol   num1+2
         rol   num1+4
         rol   num1+6
         dec   a
         bne   loop1
         
rt0      pld
rtl      rtl
         end

****************************************************************
*
*  ~CnvULongLongReal - convert an unsigned long long integer 
*        into an extended SANE real
*
*  Inputs:
*        unsigned long long int on stack
*
*  Outputs:
*        extended real on stack
*
****************************************************************
*
~CnvULongLongReal start
mantissa equ   4                        mantissa (integer and fraction)
exponent equ   mantissa+8               biased exponent and sign bit

         lda   1,S                      move return value
         pha
         lda   4,S
         sta   2,S
         tsc                            set up DP
         phd
         tcd

         lda   mantissa+2               move 64-bit value to mantissa
         sta   mantissa
         lda   mantissa+4
         sta   mantissa+2
         lda   mantissa+6
         sta   mantissa+4
         lda   mantissa+8
         sta   mantissa+6

         ora   mantissa                 if value is 0 then
         ora   mantissa+2
         ora   mantissa+4
         beq   ret                        return

         lda   #63+16383                set initial exponent (2^63) and sign
         sta   exponent

         lda   mantissa+6               if number is normalized (i=1) then
         bmi   ret                        return

lp1      dec   exponent                 normalize number
         asl   mantissa
         rol   mantissa+2
         rol   mantissa+4
         rol   mantissa+6
         bpl   lp1

ret      pld
         rtl
         end

****************************************************************
*
*  ~CnvLongLongReal - convert a long long integer into
*        an extended SANE real
*
*  Inputs:
*        signed long long int on stack
*
*  Outputs:
*        extended real on stack
*
****************************************************************
*
~CnvLongLongReal start
mantissa equ   4                        mantissa (integer and fraction)
exponent equ   mantissa+8               biased exponent and sign bit

         lda   1,S                      move return value
         pha
         lda   4,S
         sta   2,S
         tsc                            set up DP
         phd
         tcd

         lda   mantissa+2               move 64-bit value to mantissa
         sta   mantissa
         lda   mantissa+4
         sta   mantissa+2
         lda   mantissa+6
         sta   mantissa+4
         lda   mantissa+8
         sta   mantissa+6

         ora   mantissa                 if value is 0 then
         ora   mantissa+2
         ora   mantissa+4
         beq   ret                        return

         ldy   #0                       default sign bit is 0 (positive)
         lda   mantissa+6               if mantissa is negative then
         bpl   lb0
         negate8 mantissa                 negate it
         ldy   #$8000                     sign bit is 1 (negative)

lb0      tya                            set sign
         ora   #63+16383                set initial exponent (2^63)
         sta   exponent

         lda   mantissa+6               if number is normalized (i=1) then
         bmi   ret                        return

lp1      dec   exponent                 normalize number
         asl   mantissa
         rol   mantissa+2
         rol   mantissa+4
         rol   mantissa+6
         bpl   lp1

ret      pld
         rtl
         end

****************************************************************
*
*  ~CnvRealLongLong - convert an extended SANE real into
*        a long long integer
*
*  Inputs:
*        extended real on stack
*
*  Outputs:
*        signed long long int on stack
*
****************************************************************
*
~CnvRealLongLong start
         tsc
         clc
         adc   #4
         pea   0                        push src address for fcpxx
         pha
         pea   llmin|-16                push dst address for fcpxx
         pea   llmin
         pea   0                        push operand address for ftintx
         pha
         ftintx                         round
         fcpxx                          compare with LLONG_MIN
         bne   convert
         
         lda   #$8000                   if it is LONG_MIN, use that value
         sta   12,s
         asl   a
         sta   10,s
         sta   8,s
         sta   6,s
         bra   done
         
convert  tsc                            if it is not LONG_MIN, call fx2c:
         clc
         adc   #4
         pea   0                          push src address for fx2c
         pha
         pea   0                          push dst address for fx2c
         inc   a
         inc   a
         pha
         fx2c                             convert
         
done     phb                            move return address
         pla
         plx
         ply
         phx
         pha
         plb
         rtl

llmin    dc    e'-9223372036854775808'
         end

****************************************************************
*
*  ~CnvRealULongLong - convert an extended SANE real into
*        an unsigned long long integer
*
*  Inputs:
*        extended real on stack
*
*  Outputs:
*        unsigned long long int on stack
*
****************************************************************
*
~CnvRealULongLong start
         pea   0                        initially assume val <= LLONG_MAX

         tsc
         clc
         adc   #6
         pea   0                        push src address for fcpxx
         pha
         pea   llbig|-16                push dst address for fcpxx
         pea   llbig
         pea   0                        push operand address for ftintx
         pha
         ftintx                         round
         fcpxx                          compare with LLONG_MAX+1
         bmi   convert
         
         lda   #1                       if val > LLONG_MAX:
         sta   1,S                        save flag to indicate this
         tsc
         clc
         adc   #6
         pea   llbig|-16                  push src address for fsubx
         pea   llbig
         pea   0                          push dst address for fsubx
         pha
         fsubx                            val -= LLONG_MAX+1
         
convert  tsc
         clc
         adc   #6
         pea   0                        push src address for fx2c
         pha
         pea   0                        push dst address for fx2c
         inc   a
         inc   a
         pha
         fx2c                           convert val as comp
         
         pla                            if orig val was > LLONG_MAX:
         beq   done
         lda   12,s
         eor   #$8000
         sta   12,s                       result += LLONG_MAX+1
         
done     phb                            move return address
         pla
         plx
         ply
         phx
         pha
         plb
         rtl

llbig    dc    e'9223372036854775808'
         end
