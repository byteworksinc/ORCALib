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
         PLD                            fix stack, DP
         TSC
         CLC
         ADC   #24
         TCS
         RTL
         END
