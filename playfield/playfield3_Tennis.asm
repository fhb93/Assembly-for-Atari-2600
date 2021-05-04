    processor 6502

    include "../UTILS/vcs.h"
    include "../UTILS/macro.h"

    seg
    org $F000

Reset:
    CLEAN_START

    ldx #$C2
    stx COLUBK
    
    lda #$0b
    sta COLUPF

StartFrame:
    lda #02
    sta VBLANK
    sta VSYNC


    REPEAT 3
        sta WSYNC     ; 3 scanlines for VSYNC
    REPEND
    lda #0
    sta VSYNC
    
    REPEAT 37
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK
    
    ; Allow CTRLPF register to allow playfield reflection
    ldx #%00000001
    stx CTRLPF
    
    ; Draw the 192 visible scanlines
    ; skip 7 scanlines with no PF set
    ldx #0
    stx PF0
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND
    
    ; Set the PF0 to 1110 (LSB first) and PF1-PF2 as 1111 1111
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND
    
    ldx #%00100000
    stx PF0
    ldx #%00000000
    stx PF1
    ldx #%10000000
    stx PF2
    REPEAT 8
        sta WSYNC
    REPEND
    
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND
    
    ; Set the Next 74 lines only with PF0 third and fourth bit enabled
    ldx #%00100000
    stx PF0
    ldx #%0000100
    stx PF1
    ldx #%10000000
    stx PF2
    REPEAT 67
        sta WSYNC
    REPEND
    
    ldx #%00100000
    stx PF0
    ldx #%00000111
    stx PF1
    ldx #%11111111
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND
    
     ; Set the Next 74 lines only with PF0 third and fourth bit enabled
    ldx #%00100000
    stx PF0
    ldx #%0000100
    stx PF1
    ldx #%10000000
    stx PF2
    REPEAT 67
        sta WSYNC
    REPEND
    
    
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND
    
    ldx #%00100000
    stx PF0
    ldx #%00000000
    stx PF1
    ldx #%10000000
    stx PF2
    REPEAT 8
        sta WSYNC
    REPEND
    
    ; Set the PF0 to 1110 (LSB first) and PF1-PF2 as 1111 1111
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND
    
    ; Skip 7 vertical lines with no PF set
    ldx #0
    stx PF0
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND
    
; overscan    
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK
       
    
    jmp StartFrame
    
    org $FFFC
    .word Reset
    .word Reset