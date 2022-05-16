* Keyboard/MIDI interrupt stuff

* Define all the important MFP equates.

	def_equ	iea,$fffffa07
	def_equ	ieb,$fffffa09 
	def_equ	imb,$fffffa15
	def_equ	isrb,$fffffa11
	def_equ	ima,$fffffa13
	def_equ	keyb,$118
	def_equ	ikbd,$fffffc02

* Keyboard keys used here

alt_key		equ	$38
ctrl_key	equ	$1d
undo		equ	$61
delete		equ	$53

* Save the old vectors

save_keyints:
	move.l	keyb.w,_oldkeyb
	move.b	ieb.w,_oldieb
	move.b	iea.w,_oldiea
	move.b	imb.w,_oldimb
	move.b	isrb.w,_oldisrb
	rts

set_keyints:
	move	sr,-(sp)
	move	#$2700,sr		; Interrupts off
	move.l	#_key_handler,keyb.w	; Slot in new keyboard handler
	bset	#6,ieb.w		{ keyboard irq on
	bset	#6,imb.w		{
	move	(sp)+,sr		; Interrupts back on
	rts

* Restore old keyboard interrupts

ret_keyints:
	move	sr,-(sp)
	move	#$2700,sr
	move.l	_oldkeyb,keyb.w
	move.b	_oldieb,ieb.w
	move.b	_oldiea,iea.w
	move.b	_oldimb,imb.w
	move.b	_oldisrb,isrb.w
	move	(sp)+,sr
	lea	ikbd.w,a0		{
.flush	move.b	(a0),d0			{ - Flush any remaining keyboard data
	btst	#0,-2(a0)		{
	bne.s	.flush			{
	rts

* Old keyboard values go here.

_oldkeyb	ds.l	1
_oldiea		ds.b	1
_oldieb		ds.b	1
_oldimb		ds.b	1
_oldisrb	ds.b	1

* Keyboard handler. Called every keyboard event.

_key_handler	
	move	#$2500,sr
	movem.l	d0-a6,-(sp)
	lea	ikbd-2.w,a1		; Get keyboard registers
	move.b	(a1),d2			; Get byte
	btst	#7,d2			; if bit 7 -> no event.
	beq.s	.exit_key
	btst	#0,d2			; If bit 0 -> clear from buffer
	beq.s	.clear_key
	bsr	.get_keybyte		; Examine byte
.clear_key				; CLEAR:
	and.b	#$20,d2			;   If bit 7 also set
	beq.s	.exit_key		;     Don't bother.
	move.b	2(a1),d0		;   Get next byte
.exit_key
	movem.l	(sp)+,d0-a6
	bclr	#6,isrb.w		; Signal keyboard interrupt ready
	btst	#4,$fffffa01.w		; Another keyboard interrupt pending
	beq	_key_handler		; back to the start again
	rte

* Assuming that a keypress has been made, we'll now check the key for
; the abort sequence. If both cases, we'll only set abort on when the
; key(s) are released.

released	equ	%010000000	; Bit 7 set if key is released

.get_keybyte			
.rsip	cmp.b	#ctrl_key,2(a1)			; CTRL pressed
	bne.s	.csnp
	st	ctrl				; CTRL flag on
	rts
.csnp	cmp.b	#ctrl_key|released,2(a1)	; CTRL released
	bne.s	.csip
	sf	ctrl				; CTRL flag off
	rts
.csip	cmp.b	#alt_key,2(a1)			; ALT pressed
	bne.s	.asnp
	st	alt				; ALT flag on
	rts
.asnp	cmp.b	#alt_key|released,2(a1)		; alt released
	bne.s	.undo
	sf	alt				; ALT flag off
	rts
.undo	cmp.b	#undo|released,2(a1)		; If UNDO (released)
	bne.s	.delete
	st	abort_demo			;   Abort demo.
	rts
.delete	cmp.b	#delete,2(a1)		; If delete pressed
	bne.s	.delete_released
	if_false.s	ctrl,.bye	; ... And CONTROL ...
	if_false.s	alt,.bye	; ... And ALTERNATE ...
	st	prime_abort_sequence	; Get abort sequence ready....
	rts
.delete_released
	cmp.b	#delete|released,2(a1)			; If delete released
	if_false.s	prime_abort_sequence,.bye	; ... And CTRL-ALT-DELETE sequence started
	st	abort_demo				;   All go for an "abort demo" situation!
	rts
.bye	rts 

shift	ds.b	1
alt	ds.b	1
ctrl	ds.b	1
	even
