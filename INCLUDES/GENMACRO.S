* General macros

* Define macro- only defines an equate if not defined already
def_equ	macro	label,value
	IFND	\1
	list +
* Defining	\1 as \2
	list -
\1	equ	\2
	ELSE
	list +
* \1 is already defined.
	list -
	ENDC
	ENDM

* Vector values

vbl		equ	$70

c16regs		equ	$ffff8240
st_res		equ	$ffff8260
vidhimid	equ	$ffff8200
vidlo		equ	$ffff820d
st_sync		equ	$ffff820a
c256regs	equ	$ffff9800
timer		equ	$468
keyclick	equ	$484

iea		equ	$fffffa07
ima		equ	$fffffa13
timer_b_control	equ	$fffffa1b
timer_b_data	equ	$fffffa21
vector_register	equ	$fffffa17

* The following is a load of pseudo-compiler stuff. If FASTER_MODE
; equals zero, then a check in stack_save for single data registers
; is made and for those, 'move.l' is used in place of 'movem.l'. This
; slows down the assembly, and so it can be switched of by making 
; FASTER_MODE equal 1.

	IFND	FASTER_MODE
FASTER_MODE	equ	1		; If not already defined assume FASTER_MODE to be on
	ENDC

_compare_string	macro	str1,str2,action,[neg]
	IF\4C	'\1','\2'
	\3
	ENDC
	endm

_ifsamestring	macro	str1,str2,action
	_compare_string	\1,\2,<\3>
	endm

_ifnotsamestring	macro	str1,str2,action
	_compare_string	\1,\2,<\3>,N
	endm

IFsingle_reg macro	register_list,action
	_ifsamestring	<\1>,<d0>,<\2>
	_ifsamestring	<\1>,<d1>,<\2>
	_ifsamestring	<\1>,<d2>,<\2>
	_ifsamestring	<\1>,<d3>,<\2>
	_ifsamestring	<\1>,<d4>,<\2>
	_ifsamestring	<\1>,<d5>,<\2>
	_ifsamestring	<\1>,<d6>,<\2>
	_ifsamestring	<\1>,<d7>,<\2>
	_ifsamestring	<\1>,<a0>,<\2>
	_ifsamestring	<\1>,<a1>,<\2>
	_ifsamestring	<\1>,<a2>,<\2>
	_ifsamestring	<\1>,<a3>,<\2>
	_ifsamestring	<\1>,<a4>,<\2>
	_ifsamestring	<\1>,<a5>,<\2>
	_ifsamestring	<\1>,<a6>,<\2>
	endm

_decregslist	macro
_regslist	set	_regslist-1
	endm

IFNEsingle_reg macro	register_list,action
	IFEQ	FASTER_MODE
_regslist	set	15
	_ifnotsamestring	<\1>,<d0>,<_decregslist>
	_ifnotsamestring	<\1>,<d1>,<_decregslist>
	_ifnotsamestring	<\1>,<d2>,<_decregslist>
	_ifnotsamestring	<\1>,<d3>,<_decregslist>
	_ifnotsamestring	<\1>,<d4>,<_decregslist>
	_ifnotsamestring	<\1>,<d5>,<_decregslist>
	_ifnotsamestring	<\1>,<d6>,<_decregslist>
	_ifnotsamestring	<\1>,<d7>,<_decregslist>
	_ifnotsamestring	<\1>,<a0>,<_decregslist>
	_ifnotsamestring	<\1>,<a1>,<_decregslist>
	_ifnotsamestring	<\1>,<a2>,<_decregslist>
	_ifnotsamestring	<\1>,<a3>,<_decregslist>
	_ifnotsamestring	<\1>,<a4>,<_decregslist>
	_ifnotsamestring	<\1>,<a5>,<_decregslist>
	_ifnotsamestring	<\1>,<a6>,<_decregslist>
		IFEQ	_regslist
		\2
		ENDC
	ELSE
	\2
	ENDC
	endm

* Stack save- save register[s] on stack

stack_save	macro	register_list
	IFEQ	FASTER_MODE
	IFsingle_reg	\1,<move.l \1,-(sp)>
	ENDC
	IFNEsingle_reg	\1,<movem.l \1,-(sp)>
	endm

* Stack restore- restore register[s] from stack

stack_restore	macro	register_list
	IFEQ	FASTER_MODE
	IFsingle_reg	\1,<move.l (sp)+,\1>
	ENDC
	IFNEsingle_reg	\1,<movem.l (sp)+,\1>
	endm

* Clears d0-d7

clear_registers	macro
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	endm

* Get physical screen base.

