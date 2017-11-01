	keep	obj/string
	case	on
	mcopy string.macros
****************************************************************
*
*  String - String Processing Library
*
*  This code implements the subroutines needed to support the
*  standard C library STRING.
*
*  December 1988
*  Mike Westerfield
*
*  Copyright 1988
*  Byte Works, Inc.
*
****************************************************************
*
String	start		dummy routine

	end

****************************************************************
*
*  c2pCommon - common work buffer for c2pstr and p2cstr
*
****************************************************************
*
c2pCommon privdata

str1	ds	258
	end

****************************************************************
*
*  char *c2pstr(str)
*	char *str;
*
*  Inputs:
*	str - pointer to the c string to convert
*
*  Outputs:
*	Returns a pointer to the p string.
*
*  Notes:
*	Any characters after the 255th are truncated without
*	warning.
*
****************************************************************
*
c2pstr	start
	using c2pCommon
addr	equ	1

	csubroutine (4:str),4
	phb
	phk
	plb

	short I,M
	ldy	#0
lb1	lda	[str],Y
	sta	str1+1,Y
	beq	lb2
	iny
	bne	lb1
	dey
lb2	sty	str1
	long	I,M
	lla	addr,str1

	plb
	creturn 4:addr
	end

****************************************************************
*
*  makeset - create a set of characters
*
*  This subroutine is called by strspn, strcspn, strpbrk and
*  strrpbrk to create a set of characters.
*
*  Inputs:
*	set - pointer to the set of characters
*
*  Outputs:
*	strset - set of bytes; non-sero for chars in set
*
****************************************************************
*
makeset	private
set	equ	8	string set

	lda	set	if the set is null then
	ora	set+2
	beq	lb3	  return

	lda	#0	clear the string set
	sta	>strset
	phb
	move	strset,strset+1,#255
	plb

	short I,M	while there are chars in the set do
	ldy	#0
lb1	lda	[set],Y
	beq	lb2
	tax		  set the array element for this char
	lda	#1
	sta	>strset,X
	iny		endwhile
	bne	lb1
	inc	set+1
	bne	lb1
	inc	set+2
	bra	lb1

lb2	long	I,M
lb3	rts
	end

****************************************************************
*
*  memchr - find a byte in memory
*
*  Returns a pointer to the byte in memory
*
*  Inputs:
*	ptr - first byte to search
*	val - byte to search for
*	len - # bytes to search
*
*  Outputs:
*	A,X - pointer to the byte; NULL for no match
*
****************************************************************
*
memchr	start
ptr	equ	4	pointer to the first byte
val	equ	8	byte to search for
len	equ	10	# bytes to search
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd

	short M
	ldy	#0
	ldx	len+2	scan 64K blocks
	beq	lb1a
lb1	lda	[ptr],Y
	cmp	val
	beq	lb3
	iny
	bne	lb1
	inc	ptr+2
	dex
	bne	lb1

lb1a	ldx	len
	beq	lb2a
lb2	lda	[ptr],Y	scan the remaining characters
	cmp	val
	beq	lb3
	iny
	dex
	bne	lb2

lb2a	long	M	no match found -> return NULL
	ldx	#0
	txy
	bra	lb4

lb3	long	M	compute the length
	tya
	clc
	adc	ptr
	tay
	ldx	ptr+2
	bcc	lb4
	inx

lb4	lda	rtl+1	remove parameters from the stack
	sta	len+2
	lda	rtl
	sta	len+1
	pld
	tsc
	clc
	adc	#10
	tcs
	tya		return the pointer in X-A
	rtl
	end

****************************************************************
*
*  memcmp - memory compare
*
*  Compare *s1 to *s2.  If *s1 < *s2 then return -1; if they are
*  equal, return 0; otherwise, return 1.
*
*  Inputs:
*	p1 - string to concatonate to
*	p2 - string to concatonate
*
*  Outputs:
*	A - result
*
****************************************************************
*
memcmp	start
p1	equ	4	pointer to memory area 1
p2	equ	8	pointer to memory area 2
len	equ	12	length to compare
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd

	short M
	ldy	#0	scan 64K chunks
	ldx	len+2
	beq	lb2
lb1	lda	[p1],Y
	cmp	[p2],Y
	bne	lb4
	iny
	bne	lb1
	inc	p1+2
	inc	p2+2
	dex
	bne	lb1

lb2	ldx	len
	beq	lb5
