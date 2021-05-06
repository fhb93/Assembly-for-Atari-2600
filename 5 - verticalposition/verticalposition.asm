    processor 6502
    include "../UTILS/vcs.h"
    include "../UTILS/macro.h"

    seg.u Variables
    org $80
P0Height    byte
PlayerYPos  byte

    seg Code
    org $F000

Reset:
    CLEAN_START

    ldx #$00
    stx COLUBK

    lda #180
    sta PlayerYPos

    lda #9
    sta P0Height

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
    sta VBLANK

;; Draw the 192 scanlines
    ldx #192

Scanline:
    txa                       ; transfer X to A
    sec                       ; make sure carry flag is set
    sbc PlayerYPos            ; subtract sprite Y coordinate
    cmp P0Height              ; are we inside the sprite height bounds?
    bcc LoadBitmap            ; if result < SpriteHeight, call subroutine
    lda #0                    ; else, set index to 0

LoadBitmap:
    tay
    lda P0Bitmap,Y            ; load player bitmap slice of data                  
    sta WSYNC                 ; wait for next scanline 
    sta GRP0                  ; set graphics for player 0 slice
    lda P0Color,Y             ; load player color from lookup table
    sta COLUP0                ; set color for player 0 slice
    dex
    bne Scanline              ; repeat nxt scanline until finished

Overscan:
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND

; Decrement Y-coordinate in each frame for animation effect
    dec PlayerYPos

; Loop to next frame
    jmp StartFrame

P0Bitmap:
    byte #%00000000
    byte #%00101000
    byte #%01110100
    byte #%11111010
    byte #%11111010
    byte #%11111010
    byte #%11111110
    byte #%01101100
    byte #%00110000

P0Color:
    byte #$00
    byte #$40
    byte #$40
    byte #$40
    byte #$40
    byte #$42
    byte #$42
    byte #$44
    byte #$D2

; Complete ROM size
    org $fffc
    word Reset
    word Reset