getphys	macro	ret_addr
	stack_save	d0-d3/a0-a3
	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,\1
	stack_restore	d0-d3/a0-a3
	endm

* Get logical screen base.

getlog	macro	ret_addr
	stack_save	d0-d3/a0-a3
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,\1
	stack_restore	d0-d3/a0-a3
	endm

* Set Falcon shifter mode.

set_shift	macro	mode
	move	\1,-(sp)
	move	#$58,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

* Get Falcon screen rez

getrez_falc	macro	ret_addr
	stack_save	d0-d3/a0-a3
	set_shift	#-1
	move	d0,\1
	stack_restore	d0-d3/a0-a3
	endm

* Set Falcon rez

setrez_falc	macro	mode,phys,log
	stack_save	d0-d3/a0-a3
	set_shift	\1
	move	\1,-(sp)
	move	#3,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move	#5,-(sp)
	trap	#14
;      	move.w	#$25,-(sp)
;      	trap	#14
;	lea	16(sp),sp
	lea	14(sp),sp
	stack_restore	d0-d3/a0-a3
	endm

* Branch to label if binary byte value is true

if_true		macro	flag,branch
	tst.b	\1
	IFEQ	('\0'-'')
	bne	\2
	ELSE
	bne.\0	\2
	ENDC
	endm

* Branch to label if binary byte value is false

if_false	macro	flag,branch
	tst.b	\1
	IFEQ	('\0'-'')
	beq	\2
	ELSE
	beq.\0	\2
	ENDC
	endm

* Set Falcon video mode using data from Avena's Falcon Screenmode Editor

set_asavmode	macro	addr
	stack_save	a0/a1
	move.l	\1,a0
	jsr	_setasa
	stack_restore	a0/a1
	endm

* Set screen to display video address

set_vidaddr	macro	screen_addr
	stack_save	d0-d1
	move.l	\1,d0
	move.l	d0,d1
	lsr.w	#8,d0 
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w
	stack_restore	d0-d1
	endm

vga_monitor	equ	2

* Get monitor type

get_monitor	macro	return_addr	; 2 if a VGA monitor
		stack_save	d1-d3/a0-a3
		move.w	#$59,-(a7)	;get monitor
		trap	#14
		addq.l	#2,a7
		stack_restore	d1-d3/a0-a3
		IFNE	('\1'-'d0')
		move.w	d0,\1
		ENDC
		endm

* Branch to label if type of monitor detected

if_monitor	macro	value,where
		get_monitor	d0
		cmp.w	\1,d0
		IFEQ ('\0'-'')
		beq	\2
		ELSE
		beq.\0	\2
		ENDC
		endm

* Branch to label if type of monitor not detected

if_not_monitor	macro	value,where
		get_monitor	d0
		cmp.w	\1,d0
		IFEQ ('\0'-'')
		bne	\2
		ELSE
		bne.\0	\2
		ENDC
		endm

* Timer macro - if timer goes down to zero, branch to label

if_time_up	macro	where
	tst.w	timer.w
	blt.\0	\1
	endm

* If timer is not at zero, branch to label

if_not_time_up	macro	where
	tst.w	timer.w
	bge.\0	\1
	endm

* GEMDOS print string function.

print_string	macro	text
	stack_save	a0/d0
	move.l	\1,-(sp)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	stack_restore	a0/d0
	endm

* Switch keyclick on and off

keyclick_on	macro			; on
	bset	#0,keyclick.w
	endm

keyclick_off	macro			; off
	bclr	#0,keyclick.w
	endm

* Execute subroutine (Ending with 'rts') in supervisor mode.

super_execute	macro	routine
	move.l	\1,-(sp)
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

* Init program. Create a startup and exit shell for program. Use at
; start of a program, and end your code with an rts. Executes your
; code in supervisor mode. 

init_prog	macro
	super_execute	#main
end_prog
	clr	-(sp)
	trap	#1

	ds.b	4096
new_stack
	ds.l	1
old_stack
	ds.l	1

main
	endm

* Save old stack - uses 'old_stack'

save_old_stack	macro
	move.l	a7,old_stack
	lea	new_stack,a7
	endm

* Restore old stack value from 'old_stack'

restore_old_stack	macro
	move.l	old_stack,a7
	endm

* Wait for a number of vbls

wait_for	macro	 period
	IFEQ	('\1'-'#0')
	stack_save	d1
	jsr	_wait_once
	stack_restore	d1
	ELSE
	stack_save	d0/d1
	move	\1,d0
	jsr	_wait_for
	stack_restore	d0/d1
	ELSE
	endm

* Wait for a single vbl

wait_vbl	macro
	wait_for	#0
	endm
	