lb3	lda	[p1],Y	scan until the end of memory is reached
	cmp	[p2],Y	 or a difference is found
	bne	lb4
	iny
	dex
	bne	lb3

	ldx	#0	memory matches
	bra	lb5

lb4	blt	less	memory differs - set the result
	ldx	#1
	bra	lb5

less	ldx	#-1

lb5	long	M
	lda	rtl	remove the parameters from the stack
	sta	len+1
	lda	rtl+1
	sta	len+2
	pld
	tsc
	clc
	adc	#12
	tcs
	txa		return the result
	rtl
	end

****************************************************************
*
*  memcpy - memory copy
*
*  Copy len bytes from p1 to p2.
*
*  Inputs:
*	p1 - destination pointer
*	p2 - source pointer
*	len - # bytes to copy
*
*  Outputs:
*	X-A - p1
*
*  Notes: The memory areas should not overlap
*
****************************************************************
*
memcpy	start
p1	equ	4	destination pointer
p2	equ	8	source pointer
len	equ	12	length to compare
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd

	ph4	p1	save the dest pointer

	lda	len	if there are an odd # of bytes then
	lsr	A
	bcc	lb1
	short M	  move 1 byte now
	lda	[p2]
	sta	[p1]
	long	M
	dec	len
	inc4	p1
	inc4	p2
lb1	anop		endif

	ldx	len+2	move full banks of memory
	beq	lb1b
	ldy	#0
lb1a	lda	[p2],Y
	sta	[p1],Y
	dey
	dey
	bne	lb1a
	inc	p2+2
	inc	p1+2
	dex
	bne	lb1a
lb1b	ldy	len	move len bytes
	beq	lb4
	dey
	dey
	beq	lb3
lb2	lda	[p2],Y
	sta	[p1],Y
	dey
	dey
	bne	lb2
lb3	lda	[p2]
	sta	[p1]

lb4	ply		get the original source pointer
	plx
	lda	rtl	remove the parameters from the stack
	sta	len+1
	lda	rtl+1
	sta	len+2
	pld
	tsc
	clc
	adc	#12
	tcs
	tya		return the result
	rtl
	end

****************************************************************
*
*  memmove - memory move
*
*  Move len bytes from p1 to p2.
*
*  Inputs:
*	p1 - destination pointer
*	p2 - source pointer
*	len - # bytes to copy
*
*  Outputs:
*	X-A - p2
*
*  Notes: The memory areas may overlap; the move will still work
*
****************************************************************
*
memmove	start
p1	equ	4	destination pointer
p2	equ	8	source pointer
len	equ	12	length to compare
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd

	ph4	p1	save the dest pointer

	lda	p1+2	if p1 < p2 then
	cmp	p2+2
	bne	lb1
	lda	p1
	cmp	p2
lb1	bge	lb5

	short M	  move len bytes, starting with the 1st
	ldy	#0
	ldx	len+2	  move 64K chunks
	beq	lb3
lb2	lda	[p2],Y
	sta	[p1],Y
	iny
	bne	lb2
	inc	p2+2
	inc	p1+2
	dex
	bne	lb2
lb3	ldx	len	  skip if there are no more bytes to
	beq	lb11	    move
lb4	lda	[p2],Y	  move the remaining bytes
	sta	[p1],Y
	iny
	dex
	bne	lb4
	bra	lb11	else

	longa on

lb5	add2	p1+2,len+2	  move len bytes, starting from the end
	add2	p2+2,len+2
	short M
	ldy	len	  branch if there are no individual
	beq	lb8	    bytes to move
	dey		  move the individual bytes
	beq	lb7
lb6	lda	[p2],Y
	sta	[p1],Y
	dey
	bne	lb6
lb7	lda	[p2]
	sta	[p1]
lb8	ldx	len+2	  branch if there are no 64K chunks to
	beq	lb11	    move
lb9	dec	p1+2	  move the 64K chunks
	dec	p2+2
	ldy	#$FFFF
lb10	lda	[p2],Y
	sta	[p1],Y
	dey
	bne	lb10
	lda	[p2]
	sta	[p1]
	dex
	bne	lb9

lb11	long	M
	ply		get the original source pointer
	plx
	lda	rtl	remove the parameters from the stack
	sta	len+1
	lda	rtl+1
	sta	len+2
	pld
	tsc
	clc
	adc	#12
	tcs
	tya		return the result
	rtl
	end

