    processor 6502

    include "../UTILS/vcs.h"
    include "../UTILS/macro.h"

     seg.u Variables
     org $80

; Variables here

logo_height byte
logo_color  byte
temp1       byte
temp2       byte

    seg Code
    org $F000

Reset:
    CLEAN_START

     

LogoFrame:
; Enable VBLANK
    lda #2
    sta logo_height

	lda #2
    sta VBLANK
	sta VSYNC
	lda #26
	sta TIM8T
LogoWaitVSync:
	lda INTIM
	bne LogoWaitVSync
	sta WSYNC                   ; 3     (0)
	sta VSYNC                   ; 3     (3)

; 37 lines of VBLANK
	lda #44                     ; 2     (5)
	sta TIM64T                  ; 3     (8)
    sleep 5                     ; 5     (13)
	lda #1                      ; 2     (15)
	sta VDELP0                  ; 3     (18)
	sta VDELP1                  ; 3     (21)
	lda #$A6                    ; 2     (23)
    sta COLUPF                  ; 3     (26)
    sleep 10                    ; 10    (36)
	sta RESP0                   ; 3     (39)
	sta RESP1                   ; 3     (42)
	lda #$20                    ; 2     (44)
	sta HMP1                    ; 2     (47)
    lda #$10                    ; 2     (49)
    sta HMP0                    ; 3     (52)
	lda #$33                    ; 2     (54)
	sta NUSIZ0                  ; 3     (57)
	STA NUSIZ1                  ; 3     (60)
	sta WSYNC
	sta HMOVE
	lda #logo_color
	sta COLUP0
	sta COLUP1
	
	
LogoWaitVBlank:
	lda INTIM
	bne LogoWaitVBlank	; loop until timer expires
	sta WSYNC

; disable VBLANK
	lda #0
    sta VBLANK

; waste 51 scanlines
;	ldx #51
    ldx #(96 - (logo_height/2))
LogoVisibleScreen:
    sta WSYNC
	dex
	bne LogoVisibleScreen



    ; Blank Screen and Set Playfield

    ldy #logo_height-1
    lda logo_colors,Y
    sta COLUP0
    sta COLUP1
    
LogoLoop:
    sta WSYNC                       ; 3     (0)
    sty temp1                       ; 3     (3)
    lda logo_0,Y                   ; 4     (7)
    sta GRP0                        ; 3     (10) 0 -> [GRP0]
    lda logo_1,Y                   ; 4     (14)
    sta GRP1                        ; 3     (17) 1 -> [GRP1] ; 0 -> GRP0
    lda logo_2,Y                   ; 4     (21)
    sta GRP0                        ; 3     (24*) 2 -> [GRP0] ; 1 -> GRP1
    ldx logo_4,Y                   ; 4     (28) 4 -> X
    lda logo_5,Y                   ; 4     (32)
    sta temp2                       ; 3     (35)
    lda logo_3,Y                   ; 4     (39) 3 -> A
    ldy temp2                       ; 3     (42) 5 -> Y
    sta GRP1                        ; 3     (45) 3 -> [GRP1] ; 2 -> GRP0
    stx GRP0                        ; 3     (48) 4 -> [GRP0] ; 3 -> GRP1
    sty GRP1                        ; 3     (51) 5 -> [GRP1] ; 4 -> GRP0
    sta GRP0                        ; 3     (54) 5 -> GRP1
    ldy temp1                       ; 3     (57)
    lda logo_colors-1,Y               ; 4     (61)
    sta COLUP0                      ; 3     (64)
    sta COLUP1                      ; 3     (67)
    dey                             ; 2     (69)
    bpl LogoLoop                    ; 3     (72)
    
    ldy #0
    sty GRP0
    sty GRP1
    sty GRP0
    sty GRP1
;	ldx #40
    ldx #((96 - (logo_height/2))-1)
LogoGap:
    sta WSYNC
	dex                         ; 2     (2)
	bne LogoGap                 ; 2     (4)

LogoOverscanStart:
; Enable VBLANK
	lda #2
        sta VBLANK
; overscan
	ldx #35
	stx TIM64T
	lda INTIM
	clc
	adc #128
	sta TIM64T
	

.drawlogo
	lda INTIM
	bmi .drawlogo	; loop until timer expires
	jmp LogoFrame

    if >. != >[.+(logo_height)]
        align #256
    endif
    
    
; Paste image information here

logo_0:
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000001
	.byte #%00000001
	.byte #%00000001
	.byte #%00000001
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000


    if >. != >[.+(logo_height)]
        align #256
    endif

