* Senior Dads "Air Dirt" demo (Atari Falcon 030)
; Code completed 12th August 1996 at The Greezy Tea Mini 680x 
; Coding Convention in Glasgow, Scotland, Europe.

; ALL CODE/GFX/SOUND BY SENIOR DADS EXCEPT:
; 1) DSP Module player (Simplet of Abstract)
; 2) Module depacker code (Karl and New Mode of Delta Force)
; 3) Sample depacker code (Don't know)
; 4) "Anarchy" module (Don't Know)
; 5) "Ring Ring" sample (Music by Abba)

; Assembled on Devpac 3 (Tabs=8), with 68030 enabled.

; Tested on TOS 4.03/4.04 on RGB and VGA monitors- no fatal errors.
; Exit by pressing CTRL-ALT-DEL (official) or UNDO (unofficial!)

; Assembles to 1245K unpacked (1254K with labels), packs down to
; 329K using Atomix v3.6 packer.

; THIS CODE IS ONLY TO BE SPREAD TO MEMBERS OF SENIOR DADS!


FINAL_VERSION		; < Comment for labels and faster assembly

	include	includes\ad_mac.s	; Vital macros

	IFD	FINAL_VERSION
	jmp	start

	dc.b	'Hello, Viper! Ripping my code again? No wonder they '
	dc.b	'call your BBS the X(tra-Lame)-Files!! '
	even

	opt	d-
	ENDC

start	init_prog

	save_old_stack
	lea	new_stack,sp
	bsr	save_ints
	bsr	set_ints
	bsr	main_demo
	bsr	ret_ints
	restore_old_stack
	rts

* SAVE INTERRUPTS

