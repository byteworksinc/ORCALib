	keep	obj/ctype
	case	on
****************************************************************
*
*  CType - Character Types Library
*
*  This code implements the tables and subroutines needed to
*  support the standard C library CTYPES.
*
*  July 1988
*  Mike Westerfield
*
*  Copyright 1988
*  Byte Works, Inc.
*
****************************************************************
*
CType	start		dummy routine
	copy	equates.asm

	end

****************************************************************
*
*  int isalnum (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
isalnum	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_upper+_lower+_digit
	rtl
	end

****************************************************************
*
*  int isalpha (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
isalpha	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_upper+_lower
	rtl
	end

****************************************************************
*
*  int isascii (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
isascii	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	cpx	#$0080	form the result
	blt	yes
	lda	#0
	rtl

yes	lda	#1
	rtl
	end

****************************************************************
*
*  int iscntrl (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
iscntrl	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_control
	rtl
	end

****************************************************************
*
*  int iscsym (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
iscsym	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype2,X
	and	#_csym
	rtl
	end

****************************************************************
*
*  int iscsymf (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
iscsymf	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype2,X
	and	#_csymf
	rtl
	end

****************************************************************
*
*  int isdigit (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
isdigit	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_digit
	rtl
	end

****************************************************************
*
*  int isgraph (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
isgraph	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_upper+_lower+_digit+_punctuation
	rtl
	end

****************************************************************
*
*  int islower (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
islower	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_lower
	rtl
	end

****************************************************************
*
*  int isodigit (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
isodigit	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype2,X
	and	#_octal
	rtl
	end

****************************************************************
*
*  int isprint (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
isprint	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_print
	rtl
	end

****************************************************************
*
*  int ispunct (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
ispunct	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_punctuation
	rtl
	end

****************************************************************
*
*  int isspace (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
isspace	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_space
	rtl
	end

****************************************************************
*
*  int isupper (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
isupper	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_upper
	rtl
	end

****************************************************************
*
*  int isxdigit (int c)
*
*  Inputs:
*	4,S - digit to test
*
*  Outputs:
*	A - result
*
****************************************************************
*
isxdigit	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	inx		form the result
	lda	>__ctype,X
	and	#_hex
	rtl
	end

****************************************************************
*
*  int toascii (int c)
*
*  Inputs:
*	4,S - digit to convert
*
*  Outputs:
*	A - result
*
****************************************************************
*
toascii	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S
	txa		form the result
	and	#$7F
	rtl
	end

****************************************************************
*
*  toint - convert a hex digit to a binary value
*
*  Inputs:
*	4,S - digit to convert
*
*  Outputs:
*	A - converted digit
*
****************************************************************
*
toint	start
FALSE	equ	-1	returned for false conditions

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from stack
	sta	4,S
	pla
	sta	1,S

	inx		branch if not hex
	lda	>__ctype,X
	and	#_hex
	beq	no
	txa		insure char is uppercase
	and	#$5F
	dec	A
	cmp	#'A'	if the character is alpha then
	blt	lb1
	sbc	#7	  convert the value
lb1	and	#$000F	return ordinal value
	rtl

no	lda	#FALSE	not hex
	rtl
	end

****************************************************************
*
*  tolower - if the input is uppercase, convert it to lowercase
*
*  Inputs:
*	4,S - digit to convert
*
*  Outputs:
*	A - converted character
*
****************************************************************
*
tolower	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from the stack
	sta	4,S
	pla
	sta	1,S

	txa
	bmi	lb2
	lda	>__ctype+1,X	branch if the character is not uppercase
	and	#_upper
	beq	lb1
	txa		convert to lowercase
	ora	#$20
	rtl

lb1	txa		return the input character
lb2	rtl
	end

****************************************************************
*
*  toupper - if the input is lowercase, convert it to uppercase
*
*  Inputs:
*	4,S - digit to convert
*
*  Outputs:
*	A - converted character
*
****************************************************************
*
toupper	start

	lda	4,S	fetch the operand
	tax
	lda	2,S	remove parm from the stack
	sta	4,S
	pla
	sta	1,S

	txa
	bmi	lb2
	lda	>__ctype+1,X	branch if the character is not lowercase
	and	#_lower
	beq	lb1
	txa		convert to uppercase
	and	#$5F
	rtl

lb1	txa		return the input character
lb2	rtl
	end

****************************************************************
*
*  __ctype - character types array
*
*  This data area defines an array of bit masks.  It is used
*  to test for character types.  For example, to determine if
*  a character is alphabetic, and the uppercase and lowercase
*  bit masks with the array element for the character being
*  tested.  If the result is non-zero, the character is
*  alphabetic.
*
****************************************************************
*
__ctype	start

	dc	i1'0'					EOF
	dc	i1'_control'					$00
	dc	i1'_control'					$01
	dc	i1'_control'					$02
	dc	i1'_control'					$03
	dc	i1'_control'					$04
	dc	i1'_control'					$05
	dc	i1'_control'					$06
	dc	i1'_control'					$07
	dc	i1'_control'					$08
	dc	i1'_control+_space'					$09
	dc	i1'_control+_space'					$0A
	dc	i1'_control+_space'					$0B
	dc	i1'_control+_space'					$0C
	dc	i1'_control+_space'					$0D
	dc	i1'_control'					$0E
	dc	i1'_control'					$0F
	dc	i1'_control'					$10
	dc	i1'_control'					$11
	dc	i1'_control'					$12
	dc	i1'_control'					$13
	dc	i1'_control'					$14
	dc	i1'_control'					$15
	dc	i1'_control'					$16
	dc	i1'_control'					$17
	dc	i1'_control'					$18
	dc	i1'_control'					$19
	dc	i1'_control'					$1A
	dc	i1'_control'					$1B
	dc	i1'_control'					$1C
	dc	i1'_control'					$1D
	dc	i1'_control'					$1E
	dc	i1'_control'					$1F
	dc	i1'_space+_print'					' '
	dc	i1'_punctuation+_print'					!
	dc	i1'_punctuation+_print'					"
	dc	i1'_punctuation+_print'					#
	dc	i1'_punctuation+_print'					$
	dc	i1'_punctuation+_print'					%
	dc	i1'_punctuation+_print'					&
	dc	i1'_punctuation+_print'					'
	dc	i1'_punctuation+_print'					(
	dc	i1'_punctuation+_print'					)
	dc	i1'_punctuation+_print'					*
	dc	i1'_punctuation+_print'					+
	dc	i1'_punctuation+_print'					,
	dc	i1'_punctuation+_print'					-
	dc	i1'_punctuation+_print'					.
	dc	i1'_punctuation+_print'					/
	dc	i1'_digit+_hex+_print'					0
	dc	i1'_digit+_hex+_print'					1
	dc	i1'_digit+_hex+_print'					2
	dc	i1'_digit+_hex+_print'					3
	dc	i1'_digit+_hex+_print'					4
	dc	i1'_digit+_hex+_print'					5
	dc	i1'_digit+_hex+_print'					6
	dc	i1'_digit+_hex+_print'					7
	dc	i1'_digit+_hex+_print'					8
	dc	i1'_digit+_hex+_print'					9
	dc	i1'_punctuation+_print'					:
	dc	i1'_punctuation+_print'					;
	dc	i1'_punctuation+_print'					<
	dc	i1'_punctuation+_print'					=
	dc	i1'_punctuation+_print'					>
	dc	i1'_punctuation+_print'					?
	dc	i1'_punctuation+_print'					@
	dc	i1'_upper+_hex+_print'					A
	dc	i1'_upper+_hex+_print'					B
	dc	i1'_upper+_hex+_print'					C
	dc	i1'_upper+_hex+_print'					D
	dc	i1'_upper+_hex+_print'					E
	dc	i1'_upper+_hex+_print'					F
	dc	i1'_upper+_print'					G
	dc	i1'_upper+_print'					H
	dc	i1'_upper+_print'					I
	dc	i1'_upper+_print'					J
	dc	i1'_upper+_print'					K
	dc	i1'_upper+_print'					L
	dc	i1'_upper+_print'					M
	dc	i1'_upper+_print'					N
	dc	i1'_upper+_print'					O
	dc	i1'_upper+_print'					P
	dc	i1'_upper+_print'					Q
	dc	i1'_upper+_print'					R
	dc	i1'_upper+_print'					S
	dc	i1'_upper+_print'					T
	dc	i1'_upper+_print'					U
	dc	i1'_upper+_print'					V
	dc	i1'_upper+_print'					W
	dc	i1'_upper+_print'					X
	dc	i1'_upper+_print'					Y
	dc	i1'_upper+_print'					Z
	dc	i1'_punctuation+_print'					[
	dc	i1'_punctuation+_print'					\
	dc	i1'_punctuation+_print'					]
	dc	i1'_punctuation+_print'					^
	dc	i1'_punctuation+_print'					_
	dc	i1'_punctuation+_print'					`
	dc	i1'_lower+_hex+_print'					a
	dc	i1'_lower+_hex+_print'					b
	dc	i1'_lower+_hex+_print'					c
	dc	i1'_lower+_hex+_print'					d
	dc	i1'_lower+_hex+_print'					e
	dc	i1'_lower+_hex+_print'					f
	dc	i1'_lower+_print'					g
	dc	i1'_lower+_print'					h
	dc	i1'_lower+_print'					i
	dc	i1'_lower+_print'					j
	dc	i1'_lower+_print'					k
	dc	i1'_lower+_print'					l
	dc	i1'_lower+_print'					m
	dc	i1'_lower+_print'					n
	dc	i1'_lower+_print'					o
	dc	i1'_lower+_print'					p
	dc	i1'_lower+_print'					q
	dc	i1'_lower+_print'					r
	dc	i1'_lower+_print'					s
	dc	i1'_lower+_print'					t
	dc	i1'_lower+_print'					u
	dc	i1'_lower+_print'					v
	dc	i1'_lower+_print'					w
	dc	i1'_lower+_print'					x
	dc	i1'_lower+_print'					y
	dc	i1'_lower+_print'					z
	dc	i1'_punctuation+_print'					{
	dc	i1'_punctuation+_print'					|
	dc	i1'_punctuation+_print'					}
	dc	i1'_punctuation+_print'					~
	dc	i1'_control'					$7F
	dc	i1'0'					$80
	dc	i1'0'					$81
	dc	i1'0'					$82
	dc	i1'0'					$83
	dc	i1'0'					$84
	dc	i1'0'					$85
	dc	i1'0'					$86
	dc	i1'0'					$87
	dc	i1'0'					$88
	dc	i1'0'					$89
	dc	i1'0'					$8A
	dc	i1'0'					$8B
	dc	i1'0'					$8C
	dc	i1'0'					$8D
	dc	i1'0'					$8E
	dc	i1'0'					$8F
	dc	i1'0'					$90
	dc	i1'0'					$91
	dc	i1'0'					$92
	dc	i1'0'					$93
	dc	i1'0'					$94
	dc	i1'0'					$95
	dc	i1'0'					$96
	dc	i1'0'					$97
	dc	i1'0'					$98
	dc	i1'0'					$99
	dc	i1'0'					$9A
	dc	i1'0'					$9B
	dc	i1'0'					$9C
	dc	i1'0'					$9D
	dc	i1'0'					$9E
	dc	i1'0'					$9F
	dc	i1'0'					$A0
	dc	i1'0'					$A1
	dc	i1'0'					$A2
	dc	i1'0'					$A3
	dc	i1'0'					$A4
	dc	i1'0'					$A5
	dc	i1'0'					$A6
	dc	i1'0'					$A7
	dc	i1'0'					$A8
	dc	i1'0'					$A9
	dc	i1'0'					$AA
	dc	i1'0'					$AB
	dc	i1'0'					$AC
	dc	i1'0'					$AD
	dc	i1'0'					$AE
	dc	i1'0'					$AF
	dc	i1'0'					$B0
	dc	i1'0'					$B1
	dc	i1'0'					$B2
	dc	i1'0'					$B3
	dc	i1'0'					$B4
	dc	i1'0'					$B5
	dc	i1'0'					$B6
	dc	i1'0'					$B7
	dc	i1'0'					$B8
	dc	i1'0'					$B9
	dc	i1'0'					$BA
	dc	i1'0'					$BB
	dc	i1'0'					$BC
	dc	i1'0'					$BD
	dc	i1'0'					$BE
	dc	i1'0'					$BF
	dc	i1'0'					$C0
	dc	i1'0'					$C1
	dc	i1'0'					$C2
	dc	i1'0'					$C3
	dc	i1'0'					$C4
	dc	i1'0'					$C5
	dc	i1'0'					$C6
	dc	i1'0'					$C7
	dc	i1'0'					$C8
	dc	i1'0'					$C9
	dc	i1'0'					$CA
	dc	i1'0'					$CB
	dc	i1'0'					$CC
	dc	i1'0'					$CD
	dc	i1'0'					$CE
	dc	i1'0'					$CF
	dc	i1'0'					$D0
	dc	i1'0'					$D1
	dc	i1'0'					$D2
	dc	i1'0'					$D3
	dc	i1'0'					$D4
	dc	i1'0'					$D5
	dc	i1'0'					$D6
	dc	i1'0'					$D7
	dc	i1'0'					$D8
	dc	i1'0'					$D9
	dc	i1'0'					$DA
	dc	i1'0'					$DB
	dc	i1'0'					$DC
	dc	i1'0'					$DD
	dc	i1'0'					$DE
	dc	i1'0'					$DF
	dc	i1'0'					$E0
	dc	i1'0'					$E1
	dc	i1'0'					$E2
	dc	i1'0'					$E3
	dc	i1'0'					$E4
	dc	i1'0'					$E5
	dc	i1'0'					$E6
	dc	i1'0'					$E7
	dc	i1'0'					$E8
	dc	i1'0'					$E9
	dc	i1'0'					$EA
	dc	i1'0'					$EB
	dc	i1'0'					$EC
	dc	i1'0'					$ED
	dc	i1'0'					$EE
	dc	i1'0'					$EF
	dc	i1'0'					$F0
	dc	i1'0'					$F1
	dc	i1'0'					$F2
	dc	i1'0'					$F3
	dc	i1'0'					$F4
	dc	i1'0'					$F5
	dc	i1'0'					$F6
	dc	i1'0'					$F7
	dc	i1'0'					$F8
	dc	i1'0'					$F9
	dc	i1'0'					$FA
	dc	i1'0'					$FB
	dc	i1'0'					$FC
	dc	i1'0'					$FD
	dc	i1'0'					$FE
	dc	i1'0'					$FF
	end

****************************************************************
*
*  __ctype2 - character types array
*
*  This data area defines a second array of of bit masks.  It
*  is used to test for character types.	 For example, to
*  determine if a character is allowed as an initial character
*  in a symbol, and _csym with the array element for the
*  character being tested.  If the result is non-zero, the
*  character is alphabetic.
*
****************************************************************
*
__ctype2 start

	dc	i1'0'					EOF
	dc	i1'0'					$00
	dc	i1'0'					$01
	dc	i1'0'					$02
	dc	i1'0'					$03
	dc	i1'0'					$04
	dc	i1'0'					$05
	dc	i1'0'					$06
	dc	i1'0'					$07
	dc	i1'0'					$08
	dc	i1'0'					$09
	dc	i1'0'					$0A
	dc	i1'0'					$0B
	dc	i1'0'					$0C
	dc	i1'0'					$0D
	dc	i1'0'					$0E
	dc	i1'0'					$0F
	dc	i1'0'					$10
	dc	i1'0'					$11
	dc	i1'0'					$12
	dc	i1'0'					$13
	dc	i1'0'					$14
	dc	i1'0'					$15
	dc	i1'0'					$16
	dc	i1'0'					$17
	dc	i1'0'					$18
	dc	i1'0'					$19
	dc	i1'0'					$1A
	dc	i1'0'					$1B
	dc	i1'0'					$1C
	dc	i1'0'					$1D
	dc	i1'0'					$1E
	dc	i1'0'					$1F
	dc	i1'0'					' '
	dc	i1'0'					!
	dc	i1'0'					"
	dc	i1'0'					#
	dc	i1'0'					$
	dc	i1'0'					%
	dc	i1'0'					&
	dc	i1'0'					'
	dc	i1'0'					(
	dc	i1'0'					)
	dc	i1'0'					*
	dc	i1'0'					+
	dc	i1'0'					,
	dc	i1'0'					-
	dc	i1'0'					.
	dc	i1'0'					/
	dc	i1'_csym+_octal'					0
	dc	i1'_csym+_octal'					1
	dc	i1'_csym+_octal'					2
	dc	i1'_csym+_octal'					3
	dc	i1'_csym+_octal'					4
	dc	i1'_csym+_octal'					5
	dc	i1'_csym+_octal'					6
	dc	i1'_csym+_octal'					7
	dc	i1'_csym'					8
	dc	i1'_csym'					9
	dc	i1'0'					:
	dc	i1'0'					;
	dc	i1'0'					<
	dc	i1'0'					=
	dc	i1'0'					>
	dc	i1'0'					?
	dc	i1'0'					@
	dc	i1'_csym+_csymf'					A
	dc	i1'_csym+_csymf'					B
	dc	i1'_csym+_csymf'					C
	dc	i1'_csym+_csymf'					D
	dc	i1'_csym+_csymf'					E
	dc	i1'_csym+_csymf'					F
	dc	i1'_csym+_csymf'					G
	dc	i1'_csym+_csymf'					H
	dc	i1'_csym+_csymf'					I
	dc	i1'_csym+_csymf'					J
	dc	i1'_csym+_csymf'					K
	dc	i1'_csym+_csymf'					L
	dc	i1'_csym+_csymf'					M
	dc	i1'_csym+_csymf'					N
	dc	i1'_csym+_csymf'					O
	dc	i1'_csym+_csymf'					P
	dc	i1'_csym+_csymf'					Q
	dc	i1'_csym+_csymf'					R
	dc	i1'_csym+_csymf'					S
	dc	i1'_csym+_csymf'					T
	dc	i1'_csym+_csymf'					U
	dc	i1'_csym+_csymf'					V
	dc	i1'_csym+_csymf'					W
	dc	i1'_csym+_csymf'					X
	dc	i1'_csym+_csymf'					Y
	dc	i1'_csym+_csymf'					Z
	dc	i1'0'					[
	dc	i1'0'					\
	dc	i1'0'					]
	dc	i1'0'					^
	dc	i1'_csym+_csymf'					_
	dc	i1'0'					`
	dc	i1'_csym+_csymf'					a
	dc	i1'_csym+_csymf'					b
	dc	i1'_csym+_csymf'					c
	dc	i1'_csym+_csymf'					d
	dc	i1'_csym+_csymf'					e
	dc	i1'_csym+_csymf'					f
	dc	i1'_csym+_csymf'					g
	dc	i1'_csym+_csymf'					h
	dc	i1'_csym+_csymf'					i
	dc	i1'_csym+_csymf'					j
	dc	i1'_csym+_csymf'					k
	dc	i1'_csym+_csymf'					l
	dc	i1'_csym+_csymf'					m
	dc	i1'_csym+_csymf'					n
	dc	i1'_csym+_csymf'					o
	dc	i1'_csym+_csymf'					p
	dc	i1'_csym+_csymf'					q
	dc	i1'_csym+_csymf'					r
	dc	i1'_csym+_csymf'					s
	dc	i1'_csym+_csymf'					t
	dc	i1'_csym+_csymf'					u
	dc	i1'_csym+_csymf'					v
	dc	i1'_csym+_csymf'					w
	dc	i1'_csym+_csymf'					x
	dc	i1'_csym+_csymf'					y
	dc	i1'_csym+_csymf'					z
	dc	i1'0'					{
	dc	i1'0'					|
	dc	i1'0'					}
	dc	i1'0'					~
	dc	i1'0'					$7F
	dc	i1'0'					$80
	dc	i1'0'					$81
	dc	i1'0'					$82
	dc	i1'0'					$83
	dc	i1'0'					$84
	dc	i1'0'					$85
	dc	i1'0'					$86
	dc	i1'0'					$87
	dc	i1'0'					$88
	dc	i1'0'					$89
	dc	i1'0'					$8A
	dc	i1'0'					$8B
	dc	i1'0'					$8C
	dc	i1'0'					$8D
	dc	i1'0'					$8E
	dc	i1'0'					$8F
	dc	i1'0'					$90
	dc	i1'0'					$91
	dc	i1'0'					$92
	dc	i1'0'					$93
	dc	i1'0'					$94
	dc	i1'0'					$95
	dc	i1'0'					$96
	dc	i1'0'					$97
	dc	i1'0'					$98
	dc	i1'0'					$99
	dc	i1'0'					$9A
	dc	i1'0'					$9B
	dc	i1'0'					$9C
	dc	i1'0'					$9D
	dc	i1'0'					$9E
	dc	i1'0'					$9F
	dc	i1'0'					$A0
	dc	i1'0'					$A1
	dc	i1'0'					$A2
	dc	i1'0'					$A3
	dc	i1'0'					$A4
	dc	i1'0'					$A5
	dc	i1'0'					$A6
	dc	i1'0'					$A7
	dc	i1'0'					$A8
	dc	i1'0'					$A9
	dc	i1'0'					$AA
	dc	i1'0'					$AB
	dc	i1'0'					$AC
	dc	i1'0'					$AD
	dc	i1'0'					$AE
	dc	i1'0'					$AF
	dc	i1'0'					$B0
	dc	i1'0'					$B1
	dc	i1'0'					$B2
	dc	i1'0'					$B3
	dc	i1'0'					$B4
	dc	i1'0'					$B5
	dc	i1'0'					$B6
	dc	i1'0'					$B7
	dc	i1'0'					$B8
	dc	i1'0'					$B9
	dc	i1'0'					$BA
	dc	i1'0'					$BB
	dc	i1'0'					$BC
	dc	i1'0'					$BD
	dc	i1'0'					$BE
	dc	i1'0'					$BF
	dc	i1'0'					$C0
	dc	i1'0'					$C1
	dc	i1'0'					$C2
	dc	i1'0'					$C3
	dc	i1'0'					$C4
	dc	i1'0'					$C5
	dc	i1'0'					$C6
	dc	i1'0'					$C7
	dc	i1'0'					$C8
	dc	i1'0'					$C9
	dc	i1'0'					$CA
	dc	i1'0'					$CB
	dc	i1'0'					$CC
	dc	i1'0'					$CD
	dc	i1'0'					$CE
	dc	i1'0'					$CF
	dc	i1'0'					$D0
	dc	i1'0'					$D1
	dc	i1'0'					$D2
	dc	i1'0'					$D3
	dc	i1'0'					$D4
	dc	i1'0'					$D5
	dc	i1'0'					$D6
	dc	i1'0'					$D7
	dc	i1'0'					$D8
	dc	i1'0'					$D9
	dc	i1'0'					$DA
	dc	i1'0'					$DB
	dc	i1'0'					$DC
	dc	i1'0'					$DD
	dc	i1'0'					$DE
	dc	i1'0'					$DF
	dc	i1'0'					$E0
	dc	i1'0'					$E1
	dc	i1'0'					$E2
	dc	i1'0'					$E3
	dc	i1'0'					$E4
	dc	i1'0'					$E5
	dc	i1'0'					$E6
	dc	i1'0'					$E7
	dc	i1'0'					$E8
	dc	i1'0'					$E9
	dc	i1'0'					$EA
	dc	i1'0'					$EB
	dc	i1'0'					$EC
	dc	i1'0'					$ED
	dc	i1'0'					$EE
	dc	i1'0'					$EF
	dc	i1'0'					$F0
	dc	i1'0'					$F1
	dc	i1'0'					$F2
	dc	i1'0'					$F3
	dc	i1'0'					$F4
	dc	i1'0'					$F5
	dc	i1'0'					$F6
	dc	i1'0'					$F7
	dc	i1'0'					$F8
	dc	i1'0'					$F9
	dc	i1'0'					$FA
	dc	i1'0'					$FB
	dc	i1'0'					$FC
	dc	i1'0'					$FD
	dc	i1'0'					$FE
	dc	i1'0'					$FF
	end
