         keep  obj/stdbit
         mcopy stdbit.macros
         case  on

****************************************************************
*
*  StdBit - Bit and byte utilities
*
*  This code implements the subroutines needed to
*  support the standard C library <stdbit.h>.
*
*  May 2026
*  Stephen Heumann
*
****************************************************************
*
StdBit   private                        dummy segment

         end

****************************************************************
*
*  unsigned int stdc_leading_zeros_uc(unsigned char value);
*
*  Count leading zeros (unsigned char).
*
****************************************************************
*
stdc_leading_zeros_uc start

         csubroutine (2:value),0

         ldy   #-1
         lda   value
         xba
         ora   #$00ff

loop     iny
         asl   a
         bcc   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_leading_zeros_us(unsigned short value);
*  unsigned int stdc_leading_zeros_ui(unsigned int value);
*
*  Count leading zeros (unsigned short/unsigned int).
*
****************************************************************
*
stdc_leading_zeros_us start
stdc_leading_zeros_ui entry

         csubroutine (2:value),0

         ldy   #-1
         lda   value
         sec

loop     iny
         rol   a
         bcc   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_leading_zeros_ul(unsigned long value);
*
*  Count leading zeros (unsigned long).
*
****************************************************************
*
stdc_leading_zeros_ul start

         csubroutine (4:value),0

         ldy   #-1
         lda   value
         sec

loop     iny
         rol   a
         rol   value+2
         bcc   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_leading_zeros_ull(unsigned long long value);
*
*  Count leading zeros (unsigned long long).
*
****************************************************************
*
stdc_leading_zeros_ull start

         csubroutine (8:value),0

         ldy   #-1
         lda   value
         sec

loop     iny
         rol   a
         rol   value+2
         rol   value+4
         rol   value+6
         bcc   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_leading_ones_uc(unsigned char value);
*
*  Count leading ones (unsigned char).
*
****************************************************************
*
stdc_leading_ones_uc start

         csubroutine (2:value),0

         ldy   #-1
         lda   value
         xba

loop     iny
         asl   a
         bcs   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_leading_ones_us(unsigned short value);
*  unsigned int stdc_leading_ones_ui(unsigned int value);
*
*  Count leading ones (unsigned short/unsigned int).
*
****************************************************************
*
stdc_leading_ones_us start
stdc_leading_ones_ui entry

         csubroutine (2:value),0

         ldy   #-1
         lda   value

loop     iny
         asl   a
         bcs   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_leading_ones_ul(unsigned long value);
*
*  Count leading ones (unsigned long).
*
****************************************************************
*
stdc_leading_ones_ul start

         csubroutine (4:value),0

         ldy   #-1
         lda   value

loop     iny
         asl   a
         rol   value+2
         bcs   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_leading_ones_ull(unsigned long long value);
*
*  Count leading ones (unsigned long long).
*
****************************************************************
*
stdc_leading_ones_ull start

         csubroutine (8:value),0

         ldy   #-1
         lda   value

loop     iny
         asl   a
         rol   value+2
         rol   value+4
         rol   value+6
         bcs   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_trailing_zeros_uc(unsigned char value);
*
*  Count trailing zeros (unsigned char).
*
****************************************************************
*
stdc_trailing_zeros_uc start

         csubroutine (2:value),0

         ldy   #-1
         lda   value
         ora   #$ff00

loop     iny
         lsr   a
         bcc   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_trailing_zeros_us(unsigned short value);
*  unsigned int stdc_trailing_zeros_ui(unsigned int value);
*
*  Count trailing zeros (unsigned short/unsigned int).
*
****************************************************************
*
stdc_trailing_zeros_us start
stdc_trailing_zeros_ui entry

         csubroutine (2:value),0

         ldy   #-1
         lda   value
         sec

loop     iny
         ror   a
         bcc   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_trailing_zeros_ul(unsigned long value);
*
*  Count trailing zeros (unsigned long).
*
****************************************************************
*
stdc_trailing_zeros_ul start

         csubroutine (4:value),0

         ldy   #-1
         lda   value
         sec

loop     iny
         ror   value+2
         ror   a
         bcc   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_trailing_zeros_ull(unsigned long long value);
*
*  Count trailing zeros (unsigned long long).
*
****************************************************************
*
stdc_trailing_zeros_ull start

         csubroutine (8:value),0

         ldy   #-1
         lda   value
         sec

loop     iny
         ror   value+6
         ror   value+4
         ror   value+2
         ror   a
         bcc   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_trailing_ones_uc(unsigned char value);
