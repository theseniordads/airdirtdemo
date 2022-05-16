* AST MOD REPLAY MACROS (by us)

; This are very useful in timing the effects with the music, and hence
; made it one hell of a lot easier to get it to work in VGA!

* Switch module player on with a defined module

module_on	macro	mod_name
	move.l	\1,Module
	jsr	Init_Music
	bmi.s	.err\@
	jsr	Init_Music_IT
.err\@
	endm	

* Switch module player off

module_off	macro
	jsr	Stop_Music_IT
	jsr	Stop_Music
	endm

* Branch to a label if module player is *at or beyond* a certain position
; in a module. (Song position and Pattern position dependent)

if_at_mod_pos	macro 	song-pos,patt-pos,where
	if_true	abort_demo,.abort_exit
	cmp.w	\1,Simplet_Song_Position	
	blt.s	.\@
	cmp.w	\2,Simplet_Pattern_Position
	IFEQ	('\0'-'')
	blt	\3
	ELSE
	blt.\0	\3
	ENDC
.\@
	endm

* Branch to a label if module player is *not yet* at a certain position 
; in a module. (Song position and Pattern position dependent)

if_not_at_mod_pos	macro	song-pos,patt-pos,where
	if_true	abort_demo,.abort_exit
	cmp.w	\1,Simplet_Song_Position	
	IFEQ	('\0'-'')
	blt	\3
	ELSE
	blt.\0	\3
	ENDC
	cmp.w	\2,Simplet_Pattern_Position
	IFEQ	('\0'-'')
	blt	\3
	ELSE
	blt.\0	\3
	ENDC
.\@
	endm

* Until module player has reached a certain position in a
; module. (Song position and Pattern position dependent)

wait_until_mod_pos	macro
.\@	if_not_at_mod_pos	\1,\2,.\@
	endm

* Set mod breakpoint to a number of positions from the 
; current position.

set_mod_breakpoint	macro	rel-patt-pos
	move.w	\1,mod_breakpoint_pattpos
	endm

* Jump to a label if mod breakpoint reached.

if_at_mod_breakpoint	macro 	where
	if_true	abort_demo,.abort_exit
	tst.w	mod_breakpoint_pattpos
	IFEQ	('\0'-'')
	bgt	\1
	ELSE
	bgt.\0	\1
	ENDC
	endm

* Jump to a label if mod breakpoint not yet reached.

if_not_at_mod_breakpoint	macro 	where
	if_true	abort_demo,.abort_exit
	tst.w	mod_breakpoint_pattpos
	IFEQ	('\0'-'')
	bgt	\1
	ELSE
	bgt.\0	\1
	ENDC
	endm

* Wait until mod breakpoint reached.

wait_until_mod_breakpoint	macro
.\@	if_not_at_mod_breakpoint	.\@
	endm
