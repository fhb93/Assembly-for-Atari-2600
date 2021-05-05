    processor 6502

    include "../UTILS/vcs.h"
    include "../UTILS/macro.h"

    seg
    org $F000

Reset:
    CLEAN_START

    ldx #$80
    stx COLUBK

    lda #%1111
    sta COLUPF

    lda #$ff
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

Player0Loop:
    lda Frame0,Y
    sta GRP0
    sta WSYNC
    iny
    lda Frame1,Y
    sta GRP0
    sta WSYNC
    iny
    lda Frame2,Y
    sta GRP0
    sta WSYNC
    iny
    cpy #24
    bne Player0Loop

    lda #0
    sta GRP0 ; disable player 0 graphics

; empty playerfield
    REPEAT 192
        sta WSYNC
    REPEND

; Overscan
    REPEAT 30
        sta WSYNC
    REPEND

    jmp StartFrame
    
    org $ffe4
Frame0:
        .byte #%00000000;--
        .byte #%00000001;--
        .byte #%00000110;--
        .byte #%00001110;--
        .byte #%00111100;--
        .byte #%01111100;--
        .byte #%10100100;--
        .byte #%00100100;--
Frame1:
        .byte #%00000001;--
        .byte #%00000110;--
        .byte #%00001110;--
        .byte #%00111100;--
        .byte #%01111100;--
        .byte #%01100010;--
        .byte #%00100000;--
        .byte #%00010000;--
Frame2:
        .byte #%00000000;--
        .byte #%00000001;--
        .byte #%00000110;--
        .byte #%00001110;--
        .byte #%00111100;--
        .byte #%11111100;--
        .byte #%00100100;--
        .byte #%01000100;--

; Fill the ROM size
  
    org $fffc
    .word Reset
    .word Reset