*  unsigned int stdc_trailing_ones_us(unsigned short value);
*  unsigned int stdc_trailing_ones_ui(unsigned int value);
*
*  Count trailing ones (unsigned char/unsigned short/unsigned int).
*
****************************************************************
*
stdc_trailing_ones_uc start
stdc_trailing_ones_us entry
stdc_trailing_ones_ui entry

         csubroutine (2:value),0

         ldy   #-1
         lda   value

loop     iny
         lsr   a
         bcs   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_trailing_ones_ul(unsigned long value);
*
*  Count trailing ones (unsigned long).
*
****************************************************************
*
stdc_trailing_ones_ul start

         csubroutine (4:value),0

         ldy   #-1
         lda   value

loop     iny
         lsr   value+2
         ror   a
         bcs   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_trailing_ones_ull(unsigned long long value);
*
*  Count trailing ones (unsigned long long).
*
****************************************************************
*
stdc_trailing_ones_ull start

         csubroutine (8:value),0

         ldy   #-1
         lda   value

loop     iny
         lsr   value+6
         ror   value+4
         ror   value+2
         ror   a
         bcs   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_leading_zero_uc(unsigned char value);
*
*  Return position of first leading zero bit
*  (most significant bit = 1, 0 if there are no zero bits)
*
****************************************************************
*
stdc_first_leading_zero_uc start

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_leading_ones_uc
         inc   a

         cmp   #8+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_leading_zero_us(unsigned short value);
*  unsigned int stdc_first_leading_zero_ui(unsigned int value);
*
*  Return position of first leading zero bit
*  (most significant bit = 1, 0 if there are no zero bits)
*
****************************************************************
*
stdc_first_leading_zero_us start
stdc_first_leading_zero_ui entry

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_leading_ones_us
         inc   a

         cmp   #16+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end
****************************************************************
*
*  unsigned int stdc_first_leading_zero_ul(unsigned long value);
*
*  Return position of first leading zero bit
*  (most significant bit = 1, 0 if there are no zero bits)
*
****************************************************************
*
stdc_first_leading_zero_ul start

         csubroutine (4:value),0

         ph4   value
         jsl   stdc_leading_ones_ul
         inc   a

         cmp   #32+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_leading_zero_ull(unsigned long long value);
*
*  Return position of first leading zero bit
*  (most significant bit = 1, 0 if there are no zero bits)
*
****************************************************************
*
stdc_first_leading_zero_ull start

         csubroutine (8:value),0

         ph8   value
         jsl   stdc_leading_ones_ull
         inc   a

         cmp   #64+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_leading_one_uc(unsigned char value);
*
*  Return position of first leading one bit
*  (most significant bit = 1, 0 if there are no one bits)
*
****************************************************************
*
stdc_first_leading_one_uc start

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_leading_zeros_uc
         inc   a

         cmp   #8+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_leading_one_us(unsigned short value);
*  unsigned int stdc_first_leading_one_ui(unsigned int value);
*
*  Return position of first leading one bit
*  (most significant bit = 1, 0 if there are no one bits)
*
****************************************************************
*
stdc_first_leading_one_us start
stdc_first_leading_one_ui entry

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_leading_zeros_us
         inc   a

         cmp   #16+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_leading_one_ul(unsigned long value);
*
*  Return position of first leading one bit
*  (most significant bit = 1, 0 if there are no one bits)
*
****************************************************************
*
stdc_first_leading_one_ul start

         csubroutine (4:value),0

         ph4   value
         jsl   stdc_leading_zeros_ul
         inc   a

         cmp   #32+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_leading_one_ull(unsigned long long value);
*
*  Return position of first leading one bit
*  (most significant bit = 1, 0 if there are no one bits)
*
****************************************************************
*
stdc_first_leading_one_ull start

         csubroutine (8:value),0

         ph8   value
         jsl   stdc_leading_zeros_ull
         inc   a

         cmp   #64+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_trailing_zero_uc(unsigned char value);
*
*  Return position of first trailing zero bit
*  (most significant bit = 1, 0 if there are no zero bits)
*
****************************************************************
*
stdc_first_trailing_zero_uc start

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_trailing_ones_uc
         inc   a

         cmp   #8+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_trailing_zero_us(unsigned short value);
*  unsigned int stdc_first_trailing_zero_ui(unsigned int value);
*
*  Return position of first trailing zero bit
*  (most significant bit = 1, 0 if there are no zero bits)
*
****************************************************************
*
stdc_first_trailing_zero_us start
stdc_first_trailing_zero_ui entry

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_trailing_ones_us
         inc   a

         cmp   #16+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end