****************************************************************
*
*  memset - set memory to a value
*
*  Set len bytes, starting at p, to val.
*
*  Inputs:
*	p - destination pointer
*	val - value (byte!) to set memory to
*	len - # bytes to set
*
*  Outputs:
*	X-A - p
*
*  Notes: The memory areas should not overlap
*
****************************************************************
*
memset	start
p	equ	4	destination pointer
val	equ	8	source pointer
len	equ	10	length to compare
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd

	ph4	p	save the pointer

	lda	val	form a 2 byte value
	xba
	ora	val
	sta	val

	lda	len	if there are an odd # of bytes then
	lsr	A
	bcc	lb1
	short M	  set 1 byte now
	lda	val
	sta	[p]
	long	M
	dec	len
	inc4	p
lb1	anop		endif

	lda	val	set len bytes
	ldx	len+2	set full banks
	beq	lb1b
	ldy	#0
lb1a	sta	[p],Y
	dey
	dey
	bne	lb1a
	inc	p+2
	dex
	bne	lb1a
lb1b	ldy	len	set a partial bank
	beq	lb4
	dey
	dey
	beq	lb3
lb2	sta	[p],Y
	dey
	dey
	bne	lb2
lb3	sta	[p]

lb4	ply		get the original source pointer
	plx
	lda	rtl	remove the parameters from the stack
	sta	len+1
	lda	rtl+1
	sta	len+2
	pld
	tsc
	clc
	adc	#10
	tcs
	tya		return the result
	rtl
	end

****************************************************************
*
*  char *p2cstr(str)
*	char *str;
*
*  Inputs:
*	str - pointer to the p string to convert
*
*  Outputs:
*	Returns a pointer to the c string.
*
****************************************************************
*
p2cstr	start
	using c2pCommon
addr	equ	1

	csubroutine (4:str),4
	phb
	phk
	plb

	short I,M
	lda	[str]
	tay
	lda	#0
	sta	str1,Y
	tyx
	beq	lb2
lb1	lda	[str],Y
	sta	str1-1,Y
	dey
	bne	lb1
lb2	long	I,M
	lla	addr,str1

	plb
	creturn 4:addr
	end

****************************************************************
*
*  strcat - string concatonation
*
*  Place *s2 at the end of *s1, returning a pointer to *s1.  No
*  checking for length is performed.
*
*  Inputs:
*	s1 - string to concatonate to
*	s2 - string to concatonate
*
*  Outputs:
*	X-A - pointer to the result (s1)
*
****************************************************************
*
strcat	start
s1	equ	8	pointer to string 1
s2	equ	12	pointer to string 2
rtl	equ	5	return address
rval	equ	1	string value to return

	lda	6,S	save the starting value of s1
	pha
	lda	6,S
	pha
	tsc		establish DP addressing
	phd
	tcd

	ldy	#0	advance s1 to point to the terminating
	short M	 null
lb1	lda	[s1],Y
	beq	lb2
	iny
	bne	lb1
	inc	s1+2
	bra	lb1
lb2	long	M
	tya
	clc
	adc	s1
	sta	s1
	short M	copy characters 'til the null is found
	ldy	#0
lb3	lda	[s2],Y
	sta	[s1],Y
	beq	lb4
	iny
	bne	lb3
	inc	s1+2
	inc	s2+2
	bra	lb3

lb4	long	M	return to the caller
	lda	rtl
	sta	s2+1
	lda	rtl+1
	sta	s2+2
	ldx	rval+2
	ldy	rval
	pld
	tsc
	clc
	adc	#12
	tcs
	tya
	rtl
	end

****************************************************************
*
*  strchr - find a character in a string
*
*  Returns a pointer to the character in the string
*
*  Inputs:
*	str - string to search
*	c - character to search for
*
*  Outputs:
*	A,X - pointer to the character; NULL for no match
*
****************************************************************
*
strchr	start
str	equ	4	pointer to the string
c	equ	8	character

	tsc		establish DP addressing
	phd
	tcd

	short M	advance s1 to point to the char
	ldy	#0
lb1	lda	[str],Y
	cmp	c
	beq	lb3
	cmp	#0
	beq	lb2
	iny
	bne	lb1
	inc	str+2
	bra	lb1

lb2	long	M	no match found -> return NULL
	ldy	#0
	tyx
	bra	lb4

lb3	long	M	compute the length
	tya
	clc
	adc	str
	tay
	ldx	str+2
	bcc	lb4
	inx

