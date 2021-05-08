    processor 6502

    include "../UTILS/vcs.h"
    include "../UTILS/macro.h"

    seg.u Variables
    org $80
P0XPos    byte    ; sprite X coordinate

    seg Code
    org $F000

Reset:
    CLEAN_START   ; macro to clean memory and TIA
 
    ldx #$00      ; black blackground color
    stx COLUBK    

; initialize variables
    lda #50
    sta P0XPos    ; initialize player X coordinate

StartFrame:
    lda #2
    sta VBLANK    ; turn VBLANK on
    sta VSYNC     ; turn VSYNC on

; 3 vertical lines of VSYNC

    REPEAT 3
        sta WSYNC
    REPEND
    lda #0
    sta VSYNC    ; turn VSYNC off
