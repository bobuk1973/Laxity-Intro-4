// $2c00 start point
// Laxity Intro 2
// Bouncing logo with 2*2 scroller with a sprite at either end.

	.label	sinetable = $2b00
	.label	scrolltext = $1a00
	.label	sprites = $2b80
	.label 	charset = $0800
	.label 	logo = $2000

	*=sprites "sprites"
	.import binary "sprites.bin"

	*= sinetable "sinetable"
	.import binary "sine.bin"

	*= scrolltext "scrolltext"
	.import binary "scrolltext.bin"

	*= charset "charset"
	.import binary "charset.bin"

	*= logo "logo"
	.import binary "logo.bin"

// BasicUpstart2(Intro)

*= $2c00 "mainblock"
Intro:
	sei 
	lda $3fff 
	sta $07ff 							// Set sprite pointer
	jsr $fda3                         // initialise i/o
	jsr $e51b						// clears the screen 
	ldx #$1f
	jsr $e5aa
	jsr $ff5e
	ldx #$00
	stx $2c     						//sinept 
	stx $2d 
	stx $2e 						//Scrollpt
	stx $d011                          // control register 1
	stx $d020                          // border color
	stx $d021                          // background color 0
	stx $3fff 
	stx $dc0e                          // control register a
	inx 
	stx $d01a                          // interrupt mask register (imr)
	stx $d010                          // sprites 0-7 msb of x coordinate
	lda #$03
	sta $d015                          // sprite display enable
	lda #$47
	sta $d000                          // sprite 0 x pos
	lda #$0f
	sta $d002                          // sprite 1 x pos
	ldx #$af
	stx $07f8 
	dex 
	stx $07f9 
	lda #$f8
	sta $d012                          // raster position
	lda #<Interrupt
	sta $0314 
	lda #>Interrupt
	sta $0315 
	ldx #$8c
	stx $d027                          // sprite 0 color
	stx $d028                          // sprite 1 color
//------------------------------
copylogo:
	lda $28bf,x 						// Copy logo
	sta $03ff,x 
	lda $294b,x 
	sta $048b,x 
	lda $29d7,x 
	sta $d7ff,x 
	lda $2a63,x 
	sta $d88b,x 
	dex 
	bne copylogo
	ldx #$50
	lda #$0b
//------------------------------
copyagain:
	sta $d917,x 
	dex 
	bne copyagain
	lda #<scrolltext
	sta $ae 
	lda #>scrolltext
	sta $af 
	lda #$00
	// jsr $1000
	lda #$80
	sta $0291 
	lda #$c1
	sta $0318 
	cli 
//------------------------------
mainloop:
//------------------------------
	jmp mainloop
//------------------------------
Interrupt:
	inc $d019                          // interrupt request register (irr)
	lda #$70
	sta $d011                          // control register 1
	lda #$1d
	sta $d018                          // memory control register
	lda #$d8
	sta $d016                          // control register 2
	// jsr $1003
	ldy $2c 						//sinept 
	clc 
	lda #$39
	adc sinetable,y 					//update sprite postition
	sta $d001                          // sprite 0 y pos
	sta $d003                          // sprite 1 y pos
	lda #$2f
//------------------------------
rasterwait1:	
//------------------------------
	cmp $d012                          // raster position
	bne rasterwait1
//------------------------------
Rasterwait2:
//------------------------------
	clc 
	lda $d011                          // control register 1
	adc #$01
	and #$07
	ora #$30
	sta $d011                          // control register 1
	lda $d012                          // raster position
//------------------------------
Rasterwait3:
//------------------------------
	cmp $d012                          // raster position
	beq Rasterwait3
	lda sinetable,y 
	cmp $d012                          // raster position
	bne Rasterwait2 
	ldx $2c 							//Sinept 
	inx 
	cpx #$80
	bne Skip1
	ldx #$00
//------------------------------
Skip1:
//------------------------------
	stx $2c 							//sinept 
	ldx #$06
//------------------------------
Delay1:
//------------------------------
	dex 
	bne Delay1
	ldx #$0b
	stx $d020                          // border color
	stx $d021                          // background color 0
	inx 

	lda $d012                          // raster position
//------------------------------
Rasterwait4:
//------------------------------
	cmp $d012                          // raster position
	beq Rasterwait4
	stx $d020                          // border color
	lda #$00
	sta $d021                          // background color 0
	clc 
	lda #$38							//depth of logo
	adc sinetable,y 