lb4	pld		remove parameters from the stack
	lda	2,S
	sta	8,S
	pla
	sta	5,S
	pla
	pla
	tya		return the pointer in X-A
	rtl
	end

****************************************************************
*
*  strcmp - string compare
*
*  Compare *s1 to *s2.  If *s1 < *s2 then return -1; if they are
*  equal, return 0; otherwise, return 1.
*
*  Inputs:
*	s1 - first string ptr
*	s2 - second string ptr
*
*  Outputs:
*	A - result
*
****************************************************************
*
strcmp	start
s1	equ	4	pointer to string 1
s2	equ	8	pointer to string 2
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd

	ldy	#0	scan until the end of string is reached
	short M	 or a difference is found
lb1	lda	[s1],Y
	beq	lb2
	cmp	[s2],Y
	bne	lb3
	iny
	bne	lb1
	inc	s1+2
	inc	s2+2
	bra	lb1

lb2	ldx	#0	s1 is finished.	 If s2 is, too, the
	lda	[s2],Y	 strings are equal.
	beq	lb4
less	ldx	#-1	It wasn't, so *s1 < *s2
	bra	lb4

lb3	blt	less	the strings differ - set the result
	ldx	#1

lb4	long	M
	lda	rtl	remove the parameters from the stack
	sta	s2+1
	lda	rtl+1
	sta	s2+2
	pld
	tsc
	clc
	adc	#8
	tcs
	txa		return the result
	rtl
	end

****************************************************************
*
*  strcpy - string copy
*
*  Copy string *s2 to string *s1.  Return a pointer to s1.
*
*  Inputs:
*	s1 - string to copy to
*	s2 - string to copy
*
*  Outputs:
*	X-A - pointer to the result (s1)
*
****************************************************************
*
strcpy	start
s1	equ	8	pointer to string 1
s2	equ	12	pointer to string 2
rtl	equ	5	return address
rval	equ	1	string value to return

	lda	6,S	save the starting value of s1
	pha
	lda	6,S
	pha
	tsc		establish DP addressing
	phd
	tcd

	short M	copy characters 'til the null is found
	ldy	#0
lb1	lda	[s2],Y
	sta	[s1],Y
	beq	lb2
	iny
	bne	lb1
	inc	s1+2
	inc	s2+2
	bra	lb1

lb2	long	M	return to the caller
	lda	rtl
	sta	s2+1
	lda	rtl+1
	sta	s2+2
	ldx	rval+2
	ldy	rval
	pld
	tsc
	clc
	adc	#12
	tcs
	tya
	rtl
	end

****************************************************************
*
*  strcspn - find the first char in s in set
*
*  Inputs:
*	s - pointer to the string to scan
*	set - set of characters to check against
*
*  Outputs:
*	A - disp to first char in s
*
****************************************************************
*
strcspn	start
s	equ	4	string to scan
set	equ	8	set of characters
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd

	jsr	makeset	form the set of characters

	stz	set	set initial displacement
	stz	set+2
	short I,M	scan for a matching char
	ldy	#0
lb1	lda	[s],Y
	beq	lb2
	tax
	lda	>strset,X
	bne	lb2
	iny
	bne	lb1
	long	M
	inc	s+1
	inc	set+1
	short M
	bra	lb1
lb2	sty	set	set the disp past the current disp

	long	I,M
	ldx	set+2	get the return value
	ldy	set
	lda	rtl+1	remove the parameters
	sta	set+2
	lda	rtl
	sta	set+1
	pld
	tsc
	clc
	adc	#8
	tcs
	tya		return the disp
	rtl
	end

****************************************************************
*
*  strerror - return the addr of an error message
*
*  Inputs:
*	err - error number to return the error for
*
****************************************************************
*
strerror start

	phb		get the error number
	plx
	ply
	pla
	phy
	phx
	phk		use local data bank
	plb
	asl	A	compute the index
	asl	A
	tay
	ldx	sys_errlist+2,Y	load the address
	lda	sys_errlist,Y
	plb		restore caller's data bank
	rtl
	end

****************************************************************
*
*  strlen - find the length of a string
*
*  Returns the length of the string.
*
*  Inputs:
*	str - string to find the length of
*
*  Outputs:
*	X-A - length of the string
*
****************************************************************
*
strlen	start
str	equ	4	pointer to the string

	tsc		establish DP addressing
	phd
	tcd

	ldy	#0	advance s1 to point to the terminating
	ldx	#0	 null
	short M
