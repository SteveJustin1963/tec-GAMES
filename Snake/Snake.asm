;Snake
;requires 8x8 led matrix
;Best enjoyed at 4mhz
;Use Port 3&4 for 8x8 matrix

SnakeLen .equ 0809H
Direction .equ 080AH
Random .equ 080Bh
Frame .equ 080Ch ;dimming for fruit - not used
FruitPresent .equ 080Dh ;If fruit is on the screen,dont generate new xy
Speed .equ 0810h ; to 0811h
MoveMade .equ 0820h

.org 0000

ColdBoot:	
	LD SP,0FFFh ;Put stack at ram High
	xor a
	out (1),a
	out (2),a
	out (3),a
	out (4),a

	xor a
	ld (800h),a ;matrix buffer
	ld (801h),a
	ld (802h),a
	ld (803h),a
	ld (804h),a
	ld (805h),a
	ld (806h),a
	ld (807h),a

	ld (MoveMade),a ;only one direction change per snek tick

	ld (Direction),a ;direction of snake

	ld a,5h     ;Speed 0500h
	ld (0810h),a
	ld a,0
	ld (0811h),a

	call ClearBrain
	
	ld a,033h ;starting position x=3, y=3
	ld (900h),a ;64 byte snake 'memory' - where its been
	
	ld a,2
	ld (SnakeLen),a ;snake length
	
	ld a,r
	and 077h ;using the dram refresh counter as a rnd number
	ld (Random),a ;truncated to 0-7, 0-7

	ld a,1
	ld (FruitPresent),a ;fruit is drawn
	
	call MakeFruit ; draw the fruit
	
	JP Main ;Main Program Thread
	
NMI: ;called every keypress
.ORG 00066H ;NMI
	push AF
	push BC
	push DE
	push HL
	
	ld a,(MoveMade)
	cp 0
	jp nz ,EndInt
	
	ld a,1
	ld (MoveMade),a
	
	in a,(0)
	and 0Fh
	cp 0 ;left
	jp z,LeftPressed
	cp 8 ;
	jp z,RightPressed
	cp 5 ;
	jp z,UpPressed
	cp 4 ;
	jp z,DownPressed
	
	jp EndInt

LeftPressed:
	ld a,(Direction)
	cp 0 ;Test for Right cos snake cant reverse
	jp z,EndInt
	ld a,3 ;Left value
	ld (Direction),a
	jp EndInt
	
RightPressed:
	ld a,(Direction)
	cp 3 ;Test for Left cos snake cant reverse
	jp z,EndInt
	ld a,0 ;Right value
	ld (Direction),a
	jp EndInt

UpPressed:
	ld a,(Direction)
	cp 2 ;Test for Down cos snake cant reverse
	jp z,EndInt
	ld a,1 ;Right value
	ld (Direction),a
	jp EndInt

DownPressed:
	ld a,(Direction)
	cp 1 ;Test for Down cos snake cant reverse
	jp z,EndInt
	ld a,2 ;Right value
	ld (Direction),a



EndInt:	

	ld a,(FruitPresent)
	cp 0
	jp nz, EI2
	
	ld a,r
	and 077h
	ld (Random),a
	ld a,1
	ld (FruitPresent),a
EI2:	
	pop HL
	pop DE
	pop BC
	pop AF
	retn

	
	ld a,(Direction)
	

MakeFruit: ;random in (Random)

	ld a,(Random)
	ld c,a
	;check if fruit lands on snek
	ld hl,0900h
	ld a,(SnakeLen)
	dec a
	ld b,a
MF1:
		ld a,(hl)
		cp c
		jp z,Crush
		inc hl
		dec b
		jr nz,MF1
		ret
Crush: ;fruit is on snake.
	ld a,r ;get new rnd value
	and 77h
	ld (Random),a
	jp MakeFruit
	
TestFruit: ;is snake eating fruit?
		ld a,(Random)
		ld c,a
		ld hl,0900h
		ld a,(SnakeLen)
		dec a
		ld b,a
TF1:
		inc hl
		ld a,(hl)
		cp c
		jp z,GrowSnek
		dec b
		jr nz,TF1
		ret
GrowSnek: ;yes
		ld a,(SnakeLen)
		inc a
		ld (SnakeLen),a

		;increase speed
		ld a,(0810h)
		ld H,a
		ld a,(0811h)
		ld L,a
		or a
		ld de,25
		sbc hl,de
		ld a,h
		ld (0810h),a
		ld a,L
		ld (0811h),a
	
		call MakeFruit
		ret

TestCollissioon: ;test newhead with body
		ld hl,0900h
		
		ld a,(hl) ;snake head
		ld c,a
		ld a,(SnakeLen)
		dec a
		ld b,a
TC1:
		inc hl
		ld a,(hl)
		cp c
		jp z,Ouch
		dec b
		jr nz,TC1
		ret
Ouch:
		ld a,0ffH
		out (3),a
		out (4),a
		ld bc,0FFFFh
O1:
		dec c
		jr nz, O1
		dec b
		jr nz, O1

		ld a,00H
		out (3),a
		out (4),a
		ld bc,0FFFFh
O2:
		dec c
		jr nz, O2
		dec b
		jr nz, O2

		ld a,0ffH
		out (3),a
		out (4),a
		ld bc,0FFFFh