****************************************************************
*
*  unsigned int stdc_first_trailing_zero_ul(unsigned long value);
*
*  Return position of first trailing zero bit
*  (most significant bit = 1, 0 if there are no zero bits)
*
****************************************************************
*
stdc_first_trailing_zero_ul start

         csubroutine (4:value),0

         ph4   value
         jsl   stdc_trailing_ones_ul
         inc   a

         cmp   #32+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_trailing_zero_ull(unsigned long long value);
*
*  Return position of first trailing zero bit
*  (most significant bit = 1, 0 if there are no zero bits)
*
****************************************************************
*
stdc_first_trailing_zero_ull start

         csubroutine (8:value),0

         ph8   value
         jsl   stdc_trailing_ones_ull
         inc   a

         cmp   #64+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_trailing_one_uc(unsigned char value);
*
*  Return position of first trailing one bit
*  (most significant bit = 1, 0 if there are no one bits)
*
****************************************************************
*
stdc_first_trailing_one_uc start

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_trailing_zeros_uc
         inc   a

         cmp   #8+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_trailing_one_us(unsigned short value);
*  unsigned int stdc_first_trailing_one_ui(unsigned int value);
*
*  Return position of first trailing one bit
*  (most significant bit = 1, 0 if there are no one bits)
*
****************************************************************
*
stdc_first_trailing_one_us start
stdc_first_trailing_one_ui entry

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_trailing_zeros_us
         inc   a

         cmp   #16+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_trailing_one_ul(unsigned long value);
*
*  Return position of first trailing one bit
*  (most significant bit = 1, 0 if there are no one bits)
*
****************************************************************
*
stdc_first_trailing_one_ul start

         csubroutine (4:value),0

         ph4   value
         jsl   stdc_trailing_zeros_ul
         inc   a

         cmp   #32+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_first_trailing_one_ull(unsigned long long value);
*
*  Return position of first trailing one bit
*  (most significant bit = 1, 0 if there are no one bits)
*
****************************************************************
*
stdc_first_trailing_one_ull start

         csubroutine (8:value),0

         ph8   value
         jsl   stdc_trailing_zeros_ull
         inc   a

         cmp   #64+1
         bne   done
         lda   #0

done     sta   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_count_zeros_uc(unsigned char value);
*
*  Count zeros in value (unsigned char).
*
****************************************************************
*
stdc_count_zeros_uc start

         csubroutine (2:value),0

         ldy   #0
         ldx   #8
         lda   value

loop     lsr   a
         bcs   lb1
         iny
lb1      dex
         bne   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_count_zeros_us(unsigned short value);
*  unsigned int stdc_count_zeros_ui(unsigned int value);
*
*  Count zeros in value (unsigned short/unsigned int).
*
****************************************************************
*
stdc_count_zeros_us start
stdc_count_zeros_ui entry

         csubroutine (2:value),0

         ldy   #0
         ldx   #16
         lda   value

loop     lsr   a
         bcs   lb1
         iny
lb1      dex
         bne   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_count_zeros_ul(unsigned long value);
*
*  Count zeros in value (unsigned long).
*
****************************************************************
*
stdc_count_zeros_ul start

         csubroutine (4:value),0

         ldy   #0
         ldx   #32
         lda   value

loop     asl   a
         rol   value+2
         bcs   lb1
         iny
lb1      dex
         bne   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_count_zeros_ul(unsigned long long value);
*
*  Count zeros in value (unsigned long long).
*
****************************************************************
*
stdc_count_zeros_ull start

         csubroutine (8:value),0

         ldy   #0
         ldx   #64
         lda   value

loop     asl   a
         rol   value+2
         rol   value+4
         rol   value+6
         bcs   lb1
         iny
lb1      dex
         bne   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_count_ones_uc(unsigned char value);
*
*  Count ones in value (unsigned char).
*
****************************************************************
*
stdc_count_ones_uc start

         csubroutine (2:value),0

         ldy   #0
         ldx   #8
         lda   value

loop     lsr   a
         bcc   lb1
         iny
lb1      dex
         bne   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_count_ones_us(unsigned short value);
*  unsigned int stdc_count_ones_ui(unsigned int value);
*
*  Count ones in value (unsigned short/unsigned int).
*
****************************************************************
*
stdc_count_ones_us start
stdc_count_ones_ui entry

         csubroutine (2:value),0

         ldy   #0
         ldx   #16
         lda   value

