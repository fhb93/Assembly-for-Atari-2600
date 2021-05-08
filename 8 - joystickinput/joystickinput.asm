    processor 6502
    include "../UTILS/vcs.h"
    include "../UTILS/macro.h"
    
    seg.u Variables
    org $80
P0XPos   byte          ; sprite X coordinate

    seg Code
    org $F000

Reset:
    CLEAN_START

    ldx #$80           ; blue background color
    stx COLUBK

    ldx #$D0           ; green playfield floor color
    stx COLUPF

    lda #10
    sta P0XPos 


StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC


    REPEAT 3
        sta WSYNC
    REPEND
    lda #0
    sta VSYNC

;; Set player horizontal position while in VBLANK
    lda P0XPos
    and #$7F
    sta HMCLR

    sec
DivideLoop:
    sbc #15
    bcs DivideLoop

    eor #7
    asl
    asl
    asl
    asl
    sta HMP0
    sta RESP0
    sta WSYNC
    sta HMOVE

    REPEAT 35
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

;; Draw the 192 visible scanlines
    REPEAT 160
        sta WSYNC
    REPEND

    ldy #17
DrawBitmap:
    lda P0Bitmap,Y
    sta GRP0

    lda P0Color,Y
    sta COLUP0
    
    sta WSYNC

    dey
    bne DrawBitmap

    lda #0
    sta GRP0            ; disable P0 bitmap graphics

    lda #$FF             ; enable grass playfield
    sta PF0
    sta PF1
    sta PF2

    REPEAT 15
        sta WSYNC
    REPEND

    lda #0              ; disable grass playfield
    sta PF0
    sta PF1
    sta PF2

Overscan:
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND

;; Joystick input test for P0-up and P0-down

CheckP0Up:
    lda #%00010000
    bit SWCHA
    bne CheckP0Down
    inc P0XPos
;; Logic when player 0 UP is pressed

CheckP0Down:
    lda #%00100000
    bit SWCHA
    bne CheckP0Left
    dec P0XPos

;; Logic when player 0 Down is pressed   

CheckP0Left:
    lda #%01000000
    bit SWCHA
    bne CheckP0Right
    dec P0XPos
;; Logic when player 0 Left is pressed   

CheckP0Right:
    lda #%10000000
    bit SWCHA
    bne NoInput
    inc P0XPos
;; Logic when player 0 Right is pressed

NoInput:

;; Fallback when no input was performed

;; Loop to next frame
    jmp StartFrame

P0Bitmap:
    byte #%00000000
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00011100
    byte #%01011101
    byte #%01011101
    byte #%01011101
    byte #%01011101
    byte #%01111111
    byte #%00111110
    byte #%00010000
    byte #%00011100
    byte #%00011100
    byte #%00011100

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lookup table for the player colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Color:
    byte #$00
    byte #$F6
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$3E
    byte #$3E
    byte #$3E
    byte #$24

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete ROM size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    word Reset
    word Reset