lb1	lda	[str],Y
	beq	lb2
	iny
	bne	lb1
	inx
	inc	str+2
	bra	lb1

lb2	long	M
	pld		remove str from the stack
	lda	2,S
	sta	6,S
	pla
	sta	3,S
	pla
	tya		return the length
	rtl
	end

****************************************************************
*
*  strncat - string concatonation with max length
*
*  Place *s2 at the end of *s1, returning a pointer to *s1.  No
*  checking for length is performed.
*
*  Inputs:
*	s1 - string to concatonate to
*	s2 - string to concatonate
*	n - max # chars to copy
*
*  Outputs:
*	X-A - pointer to the result (s1)
*
****************************************************************
*
strncat	start
rval	equ	1	string value to return

	csubroutine (4:s1,4:s2,4:n),4

	move4 s1,rval	save the address to return
	ldy	#0	advance s1 to point to the terminating
	short M	 null
lb1	lda	[s1],Y
	beq	lb2
	iny
	bne	lb1
	inc	s1+2
	bra	lb1
lb2	long	M
	tya
	clc
	adc	s1
	sta	s1
	short M	copy characters 'til the null is found
	ldy	#0
	ldx	n
	beq	lb4
	bmi	lb4
lb3	lda	[s2],Y
	sta	[s1],Y
	beq	lb4
	iny
	dex
	bne	lb3
	lda	n+2
	beq	lb4
	dec	n+2
	bra	lb3

lb4	lda	#0	write the terminating null
	sta	[s1],Y
	long	M	return to the caller

	creturn 4:rval
	end

****************************************************************
*
*  strncmp - string compare; max length of n
*
*  Compare *s1 to *s2.  If *s1 < *s2 then return -1; if they are
*  equal, return 0; otherwise, return 1.
*
*  Inputs:
*	s1 - string to concatonate to
*	s2 - string to concatonate
*	n - max length of the strings
*
*  Outputs:
*	A - result
*
****************************************************************
*
strncmp	start
flag	equ	1	return flag

	csubroutine (4:s1,4:s2,4:n),2

	ldy	#0	scan until the end of string is reached
	ldx	n+2	 or a difference is found
	bmi	equal
	bne	lb0
	ldx	n
	beq	equal
lb0	ldx	n
	short M
lb1	lda	[s1],Y
	beq	lb2
	cmp	[s2],Y
	bne	lb3
	dex
	bne	lb1a
	lda	n+2
	beq	equal
	dec	n+2
lb1a	iny
	bne	lb1
	inc	s1+2
	inc	s2+2
	bra	lb1

lb2	ldx	#0	s1 is finished.	 If s2 is, too, the
	lda	[s2],Y	 strings are equal.
	beq	lb4
less	ldx	#-1	It wasn't, so *s1 < *s2
	bra	lb4

equal	ldx	#0
	bra	lb4

lb3	blt	less	the strings differ - set the result
	ldx	#1

lb4	stx	flag	return the result
	long	M
	creturn 2:flag
	end

****************************************************************
*
*  strncpy - string copy; max length of n
*
*  Copy string *s2 to string *s1.  Return a pointer to s1.
*
*  Inputs:
*	s1 - string to copy to
*	s2 - string to copy
*	n - max length of the string
*
*  Outputs:
*	X-A - pointer to the result (s1)
*
****************************************************************
*
strncpy	start
rval	equ	1	string value to return

	csubroutine (4:s1,4:s2,4:n),4

	move4 s1,rval	save the address to return
	short M	copy characters 'til the null is found
	ldy	#0	 or we have copied n characters
	ldx	n+2
	bmi	lb4
	bne	lb0
	ldx	n
	beq	lb4
lb0	ldx	n
lb1	lda	[s2],Y
	sta	[s1],Y
	beq	lb2
	dex
	bne	lb1a
	lda	n+2
	beq	lb4
	dec	n+2
lb1a	iny
	bne	lb1
	inc	s1+2
	inc	s2+2
	bra	lb1

lb3	iny		null terminate the string
	sta	[s1],Y
lb2	dex
	bne	lb3

lb4	long	M	return to the caller
	creturn 4:rval
	end

****************************************************************
*
*  strpbrk - find the first char in s in set
*
*  Inputs:
*	s - pointer to the string to scan
*	set - set of characters to check against
*
*  Outputs:
*	X-A - pointer to first char in s; NULL if none found
*
****************************************************************
*
strpbrk	start
s	equ	4	string to scan
set	equ	8	set of characters
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd

	jsr	makeset	form the set of characters

	short I,M	scan for a matching char
	ldy	#0