loop     lsr   a
         bcc   lb1
         iny
lb1      dex
         bne   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_count_ones_ul(unsigned long value);
*
*  Count ones in value (unsigned long).
*
****************************************************************
*
stdc_count_ones_ul start

         csubroutine (4:value),0

         ldy   #0
         ldx   #32
         lda   value

loop     asl   a
         rol   value+2
         bcc   lb1
         iny
lb1      dex
         bne   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_count_ones_ul(unsigned long long value);
*
*  Count ones in value (unsigned long long).
*
****************************************************************
*
stdc_count_ones_ull start

         csubroutine (8:value),0

         ldy   #0
         ldx   #64
         lda   value

loop     asl   a
         rol   value+2
         rol   value+4
         rol   value+6
         bcc   lb1
         iny
lb1      dex
         bne   loop

         sty   value
         creturn 2:value
         end

****************************************************************
*
*  bool stdc_has_single_bit_uc(unsigned char value);
*  bool stdc_has_single_bit_us(unsigned short value);
*  bool stdc_has_single_bit_ui(unsigned int value);
*
*  Check if value has a single bit set.
*
****************************************************************
*
stdc_has_single_bit_uc start
stdc_has_single_bit_us entry
stdc_has_single_bit_ui entry

         csubroutine (2:value),0

         lda   value
         beq   ret
         
         dec   a
         and   value
         beq   onebit
         
         stz   value
         bra   ret

onebit   lda   #1
         sta   value
         
ret      creturn 2:value
         end

****************************************************************
*
*  bool stdc_has_single_bit_ul(unsigned long value);
*
*  Check if value has a single bit set (unsigned long).
*
****************************************************************
*
stdc_has_single_bit_ul start

         csubroutine (4:value),0

         lda   value
         ora   value+2
         beq   ret
         
         sec
         lda   value
         sbc   #1
         and   value
         bne   multibit
         
         lda   value+2
         sbc   #0
         and   value+2
         bne   multibit
         
         lda   #1
         sta   value
         bra   ret

multibit stz   value
         
ret      creturn 2:value
         end

****************************************************************
*
*  bool stdc_has_single_bit_ull(unsigned long long value);
*
*  Check if value has a single bit set (unsigned long long).
*
****************************************************************
*
stdc_has_single_bit_ull start

         csubroutine (8:value),0

         lda   value
         ora   value+2
         ora   value+4
         ora   value+6
         beq   ret
         
         sec
         lda   value
         sbc   #1
         and   value
         bne   multibit
         
         lda   value+2
         sbc   #0
         and   value+2
         bne   multibit

         lda   value+4
         sbc   #0
         and   value+4
         bne   multibit

         lda   value+6
         sbc   #0
         and   value+6
         bne   multibit
         
         lda   #1
         sta   value
         bra   ret

multibit stz   value
         
ret      creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_bit_width_uc(unsigned char value);
*  unsigned int stdc_bit_width_us(unsigned short value);
*  unsigned int stdc_bit_width_ui(unsigned int value);
*
*  Return number of bits needed to hold value (0 for zero).
*
****************************************************************
*
stdc_bit_width_uc start
stdc_bit_width_us entry
stdc_bit_width_ui entry

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_leading_zeros_us
         
         eor   #-1
         sec
         adc   #16
         sta   value
         
ret      creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_bit_width_ul(unsigned long value);
*
*  Return number of bits needed to hold value (0 for zero).
*
****************************************************************
*
stdc_bit_width_ul start

         csubroutine (4:value),0

         ph4   value
         jsl   stdc_leading_zeros_ul
         
         eor   #-1
         sec
         adc   #32
         sta   value
         
ret      creturn 2:value
         end

****************************************************************
*
*  unsigned int stdc_bit_width_ull(unsigned long long value);
*
*  Return number of bits needed to hold value (0 for zero).
*
****************************************************************
*
stdc_bit_width_ull start

         csubroutine (8:value),0

         ph8   value
         jsl   stdc_leading_zeros_ull
         
         eor   #-1
         sec
         adc   #64
         sta   value
         
ret      creturn 2:value
         end

****************************************************************
*
*  unsigned char stdc_bit_floor_uc(unsigned char);
*  unsigned short stdc_bit_floor_us(unsigned short);
*  unsigned int stdc_bit_floor_ui(unsigned int);
*
*  Return greatest power of two that is <= value (0 for zero).
*
****************************************************************
*
stdc_bit_floor_uc start
stdc_bit_floor_us entry
stdc_bit_floor_ui entry

         csubroutine (2:value),0
         
         ph2   value
         jsl   stdc_bit_width_us
         
         tax
         beq   ret
         lda   #0
         sec
         
