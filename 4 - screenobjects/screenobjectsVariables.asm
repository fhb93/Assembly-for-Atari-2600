    processor 6502

    include "../UTILS/vcs.h"
    include "../UTILS/macro.h"

    seg.u Variables
    org $80
P0Height ds 1     ; defines one byte for player 0 height
P1Height ds 1     ;  defines one byte for player 1 height
   
   ; Start of our ROM code segment
    seg
    org $F000

Reset:
    CLEAN_START

    ldx #$80
    stx COLUBK

    lda #%1111
    sta COLUPF

    lda #10
    sta P0Height ; P0Height = 10
    sta P1Height ; P1Height = 10

    lda #$48
    sta COLUP0

    lda #$C6
    sta COLUP1

    ldy #%00000010 ;CTRLPF D1 seto to 1 means (score)
    sty CTRLPF

StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC

    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC

    REPEAT 37
        sta WSYNC
    REPEND
    
    lda #0
    sta VBLANK ; turn VBLANK off

VisibleScanlines:
    
    REPEAT 10
        sta WSYNC
    REPEND

    ldy #0
ScoreboardLoop:
    lda NumberBitmap,Y
    sta PF1
    sta WSYNC
    iny
    cpy #10
    bne ScoreboardLoop

    lda #0
    sta PF1

; Draw 50 empty scanlines between scoreboard and player
    REPEAT 50
        sta WSYNC
    REPEND

    ldy #0
Player0Loop:
    lda PlayerBitmap,Y
    sta GRP0
    sta WSYNC
    iny
    cpy P0Height
    bne Player0Loop

    lda #0
    sta GRP0 ; disable player 0 graphics

    ldy #0
Player1Loop:
    lda PlayerBitmap,Y
    sta GRP1
    sta WSYNC
    iny
    cpy P1Height
    bne Player1Loop

    lda #0
    sta GRP1 ; disable player 1 graphics

; empty playerfield
    REPEAT 102
        sta WSYNC
    REPEND

; Overscan
    REPEAT 30
        sta WSYNC
    REPEND

    jmp StartFrame
    
    org $ffe8
PlayerBitmap:
    .byte #%01111110
    .byte #%11111111
    .byte #%10011001
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%10111101
    .byte #%11000011
    .byte #%11111111
    .byte #%01111110

    org $fff2
NumberBitmap:
    .byte #%00001110
    .byte #%00001110
    .byte #%00000010
    .byte #%00000010
    .byte #%00001110
    .byte #%00001110
    .byte #%00001000
    .byte #%00001000
    .byte #%00001110
    .byte #%00001110

; Fill the ROM size
    org $fffc
    .word Reset
    .word Reset