lb1	lda	[s],Y
	beq	lb2
	tax
	lda	>strset,X
	bne	lb3
	iny
	bne	lb1
	long	M
	inc	s+1
	short M
	bra	lb1

lb2	long	I,M	no match found -> return NULL
	ldx	#0
	txy
	bra	lb4

lb3	long	I,M	increment s by Y and load the value
	tya
	and	#$00FF
	clc
	adc	s
	tay
	lda	s+2
	adc	#0
	tax

lb4	lda	rtl+1	remove the parameters
	sta	set+2
	lda	rtl
	sta	set+1
	pld
	tsc
	clc
	adc	#8
	tcs
	tya		return the ptr
	rtl
	end

****************************************************************
*
*  strpos - find a character in a string
*
*  Returns the position of a character in a string
*
*  Inputs:
*	str - string to search
*	c - character to search for
*
*  Outputs:
*	A - position of the character; -1 of none
*
****************************************************************
*
strpos	start
str	equ	4	pointer to the string
c	equ	8	character

	tsc		establish DP addressing
	phd
	tcd

	ldy	#0	advance s1 to point to the char
	short M
lb1	lda	[str],Y
	cmp	c
	beq	lb3
	cmp	#0
	beq	lb2
	iny
	bpl	lb1

lb2	ldy	#-1	no match found -> return -1

lb3	long	M
	pld		remove parameters from the stack
	lda	2,S
	sta	8,S
	pla
	sta	5,S
	pla
	pla
	tya		return the result
	rtl
	end

****************************************************************
*
*  strrchr - find the last occurrance of a character in a string
*
*  Returns a pointer to the last occurrance of the character
*
*  Inputs:
*	str - string to search
*	c - character to search for
*
*  Outputs:
*	A,X - pointer to the character; NULL for no match
*
****************************************************************
*
strrchr	start
str	equ	8	pointer to the string
c	equ	12	character
ptr	equ	1	result pointer

	pea	0	initialize the result
	pea	0
	tsc		establish DP addressing
	phd
	tcd

	short M	advance s1 to point to the char
	ldy	#0
lb1	lda	[str],Y
	cmp	c
	beq	lb3
	cmp	#0
	beq	lb4
lb2	iny
	bne	lb1
	inc	str+2
	bra	lb1

lb3	long	M	compute the pointer
	tya
	clc
	adc	str
	sta	ptr
	lda	str+2
	adc	#0
	sta	ptr+2
	sep	#$20
	lda	[str],Y
	bne	lb2

lb4	long	M
	pld		rest DP
	ply		remove the return value
	plx
	lda	2,S	remove the parameters
	sta	8,S
	pla
	sta	5,S
	pla
	pla
	tya		return the pointer in X-A
	rtl
	end

****************************************************************
*
*  strrpos - find the last occurrance of a character in a string
*
*  Returns the position of the las occurrance of the character
*
*  Inputs:
*	str - string to search
*	c - character to search for
*
*  Outputs:
*	A - position of the character; -1 of none
*
****************************************************************
*
strrpos	start
str	equ	4	pointer to the string
c	equ	8	character

	tsc		establish DP addressing
	phd
	tcd

	ldx	#-1	assume we won't find it
	ldy	#0	advance s1 to point to the char
	short M
lb1	lda	[str],Y
	cmp	c
	bne	lb2
	tyx
lb2	cmp	#0
	beq	lb3
	iny
	bpl	lb1

lb3	long	M
	pld		remove parameters from the stack
	lda	2,S
	sta	8,S
	pla
	sta	5,S
	pla
	pla
	txa		return the result
	rtl
	end

****************************************************************
*
*  strrpbrk - find the first char in s in set
*
*  Inputs:
*	s - pointer to the string to scan
*	set - set of characters to check against
*
*  Outputs:
*	X-A - pointer to first char in s; NULL if none found
*
****************************************************************
*
strrpbrk start
s	equ	4	string to scan
set	equ	8	set of characters
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd

	jsr	makeset	form the set of characters

	stz	set	assume no match will be found
	stz	set+2
	short I,M	scan for a matching char
	ldy	#0
lb1	lda	[s],Y
	beq	lb4
	tax
	lda	>strset,X
	bne	lb3
lb2	iny
	bne	lb1
	long	M
	inc	s+1
	short M
	bra	lb1