loop     rol   a
         dex
         bne   loop

         sta   value
ret      creturn 2:value
         end

****************************************************************
*
*  unsigned long stdc_bit_floor_ul(unsigned long);
*
*  Return greatest power of two that is <= value (0 for zero).
*
****************************************************************
*
stdc_bit_floor_ul start

         csubroutine (4:value),0
         
         ph4   value
         jsl   stdc_bit_width_ul

         stz   value+2

         tax
         beq   ret
         lda   #0
         sec
         
loop     rol   a
         rol   value+2
         dex
         bne   loop

         sta   value
ret      creturn 4:value
         end

****************************************************************
*
*  unsigned long long stdc_bit_floor_ull(unsigned long long);
*
*  Return greatest power of two that is <= value (0 for zero).
*
****************************************************************
*
stdc_bit_floor_ull start
retptr   equ   1

         csubroutine (8:value),4
         stx   retptr
         stz   retptr+2
         
         ph8   value
         jsl   stdc_bit_width_ull

         stz   value+2
         stz   value+4
         stz   value+6

         tax
         beq   done
         lda   #0
         sec
         
loop     rol   a
         rol   value+2
         rol   value+4
         rol   value+6
         dex
         bne   loop

done     sta   [retptr]
         ldy   #2
         lda   value+2
         sta   [retptr],y
         iny
         iny
         lda   value+4
         sta   [retptr],y
         iny
         iny
         lda   value+6
         sta   [retptr],y
         creturn
         end

****************************************************************
*
*  unsigned char stdc_bit_ceil_uc(unsigned char);
*
*  Return smallest power of two that is >= value (0 on overflow).
*
****************************************************************
*
stdc_bit_ceil_uc start

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_has_single_bit_uc
         tax
         bne   ret

         ph2   value
         jsl   stdc_bit_width_uc
         
         tax
         lda   #0
         sec
         
loop     rol   a
         dex
         bpl   loop

         and   #$00FF
         sta   value
ret      creturn 2:value
         end

****************************************************************
*
*  unsigned short stdc_bit_ceil_us(unsigned short);
*  unsigned int stdc_bit_ceil_ui(unsigned int);
*
*  Return smallest power of two that is >= value (0 on overflow).
*
****************************************************************
*
stdc_bit_ceil_us start
stdc_bit_ceil_ui entry

         csubroutine (2:value),0

         ph2   value
         jsl   stdc_has_single_bit_us
         tax
         bne   ret

         ph2   value
         jsl   stdc_bit_width_us
         
         tax
         lda   #0
         sec
         
loop     rol   a
         dex
         bpl   loop

         sta   value
ret      creturn 2:value
         end

****************************************************************
*
*  unsigned long stdc_bit_ceil_ul(unsigned long);
*
*  Return smallest power of two that is >= value (0 on overflow).
*
****************************************************************
*
stdc_bit_ceil_ul start

         csubroutine (4:value),0

         ph4   value
         jsl   stdc_has_single_bit_ul
         tax
         bne   ret

         ph4   value
         jsl   stdc_bit_width_ul

         stz   value+2

         tax
         lda   #0
         sec
         
loop     rol   a
         rol   value+2
         dex
         bpl   loop

         sta   value
ret      creturn 4:value
         end

****************************************************************
*
*  unsigned long long stdc_bit_ceil_ull(unsigned long long);
*
*  Return smallest power of two that is >= value (0 on overflow).
*
****************************************************************
*
stdc_bit_ceil_ull start
retptr   equ   1

         csubroutine (8:value),4
         stx   retptr
         stz   retptr+2

         ph8   value
         jsl   stdc_has_single_bit_ull
         tax
         beq   compute
         lda   value
         bra   done

compute  ph8   value
         jsl   stdc_bit_width_ull

         stz   value+2
         stz   value+4
         stz   value+6

         tax
         lda   #0
         sec
         
loop     rol   a
         rol   value+2
         rol   value+4
         rol   value+6
         dex
         bpl   loop

done     sta   [retptr]
         ldy   #2
         lda   value+2
         sta   [retptr],y
         iny
         iny
         lda   value+4
         sta   [retptr],y
         iny
         iny
         lda   value+6
         sta   [retptr],y
         creturn
         end