O3:
		dec c
		jr nz, O3
		dec b
		jr nz, O3

		jp 0 ;restart

ClearBrain: ;the snakes memory
	ld HL,0900h
	ld b,64
	xor a
CB1:
	ld (HL),a
	inc hl
	dec b
	jr nz, CB1
	ret

Brain2Field: ;update the playing field
	call ClearVram
	;draw each snake memory to display
	ld HL,0900h
	ld a,(SnakeLen)
	ld b,a
B2F1:
	ld a,(HL)
	inc HL
	call PixOn
	dec b
	jr nz,B2F1
	ret

BrainShift: ;move the array
;0900h contains the Head
;shift the head down to make a new head
;0900 > 0901 etc
;we'll need to do this from the bottom up
;

	ld HL,0940h
	ld DE,093Fh
	ld b,64
BS1:
	ld a,(DE)
	ld (HL),a
	dec HL
	dec De
	dec b
	jr nz,BS1
	ret
	
NewHead: ;grow a new head in direction

	ld a,0
	ld (MoveMade),a ; enable new key input

	ld a,(Direction)
	cp 0h
	jp z,HeadRight
	cp 1h
	jp z,HeadUp
	cp 2h
	jp z,HeadDown
	cp 3h
	jp z,HeadLeft
	
	ret
	

HeadUp:
	ld HL,0900h
	ld a,(HL)
	add a,1h
	bit 3,a
	jr z,HU1
	and 0F7h
HU1:
	ld (HL),a
	ret

HeadRight:
	ld HL,0900h
	ld a,(HL)
	add a,10h
	bit 7,a
	jr z,HR1
	and 7Fh
HR1:
	ld (HL),a
	ret
	
HeadDown:
	ld HL,0900h
	ld a,(HL)
	ld c,a ;c is orig
	and 70h
	ld b,a; b is upper nibble
	ld a,c
	and 0Fh
	dec a
	and 07h
	or b
	ld (HL),a
	ret
	
HeadLeft:
	ld HL,0900h
	ld a,(HL)
	ld c,a ;c is orig
	and 07h
	ld b,a; b is lower nibble
	ld a,c
	and 0F0h
	sub 10h
	and 70h
	or b
	ld (HL),a
	ret
	
ClearVram:
	xor a
	ld (800h),a
	ld (801h),a
	ld (802h),a
	ld (803h),a
	ld (804h),a
	ld (805h),a
	ld (806h),a
	ld (807h),a
	ret

;Routines:
ReDraw:
;
; 0800h left column
; bit 0 bottom row.
;
;
;
;VRAM in 0800, 8 bytes
	push HL
	ld HL,0800h
	ld a,(HL)
	out (4),a
	ld a,1
	out (3),a
	inc hl
	xor a
	out (3),a
	
	ld a,(HL)
	out (4),a
	ld a,2
	out (3),a
	inc hl
	xor a
	out (3),a
	
	ld a,(HL)
	out (4),a
	ld a,4
	out (3),a
	inc hl
	xor a
	out (3),a
	
	ld a,(HL)
	out (4),a
	ld a,8
	out (3),a
	inc hl
	xor a
	out (3),a
	
	ld a,(HL)
	out (4),a
	ld a,10h
	out (3),a
	inc hl
	xor a
	out (3),a
	
	ld a,(HL)
	out (4),a
	ld a,20h
	out (3),a
	inc hl
	xor a
	out (3),a
	
	ld a,(HL)
	out (4),a
	ld a,40h
	out (3),a
	inc hl
	xor a
	out (3),a
	
	ld a,(HL)
	out (4),a
	ld a,80h
	out (3),a
	inc hl
	xor a
	out (3),a
	
	pop HL
	ret

PixOn: ;A - High Nibble = X, Low Nibble = Y
	push HL
	push BC
	ld H,08h
	ld b,a
	and 0F0h
	RRA
	RRA
	RRA
	RRA
	ld L,A
	ld a,b
	and 0Fh
	ld b,a
	inc b
	
	ld a,1
	dec b
	jr z, POdone
	RLA
	dec b
	jr z, POdone
	RLA
	dec b
	jr z, POdone
	RLA
	dec b
	jr z, POdone
	RLA
	dec b
	jr z, POdone
	RLA
	dec b
	jr z, POdone
	RLA
	dec b
	jr z, POdone
	RLA
	dec b
	jr z, POdone
	
POdone:
	
	ld b,a
	ld a,(hl)
	or b
	ld (HL),a
	pop BC
	pop HL
	ret
	
Main:
	call Brain2Field
	ld a,(0810h) ;speed registers
	ld b,a
	ld a,(0811h)
	ld c,a
M1:
	call ReDraw
	dec c
	jp nz,M1
	dec b
	jp nz,M1

	ld a,(0810h)
	ld b,a
	ld a,(0811h)
	ld c,a
M2:
	LD A,(Random)
	call PixOn ;draw the fruit
	call ReDraw
	dec c
	jp nz,M2
	dec b
	jp nz,M2

	call BrainShift
	call NewHead
	call TestCollissioon 
	call TestFruit

	jp Main

	.DB "Snake By Ben Grimmett"
.END