lb3	long	I,M	set the address of the match found
	tya
	and	#$00FF
	clc
	adc	s
	sta	set
	lda	s+2
	adc	#0
	sta	set+2
	short I,M
	bra	lb2

lb4	long	I,M
	ldy	set	get the address
	ldx	set+2
	lda	rtl+1	remove the parameters
	sta	set+2
	lda	rtl
	sta	set+1
	pld
	tsc
	clc
	adc	#8
	tcs
	tya		return the ptr
	rtl
	end

****************************************************************
*
*  strset - work area for string operations
*
****************************************************************
*
strset	private

	ds	256
	end

****************************************************************
*
*  strspn - find the first char in s not in set
*
*  Inputs:
*	s - pointer to the string to scan
*	set - set of characters to check against
*
*  Outputs:
*	A - disp to first char not in s
*
****************************************************************
*
strspn	start
s	equ	4	string to scan
set	equ	8	set of characters
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd

	jsr	makeset	form the set of characters

	stz	set	set initial displacement
	stz	set+2
	short I,M	scan for a non-matching char
	ldy	#0
lb1	lda	[s],Y
	beq	lb2
	tax
	lda	>strset,X
	beq	lb2
	iny
	bne	lb1
	long	M
	inc	s+1
	inc	set+1
	short M
	bra	lb1
lb2	sty	set	set the disp past the current disp

	long	I,M
	ldx	set+2	get the return value
	ldy	set
	lda	rtl+1	remove the parameters
	sta	set+2
	lda	rtl
	sta	set+1
	pld
	tsc
	clc
	adc	#8
	tcs
	tya		return the disp
	rtl
	end

****************************************************************
*
*  strstr - string search
*
*  Inputs:
*	src - string to search
*	sub - string to search for
*
*  Outputs:
*	X-A - pointer to the string; NULL if not found
*
****************************************************************
*
strstr	start
len	equ	1	length of remaining string - strlen(sub)
lensub	equ	5	strlen(sub)
p1	equ	9	temp pointer
p2	equ	13
cnt	equ	17	temp counter
num1	equ	21	temp number

workLen	equ	24	length of work space

src	equ	workLen+4	string to scan
sub	equ	workLen+8	string to search for
rtl	equ	workLen+1	return address
;
;  Set up our local variables
;
	tsc		create work space
	sec
	sbc	#workLen
	tcs
	tsc		establish DP addressing
	phd
	tcd
	phb		use local data areas
	phk
	plb
;
;  Calculate the max # chars we can search
;
	lda	sub	if the search string is null, return null
	ora	sub+2
	beq	fl2
	lda	src	if the string to search is null,
	ora	src+2	 return null
	beq	fl2
	ph4	sub	get the length of the search string
	jsl	strlen
	stx	strset+2
	sta	strset
	stx	lensub+2
	sta	lensub
	ora	lensub+2	if the length is 0 then
	jeq	rt1	  return the search string
	ph4	src	get the length of the string to search
	jsl	strlen
	sec		subtract off the length of the search
	sbc	lensub	 string
	bvs	fl2
	sta	len
	txa
	sbc	lensub+2
	sta	len+2
	bpl	fl3	if there aren't enough chars for a match
fl2	stz	src
	stz	src+2	  then return NULL
	brl	rt1
fl3	anop
;
;  Set up the displacement array (used to see how far we can shift)
;
	lda	strset+1	if strlen(sub) > 255 then
	ora	strset+2	  use 255 for the max move
	beq	ds1
	lda	#255
	sta	strset
ds1	move	strset,strset+1,#255	init all char disps to strlen(sub)

	lda	strset	skip if the length is 1
	and	#$00FF
	dec	A
	beq	ds5

	stz	cnt	no chars processed so far
	stz	cnt+2
	move4 sub,p1	for each char but the last do
ds3	lda	[p1]	  branch if this is the last char
	and	#$FF00
	beq	ds5
	sub4	lensub,cnt,num1	  compute strlen(sub) - cnt - 1
	dec4	num1
	lda	num1+1
	ora	num1+2
	bne	ds4	  if the result is <= 255 then
	short I,M	    set the char index
	lda	[p1]
	tax
	lda	num1
	sta	strset,X
	long	I,M
ds4	inc4	cnt	next char
	inc4	p1
	bra	ds3
