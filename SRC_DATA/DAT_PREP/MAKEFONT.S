* Font maker for Senior Dads "airdirt" demo.

complane	MACRO
	move.l	\1,a0
	move.l	\2,a1
	move.l	\3,plane_offset
	bsr	do_it
	ENDM

fontmake	MACRO
	move.l	\1,a0
	move.l	\2,a1
	move.l	\3,plane_offset
	bsr	f_m
	ENDM

getkey	MACRO
.loop	move	#$ff,-(sp)
	move	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst	d0
	beq	.loop
	ENDM

super	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ustack
getrez	move	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move	d0,rez
getlog	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,logbase
	movem.l	$ff8240,d0-d7
	lea	gcol,a0
	movem.l	d0-d7,(a0)
go_lo	clr	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp

;	complane #pic1,#name1,#0	
;	complane #pic2,#name2,#1	
;	complane #pic3,#name3,#2	
	fontmake #pic4,#name4,#3	

	lea	gcol,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ff8240
user	move.l	ustack,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
go_norm	move	rez,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
bye	clr	-(sp)
	trap	#1

do_it	move.l	plane_offset,d0
	add.l	d0,d0
	move.l	d0,plane_offset
	bsr	showpic
	movea.l	a0,a2
	move.l	logbase,a3
	move.l	#$1f3f,d0
clear	clr.l	(a3)+
	dbf	d0,clear
	lea	plane,a3
	adda.l	plane_offset,a2
	move.l	#4000,d0
copy2	move	(a2)+,(a3)+
	add	#6,a2
	dbf	d0,copy2
	lea	plane,a2
	move.l	logbase,a3
	move.l	#4000,d0
	adda.l	plane_offset,a3
copy3	move	(a2)+,(a3)+
	adda.l	#6,a3
	dbf	d0,copy3
	getkey
create	clr	-(sp)
	move.l	a1,-(sp)
	move	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	bye
	move	d0,handle
write	pea	plane
	move.l	#8000,-(sp)
	move	handle,-(sp)
	move	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	bye
close	move	handle,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	bmi	bye
	rts

showpic	adda.l	#2,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ff8240
	movea.l	a0,a2
	move.l	logbase,a3
	move.l	#$1f3f,d0
copy1	move.l	(a2)+,(a3)+
	dbf	d0,copy1
	getkey
	rts


f_m	move.l	plane_offset,d0
	add.l	d0,d0
	move.l	d0,plane_offset
	bsr	showpic
	adda.l	plane_offset,a0
	lea	plane,a2
	move.l	a0,d3
	move.l	d3,d4
	clr.l	d5
	addi.l	#$77ff,d4
	move.l	#1999,d0
.copy1	move	(a0)+,(a2)+
	addq.l	#6,a0
	move	(a0)+,(a2)+
	adda.l	#$96,a0
	cmp.l	d4,a0
	bgt	.creset
.cnext	dbf	d0,.copy1
	bra	create
.creset	move.l	d3,a0
	addi.l	#16,d5
	adda.l	d5,a0
	bra	.cnext

rez		ds.w	1
handle		ds.w	1
logbase		ds.l	1
ustack		ds.l	1
plane_offset	ds.l	1
gcol		ds.l	8

;name1	dc.b	'a:\planes.dat\plane1.dat',0
;name2	dc.b	'a:\planes.dat\plane2.dat',0
;name3	dc.b	'a:\planes.dat\plane3.dat',0
name4	dc.b	'crapfont.dat',0

;pic1	incbin	plane1.pi1
;pic2	incbin	plane2.pi1
;pic3	incbin	plane3.pi1
pic4	incbin	font.pi1

plane	ds.l	2000