//------------------------------
Rasterwait5:
//------------------------------
	cmp $d012                          // raster position
	bne Rasterwait5
	ldx #$08
//------------------------------
Delay2:
	dex 
	bne Delay2
	lda $d011                          // control register 1
	and #$07
	ora #$10
	sta $d011                          // control register 1
	lda #$0c
	sta $d021                          // background color 0
	lda #$13
	sta $d018                          // memory control register
	lda $2d 
	sta $d016                          // control register 2

// Screen control register #2. Bits:
// Bits #0-#2: Horizontal raster scroll.
// Bit #3: Screen width; 0 = 38 columns; 1 = 40 columns.
// Bit #4: 1 = Multicolor mode on.
// Default: $C8, %11001000.


	ldx #$0b
	clc 
	lda #$4b
	adc sinetable,y 
//------------------------------
Rasterwait6:
//------------------------------
	cmp $d012                          // raster position
	bne Rasterwait6
	stx $d020                          // border color
	stx $d021                          // background color 0
	ldx #$00
	lda $d012                          // raster position
//------------------------------
Rasterwait7:
	cmp $d012                          // raster position
	beq Rasterwait7
	stx $d020                          // border color
	stx $d021                          // background color 0
	lda $02 
	beq Skip2
	dec $02 
	jmp SpacePressed
Skip2:
	sec 
	lda $2d 
Poop:
	sbc #$03
	bcc Skip3
	sta $2d 
	jmp SpacePressed
//------------------------------
Skip3:
	and #$07
	sta $2d 
	ldx #$00
//------------------------------
Scrollcopy:
//------------------------------
	lda $0519,x 
	sta $0518,x 
	ora #$80
	sta $0540,x 
	inx 
	cpx #$27
	bne Scrollcopy
	ldy #$00
	lda $2e //scrollpt 
	beq Dontputnewchar
	dec $2e //scrollpt
	lda $053e 
	ora #$40
	sta $053f 
	ora #$80
	sta $0567 
	jmp SpacePressed
//------------------------------
Dontputnewchar:
	lda ($ae),y 
	bne Resetscrollpointer
	lda #<scrolltext
	sta $ae 
	lda #>scrolltext
	sta $af 
	bne Dontputnewchar
//------------------------------
Resetscrollpointer:
	tax 
	and #$80
	beq Skip4
	jsr Readnextcharacter
	txa 
	and #$07
	beq Skip5
	sta Poop+1
	bne Skip4
Skip5:
	lda #$70
	sta $02 
	bpl SpacePressed
//------------------------------
Skip4:
	lda ($ae),y 
	sta $053f 
	ora #$80
	sta $0567 
	ldx #$09
//------------------------------
Skip6:
	cmp $2aef,x //Check for end of scrolltext? 
	beq Skip7
	dex 
	bne Skip6
	inc $2e //Scrollpt 
//------------------------------
Skip7:
	jsr Readnextcharacter
//------------------------------
SpacePressed:
	lda $dc01                          // data port b (keyboard, joystick, paddles)
	cmp #$ef
	beq Exitcleanly
	jmp $ea7e
//------------------------------
Readnextcharacter:
	inc $ae 					// scrollpt low part
	bne Skip8
	inc $af 					//scrollpt hi part
Skip8:
	rts 


//------------------------------
Exitcleanly:
	sei 
	jsr $fda3                         // initialise i/o
	jsr $e51b
	ldx #$1f
	jsr $e5aa
	jsr $ff5e
	ldx #$1f
//------------------------------
Loop4:
//------------------------------
	lda $fd30,x                          // kernal reset vectors
	sta $0314,x 
	dex 
	bpl Loop4
	lda $07ff 
	sta $3fff 
	ldx #$00
	txa 
//------------------------------
Colorloop:
//------------------------------
	sta $d800,x 
	sta $d900,x 
	sta $da00,x 
	sta $db00,x 
	inx 
	bne Colorloop
	ldx #$a0
//------------------------------
Loop5:
//------------------------------
	lda #$0f
	sta $d877,x 
	lda $2e5f,x 
	sta $0477,x 
	dex 
	bne Loop5
	ldx #$34
	stx $01 
//------------------------------
Exitscreencopy:
//------------------------------
	lda $2e43,x // Copy the intro credits to the top line 
	sta $0400,x 
	dex 
	bpl Exitscreencopy
	
	jmp $0400


