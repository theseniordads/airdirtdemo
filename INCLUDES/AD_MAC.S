* Senior Dads "Air Dirt Demo" (Falcon 030)

; Local Macros

	IFD	FINAL_VERSION
FASTER_MODE	equ	0	; <- If assembling final version, don't bother about faster assembly
	ENDC

	include	includes\genmacro.s		; General macros

	include	sound\trackmac.s		; Tracker macros

* CHECK DEMO ABORT- if the abort sequence has been activated, then this
; macro jumps to '.abort_exit'. That's why nearly all the parts of the
; demo code have a local label '.abort_exit' just before the 'rts'!

check_demo_abort	macro
	if_true	abort_demo,.abort_exit
	endm

* DO DEMO PART- This does a demo part, then does a check for abort.

demo_part	macro	demo_part
	bsr	\1
	check_demo_abort
	endm
