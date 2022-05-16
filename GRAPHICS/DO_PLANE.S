* Prepare logo

plane	equ	0

main	lea	logo_start+(plane*2),a0
	lea	new_logo_start,a1
.loop	cmpa.l	#logo_end,a0
	bge.s	.exit
	move.w	(a0),(a1)+
	addq.l	#8,a0
	bra.s	.loop
.exit	rts

logo_start
	incbin	seniorl.tru
logo_end
	even
new_logo_start
	ds.b	(logo_end-logo_start)/4
new_logo_end
	even
