         keep  obj/locale
         mcopy locale.macros
         case  on
****************************************************************
*
*  Locale - locale support
*
*  This currently implements a minimalistic version of the
*  <locale.h> functions, supporting only the "C" locale.
*
****************************************************************
*
Locale   private                        dummy routine
         end

****************************************************************
*
*  char *setlocale(int category, const char *locale);
*
*  Set or query current locale
*
*  Inputs:
*        category - locale category to set or query
*        locale - locale name (or NULL for query)
*
*  Outputs:
*        returns locale string (for relevant category),
*        or NULL if locale cannot be set as requested
*
****************************************************************
*
setlocale start
LC_MAX   equ   5                        maximum valid LC_* value

         csubroutine (2:category,4:locale),0

         lda   category                 if category is invalid
         cmp   #LC_MAX+1
         bge   err                        return NULL
         lda   locale                   if querying the current locale
         ora   locale+2
         beq   good                       return "C"
         lda   [locale]
         cmp   #'C'                     if locale is "C" or "", we are good
         beq   good
         and   #$00FF
         bne   err
good     lda   #C_str                   if successful, return "C"
         sta   locale
         lda   #^C_str
         sta   locale+2
         bra   ret
err      stz   locale                   otherwise, return NULL for error
         stz   locale+2
ret      creturn 4:locale

C_str    dc    c'C',i1'0'
         end

****************************************************************
*
*  struct lconv *localeconv(void);
*
*  Get numeric formatting conventions
*
*  Outputs:
*        returns pointer to a struct lconv containing
*        appropriate values for the current locale
*
****************************************************************
*
localeconv start
CHAR_MAX equ   255

         ldx   #^C_locale_lconv
         lda   #C_locale_lconv
         rtl

C_locale_lconv anop
decimal_point           dc a4'period'
thousands_sep           dc a4'emptystr'
grouping                dc a4'emptystr'
mon_decimal_point       dc a4'emptystr'
mon_thousands_sep       dc a4'emptystr'
mon_grouping            dc a4'emptystr'
positive_sign           dc a4'emptystr'
negative_sign           dc a4'emptystr'
currency_symbol         dc a4'emptystr'
frac_digits             dc i1'CHAR_MAX'
p_cs_precedes           dc i1'CHAR_MAX'
n_cs_precedes           dc i1'CHAR_MAX'
p_sep_by_space          dc i1'CHAR_MAX'
n_sep_by_space          dc i1'CHAR_MAX'
p_sign_posn             dc i1'CHAR_MAX'
n_sign_posn             dc i1'CHAR_MAX'
int_curr_symbol         dc a4'emptystr'
int_frac_digits         dc i1'CHAR_MAX'
int_p_cs_precedes       dc i1'CHAR_MAX'
int_n_cs_precedes       dc i1'CHAR_MAX'
int_p_sep_by_space      dc i1'CHAR_MAX'
int_n_sep_by_space      dc i1'CHAR_MAX'
int_p_sign_posn         dc i1'CHAR_MAX'
int_n_sign_posn         dc i1'CHAR_MAX'

period   dc    c'.',i1'0'
emptystr dc    i1'0'
         end
