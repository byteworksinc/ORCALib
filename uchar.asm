         keep  obj/uchar
         mcopy uchar.macros
         case  on

****************************************************************
*
*  UChar - Unicode utilities
*
*  This code implements conversions to and from Unicode.
*  It assumes the multibyte character set is Mac OS Roman.
*
****************************************************************
*
uchar    private
         copy  equates.asm
         end

****************************************************************
*
*  size_t mbrtoc16(char16_t * pc16, const char * s, size_t n,
*        mbstate_t * ps);
*
*  size_t mbrtoc32(char32_t * pc32, const char * s, size_t n,
*        mbstate_t * ps);
*
*  Convert a multibyte character to UTF-16 or UTF-32.
*
*  Inputs:
*        pc16 or pc32 - pointer to output location
*        s - pointer to multibyte character
*        n - maximum number of bytes to examine
*        ps - conversion state
*
*  Outputs:
*        *pc16 or *pc32 - UTF-16 or UTF-32 code unit
*        Returns number of bytes in multibyte character or
*        0 for null character.  
*
****************************************************************
*
mbrtoc16 start
         clv                            v flag clear => doing mbrtoc16
         bra   csub
         
mbrtoc32 entry
         sep   #$40                     v flag set => doing mbrtoc32

csub     csubroutine (4:pc16,4:s,4:n,4:ps),0
         
         lda   s                        if s == NULL
         ora   s+2
         bne   check_n
         stz   n                          call is equivalent to
         stz   n+2                        mbrtoc16(NULL, "", 1, ps),
         bra   ret                        so return 0
check_n  lda   n                        if n = 0
         ora   n+2
         bne   getchar
         dec   a                          return (size_t)(-2)
         sta   n+2
         dec   a
         sta   n
         bra   ret
getchar  ldy   #1                       assume return value is 1
         lda   [s]                      load character *s
         and   #$00ff
         bne   set_rv                   if *s == '\0'
         dey                              return value is 0
set_rv   sty   n                        set return value
         stz   n+2         
         cmp   #$0080                   if *s is an ASCII character
         blt   output                     store it as-is
         asl   a                        else
         and   #$00FF
         tax
         lda   >macRomanToUCS,x           convert it to Unicode
output   ldx   pc16                     if pc16 != NULL
         bne   storeit
         ldx   pc16+2
         beq   ret
storeit  sta   [pc16]                     store result to *pc16
         bvc   ret                        if doing mbrtoc32
         lda   #0
         ldy   #2
         sta   [pc16],y                     store 0 as high word of result

ret      creturn 4:n
         end


****************************************************************
*
*  size_t c16rtomb(char * s, char16_t c16, mbstate_t * ps);
*
*  Convert a UTF-16 code unit to a multibyte character.
*
*  Inputs:
*        s - pointer to output location
*        c16 - UTF-16 code unit
*        ps - conversion state
*
*  Outputs:
*        *s - converted character
*        Returns number of bytes stored, or -1 for error.
*
****************************************************************
*
c16rtomb start

         csubroutine (4:s,2:c16,4:ps),0

         lda   s                        if s == NULL, call is equivalent to
         ora   s+2                        c16rtomb(internal_buf, 0, ps),
         beq   return_1                   so return 1
         lda   c16                      if c16 is an ASCII character
         cmp   #$0080
         blt   storeit                    store it as-is
         short I
         ldx   #0
cvt_loop lda   >macRomanToUCS,x         for each entry in macRomanToUCS
         cmp   c16                        if it matches c16
         beq   gotit                        break and handle the mapping
         inx
         inx
         bne   cvt_loop
         lda   #EILSEQ                  if no mapping was found
         sta   >errno                     errno = EILSEQ
         lda   #-1                        return -1
         sta   s
         sta   s+2
         long  I
         bra   ret
gotit    longi off
         txa                            if we found a mapping
         lsr   a                          compute the MacRoman character
         ora   #$0080
storeit  short M                        store the character
         sta   [s]
         long  M,I
return_1 lda   #1                       return 1
         sta   s
         stz   s+2

ret      creturn 4:s
         end


****************************************************************
*
*  size_t c32rtomb(char * s, char16_t c16, mbstate_t * ps);
*
*  Convert a UTF-32 code unit to a multibyte character.
*
*  Inputs:
*        s - pointer to output location
*        c16 - UTF-32 code unit
*        ps - conversion state
*
*  Outputs:
*        *s - converted character
*        Returns number of bytes stored, or -1 for error.
*
****************************************************************
*
c32rtomb start

         lda   10,s                     if char is outside the BMP
         beq   fixstack
         lda   #$FFFD                     substitute REPLACEMENT CHARACTER
         bra   fs2
         
fixstack lda   8,s                      adjust stack for call to c16rtomb
fs2      sta   10,s
         lda   6,s
         sta   8,s
         lda   4,s
         sta   6,s
         lda   2,s
         sta   4,s
         pla
         sta   1,s
         jml   c16rtomb                 do the equivalent c16rtomb call
         end


macRomanToUCS private
         dc    i2'$00C4, $00C5, $00C7, $00C9, $00D1, $00D6, $00DC, $00E1'
         dc    i2'$00E0, $00E2, $00E4, $00E3, $00E5, $00E7, $00E9, $00E8'
         dc    i2'$00EA, $00EB, $00ED, $00EC, $00EE, $00EF, $00F1, $00F3'
         dc    i2'$00F2, $00F4, $00F6, $00F5, $00FA, $00F9, $00FB, $00FC'
         dc    i2'$2020, $00B0, $00A2, $00A3, $00A7, $2022, $00B6, $00DF'
         dc    i2'$00AE, $00A9, $2122, $00B4, $00A8, $2260, $00C6, $00D8'
         dc    i2'$221E, $00B1, $2264, $2265, $00A5, $00B5, $2202, $2211'
         dc    i2'$220F, $03C0, $222B, $00AA, $00BA, $03A9, $00E6, $00F8'
         dc    i2'$00BF, $00A1, $00AC, $221A, $0192, $2248, $2206, $00AB'
         dc    i2'$00BB, $2026, $00A0, $00C0, $00C3, $00D5, $0152, $0153'
         dc    i2'$2013, $2014, $201C, $201D, $2018, $2019, $00F7, $25CA'
         dc    i2'$00FF, $0178, $2044, $00A4, $2039, $203A, $FB01, $FB02'
         dc    i2'$2021, $00B7, $201A, $201E, $2030, $00C2, $00CA, $00C1'
         dc    i2'$00CB, $00C8, $00CD, $00CE, $00CF, $00CC, $00D3, $00D4'
         dc    i2'$F8FF, $00D2, $00DA, $00DB, $00D9, $0131, $02C6, $02DC'
         dc    i2'$00AF, $02D8, $02D9, $02DA, $00B8, $02DD, $02DB, $02C7'
         end
