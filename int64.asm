         keep  obj/int64
         mcopy int64.macros
         case  on

****************************************************************
*
*  Int64 - 64-bit integer math routines.
*
*  This code implements routines called by ORCA/C generated
*  code for operations on 64-bit integers.
*
****************************************************************
*
Int64    start                          dummy segment
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