ds5	anop
;
;  Search for the string
;
ss0	lda	lensub	if the length of the sreach string is
	and	#$8000	  > 32767 then use a long method
	ora	lensub+2
	beq	ss3

	add4	lensub,src,p1	 set the pointer to the end of the
	dec4	p1	  string to search
	add4	lensub,sub,p2	 set the pointer to the end of the
	dec4	p2	  search string
	move4 lensub,cnt	 set the # chars to check
ss1	lda	[p1]	 branch if the characters do not match
	eor	[p2]
	and	#$00FF
	bne	ss2
	dec4	p1	 match - next char
	dec4	p2
	dec4	cnt
	lda	cnt
	ora	cnt+2
	bne	ss1
	bra	rt1	 match - return the pointer

ss2	add4	lensub,src,p1	 no match - find the skip length
	dec4	p1
	lda	[p1]
	bra	ss6	 go to common handling for no match

ss3	ldy	lensub	strlen(sub) < 32K, so use fast search
	dey
	short M
ss4	lda	[src],Y
	cmp	[sub],Y
	bne	ss5
	dey
	bpl	ss4
	long	M	 match - return the pointer
	bra	rt1

ss5	long	M	 no match - find the skip length
	ldy	lensub
	dey
	lda	[src],Y
ss6	and	#$00FF
	tax
	lda	strset,X
	and	#$00FF
	sta	cnt	update the source string pointer
	clc
	adc	src
	sta	src
	bcc	ss7
	inc	src+2
ss7	sec		update the # of chars left
	lda	len
	sbc	cnt
	sta	len
	lda	len+2
	sbc	#0
	sta	len+2
	jcs	ss0	go try for another match

	stz	src	no match - return NULL
	stz	src+2
;
;  Return to the caller
;
rt1	ldx	src+2	get the return value
	ldy	src
	lda	rtl+1	remove the parameters
	sta	sub+2
	lda	rtl
	sta	sub+1
	plb
	pld
	tsc
	clc
	adc	#8+workLen
	tcs
	tya		return the disp
	rtl
	end

****************************************************************
*
*  strtok - find a token
*
*  Inputs:
*	s - pointer to the string to scan
*	set - set of characters to check against
*
*  Outputs:
*	X-A - pointer to the token; NULL if none
*
****************************************************************
*
strtok	start
s	equ	4	string to scan
set	equ	8	set of characters
rtl	equ	1	return address

	tsc		establish DP addressing
	phd
	tcd
	phb		use our local direct page
	phk
	plb

	jsr	makeset	form the set of characters

	lda	s	if s is not NULL then
	ora	s+2
	beq	lb3
	short I,M	  scan for a non-matching char
	ldy	s
	stz	s
lb1	lda	[s],Y
	tax
	lda	strset,X
	beq	lb2
	iny
	bne	lb1
	long	M
	inc	s+1
	short M
	bra	lb1
lb2	sty	s	  set the disp past the current disp
	long	I,M
	bra	lb4	else
lb3	lda	isp	  s := internal state pointer
	ldx	isp+2
	sta	s
	stx	s+2
lb4	anop		endif

	lda	[s]	if we are at the end of the string then
	and	#$00FF
	bne	lb5
	stz	set	  return NULL
	stz	set+2
	stz	isp	  set the isp to NULL
	stz	isp+2
	bra	lb10	else
lb5	lda	[s]	  scan to the 1st char not in the set
	and	#$00FF
	beq	lb8a
	tax
	lda	strset,X
	and	#$00FF
	beq	lb6
	inc4	s
	bra	lb5
lb6	lda	s	  return a ptr to the string
	sta	set
	lda	s+2
	sta	set+2
lb7	lda	[s]	  scan to the 1st char in the set
	and	#$00FF
	beq	lb8a
	tax
	lda	strset,X
	and	#$00FF
	bne	lb8
	inc4	s
	bra	lb7
lb8	short M	  if a match was found then
	lda	#0	    null terminate the token
	sta	[s]
	long	I,M	    set isp to the char past the token
	add4	s,#1,isp
	bra	lb9
lb8a	long	I,M	  else
	stz	isp	    set isp to NULL
	stz	isp+2
lb9	anop		  endif

lb10	ldx	set+2	get the return value
	ldy	set
	lda	rtl+1	remove the parameters
	sta	set+2
	lda	rtl
	sta	set+1
	plb
	pld
	tsc
	clc
	adc	#8
	tcs
	tya		return the disp
	rtl

isp	ds	4	internal state pointer (isp)
	end