logo_1:
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00110001
	.byte #%00001001
	.byte #%00110011
	.byte #%00011001
	.byte #%00000000
	.byte #%00000000
	.byte #%00100010
	.byte #%00110010
	.byte #%00101011
	.byte #%00110010
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000001
	.byte #%00000011
	.byte #%00000111
	.byte #%00000101
	.byte #%00000111
	.byte #%00000101
	.byte #%00000111
	.byte #%00000101
	.byte #%00000011
	.byte #%00000011
	.byte #%00000001
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00011101
	.byte #%00010101
	.byte #%00010101
	.byte #%00010101
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%11010010
	.byte #%00010111
	.byte #%10010010
	.byte #%11010001
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000


    if >. != >[.+(logo_height)]
        align #256
    endif

logo_2:
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00111001
	.byte #%00101010
	.byte #%10101001
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%10101010
	.byte #%10101010
	.byte #%00001000
	.byte #%00101010
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00001100
	.byte #%00000110
	.byte #%00000011
	.byte #%00000001
	.byte #%00111111
	.byte #%11010001
	.byte #%11111001
	.byte #%01010101
	.byte #%11111111
	.byte #%01010101
	.byte #%11111111
	.byte #%01010101
	.byte #%11111110
	.byte #%01010110
	.byte #%11111100
	.byte #%01011000
	.byte #%11110000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00100101
	.byte #%00100101
	.byte #%01110001
	.byte #%00100100
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01110101
	.byte #%01100101
	.byte #%01110110
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000


    if >. != >[.+(logo_height)]
        align #256
    endif

logo_3:
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%10100100
	.byte #%10101010
	.byte #%10000100
	.byte #%10100000
	.byte #%00000000
	.byte #%00000000
	.byte #%11000100
	.byte #%01001010
	.byte #%01100100
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00011000
	.byte #%00110000
	.byte #%01100000
	.byte #%11000000
	.byte #%11111110
	.byte #%11000101
	.byte #%01001111
	.byte #%01010101
	.byte #%01111111
	.byte #%01010101
	.byte #%01111111
	.byte #%01010101
	.byte #%00111111
	.byte #%00110101
	.byte #%00011111
	.byte #%00001101
	.byte #%00000111
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01001100
	.byte #%11010100
	.byte #%11001101
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00010000
	.byte #%00011001
	.byte #%00010100
	.byte #%00011000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000


    if >. != >[.+(logo_height)]
        align #256
    endif

logo_4:
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01000100
	.byte #%11100100
	.byte #%01001110
	.byte #%00100100
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%10000000
	.byte #%11000000
	.byte #%01100000
	.byte #%11110000
	.byte #%01010000
	.byte #%11110000
	.byte #%01010000
	.byte #%11110000
	.byte #%01010000
	.byte #%11100000
	.byte #%01100000
	.byte #%11000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%10011100
	.byte #%10011000
	.byte #%11011100
	.byte #%10000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%10010100
	.byte #%01010101
	.byte #%10011001
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000


    if >. != >[.+(logo_height)]
        align #256
    endif

logo_5:
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%11000000
	.byte #%01000000
	.byte #%00000000
	.byte #%11000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000


    if >. != >[.+(logo_height)]
        align #256
    endif

logo_colors:
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C0
   .byte #$C2
   .byte #$C2
   .byte #$C2
   .byte #$C2
   .byte #$C2
   .byte #$C2
   .byte #$C2
   .byte #$C2
   .byte #$C2
   .byte #$C2
   .byte #$C4
   .byte #$C4
   .byte #$C4
   .byte #$C4
   .byte #$C4
   .byte #$C4
   .byte #$C4
   .byte #$C4
   .byte #$C4
   .byte #$C4
   .byte #$C6
   .byte #$C6
   .byte #$C6
   .byte #$C6
   .byte #$C6
   .byte #$C6
   .byte #$C6
   .byte #$C6
   .byte #$C6
   .byte #$C6
   .byte #$C8
   .byte #$C8
   .byte #$C8
   .byte #$C8
   .byte #$C8
   .byte #$C8
   .byte #$C8
   .byte #$C8
   .byte #$C8
   .byte #$C8
   .byte #$CA
   .byte #$CA
   .byte #$CA
   .byte #$CA
   .byte #$CA
   .byte #$CA
   .byte #$CA
   .byte #$CA
   .byte #$CA
   .byte #$CA
   .byte #$CC
   .byte #$CC
   .byte #$CC
   .byte #$CC
   .byte #$CC
   .byte #$CC
   .byte #$CC
   .byte #$CC
   .byte #$CC
   .byte #$CC
   .byte #$CE

    ; end of ROM Cartridge
    org $FFFC
    word Reset
    word Reset
