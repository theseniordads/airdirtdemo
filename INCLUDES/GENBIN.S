* General binaries used by GENMACRO.S

* Another set mode. This is based on code used with Avena's Screenmode
; Editor and uses their .ASA data format. This rout assumes timer.w ($468)
; is altered every vbl. (Which it is)
; a0 = ASA data.

_setasa
	bsr	_wait_once			; Wait vbl. See below
	move.b  (a0)+,$FFFF820A.w		{
	move.b  (a0)+,$FFFF8260.w		{
	move.w  (a0)+,$FFFF8266.w		{
	move.w  (a0)+,$FFFF8282.w		{
	move.w  (a0)+,$FFFF828C.w		{
	move.w  (a0)+,$FFFF82AC.w		{
	move.w  (a0)+,$FFFF82C0.w		{
	move.w  (a0)+,$FFFF82C2.w		{
	move.w  (a0)+,$FFFF8284.w		{
	move.w  (a0)+,$FFFF8286.w		{ - Change hardware regs
	move.w  (a0)+,$FFFF8288.w		{   to new screen mode.
	move.w  (a0)+,$FFFF828A.w		{
	move.w  (a0)+,$FFFF82A2.w		{
	move.w  (a0)+,$FFFF82A4.w		{
	move.w  (a0)+,$FFFF82A6.w		{
	move.w  (a0)+,$FFFF82A8.w		{
	move.w  (a0)+,$FFFF82AA.w		{
	move.w  (a0),$FFFF8210.w           	{
	rts

* Wait for d0 frames

_wait_for
	check_demo_abort		;   Check for abort sequence
	bsr	_wait_once		;   Wait vbl
	dbf	d0,_wait_for		; Do next wait vbl
.abort_exit				; If abort sequence activated go here.
	rts
_wait_once
	move	timer.w,d1		; Get value in timer.w
.loop	cmp.w	timer.w,d1		; Is it changed?
	beq.s	.loop			;   If yes, there's been a vbl.
	rts