save_ints
	bsr	save_keyints
	getphys		oldphys		{
	getlog		oldlog		{ - Save screen details
	getrez_falc	oldrez		{
	movem.l	c16regs.w,d0-d7		; Save ST colours
	movem.l	d0-d7,old_c16cols	;
	move.w	#256-1,d0		{ Save Falcon colours
	lea	c256regs.w,a0		{
	lea	old_c256cols,a1		{
.loop	move.l	(a0)+,(a1)+		{
	dbf	d0,.loop		{
	move.l	vbl.w,old_vbl		; Save old vbl counter
	rts

* SETUP VARIABLES AND INTERRUPTS

set_ints
	keyclick_off			; Switch off key click
	bsr	speaker_ask		; Ask viewer about speaker on/off
	bsr	set_keyints		; Set up keyboard interrupts
	sf	abort_demo		; Set abort demo variables!
	sf	prime_abort_sequence
	movem.l	front,d0-d1		{
	clr.b	d0			{-- Set up screen defaults
	clr.b	d1			{
	movem.l	d0-d1,front		{
	bsr	prepare_vga		; Check for VGA monitors
	bsr	get_8x8_font		; "Precalc" 8X8 font
	lea	main_module,a0		; depack main module
	bsr	depack_module
	lea	dsp_stuff_sample,a0	; depack "DSP Stuffs" sample
	move.l	#dsp_stuff_sample_end-dsp_stuff_sample,d0
	bsr	decrunch_sample
	module_on	#main_module	; Switch module player on
	move.l	#vbl_timer,vbl.w	; Slot in custom vbl
	wait_vbl			; Wait a vbl..
	rts

* RESTORE INTERRUPTS AND OTHER STUFF.

ret_ints
	bsr	ret_keyints			; Restore keyboard
      	module_off				; Module off (If on already)
	move.l	old_vbl,vbl.w			; Restore old vbl
	setrez_falc	oldrez,oldphys,oldlog	; restore screen
	movem.l	old_c16cols,d0-d7		; Restore ST colours
	movem.l	d0-d7,c16regs.w			;
	move.w	#256-1,d0			{ Restore Falcon colours
	lea	old_c256cols,a0			{
	lea	c256regs.w,a1			{
.loop	move.l	(a0)+,(a1)+			{
	dbf	d0,.loop			{
	keyclick_on
	rts

* Check if VGA monitor is running, and alter mode change
; data accordingly.

prepare_vga
	if_not_monitor.s	#vga_monitor,.exit	; If RGB, no change needed
	lea	trucol_inf,a1				; ... otherwise copy over VGA data
	lea	trucol_vga_inf,a0
	move.w	#((end_infs-trucol_inf)/2)-1,d0
.loop1	move.w	(a0)+,(a1)+
	dbf	d0,.loop1
.exit	rts

* Initial bit where you can select whether to put speaker on or off

speaker_ask
	print_string	#.init		; Show introductory text
	sf	.speaker_on		; Start with speaker off
.loop	wait_vbl			; wait a bit
	moveq	#0,d0			{ - Get key press
	move.b	$fffffc02.w,d0		{
	cmp.b	#$39,d0			; SPACE BAR - exit
	beq.s	.exit
	cmp.b	#$1f,d0			; S - Toggle speaker
	bne.s	.loop
	eori.b	#-1,.speaker_on		; Toggle speaker
	if_true.s	.speaker_on,.on	; If already on...
.off	move.w	#%01000000,-(sp)	 { - Switch speaker off
	move.w	#$1e,-(sp)		 {
	trap	#14			 {
	addq.l	#4,sp			 {
	print_string	#.toff		 ; Tell user
	bra.s	.loop			 ; Wait for next keypress
.on	move.w	#%10111111,-(sp)	{ - .. Otherwise, switch speaker on
	move.w	#$1d,-(sp)		{
	trap	#14			{
	addq.l	#4,sp			{
	print_string	#.ton		 ; Inform user (Beep)
	bra.s	.loop			 ; Wait for next keypress
.exit	rts

; Introductory string.

.init	dc.b	27,'E'
	incbin	graphics\senior_l.ogo
	dc.b	13,10,10
	dc.b	'  W3Lc0Me3 2 dA',13,10
	dc.b	' A I R    D 1 R T   D 3 M 0 !',13,10,10
	dc.b	'speaker on or off??',13,10
	dc.b	'  PRess S to toggle, SPACE BAr to start.',13,10,10,10,0
.ton	dc.b	'Speaker off',7,13,10,10,0	; Speaker on string - includes chr$(7) beep.
.toff	dc.b	'Speaker on',13,10,10,0		; Speaker off string
.speaker_on	ds.b	1			; Speaker on/off toggle value.
	even


* MAIN DEMO.

main_demo
	demo_part	do_presents		; Initial pic and "presents" flashing bit.
	demo_part	do_title_pic		; Show "Air Dirt Demo" pic.	
	demo_part	do_credits		; Show credits pics.
	demo_part	do_starfield		; 64000 dot "starfield"
	demo_part	do_shadebobs		; Shade bobs
	demo_part	do_tunnel		; "Filled vector tunnel".
	demo_part	do_show_raytrace	; Jackson Pollock's "raytrace".
	demo_part	do_3d_cube		; 3D Cube + scroller
	demo_part	do_fire			; "Fire" + scroller
	demo_part	do_dsp_stuffs		; DSP "Stereogram DOOM clone".
	demo_part	do_motion_blur		; "Parklife" motion blur.
	demo_part	do_endbit		; "Anarchy in the UK" endbit
.abort_exit
	rts


* Show "Senior Dads present.." pic, then do flashing "presents.." bit.

do_presents
	bsr	st_lorez		; Go ST low rez (just in  case)
	lea	presents,a6		; Show "Senior dads piccy"
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
	wait_until_mod_pos	#1,#0	; Wait until the beat kicks in....
	bsr	fadeoff_16col 		; Special Senior Dads fade!
	lea	a_demo,a6		; Get "presents" pic (Remember
	move.l	front,a1		;   screen is completely faded off at the mo...)
	bsr	copy_16col_pic_to_screen	; Copy to currently displayed screen.
	moveq	#1,d1			; start at colour 1
	moveq	#6-1,d0			; for the next 6 colours
.loop	bsr	flash_titles		; ... flash that colour!
	check_demo_abort		; Check for abort sequence
	addq.l	#1,d1			; ... next colour please.
	dbf	d0,.loop
	movem.l	a_demo+2,d0-d7		; Briefly put on original piccy colours, so
	movem.l	d0-d7,c16regs.w		; ... you can all the bits at once. Ho ho!
	wait_until_mod_pos	#5,#0	; Wait until the "Move your ass to the Senior Dads!" bit.
.abort_exit
	rts

* FLASHING THE COLOURS BIT. (Easy)
; The picture 'a_demo' is a degas format piccy with the texts "presents..",
; "a new demo..", and so on, in increasing colour index values (ie the
; first text is colour 1, the second is colour 2). So, to flash the bit you
; want, flash the colour it's in, and keep the rest of pallete to the
; background colour- see, it's easy-peasy isn't it? Note though, that
; instead of timing using the vbl, we're using the position of the
; module player in playing the module, so that this works the
; same on a VGA monitor.
;
; Input values- d1 = colour

flash_titles:
	lea	a_demo+2,a0		; We get the colours to flash from the pallete of the "presents" piccy.
	lea	(a0,d1.w*2),a1		; Get the colour....
	lea	c16cols,a2		; Get our custom pallete
	lea	(a2,d1.w*2),a2		; point it to where we want our colour to be...
	stack_save	d0-d7
	set_mod_breakpoint	#40	; We're doing this for 41 mod pattern positions!
	clear_registers			; clear d0-d7
	movem.l	d0-d7,c16cols		; All of our custom pallete is black...
	move	(a1),(a2)		; .... except this special colour, which we're slotting in.
.floop	movem.l	c16cols,d0-d7		; Show our special pallette, which displays the text we want to see.
	movem.l	d0-d7,c16regs.w
	wait_for	#1		; wait a couple of frames.
	clear_registers			; clear d0-d7
	movem.l	d0-d7,c16regs.w		; blank the pallete for another couple of frames.
	wait_for	#1
	if_not_at_mod_breakpoint.s	.floop   ; Loop until we've done 41 mod pattern positions.
.abort_exit
	stack_restore	d0-d7
	rts

* DO "AIR DIRT DEMO" TITLE PIC- if it looks simple, that's because the
; subroutine that displays the trucolour picture used to be a part of
; this bit!

do_title_pic
	set_asavmode	#trucol_inf 	; Zap into trucol lores using hardware regs
	set_vidaddr	front		; Now you see a load of rubbish where the lo-res screen used to be!
	lea	title_pic,a6		; Show "Air Dirt Demo
	bsr	show_trucol 		; Special Senior Dads Trucol pic displayer!
	wait_until_mod_pos	#8,#0	; Wait until next bit of that chunky choon!
.abort_exit
	rts


* SHOW CREDITS- This alternates between lo-res screens with text like
; "code by.." and the trucol logos of the guys who did it! Getting this
; bit to work on certain Falcons was an interesting experience because
; of the constant mode changes between lo-res and trucol, and the funny
; way the mode change call works on different TOS versions! We 
; eventually settled on a Falcon TOS call to go to lo-res, and a hardware
; call to go to trucol.

do_credits
	wait_for	#20		; Mysterious enigmatic wait- don't ask me why.
	bsr	swap_screens		; flip front and back screens
	lea	credits_list,a3		; Get credits list ready
	moveq	#4-1,d4			; 4 credits to do...
.loop	bsr	st_lorez		; Get into ST lo-res
	move.l	(a3)+,a0		; Get text to display
	move.l	front,a1		; ... display on currently displayed screen
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	(a3)+,d0		; Get x-pos
	move.w	(a3)+,d1		; Get y-pos
	move.w	(a3)+,d3		; Get colour
	bsr	do_titles 		; Special Senior Dads text displayer!
	set_mod_breakpoint	#20	; Wait for 2 mod pattern positions
	wait_until_mod_breakpoint	
	bsr	fadeoff_16col 		; Special Senior Dads fade!
	set_asavmode	#trucol_inf 	; Zap into trucol lores using hardware regs
	move.l	(a3)+,a6		; Get trucol logo
	bsr	.show_logo		; ... and show it!
	check_demo_abort		; Check for abort sequence
	dbf	d4,.loop
.abort_exit
	rts

* Show trucol logo bit. (Logo is in a6) The logos are 144 X 84, but
; are displayed on screen at twice the size.

.show_logo
	set_vidaddr	front		; Make sure screen is pointing to currently displayed one.
	move.l	front,a1		; ... Get screen ready.
	move	#84-1,d0		; for 84 (y) lines do..
.loop1	move.l	a1,a2			;   Get start of line of logo.
	move	#144-1,d1		;   for 144 (x) pixels do...
.loop2	move.w	(a6),(a2)		;     plot logo pixel at (x,y)
	move.w	(a6),2(a2)		;     plot logo pixel at (x+1,y)
	move.w	(a6),(320*2)(a2)	;     plot logo pixel at (x,y+1)
	move.w	(a6)+,(320*2)+2(a2)	;     plot logo pixel at (x+1,y+1)
	addq.l	#4,a2			;     move 2 pixels forward on screen
	dbf	d1,.loop2		;   next (x) pixel
	adda.l	#(320*2*2),a1		;   move 2 lines down
	dbf	d0,.loop1		; next (y) line
	set_mod_breakpoint	#30	; wait for 30 mod pattern positions
	wait_until_mod_breakpoint
	rts

credits_list			; Here's the list of credits data

; Code by... Old fart
	dc.l	m1		; Text string
	dc.w	3,45		; Text pos (x,y)
	dc.w	$777		; Text colour
	dc.l	old_fart	; Trucol logo

; And... Doddering Git
	dc.l	m2
	dc.w	5,145
	dc.w	$707
	dc.l	dod_git

; Muzixx by... Dame Vera Lynn
	dc.l	m3
	dc.w	2,70
	dc.w	$77
	dc.l	dame_vera

; GFX by... Jackson Pollock
	dc.l	m4
	dc.w	1,160
	dc.w	$770
	dc.l	jack_poll



* 64000 DOT STARFIELD- this is a really poor joke! Basically the screen
; is filled up with crap, the pallete is filled with grey then colour
; cycled for a bit! The "64000" bit- well, it's a 320 x 200 display,
; isn't it?

do_starfield:
	bsr	st_lorez		; Get into ST lo-res
	lea	t_letsgo,a0		; "OK let's go" text is displayed.
	move.l	front,a1
	moveq	#0,d0
	moveq	#45,d1
	moveq	#0,d2
	move.w	#$70,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#14,#0	; Wait while precalculating. (Ho ho!)
	bsr	fadeoff_16col 		; Special Senior Dads fade!
	move	#32000/2,d7		; Fill 32k worth with crap.
	move.l	front,a5		; ... Do it on the screen.
	bsr	generate_crap 		; Special Senior Dads crap generator!
	move.l	front,a5		{ Fill up plane 4,
	addq.l	#6,a5			{  so only colours
	move	#8000-1,d7		{  8-15 are visible
.loop1	move.w	#-1,(a5)+		{  on screen.
	addq.l	#6,a5			{
	dbf	d7,.loop1		{
	lea	c16cols+(16*2),a0	; Go to end of custom pallette
	moveq	#4-1,d0			; for 4 colours do...
	move	#$fff,d1		;   get grey colour
	move	#$777,d2		;   ger another grey colour
.loop2a	move	d1,-(a0)		;   put into next entry downwards of custom pallete
	move	d2,-(a0)		;
	subi.w	#$111,d1		;   darken grey colours
	subi.w	#$111,d2		;
	dbf	d0,.loop2a		; next colour
.loop3	bsr	cycle16 			; Special Senior Dads colour cycler!
	if_not_at_mod_pos	#16,#0,.loop3	; Cycle until next "Move your ass to the Senior Dads" bit.
.abort_exit
	rts


* SHADE BOBS- basically a 1-plane object being or-ed on top of itself
; over successive planes.

do_shadebobs
	lea	t_shadebobs,a0		; "SHADE BOBS!"
	move.l	front,a1
	moveq	#0,d0
	moveq	#100,d1
	moveq	#0,d2
	move.w	#$740,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#17,#0	; Wait until "Move your ass to the Senior Dads" bit is over.
	move.w	#400,timer.w		; do for 400 frames
	move.w	#15,d7			; Do 15 words of crap
	lea	c16regs+2.w,a5		; start from colour 1 in pallete
	bsr	generate_crap 		; Special Senior Dads crap generator!
	moveq	#0,d7			; start at plane 1
.loop	bsr	.do_bobs		; Do "shade" bobs
	check_demo_abort		; Check for abort sequence
	if_not_time_up.s	.loop	; ... until 400 frames are done.
	bsr	fadeoff_16col 		; Special Senior Dads fade!
	lea	say_ni,a6		; Show "Dads who say NI!" pic
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
	wait_until_mod_pos	#20,#28 ; Wait until next bit in module.
	bsr	fadeoff_16col 		; Special Senior Dads fade!
.abort_exit
	rts

* Do shade bobs. Basically does a lot of bobs at random positions in
; one plane, then switches to another plane, ready to the same again.
; d7 = plane (0- 3)

.do_bobs
	move.l	front,a6		; Do bobs on current screen
	lea	(a6,d7.w*2),a6		; Get current plane on screen ready
	addq.l	#1,d7			; Go to next plane.
	andi.w	#4-1,d7			; Make sure plane is (0 - 3)

	move	#50-1,d6		; for 50 bobs do...
.bob1	move.l	a6,a5			;   Get screen address
	move	#17,-(sp)		;   Get random number
	trap	#14			;   ( d0 = x, d1 = y )
	addq.l	#2,sp
.bx	andi.w	#16-1,d0		;   Make 0<=x<15
	beq.s	.bxa			;   If x > 0
	subq.l	#1,d0			;     take away 1 from x
.bxa	lea	(a5,d0.w*8),a5		;   add to screen address
.by	andi.w	#32-1,d1		;   Make 0<=y<32
	addi.w	#12,d1			;   Lower y in screen pos
	mulu	#160,d1			;   Adjust for screen address
	adda.w	d1,a5			;   Add to screen.
	lea	senior_bitmaps+34,a4	;   Get bob source
	bsr	or_bob			;   plot "or" bob.
	dbf	d6,.bob1		; next bob
	rts


* FILLED VECTOR TUNNEL - This is pretty obviously a bunch of concentric
; filled circles colour cycled! Though later the screen is scrolled
; left and right as well. the wierd and wonderful world of STE hard-scrolling
; is used to effect here! (including a deliberate glitch!)

do_tunnel:
	lea	t_vector_tunnel,a0	; "Filled vector tunnel"!
	move.l	front,a1		;  (I wonder if they know
	moveq	#0,d0			;   what's going to hit them?)
	moveq	#100,d1
	moveq	#0,d2
	move.w	#$77,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#21,#0	; Wait the next for in the module.
	bsr	st_lorez		; Do a St lo-rez colour blast!
	bsr	swap_screens		; ...and a screen swap to show off the crap on the other screen.
	lea	tunnel_pic+34,a0	; Get the precalculated (!) tunnel picture on screen.
	move.l	front,a1		; Display on screen.
	move.l	#(32000-1),d0
.loop1	move.b	(a0)+,(a1)+
	dbf	d0,.loop1
	movem.l	tunnel_pic+2,d0-d7	; Get the tunnel colours
	movem.l	d0-d7,c16cols		;   into the custom pallete.
	movem.l	d0-d7,c16regs.w		;   ... and the display pallete.
	wait_for	#50		; Wait a bit before we "move" along the tunnel!
	move.w	#100,timer.w		; do for 100 frames
.cycle1	bsr	cycle16 		; Special Senior Dads colour cycler!
	check_demo_abort		; Check for abort sequence
	if_not_time_up.s	.cycle1	; "Move" along tunnel for next 100 frames.
	bsr	move_tunnel		; Animate the tunnel
	check_demo_abort		;     Check for abort sequence
	lea	not_happy,a6		; Show "Happy? NOT!" picture.
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
	wait_until_mod_pos	#24,#60	; Wait until tha kickin' muzixx is ready!
	bsr	fadeoff_16col 		; Special Senior Dads fade!
.abort_exit
	rts

; OK, now the hard-scrolling bit. I'm setting up a 640X200 window in
; memory to scroll jerkily around, made up of two copies of the existing 
; screens side by side. That means that each line of the current screen 
; will be done twice in memory, hence this copy routine...

move_tunnel:
	move.l	front,a0		; Get the current screen.
	adda.l	#32000,a0		; Go to the end of it
	move.l	a0,a1
	adda.l	#32000-160,a1		; Go to 32K beyond that!
	move.l	#200-1,d0		; For 200 lines do...
.cloop
i	set	160
	REPT	20*8			;   Copy each line on the existing
	move.b	i(a0),i(a1)		;   screen twice to the 640X200 window
	move.b	i(a0),i+160(a1)		;   (This is done backwards in memory, so
i	set	i-1			;    not to overwrite the current screen.)
	ENDR
	suba.l	#160,a0			{
	suba.l	#2*160,a1		{- Do next line
	dbf	d0,.cloop		{

* Now the actual scrolling bit. Note that the window width ($e(a0))
; value needs to be changed according to whether the hardscroll 
; value ($65(a0)) is 0 zero, or it's 1-15. This is what makes 
; programming the hardware scrolling a bit of a bastard to do properly.
; However, we don't really bother about that, we'll just let the screen
; do a "skew" when the $65(a0) hits zero, see if we care!

	lea	$ffff8200.w,a0		; Get video registers
	move.w	$e(a0),oldwidth		; Save window width
	move.w	#80-4,$e(a0)		; Set window width to another 80 words (ie 640 x wide)
	move.b	#15,$65(a0)		; Set hardscoll pixel bit to 15
	moveq	#4-1,d0			; For 4 times do...
.lr	moveq	#16-1,d7		;   For 16 times left do....
.scroll_l
	wait_for	#1		;     wait a couple of frames
	subi.b	#1,$65(a0)		;     hardscroll left a pixel
	bsr	cycle16 		;     Special Senior Dads colour cycler!
	check_demo_abort		;     Check for abort sequence
	dbf	d7,.scroll_l		;   Next pixel
	move.w	#80,$e(a0)		;   Have to add 4 width bit if hardscroll bit is zero! (Already glitched though.)
	moveq	#16-1,d7		;   For 16 times right do....
.scroll_r1
	wait_for	#1		;     wait a couple of frames
	addi.b	#1,$65(a0)		;     hardscroll right a pixel
	move.w	#80-4,$e(a0)		;     reset width back to 640 x pixels.
	bsr	cycle16 		;     Special Senior Dads colour cycler!
	check_demo_abort		;     Check for abort sequence
	dbf	d7,.scroll_r1		;   Next pixel
	dbf	d0,.lr			; Next time.
.abort_exit
	clr.b	$65(a0)			; Reset hardscroll value
	move.w	oldwidth,$e(a0)		; Restore width value
	rts


* SHOW JACKSON POLLOCKS AMAZING RAYTRACING SKILLS!

do_show_raytrace:
	lea	t_raytrace_pic,a0	; "We're showing you...
	move.l	front,a1		;  ... a raytraced pic by...
	moveq	#0,d0			;  ... JACKSON POLLOCK."
	moveq	#70,d1			; Ha ha ha ha ha ha!
	moveq	#0,d2
	move.w	#$740,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#25,#48	; Wait while raytracing pic!!!!
	set_asavmode	#trucol_inf 	; Zap into trucol lores using hardware regs
	set_vidaddr	front		; Make sure we're showing current screen
	lea	raytrace_pic,a6		; Show that amazing pic!
	bsr	show_trucol 		; Special Senior Dads Trucol pic displayer!
	wait_until_mod_pos	#27,#0	; Any longer and the screen will blow up at the inherent beauty of the picture...
.abort_exit
	rts


* DO 3D CUBE- This amazing part shows how to do a really slow and jerky
; looking "3D Sprite"! This also includes a scroller.

do_3d_cube:
	bsr	st_lorez		{ - back to low res after
	bsr	swap_screens		{    "raytraced" pic.
	lea	t_3d_cube,a0		; Prepare public for amazing 3D!
	move.l	front,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#$777,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#27,#24	; Wait a bit in mod time.
	move.w	#$ff0,c16regs+(2*2).w	; Set 3D colour
	move.w	#$ff,c16regs+(4*2).w	; Set Scroller colour
	moveq	#14,d0			; X-coord of cube
	moveq	#30,d1			; Y-coord of cube
	bsr	draw_3d_cube		; Plot 1 frame of cube
	wait_until_mod_pos	#27,#56	; Wait so that they think we're lame and can't move our "3D"!
	move.l	front,a6		{ - Set starting point of scroller
	adda.l	#(160*150)+4,a6		{
	moveq	#-1,d2			; Set "direction" of "3D".
.loop	bsr	draw_3d_cube		; Draw 1 frame of "3D"
	bsr	draw_scroller 		; Special Senior Dads scroller!
	bsr	clear_3d_cube		; Clear "3D" frame
	bsr	draw_scroller 		; Special Senior Dads scroller!
	add.w	d2,d0			; Move X-coord in "direction"
	bmi.s	.neg			; if X<0 reverse direction
	cmp.b	#15,d0			{ - if X>15 reverse direction
	bgt.s	.neg			{
.l1a	if_not_at_mod_pos.s	#31,#8,.loop	; Loop until 3/4 through double "Move your ass.." bit.
	bsr	draw_3d_cube		; Final frame of "3D"

* Now we're just doing the scroller by itself... Er, isn't a little bit
; quicker now??!?!

	move.l	front,a6		{ - Set starting point of scroller
	adda.l	#(160*150)+4,a6		{
.loop2	bsr	draw_scroller 		; Special Senior Dads scroller!
	wait_for	#2		; Wait a couple of frames
	if_not_at_mod_pos.s	#33,#48,.loop2		; Wait for more mod time.
	bsr	fadeoff_16col 		; Special Senior Dads fade!
.abort_exit
	rts

.neg	neg.w	d2			; Reverse direction bit.
	bra.s	.l1a

* Draw "3D" cube- would I be giving too much away if I said that this
; cube used some precalculation? ;) This cube is drawn in two parts-
; one half is drawn during one vbl, the other half during another.
; d0, d1 = "x",y coords

draw_3d_cube:
	stack_save	d0-d1			; save x,y coords for later
	lea	senior_bitmaps+34+(6*8),a0	; Get start of "precalculated" cube.
	move.l	front,a1			; Get front screen
	mulu	#160,d1				; move down y lines
	lea	2(a1,d0.w*8),a1			; Set coords at (x*16,0)
	adda.l	d1,a1				; Now at (x*16,y)
	move.w	#45-1,d0			; For 45 lines do...
.d3loop1
i	set	0
	REPT	6				;   For 6 words do
	move.w	i(a0),i(a1)			;     Copy word of "3D" to screen
i	set	i+8
	ENDR
	lea	160(a0),a0			;   Go down a line of "3D"
	lea	160(a1),a1			;   Go down a line of the screen.
	dbf	d0,.d3loop1			; Next line
	wait_for	#1			; Wait for a vbl.
	move.w	#45-1,d0			; For 45 lines do...
.d3loop1a
i	set	0
	REPT	6				;   For 6 words do
	move.w	i(a0),i(a1)			;     Copy word of "3D" to screen
i	set	i+8
	ENDR
	lea	160(a0),a0			;   Go down a line of "3D"
	lea	160(a1),a1			;   Go down a line of the screen.
	dbf	d0,.d3loop1a			; Next line
	wait_for	#3			; Wait a couple more frames!
	stack_restore	d0-d1			; Restore old (x,y) coords
	rts

* Clear "3D" cube- this is a little less complex. As before, it uses
; a two stage process, and (d0,d1) = ("x",y) coords

clear_3d_cube:
	stack_save	d0-d1			; save x,y coords for later
	move.l	front,a1			; Get front screen
	mulu	#160,d1				; move down y lines
	lea	2(a1,d0.w*8),a1			; Set coords at (x*16,0)
	adda.l	d1,a1				; Now at (x*16,y)
	moveq	#0,d1				; Get the "big cloth" ready....
	move.w	#45-1,d0			; For 45 lines do...
.d3loop2
i	set	0
	REPT	6				;   For 6 words do...
	move.w	d1,i(a1)			;     Wipe that sucka!
i	set	i+8
	ENDR
	lea	160(a1),a1			;   Go down a screen line
	dbf	d0,.d3loop2			; Next line.
	wait_for	#1			; Wait a frame
	move.w	#45-1,d0			; For 45 lines do...
.d3loop2a
i	set	0
	REPT	6				;   For 6 words do...
	move.w	d1,i(a1)			;     Wipe that sucka!
i	set	i+8
	ENDR
	lea	160(a1),a1			;   Go down a screen line
	dbf	d0,.d3loop2a			; Next line.
	wait_for	#3			; Wait a couple more frames!
	stack_restore	d0-d1			; Restore old (x,y) coords
	rts


* DO FIRE- Believe it or not, this is acually done using colour cycling!
; There's also a scroller in it...

do_fire
	lea	t_fire,a0		; Prepare for that buring sensation!
	move.l	front,a1
	moveq	#5,d0
	move.w	#160,d1
	moveq	#0,d2
	move.w	#$f40,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#34,#16	; Wait a bit of mod-time.
	move.l	front,a5		; Write crap all over front screen
	move.l	#((20*4)*200)-1,d7	; Write a full screen of it.
	bsr	generate_crap 		; Special Senior Dads crap generator!
	bsr	fadeoff_16col 		; Special Senior Dads fade!

* Now we have to have a few logos to "burn", so we do a row of Senior
; Dads logos at this bit. First we clear plane 3

	move.l	front,a0		; Do it on the front screen.
	addq.l	#6,a0			; ... in plane 3
	moveq	#0,d1			; Get the "big cloth" ready...
	move.w	#((20*200)-1),d0	; For a screens worth do...
.loop	move.w	d1,(a0)			;   Wipe that plane!
	addq.l	#8,a0			;   Miss out planes 0-2
	dbf	d0,.loop		; Next wipe...

* Now the logo-drawing....

	move.l	front,a0		; Do 'em on the front screen.
	addq.l	#6,a0			; ... in plane 3
	lea	senior_bitmaps+34,a1	; Get logo ready.
	move.w	#144-1,d0		; For 144 line high logo do...
.loop1	
i	set	0
	REPT	6			;   For 6 words do...
	move.w	i(a1),i(a0)		;     Draw logo copy no. 1
	move.w	i(a1),i+(6*8)(a0)	;     Draw logo copy no. 2
	move.w	i(a1),i+(2*6*8)(a0)	;     Draw logo copy no. 3
	move.w	i(a1),i+(3*6*8)(a0)	;     Draw logo copy no. 4
i	set	i+8
	ENDR
	adda.l	#160,a0			;   Go down a line of the screen.
	adda.l	#160,a1			;   Go down a line of the logo.
	dbf	d0,.loop1		; Next line

* Now we generate that all-important "fire-colour" table for the colour
; cycler bit, and start colour cycling a realistic fire effect with a
; scroller at the same time!!

	lea	c16cols,a0		; Get colour cycling table
	lea	(8*2)(a0),a1		; Go to colours (8-15)
	move.w	#$770,d1		; Start with Yellow.
	moveq	#0,d2			; ... and black
	moveq	#8-1,d0			; Do this 8 times...
.loop2	move	d2,(a0)+		;   Blank out part of lower 8 of palette
	move	d1,(a1)+		;   Add fire colour to part of upper 8 of palette
	subi.w	#$10,d1			;   Make colour slight more "red"
	dbf	d0,.loop2		; Next colour
	move.w	#$fff,d1		; Get white colour
	move.w	#8-1,d0			; Get top 8 colours
	lea	c16regs+(8*2).w,a0	; ... in displayed palette
.loop2a	move.w	d1,(a0)+		; and white them out!
	dbf	d0,.loop2a
	move.l	#scr_text2,scr_strt	; Get new scrolltext ready
	move.l	#scr_text2,scr_ptr	;
	move.l	front,a6		{ Position scroller in screen
	adda.l	#(160*180)+6,a6		{
	wait_until_mod_pos	#34,#32		; Wait until say so from module!
.loop3	bsr	cycle16 			; Special Senior Dads colour cycler!
	bsr	draw_scroller 			; Special Senior Dads scroller!
	if_not_at_mod_pos.s	#36,#56,.loop3	; Do the business until the music changes....
	bsr	fadeoff_16col 			; Special Senior Dads fade!
.abort_exit
	rts


* DO DSP STUFFS!
; This stops the music. (To show that we're really using the DSP!),
; and starts the "stereogram Doom clone" along with a scroller and
; a nice looped sample of "Ring Ring" by Abba, in honour of all those
; brilliant Swedish coders. 

do_dsp_stuffs:
	bsr	st_lorez		; We're already in lo-res - Don't know what this is for!
	bsr	swap_screens		; Dunno about this swap screen business either!
	lea	t_dsp_stuffs,a0		; "DSP STUFFS!"
	move.l	front,a1
	moveq	#3,d0
	moveq	#10,d1
	moveq	#0,d2
	move.w	#$f4,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	bsr	suspend_music		; "Move your ass to the Se-ee-ee-ee-ee-ee-ee-ee-ee-ee..."
	check_demo_abort		; Check for abort sequence
	move.w	#15,d7			{
	lea	c16cols,a5		{ - Generate random palette
	clr.w	(a5)+			{
	bsr	generate_crap 		; Special Senior Dads crap generator!
	bsr	.sort_brightest		; Get the brightest colour in col 1
	bsr	.crap_frame		; Fill screens with crap
	move.w	#50,timer.w		; Do for least 70% of 1 second...
.loop1	bsr	swap_screens		; Start swapping screens to get that animated "stereogram" effect!
	wait_for	#15		; ... Wait a bit...
	check_demo_abort		; Check for abort sequence
	if_not_time_up.s	.loop1	; ... repeat until time up ...

* Now get the sound ready for that amazing sample!

	lea	$ffff8900.w,a0		; Get sound registers ready!
	clr.b	$35(a0)			; Switch off internal prescale clock (Used by module player)
	bsr	swap_screens		; Swap screens for that animated "stereogram" effect!
	wait_for	#15		; ... Wait a bit ...
	move.b	#%11000011,$21(a0)	; Set replay rate to 50K 16bit mono
	bsr	swap_screens		; Swap screens for that animated "stereogram" effect!
	wait_for	#15		; ... Wait a bit ...
	move.b	#%11000010,$21(a0)	; Set replay rate to 25K 16bit mono
	bsr	swap_screens		; Swap screens for that animated "stereogram" effect!
	wait_for	#15		; ... Wait a bit ...
	move.b	#%10000001,$21(a0)	; Set replay rate to 12K bit mono
	bsr	swap_screens		; Swap screens for that animated "stereogram" effect!
	wait_for	#15		; ... Wait a bit ...
	check_demo_abort		; Check for abort sequence
	clr.b	$20(a0)			{ Make sure one track play and track one audio-through is set. }
	move.w	#1,$30(a0)		{ Switch of DSP-play hand-shaking			       } - These values are the standard ones.
	clr.l	$32(a0)			{ Reset matrix						       }
 	move.w	#3,$36(a0)		{ Er, record 4 tracks?!?!?!				       }	
	clr.b	1(a0)				; Ok, let's switch off the sample.
	move.l	#dsp_stuff_sample,d0		; Get the start of the new sample.
	move.b	d0,7(a0)			; Put LSB in hardware regs
	lsr.w	#8,d0				{ - put HSB and MSB in hardware regs
	move.l	d0,2(a0)			{
	move.l	#dsp_stuff_sample_end2,d0	; Get the end of the new sample
	move.b	d0,$13(a0)			; Put LSB in hardware regs
	lsr.w	#8,d0				{ - put HSB and MSB in hardware regs
	move.l	d0,$e(a0)			{
	move.b	#3,1(a0)			; Now start playing the sample in looped mode.

	move.l	#scr_text3,scr_strt	{ - Get new scrolltext ready
	move.l	#scr_text3,scr_ptr	{
	sf	scr_resetted		; Set scroller to "reset" mode
.loop2	bsr	swap_screens		; Swap screens for that animated "stereogram" effect!
	move.l	back,a6			; Draw on back screen for a change.
	adda.l	#(160*180)+2,a6		; Set scroller position
	bsr	draw_scroller 		; Special Senior Dads scroller!
	wait_for	#2		; ... Wait a bit ...
	bsr	draw_scroller 		; Special Senior Dads scroller!
	wait_for	#2		; ... Wait a bit ...
	bsr	draw_scroller 		; Special Senior Dads scroller!
	wait_for	#2		; ... Wait a bit ...
	check_demo_abort		; Check for abort sequence
	tst.b	scr_resetted		; If not at end of scroller...
	beq.s	.loop2			; ... Keep going.
	bsr	restart_music		; "ee-ee-ee-ee-ee-ee-ee-enior Dads!"
	check_demo_abort		; Check for abort sequence
	lea	senior_logo,a6		; Now show our amazing logo of ours...
	bsr	disp_16col_pic	 	; Special Senior Dads pic display method!
	wait_until_mod_pos	#38,#48	; Wait a bit in mod-time
	bsr	fadeoff_16col 		; Special Senior Dads fade!
.abort_exit
	rts

* Put the brightest colour in colour 1 (Scroller colour!)

.sort_brightest
	lea	c16cols+2,a5		; source colour is colour 1
	move.l	a5,a6			; This is where col. no. 1 will be
	move.w	(a5)+,d1		; Get colour 1
	move.w	d1,d5			; Look at colour 1
	andi.w	#7,d5			; Isolate blue
	move.w	d1,d3			; Look at colour 1
	andi.w	#$700,d3		; Isolate red
    	lsr.w	#8,d3			; Convert to 0-7
	add.w	d3,d5			; Add red
	move.w	d1,d3			; Look at colour 1
	andi.w	#$70,d3			; Isolate green
	lsr.w	#4,d3			; Convert to 0-7
	add.w	d3,d5			; Add green		(d5 = no. to compare)
	move.w	#14-1,d0		; For next 14 colours do...
.sblp	move.w	(a5),d2			;   Get new color
	move.w	d2,d4			;   Look at it
	andi.w	#7,d4			;   Isolate blue
	move.w	d2,d3			
	andi.w	#$700,d3		;   Isolate red
	lsr.w	#8,d3			;   Convert to 0-7
	add.w	d3,d4			;   Add red
	move.w	d2,d3
	andi.w	#$70,d3			;   Isolate green
	lsr.w	#4,d3			;   Convert to 0-7
	add.w	d3,d4			;   Add green
	cmp.w	d4,d5			;   is new colour grighter?
	bge.s	.sblpa			;     .. if not, try next colour
	exg	d1,d2			;   Swap colours
	move.w	d1,(a6)			;   .. And put them back in palette
	move.w	d2,(a5)
.sblpa	addq.l	#2,a5			;   Go to next palette entry.
	dbf	d0,.sblp		; Next colour
	movem.l	c16cols,d0-d7		; Display finished palette
	movem.l	d0-d7,c16regs.w
	rts

* Cover two screens with crap, and clear bottom 40 lines for scroller.

.crap_frame
	move.l	back,a5			; Draw crap on back screen
	move.l	#(20*4*160),d7		; Draw 160 lines of crap
	bsr	generate_crap 		; Special Senior Dads crap generator!
	move.l	front,a5		; Draw crap on front screen
	move.l	#(20*4*160),d7		; Draw 160 lines of crap
	bsr	generate_crap 		; Special Senior Dads crap generator!
	move.l	front,a0		; Get front ready
	move.l	back,a1			; Get back ready
	adda.l	#160*160,a0		; Move 160 lines down...
	adda.l	#160*160,a1
	moveq	#0,d0			; Get "cloth" ready
	move.w	#((160/4)*40)-1,d1	; For 40 lines do....
.cflp	move.l	d0,(a0)+		;   Wipe that sucka!
	move.l	d0,(a1)+		;   (..And the other one)
	dbf	d1,.cflp		; Next bit to wipe.
	rts

* This stops the music without switching the sample off, so you're left
; with a looped sample firing on all cylinders!!! This bit also saves
; the sample playing hardware registers, since we're going to be
; mucking around with them, and playing a sample.

suspend_music
	wait_until_mod_pos	#37,#15		; "Move your ass to the Se.."
	jsr	Stop_Music_IT			; Stop music but no sample player. "..ee-ee-ee-ee-ee-ee-ee..."
	lea	$ffff8900.w,a0			; Get sound hardware registers ready
	lea	old_mus_vals,a1			; Get restore space ready
	move	#($14/2)-1,d0			{
.loop1	move.w	(a0)+,(a1)+			{
	dbf	d0,.loop1			{ - Save hardware registers
	move.w	$ffff8920.w,(a1)+		{
	move.w	$ffff8930.w,(a1)+		{
	move.w	$ffff8932.w,(a1)+		{
	move.w	$ffff8934.w,(a1)+		{
	move.w	$ffff8936.w,(a1)+		{
.abort_exit
	rts

* This restores the sound registers used by the module player, then
; restarts the module player itself...

restart_music
	lea	$ffff8900.w,a0			; Get sound hardware registers ready
	lea	old_mus_vals,a1			; Get restore space ready
	move	#($14/2)-1,d0			{
.loop1	move.w	(a1)+,(a0)+			{
	dbf	d0,.loop1			{ - Save hardware registers
	move.w	(a1)+,$ffff8920.w		{
	move.w	(a1)+,$ffff8930.w		{
	move.w	(a1)+,$ffff8932.w		{
	move.w	(a1)+,$ffff8934.w		{
	move.w	(a1)+,$ffff8936.w		{  (Now it's "ee-ee-ee-ee-ee-ee-ee..." again.)
	lea	t_dsp_stuffs_end,a0		; "End of DSP Stuffs"
	move.l	front,a1
	moveq	#3,d0
	moveq	#10,d1
	moveq	#0,d2
	move.w	#$f4,d3
	bsr	do_titles	 		; Special Senior Dads text displayer!
	wait_for	#200			; Wait a bit
	jsr	Init_Music_IT			; Unpause music ("..Eenior Dads!")
	rts


* DO MOTION BLUR!
; This uses a similar trick to the "shadebobs" screen believe it or not!
; It also have a very funny joke about Blur, the pop group!!!!

do_motion_blur:
	lea	t_motion_blur,a0		; "MOTION BLUR"
	move.l	front,a1
	moveq	#1,d0
	moveq	#100,d1
	moveq	#0,d2
	move.w	#$f00,d3
	bsr	do_titles 			; Special Senior Dads text displayer!
	wait_until_mod_pos	#39,#32		; Wait a bit in mod-time
	lea	senior_bitmaps+(34+96),a4	; Get hilarious "Blur" sprite ready
	move.l	front,a5			; Get the front of screen ready
	adda.l	#96,a5				; ... Move along a bit
	bsr	or_bob				; Plonk sprite on screen.
	wait_until_mod_pos	#40,#0		; Pause for huge laugh at this brilliant joke!
	move.w	#$47,c16regs+2.w		; Now change the sprite to a more "blurry" colour 
	moveq	#8,d2				; d2 = the amount to move in x-direction
	move.l	front,a6			; Get front screen ready.
	move.l	a6,a2				; Set left limits of movement of sprite
	move.l	a6,a3				{ Set right limits of movement of sprite
	adda.l	#14*8,a3			{
.loop1	moveq	#4-1,d6				; Blur by or-ing 4 times!
.loop2	move.l	a6,a5				;   Set coords to plot to...
	lea	senior_bitmaps+(34+96),a4	;   Set "Damon" as source sprite.
	bsr	or_bob				;   plot sprite
	add	d2,a6				;   move along x-direction
	cmpa.l	a2,a6				;   If hit left border...
	bne.s	.miss1				
	neg.w	d2				;     ... Reverse direction
.miss1	cmpa.l	a3,a6				;   If hit right border...
	bne.s	.miss2
	neg.w	d2				;     ... Reverse direction
.miss2	wait_vbl				;   wait a frame
	dbf	d6,.loop2			; Next "Blur"
	set_mod_breakpoint	#2		; Set wait for 2 mod positions
	stack_save	a2-a3/a6		; Save registers trashed by next procedure
	bsr	clear_16col_screen		; Clear screen to get rid of excess "Blur" (Screen already defined in a6)
	stack_restore	a2-a3/a6		; Restore the registers
	wait_until_mod_breakpoint		; Wait until 2 mod positions are over.
	move.w	#$47,c16regs+2.w		; Reset "blurry" colour.
	if_not_at_mod_pos.s	#42,#0,.loop1	; Repeat until a couple of patterns have elapsed
	lea	sleeper,a6			; "Risque" pic of "foxy" Louise Weiner from Sleeper!
	bsr	disp_16col_pic 			; Special Senior Dads pic display method!
	wait_until_mod_pos	#44,#48		; Wait some more mod-time.
	bsr	fadeoff_16col 			; Special Senior Dads fade!
.abort_exit
	rts


* END PART
; This endpart is in two parts. In reverse order...
; 2) "Anarchy in the UK" and credits
; 1) The build up to "Anarchy in the UK" and credits

do_endbit:
	lea	t_end1,a0			; "And now..."
	move.l	front,a1
	moveq	#0,d0
	moveq	#100,d1
	moveq	#0,d2
	move.w	#$fff,d3
	bsr	do_titles 			; Special Senior Dads text displayer!
	wait_until_mod_pos	#47,#0		; Wait a bit in mod-time
	lea	t_end2,a0			; "Mega GFX/sound anim time.."
	move.l	front,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#$fff,d3
	bsr	do_titles 			; Special Senior Dads text displayer!
	wait_until_mod_pos	#49,#0		; Wait a bit in mod-time
	lea	t_end3,a0			; "All GFX by..."
	move.l	front,a1
	moveq	#0,d0
	moveq	#50,d1
	moveq	#0,d2
	move.w	#$fff,d3
	bsr	do_titles 			; Special Senior Dads text displayer!
	wait_until_mod_pos	#51,#0		; Wait a bit in mod-time
	lea	gfx_by,a6			; "...Jackson Pollock"
	bsr	disp_16col_pic 			; Special Senior Dads pic display method!
	wait_until_mod_pos	#55,#20		; Wait until "Move your ass to the Senior.."
	bsr	do_anarchy			; ... and BANG!
.abort_exit
	rts


* ANARCHY IN THE UK BIT:
; Believe it or not, this animation uses colour palette switching for it's
; amazing animation effect! The plaettes are switched in time to the
; music to create more "realistic" movement!

do_anarchy:
	bsr	st_lorez			; Zap to ST lo-res. Why I do not know.
	bsr	swap_screens			; And swap screens again.
	bsr	whiteout			; Zap all colours to white
	module_off				; switch module player off
	movem.l	front,a5-a6			{
	move.w	#(64000/4)-1,d0			{
	moveq	#0,d1				{ - Clear all the crap that accumulated on the
.loop	move.l	d1,(a5)+			{   screen during the demo right off!
	move.l	d1,(a6)+			{
	dbf	d0,.loop			{
	bsr	.prepare_end_mod		; Depack and move our great "Anarchy" mod!
	lea	anarchy,a6			; Get the "animation" source data
	bsr	disp_16col_pic 			; Special Senior Dads pic display method!
	bsr	copy_to_back			; Copy it to the back screen.

* Establishing shot of Johnny Rotten

	move.l	#$0fff0fff,d0			{ Now prepare the colours. First set all
	move.l	d0,d1				{ the colours from 0-7 to be white
	move.l	d0,d2				{
	move.l	d0,d3				{
	move.l	#$000f000f,d4			; Now set all plane 3 (Scroller) affected
	move.l	d4,d5				; colours to blue.
	move.l	d4,d6				;
	move.l	d4,d7				;
	move.w	#0,d0				; Make colour 1 black }
	move.w	#0,d1				; Make colour 2 black }- colour 1+2 Johnny Rotten frame 1
	swap	d1				;
	move.w	#$705,d3			; Set MTV logo and URL colour to Magenta
	movem.l	d0-d7,c16regs.w			; Put colours into palette
	wait_until_mod_pos	#1,#0		; Wait until halfway through introduction, then start scroller
.loop1	moveq	#0,d0				; Scroller at left of screen
	bsr	vert_scroller			; Do 1 frame of credits scroller
	set_mod_breakpoint	#2		; Wait for 2 mod positions
	wait_until_mod_breakpoint
	if_not_at_mod_pos	#2,#0,.loop1	; Repeat until Johnny Rotten starts singing...
.loop2

* "Animation" of Johnny Rotten

.rotten
	move.l	c16regs+(2*2).w,d0		; Get colours 2 + 3
	swap	d0				; Swap them (Thus "animating" Johnny Rotten)
	move.l	d0,c16regs+(2*2).w		; .. and plonk them back
	moveq	#0,d0				; Scroller still at left of screen
	bsr	vert_scroller			; Do 1 frame of credits scroller
	set_mod_breakpoint	#2		; Wait for 2 mod positions
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#5,#32,.rotten	; Repeat until just before guitar stuff starts.

* Establishing shot of "Steve Matlock"

	move.l	#$fff0fff,d0			; Set colours 0-1 to white
	move.l	d0,d1				; "         " 2-3 "      "
	moveq	#0,d2				; "         " 4-5 to black (frame 1 of "Steve Matlock")
	movem.l	d0-d2,c16regs.w			; Change palette for "establishing" shot of "Steve Matlock"
.loop3	move.l	#160/2,d0			; Scroller now at right of screen, since "Steve Matlock" is on the left.
	bsr	vert_scroller			; Do 1 frame of credits scroller
	set_mod_breakpoint	#2		; Wait for 2 mod positions
	wait_until_mod_breakpoint
	if_not_at_mod_pos	#6,#0,.loop3	; Repeat until actual guitar solo begins....

* "Animation" of "Steve Matlock"

.matlock
	move.l	c16regs+(5*2).w,d0		; Get colours 5 + 6
	swap	d0				; Swap them (Thus "animating" "Steve Matlock")
	move.l	d0,c16regs+(5*2).w		; .. and plonk them back
	move.l	#160/2,d0			; Scroller at right of screen
	bsr	vert_scroller			; Do 1 frame of credits scroller
	set_mod_breakpoint	#2		; Wait for 2 mod positions
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#7,#62,.matlock	; Repeat until guitar solo ends

* Final shot of "Steve Matlock"

.loop4	move.l	#160/2,d0			; Scroller at right of screen
	bsr	vert_scroller			; Do 1 frame of credits scroller
	set_mod_breakpoint	#2		; Wait for 2 mod positions
	wait_until_mod_breakpoint
	if_not_at_mod_pos	#1,#2,.loop4	; Wait until mod is repeating

* Wrap up.

	moveq	#8,d0				; 8 bombs please
	bsr	do_bombs			; Go do them...
	wait_until_mod_pos	#1,#12		; Wait a bit in mod time.
	move	#32000/2,d7			; Fill 32k worth with crap.
	move.l	front,a5			; ... Do it on the screen.
	bsr	generate_crap 			; Special Senior Dads crap generator!
	lea	dsp_stuff_sample,a5		; Get area previously used by the Abba sample with crap.
	lea	$4.w,a4				; Get bottom of computer memory
	move.l	#((dsp_stuff_sample_end2-dsp_stuff_sample)/4)-1,d7 ; For length of old sample do...
.craploop
	move.l	(a4)+,(a5)+			;   Copy low memory into old sample area (Sounds better than random crap -> white noise)
	dbf	d7,.craploop			; Next sample bit
	module_off				; switch module player off
	bsr	whiteout			; Zap all colours to white
	lea	$ffff8900.w,a0			; Get sample player registers
	clr.b	$35(a0)				; Switch prescale clock to STE mode
	move.b	#%00000001,$21(a0)		; Set sample play to play 12K 8bit stereo
	clr.b	$20(a0)				{ Make sure one track play and track one audio-through is set. }
	move.w	#1,$30(a0)			{ Switch of DSP-play hand-shaking			       } - These values are the standard ones.
	clr.l	$32(a0)				{ Reset matrix						       }
 	move.w	#3,$36(a0)			{ Er, record 4 tracks?!?!?!				       }
	clr.b	1(a0)				; Ok, let's switch off the sample.
	move.l	#dsp_stuff_sample,d0		; Get the start of the new sample.
	move.b	d0,7(a0)			; Put LSB in hardware regs
	lsr.w	#8,d0				{ - put HSB and MSB in hardware regs
	move.l	d0,2(a0)			{
	move.l	#dsp_stuff_sample_end2,d0	; Get end of the new sample.
	move.b	d0,$13(a0)			; Put LSB in hardware regs
	lsr.w	#8,d0				{ - put HSB and MSB in hardware regs
	move.l	d0,$e(a0)			{
	move.b	#1,1(a0)			; Play sample once
.samp	tst.b	1(a0)				; wait until it ends.
	bne.s	.samp
.abort_exit			; AND THAT'S A WRAP!!
.exit	rts

* This bit copies the packed "Anarchy" module to the other module 
; position and then depacks it. The reason the moudule has to be
; in the same place all the time is because the module player assumes
; there to be a whole lot of blank memory after it to be used as
; workspace! Hence the module is always the last bit of data, and the
; workspace is the first bit of the bss section after it. So either I
; use this way, or I waste even more memory by sticking a massive ds.b
; declaration after the "Anarchy" module!

.prepare_end_mod
	lea	endpart_module,a0		; Get "Anarchy" module
	lea	m_s,a1				; Get position of old module
.pem1	cmpa.l	#endpart_module_end,a0		; Until at end of "Anarchy" module...
	beq.s	.pem1_exit
	move.b	(a0)+,(a1)+			;   Copy data from "Anarchy" module into old module position 
	bra.s	.pem1				; Next byte please
.pem1_exit
	clr.l	(a1)+				; Clear an extra longword at the end, so the depacker won't be confused!
	lea	m_s,a0				; Get "moved" "Anarchy" module
	bsr	depack_module			; Depack it...
	module_on	#m_s			; ... and start playing it.
	rts

* Whiteout- changes all the colours to white. Easy, huh!

whiteout
	move.l	#$fff0fff,d0		; Colours 0-1 = white
	move.l	d0,d1			;         2-3 
	move.l	d0,d2			;         : :
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6			;         : :
	move.l	d0,d7			;        14-15
	movem.l	d0-d7,c16regs.w		; Display them.
	rts

* Vertical scroller- This actually scrolls in 8 pixel jumps!!!!
; d0 = start position of scroller

vert_scroller:
	move.l	back,a0			; Get back screen
	addq.l	#6,a0			; Go to plane 3
	move.l	a0,a1			; Save start of plane
	lea	(a0,d0.w),a0		; Go to starting position of scroller
	move.w	#8000-1,d1		{
.loop1	clr.w	(a1)+			{ - clear plane 3
	addq.l	#6,a1			{
	dbf	d1,.loop1		{
	move.l	front,a1		; We're copying from the front screen...
	adda.l	#6+(8*160),a1		; ... from plane 3 eight lines down.
	add.l	.start,a1		; Add saved starting position of front screen
	move.l	d0,.start		; Now we can save current starting position on back screen
	move.l	a0,a2			; Get starting position of scroller on back screen
	move.w	#((200-16)*(160/4))-1,d1	; Do for 184 lines
.loop2	move.w	(a1)+,(a2)+		{ - Copy scroller from front screen
	addq.l	#6,a1			{
	addq.l	#6,a2			{
	dbf	d1,.loop2		{
	move.l	v_text_ptr,a6		; Get scrolltext pointer
	cmpi.b	#-1,(a6)		; If at end of scrolltext
	bne.s	.no_reset		
	lea	v_text,a6		;  ...send pointer back the start of the scrolltext
.no_reset
	lea	small_font,a2		; Get the "small font"
	adda.l	#192*160,a0		; Go down to line 192 of back screen to start writing the scrolltext
	moveq	#1,d2			; Set byte counter 1 = ON
	moveq	#0,d3			; Set byte counter 2 = OFF
	move	#20-1,d0		; For 20 characters do...
.loop3	moveq	#0,d1
	move.b	(a6)+,d1		;   Get a scrolltext character
	subi.b	#' ',d1			;   Subtract base character of font
	lsl.w	#3,d1			;   multiply by length (8 bytes) of single font character
	lea	(a2,d1.w),a3		;   now a3 = font representation of scrolltext character
i	set	0
	REPT	8			{
	move.b	(a3)+,i(a0)		{-- Write character on screen
i	set	i+160			{
	ENDR				{
	add.l	d2,a0			;   Add byte counter 1 or 2
	add.l	d3,a0			;     (Only one of the two is on at any time)
	eori.b	#1,d2			;   Toggle byte counter 1 on/off
	eori.b	#7,d3			;   Toggle byte counter 2 on/off
	dbf	d0,.loop3		; Next character please
	move.l	a6,v_text_ptr		; Save scrolltext pointer
	bsr	swap_screens		; flip between back & front screens.
	rts
.start	ds.l	1

v_text_ptr	dc.l	v_text		; Contains position of scrolltext
v_text
	include	includes\vscroll.s	; Scrolltext (20 chars wide per line)
	dc.b	-1	; End char
	even

* Cycle16- It actually only cycles the top 8 of the 16 colours.

cycle16
	stack_save	d0-d7		; d0-d7 are used
	movem.l	c16cols+(2*8),d1-d4	; Get colours 8-14
	move.w	c16cols+(2*15),d0	; Get colour 15 by itself
	movem.l	d1-d4,c16cols+(2*9)	; move colours 8-14 -> 9-15	}- ie cycle palette upwards.
	move.w	d0,c16cols+(2*8)	; move (former) colour 15 -> 8	} 
	movem.l	c16cols,d0-d7		; Get custom palette
	movem.l	d0-d7,c16regs.w		; ...And display it.
	wait_for	#1		; Wait a couple of frames
	stack_restore	d0-d7		; restore data registers
	rts

* Do bombs. Plots the old system bomb bitmap to the screen. Converted
; from a similar procedure in "Colonic Irrigation". Assumes ST lo-res
; screen. d0= no of bombs

do_bombs
	move.l	front,a1		; Get to front of screen
	adda.l	#100*160,a1		; Go halfway down it.
	lea	bomb_dat,a0		; Get bomb bitmap ready
.loop					; For d0 bombs do...
i	set	0
j	set	0
	REPT	16			 
	move.w	i(a0),j(a1)		{
	move.w	i(a0),j+2(a1)		{ --- Copy bomb bitmap to screen
	move.w	i(a0),j+4(a1)		{     (all planes ie colour 15)
	move.w	i(a0),j+6(a1)		{
i	set	i+2
j	set	j+160
	ENDR
	addq.l	#8,a1			;   Go to position of next bomb
	dbf	d0,.loop		; Next bomb.
	rts

* "or" bob- Ors a 96 X 144 bob on an ST lo-res screen from a 
; 4 plane source Degas pic.
; a5 = where to plot bob.
; a4 = source to copy bob from.

or_bob:	move.w	#144-1,d0		; For 144 lines do...
.bob2
i	set	0
	REPT	6			;   For 6 words do...
	move.w	i(a4),d1		;     Get bitmap data
	or.w	d1,i(a5)		;     ... And OR it on screen
i	set	i+8
	ENDR
	lea	160(a4),a4		;   Go down a line in source
	lea	160(a5),a5		;   Go down a screen line.
	dbf	d0,.bob2		; Next line of bob
	wait_for	#1		; Wait 2 frames
	rts

* Show trucolour pic. Takes a lot fiddling around to show a trucolour
; pic this way! a6 = the (320X200) trucol pic.
	
show_trucol:
	move.l	back,a0			; Get back screen
	move	#(320*200)-1,d0		; For the whole (320X200) screen do.
.loop1	movem.w	.rand1,d1-d2		{
	eor.w	d2,d1			{
	neg.w	d1			{ - Faff about to get "random" numbers
	move.w	d1,.rand1		{
	move.w	timer.w,.rand2		{
	move.w	d1,c256regs.w		; - Stick it in the border colour register
	move.w	d3,c256regs+2.w		;
	move.w	d1,d3
	move.w	d1,(a0)+		;   Put	it on the screen.
	dbf	d0,.loop1		; Next pixel.
	bsr	swap_screens		; Swap screens to show this beautiful random painting!
	move.l	back,a0			; Get back screen	
	lea	$100.w,a1		{ - zap down to bottom of memory
	suba.l	a1,a1			{
	move	#(320*200)-1,d0		; For the whole (320X200) screen do.
.loop2	move.w	(a1)+,d2		;   Get a bit of low memory
	move.w	d2,c256regs.w		;   Stick it in the border colour
	move.w	d1,c256regs+2.w		;   Add the previous bit in as well!
	move.w	d2,d1			;   Save new bit
	move.w	d2,(a0)+		;   Plot on back screen.
	dbf	d0,.loop2		; Next pixel.
	wait_for	#20		; Wait a bit
	bsr	swap_screens		; Show the beauty of low memory on the screen!
	wait_for	#5		; Wait another bit.
	move.l	a6,a0			; Now get the actual picture ready.
	move.l	front,a1		; Get the FRONT screen ready
	move	#(320*200)-1,d0		; For half of it....
.loop3	move.b	(a0)+,(a1)+		;   Plot very slowly!
	dbf	d0,.loop3		; Next slow plot
	wait_for	#5		; Wait a bit.
	move	#(320*200)-1,d0		; For rest of it....
.loop3a	move.b	(a0)+,(a1)+		;   Plot very slowly!
	dbf	d0,.loop3a		; Next slow plot
	rts
.rand1	dc.w	$3f3f		{ - The "random" bits!
.rand2	dc.w	$7171		{

* Display Degas pic. Well, it does more than that- it also craps on
; the screen and negates the palette beforehand!
; a6 = Degas pic

disp_16col_pic
	bsr	st_lorez			; Go to ST-lores (Defaults palette)
	move.l	back,a5				; Do crap of back screen
	move.l	#32000/2,d7			; Do 32K worth
	bsr	crap_on_screen			; Special Senior Dads crap generator!
	move.l	front,a1			; Go to front screen
	bsr	copy_16col_pic_to_screen	; ... and copy the picture onto it.
	movem.l	2(a6),d0-d7			; Get palette of picture
	neg.l	d0				{ ... And negate it!
	neg.l	d1				{
	neg.l	d2				{
	neg.l	d3				{
	neg.l	d4				{
	neg.l	d5				{
	neg.l	d6				{
	neg.l	d7				{
	movem.l	d0-d7,c16regs.w			; Display negated palette!
	wait_for	#10			; Wait a bit
	movem.l	2(a6),d0-d7			; Display proper palette!
	movem.l	d0-d7,c16regs.w
	rts

* Scroller. Draws a single frame of a 32X16 one-plane scroller.
; a6 = where to draw scroller to.

draw_scroller:
	stack_save	d0-a6		; Save all the registers
	subq.b	#1,scr_cnt		; Build a new letter?
	beq	.build
.scr	lea	scr_build,a1		; Get scroller buffer
	lea	scr_ltr_build,a2	; Get letter to scroll
	move.w	#16-1,d0		; For 16 lines do
.loop1	
i	set	0
	REPT	40-1			;   For 39 bytes do
	move.b	i+1(a1),i(a1)		;     Scroll bytes along (Yes, it's a byte scroller!)
i	set	i+1
	ENDR
	move.b	(a2),i(a1)		;   Put letter part into scroller buffer
	move.w	1(a2),(a2)		{ - scroll line of letter data buffer  
	move.b	3(a2),2(a2)		{
	clr.b	3(a2)			{
	adda.l	#20*2,a1		;   Go to next line in the scroller buffer
	addq.l	#4,a2			;   Go to next line in letter buffer
	dbf	d0,.loop1		; Next line

	lea	scr_build,a1		; Get scroller buffer
	move.w	#16-1,d0		; For 16 lines do...
.loop2
i	set	0
j	set	0
	REPT	20			{
	move.w	i(a1),j(a6)		{ - copy a line to the screen
i	set	i+2			{
j	set	j+8
	ENDR
	lea	i(a1),a1		{ - prepare for next line
	lea	j(a6),a6		{
	dbf	d0,.loop2		; Next line

	stack_restore	d0-a6		; Restore all the registers
	rts

; Build new scrolltext letter

.build	move.l	scr_ptr,a2		; Get scrolltext pointer
	moveq	#0,d0
	move.b	(a2)+,d0		; Get next character
	cmp.b	#-1,d0			; At end of scrolltext?
	bne.s	.b2			; If yes...
	st	scr_resetted		;   Set the reset flag.
	move.l	scr_strt,a2		;   Reset the pointer to the start of the scrolltext
	move.b	(a2)+,d0		;   Get character at start of scrolltext
.b2	move.l	a2,scr_ptr		; Save scrolltext pointer
	subi.b	#' ',d0			; Subtract base of font
	lsl.w	#6,d0			; Multiply by length (32 bytes) of single character in font.
	lea	main_font,a2		; Get this font.
	lea	(a2,d0.w),a2		; Now a2 = start of font representation of character.
	lea	scr_ltr_build,a3	; Get letter buffer
	REPT	16			{
	move.l	(a2)+,(a3)+		{ - copy font char into buffer
	ENDR				{
	move.b	#4,scr_cnt		; Can be scrolled 4 times before new letter is needed.
	bra	.scr			; Go back to scroller.

scr_ltr_build	ds.l	16		; Single letter buffer
scr_build	ds.w	16*20		; Scroller buffer
scr_strt	dc.l	scr_text1	; This points to the restart position of the scrolltext- can be changed.
scr_ptr		dc.l	scr_text1	; This points to the current position of the scrolltext
scr_cnt		dc.b	1		; When this reaches 0, a new letter is read from the scrolltext.
scr_resetted	ds.b	1		; Set to TRUE if scrolltext wraps.
	even

; Scrolltexts

; 3D bit.
scr_text1	dc.b	'           This part is dedicated to DENTHOR of ASPHIXIYA on the PC ... '
		dc.b	-1	; <- End char

; Fire bit.
scr_text2	dc.b	'         Wow, a fire-scroller!!! YET AGAIN WE CANNOT BE BEATEN!! '
		dc.b	-1

; "Doom"  bit.
scr_text3	dc.b	'        You are watching our DSP gourad phong shade mapped 3 '
		dc.b	'domain texture STEREOGRAM "Doom" clone called "POOM"!!  This '
		dc.b	'will be a Format Gold!!!  '
		dc.b	-1
	even

* Copies the actual picture data from a Degas pic (in a6). This subroutine
; copies it in bits, and waits a frame inbetween each bit.
	
copy_16col_pic_to_screen
	lea	34(a6),a0			; Get picture data
	move	#(((320/2)/16)-1),d0		; Do blah blah times...
.loop1	move.l	#((200*16)-1),d1		;   Do blah blah times...
.loop2	move.b	(a0)+,(a1)+			;     Copy pic data very slowly to screen.
	dbf	d1,.loop2			;   Do more blah blah
	wait_vbl				;   Wait a frame.
	dbf	d0,.loop1			; Do this blah blah times.
	rts

* The faithful old ST lo-rez calling subroutine. Before calling it,
; we replace the old vbl, since it seems to default the palette for
; some reason. Who cares, it looks good!

st_lorez:
	move.l	old_vbl,vbl.w			; Restore old vbl
	wait_vbl				; Wait until it kicks in
	setrez_falc	lores_inf,#-1,#-1	; Set the lo-res
	move.l	#vbl_timer,vbl.w		; Back to custom vbl
	rts

* Erm this calls the generate_crap bit, swaps the screen then waits a
; bit!!! This must be one of the procedures written early on!

crap_on_screen
	bsr	generate_crap 			; Special Senior Dads crap generator!
	bsr	swap_screens			; Show crap on screen
	wait_for	#10			; Wait a bit.
	rts

* GENERATE CRAP! This is probably the most important procedure in the
; entire demo. This writes random values to d7 words starting from the
; address in a5.

generate_crap:
	stack_save	d0-d3/a0-a3		; d0-d3/a0-a3 affected by XBIOS calls
	subq.l	#1,d7				; Get ready for dbf loop...
.loop	move	#17,-(sp)			{
	trap	#14				{ - Get random number
	addq.l	#2,sp				{
	move.w	d0,(a5)+			; Put it in memory location.
	dbf	d7,.loop			; Do next word...
	stack_restore	d0-d3/a0-a3		; Restore old registers.
	rts

* SPECIAL FADEOFF ROUTINE. Er, this effect is simply generated by 
; subtracting one from each of the RGB values, and doing it another
; 15 times!

fadeoff_16col
	stack_save	d0-d7			; All data registers are used here.
	moveq	#16-1,d0			; For 16 times do...
.loop1	wait_vbl				;   Wait a frame
	lea	c16regs.w,a0			;   Get the palette ready...
	moveq	#16-1,d1			;   For 16 colours do...
.loop2	sub.w	#$111,(a0)			;     Subtract 1 from R,G,B values
	addq.l	#2,a0				;     Go to next position of colour..
	dbf	d1,.loop2			;   Next colour
	dbf	d0,.loop1			; Next frame
	clear_registers				; clear d0-d7
	movem.l	d0-d7,c16regs.w			; Turn everything to black to complete "fade"
	wait_for	#10			; Wait a few frames
	stack_restore	d0-d7			; Restore all the data registers.
	rts

* SWAP SCREENS: this swaps between front and back screen pointers, and
; displays new "front" screen.

swap_screens:
	stack_save	d0			; d0 is used
	move.l	back,d0				{
	move.l	front,back			{ - swap "front" and "back" screens.
	move.l	d0,front			{
	set_vidaddr	d0			; Display new "front" screen.
	wait_vbl				; Wait one frame
	stack_restore	d0			; Restore d0
	rts

* GET SMALL FONT: The font at the end bit looks a bit like the system
; font you're using, doesn't it? Well, guess what- it is! However, we're
; not using the system method of printing it on the screen, after the 
; problems we had using this technique in "Colonic Irrigation". We've
; decided to use our own routine and grab the system font, which is what
; this procedure does. This prints a list of characters, which are
; grabbed and stored in the font buffer. If you're really quick you
; might see it happening at in the top left corner of the screen during
; the start of the demo.

get_8x8_font:
	bsr	st_lorez			; Make sure we're in lo-res
	wait_for	#1			; Wait a frame.
	bsr	whiteout			; Blank colours
	print_string	#.setcol		; Set system font pen
	move.l	#' ',d6				; Start font with ' ' (Space)
	move.l	$44e.w,a5			; Get screen ready as source
	lea	small_font,a6			; Get font buffer ready as dest
	move.w	#('~'-' ')-1,d7			; For loads of characters do....
.loop	move.b	d6,.char			;   Set character to print.
	addq.l	#1,d6				;   Get next char ready for next time.
	print_string	#.char_print		;   Print char on screen. 
i	set	0
	REPT	8				{
	move.b	i(a5),(a6)+			{ - Copy bitmap data from
i	set	i+160				{   screen to font buffer.
	ENDR
	dbf	d7,.loop			; Do next character.
	rts

.setcol		dc.b	27,'b1',0		; This appears to work  for pen colour
.char_print	dc.b	27,'H'			; ESC code to move to top-left
.char		dc.b	0,0			; Char + null end code.
	even

* TITLES SUBROUTINE!
; a0 = text (ends with 0)
; a1 = screen
; d0,d1 = x (1-20), y (1-200)
; d2 = plane (0-3)
; d3 = colour ($rgb)

do_titles:
	stack_save	d0-a6
	move.l	a1,a6
	bsr	clear_16col_screen		; First clear the screen.
	lea	c16regs.w,a2			; Get the colour palette
	moveq	#0,d4
	bset	d2,d4				; Go to the colour of the plane defined in d2
	add	d4,d4				{
	move.w	d3,(a2,d4.w)			{- Set it to the colour defined in d3
	bsr	font_string			; Call print string subroutine
	stack_restore	d0-a6
	rts

* Print text using a 32X32 font
; a0 = string
; a1 = screen
; d0,d1 = x,y
; d2 = plane

font_string
	add	d2,d2				{ - move to plane in screen 
	lea	(a1,d2.w),a1			{
	lsl.w	#3,d0				; Move to..
	lea	(a1,d0.w),a1			; ..X-position
	mulu	#160,d1				; Move to..
	lea	(a1,d1.w),a1			; ..Y-position
	move.l	a1,a4				; Get starting position
.loop	lea	main_font,a2			; Get font ready
	moveq	#0,d0
.ag	move.b	(a0)+,d0			; Get character
	beq	.exit				; Until at end of string...
	cmp.b	#13,d0				;   If c/r detected...
	bne.s	.fn
	adda.l	#160*16,a1			;     Go down a line.
	move.l	a1,a4				;     Update starting position
	bra.s	.ag				;     Get another character
.fn	subi.b	#' ',d0				;   Subtract base of font
	lsl.l	#6,d0				;   Multiply by length (64 bytes) of single char
	lea	(a2,d0.w),a3			;   Now a3 = bitmap representation of char
i	set	0
	REPT	16				{
	move	(a3)+,i(a4)			{ - Copy letter bitmap to screen
	move	(a3)+,i+8(a4)			{
i	set	i+160				{
	ENDR
	adda.l	#16,a4				;   Move forward to next char position on screen
	bra	.loop				; Do next character
.exit	rts

* CLEAR 16COL SCREEN - This, erm, clears an ST-lores screen! BTW It also
; sets all the colours to black.
; a6 = start of screen

clear_16col_screen
	move.w	#32000-1,d7			; For 32000 bytes...
.loop	clr.b	(a6)+				;   Clear rather slowly
	dbf	d7,.loop			; Next byte please.
	wait_for	#10			; Wait a few frames
	lea	c16regs.w,a6			; Get palette regs ready
i	set	0
	REPT	16				{
	clr	i(a6)				{ - clear them slowly too
i	set	i+2				{
	ENDR
	rts

* COPY FRONT SCREEN TO BACK SCREEN - Quite self explanatory, I think!

copy_to_back
	movem.l	front,a0-a1			; Get the front and back screens
	move	#(32000/4)-1,d0			; For the 32000 bytes do...
.loop	move.l	(a0)+,(a1)+			;   Copy "front" onto "back"
	dbf	d0,.loop			; Next longword please
	rts

* CUSTOM VBL - Doesn't really do much does it? It's only really there to
; provide a vbl timer for the demo routines. The system also alters
; timer.w ($468), so this is only really for the routines where we need to
; countdown a specific number of vbls. The other main reason of course is
; to switch off the system vbl in case it does something styoopid that our
; demo didn't expect! (eg the screensaver in NVDI, which switched off the
; display near the end of a test-run of the demo!!)

vbl_timer
	subq.w	#1,timer.w			; Count-down progressing...
	rte

* DECRUNCH SAMPLE: Most of this isn't Senior Dads code, only the first
; bit which makes an extra copy of the packed sample after the original
; data. This is because the original routine cannot depack to the area
; from which the source data is being read.
; a0 = packed sample
; d0 = packed length

decrunch_sample:
	movem.l	a0/d0/d7,-(sp)
	move.l	d0,d1				; Get length of packed sample
	move.l	a0,a1				; Get start of packed sample (Source)
	lea	(a1,d1.l),a2			; Go to end of packed sample (Dest)
	move.l	a2,a3				; Save position of end of packed sample
.loop1	move.b	(a1)+,(a2)+			;   Copy bytes...
	subq.l	#1,d1				;   Next byte please.
	bne	.loop1				; Until no more bytes to copy.
	move.l	a0,a1				; Get start of old sample ready (Dest)
	move.l	a3,a0				; Get start of copy of sample ready (Source)

* This is the original unpack to source. (Not my comments)
; a0 = source packed sample
; d0 = packed sample length
; a1 = address to unpack sample to.

                lea     .decrntab,a2     ;Table with decrunched offsets
                clr.l   d1
                clr.b   .byte1           ;Last byte start with 0
.crnloop:        move.b  (a0)+,d1
                ror.l   #4,d1
                bclr    #3,d1
                beq.s   .crn_1           ;Was not Negative
                move.b  0(a2,d1.w),d1
                sub.b   d1,.byte1
                bra.s   .crn_2
.crn_1:          move.b  0(a2,d1.w),d1
                add.b   d1,.byte1
.crn_2:          move.b  .byte1,(a1)+
                clr.b   d1

                rol.l   #4,d1
                bclr    #3,d1
                beq.s   .crn_3           ;Was not Negative
                move.b  0(a2,d1.w),d1
                sub.b   d1,.byte1
                bra.s   .crn_4
.crn_3:          move.b  0(a2,d1.w),d1
                add.b   d1,.byte1
.crn_4:          move.b  .byte1,(a1)+

                subq.l  #1,d0
                bne     .crnloop
		movem.l	(sp)+,a0/d0/d7

* Decruncher uses unsigned samples, so this bit of code re-signs it. 
; a0 = start of unpacked sample
; a1 = end of unpacked sample

	move.l	a1,d0				{ Get length of sample
	sub.l	a0,d0				{
.loop	addi.b	#128,(a0)+			;   Sign sample
	subq.l	#1,d0				;   Next byte
	beq.s	.exit				; Until no more bytes
	bra.s	.loop				; ...Otherwise keep going.
.exit           rts

.decrntab:      incbin	sound\decrntab.bin	; Sample decrunch table
.byte1:		ds.w	1			;  


* INCLUDED SOURCE CODE

	include	includes\genbin.s		; Code used by some of the macros.
	include	includes\key_mid.s		; Keyboard routines
	include	sound\nmdepack.s		; Noisepakker module depack code.
	include	sound\tracker.s			; DSP Tracker code.

	section data


* Text used in the Credits part

m1	dc.b	'Code by..',0
m2	dc.b	'And..',0
m3	dc.b	'Muzix by:',0
m4	dc.b	'GFX by...',0

* Text used in the titles for each demo part

t_letsgo	dc.b	'LET''S GO!',13,13		; 64000 dot starfield
		dc.b	'With a',13
		dc.b	'64000 dot',13
		dc.b	'tri-di',13
		dc.b	'starfield!',0

t_shadebobs	dc.b	' ShADE',13			; Shade bobs
		dc.b	'B0BS!!',0

t_vector_tunnel	dc.b	'Now a',13			; Filled vector tunnel
		dc.b	'  FILLED',13
                dc.b	' vector',13
		dc.b	'  tunnel!',0

t_raytrace_pic	dc.b	'Now one',13			; Raytraced pic
		dc.b	'of JACKSON',13
                dc.b	'POLLOCK''S',13
		dc.b	'Raytraced',13
		dc.b	'    pics!',0

t_3d_cube	dc.b	'3D!',0				; 3D stuff

t_fire		dc.b	'Fire!!!!',0			; Fire

t_dsp_stuffs_end
		dc.b	' END OF',13			
							; DSP Stuffs
t_dsp_stuffs	dc.b	'DSP',13
		dc.b	' STUFFS!',0

t_motion_blur	dc.b	'M0TION',13			; Motion Blur
		dc.b	'BLuR!',0

t_end1		dc.b	'And now..',13			; End bit
		dc.b	'the FINAL',13
		dc.b	' triumph!',0

t_end2		dc.b	'MEGA SOUND',13
		dc.b	'& GFX ANIM',13
		dc.b	'TIME!!!!! ',0

t_end3		dc.b	'with GFX',13
		dc.b	' by.....',0

	even

* 16 colour pictures - All 320 X 200 and Degas format

presents	incbin	graphics\senior1.pi1		; "Senior Dads presents..."
a_demo		incbin	graphics\faclon.pi1		; "Presents... A new demo..." images
say_ni		incbin	graphics\say_ni.pi1		; "Dads who say ni!"
not_happy	incbin	graphics\nothappy.pi1		; "Not Happy!"
senior_logo	incbin	graphics\sen_log.pi1		; Senior Dads logo (tm)
sleeper		incbin	graphics\sleeper.pi1		; Lousie "Foxy" Wiener!
anarchy		incbin	graphics\anarchy.pi1		; "Anarchy" images
gfx_by		incbin	graphics\gfx_jp.pi1		; "GFX by Jackson Pollock"

* Trucolour pictures - 320 X 200, and in raw headerless format.

title_pic	incbin	graphics\title.tru		; "Air Dirt" main title pic
raytrace_pic	incbin	graphics\raytrace.tru		; Jackson Pollocks "Raytrace"

* Trucolour Senior Dads logos - 144 X 84, and in raw headerless format.

dod_git		incbin	graphics\dodgit.tru		; Doddering Git
old_fart	incbin	graphics\oldfart.tru		; Old Fart
dame_vera	incbin	graphics\damevera.tru		; Dame Vera Lynn
jack_poll	incbin	graphics\jackpoll.tru		; Jackson Pollock

* Bitmap data

main_font	incbin	graphics\crapfont.dat		; Brilliant 1 plane font! (64 bytes per char)
tunnel_pic	incbin	graphics\tunnel.pi1		; Precalculated Tunnel (Degas format)
senior_bitmaps	incbin	graphics\sad2.pi1		; Bitmaps used in demo parts (Degas format)

* Mode data for RGB and VGA monitors
; There's hardware data for Trucolour mode, and a mode number for
; a TOS call into ST-lores. This appears to work on all TOS versions
; on both RGB and VGA displays.

trucol_inf	incbin	graphics\tru_rgb.asa		{- RGB data
lores_inf	dc.w	$a2				{
end_infs

trucol_vga_inf	incbin	graphics\tru_vga.asa		{- VGA data
lores_vga_inf	dc.w	$1b2				{

* Bitmap pattern for "bomb". Copied out of ST Internals BIOS listing.

bomb_dat
	dc.w	%0000011000000000
	dc.w	%0010100100000000
	dc.w	%0000000010000000
	dc.w	%0100100001000000
	dc.w	%0001000111110000
	dc.w	%0000000111110000
	dc.w	%0000011111111100
	dc.w	%0000111111111110
	dc.w	%0000111111111110
	dc.w	%0001111111111111
	dc.w	%0001111111101111
	dc.w	%0000111111101110
	dc.w	%0000111111011110
	dc.w	%0000011111111100
	dc.w	%0000001111111000
	dc.w	%0000000011100000

* Pointers to front and back screens. These two pointers are assumed to
; be next to each other, so don't go seperating them!

front	dc.l	end_code+(256*2)
back	dc.l	end_code+(320*220*2)+(256*3)

* Here's the packed sample for the "DSP Stuffs" bit, along with enough
; memory for the depacked version. Look, this is no joke, it really is
; and Abba sample! What's more, it's a sample of the song they used as
; their first attempt to win Eurovision!!! They didn't even get past the
; Swedish heat, though. The judges were put off, apparently because at
; the time, they looked like a bunch of hippies and one of them was
; heavily pregnant.

dsp_stuff_sample
		incbin	sound\ringring.rap		; "Ring Ring... etc" Did you know Neil Sedaka did the lyrics??!?!?!
dsp_stuff_sample_end
	ds.b	70404-(dsp_stuff_sample_end-dsp_stuff_sample)	; Space for the unpacked sample
dsp_stuff_sample_end2

* Here's the packed "Anarchy" module. This came from the Amiga scene
; via FTP and Aminet's modules directory!

endpart_module	incbin	sound\anarchy.mop
endpart_module_end
	even

* Here's the packed "Move Your Ass To The Senior Dads" module. There's
; enough memory space for the unpacked module, but more is allowed for
; the "Anarchy" module when it gets copied here.

m_s
main_module	incbin	sound\moveuass.mop
main_module_end 
	ds.b	302300-(main_module_end-main_module)
m_e

* Now the bss variables. Note that a "section bss" was already called in
; the tracker code included before here, so the first bss variable is
; actually the workspace for the module player.

	section	bss

abort_demo		ds.b	1	; True if UNDO or CTRL-ALT-DEL pressed
prime_abort_sequence	ds.b	1	; True if CTRL-ALT pressed (Waiting for DEL)

oldphys			ds.l	1	; Old physical screen base
oldlog			ds.l	1	; Old logical screen base
oldrez			ds.w	1	; Old screen resolution
oldwidth		ds.w	1	; Old screen width
old_vbl			ds.l	1	; Old VBL routine

old_mus_vals
	ds.b	$14+(5*2)		; Old DMA sound hardware values

c16cols	ds.w	18			; Custom colour palette

old_c16cols	
	ds.w	16			; Old 16 colour palette
old_c256cols
	ds.l	256			; Old 256 colour palette

small_font
	ds.b	(8*('~'-' '))		; Store for 8X8 font.


* THE END! *

end_code

