; Final Project code stub - paused in lecture 55

    processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Include required files VCS register memory mapping and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    include "../UTILS/vcs.h"
    include "../UTILS/macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Declare the variable starting from memory adderss $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg.u Variables
    org $80

JetXPos         byte          ; player0 x-position
JetYPos         byte          ; player y-position
BomberXPos      byte          ; player1 x-position (enemy x)
BomberYPos      byte          ; player1 y-position (enemy y)
P0SpritePtr     word          ; pointer to player0 sprite lookup table
P0ColorPtr      word          ; pointer to player0 color lookup table
P1SpritePtr     word          ; pointer to enemy sprite lookup table
P1ColorPtr      word          ; pointer to enemy color lookup table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Define constants  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0_HEIGHT = 9                 ; player0 sprite height (# rows in lookup table)
P1_HEIGHT = 9                 ; player1 sprite height (# rows in lookup table)

;; below code can be possible as an alternative
;; P0_HEIGHT = . - P0Frame0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Start our ROM code at memory address $F000  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg Code
    org $F000

Reset:
    CLEAN_START               ; call macro to reset memory and registers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Initialize RAM variables and TIA registers 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #10
    sta JetYPos               ; JetYPos = 10
    
    lda #60
    sta JetXPos               ; JetXPos = 60
    lda #83
    sta BomberYPos
    lda #54
    sta BomberXPos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Initialize the pointers to the correct lookup table addresses 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #<P0Frame1
    sta P0SpritePtr           ; lo-byte pointer for player sprite lookup table
    lda #>P0Frame1   
    sta P0SpritePtr+1          ; hi-byte pointer for player sprite lookup table

    lda #<P0ColorFrame1       
    sta P0ColorPtr    
    lda #>P0ColorFrame1
    sta P0ColorPtr+1

    lda #<P1Frame0
    sta P1SpritePtr           ; lo-byte pointer for enemy sprite lookup table
    lda #>P1Frame0   
    sta P1SpritePtr+1          ; hi-byte pointer for enemy sprite lookup table

    lda #<P1ColorFrame0       
    sta P1ColorPtr    
    lda #>P1ColorFrame0
    sta P1ColorPtr+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Start the main display loop and frame rendering 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Display VSYNC and VBLANK 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK               ; turn on VBLANK (0010)
    sta VSYNC                ; turn on VSYNC
    REPEAT 3                 
        sta WSYNC            ; display 3 recommended liens of VSYNC    
    REPEND  
    lda #0             
    sta VSYNC                ; turn off VSYNC 
    REPEAT 37
        sta WSYNC            ; display the 37 recommended lines of VBLANK
    REPEND
    sta VBLANK               ; turn off VBLANK                      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Display the 192 visible scanlines of our main game 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameVisibleLine:
    lda #$84                 
    sta COLUBK                ; set color background to blue

    lda #$C2
    sta COLUPF                ; set playfield/grass color to green
    
    lda #%00000001
    sta CTRLPF                ; enable playfield reflection

    lda #$F0
    sta PF0                   ; setting PF0 bit pattern
    
    lda #$FC
    sta PF1                   ; setting PF1 bit paattern
    
    lda #0
    sta PF2                   ; setting PF2 bit paattern

    ldx #192                  ; X counts the number of remaining scanlines
.GameLineLoop:
    sta WSYNC
    dex                       ; X--
    bne .GameLineLoop         ; repeat next main game scanline until finished

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Display Overscan 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    lda #2
    sta VBLANK                ; turn VBLANK on again
    REPEAT 30                 
        sta VBLANK            ; display 30 recommended lines of VBLANK Overscan
    REPEND
    lda #0
    sta VBLANK                ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Loop back to start a brand new frame 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    jmp StartFrame            ; continue to display the next frame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Declare ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Frame0:
    .byte #%00000000 
    .byte #%00010000;$0E
    .byte #%00111000;$06
    .byte #%00010000;$0E
    .byte #%00010000;$0E
    .byte #%00111000;$0E
    .byte #%01111100;$0E
    .byte #%00010000;$9A
    .byte #%00010000;--

P0Frame1:
    .byte #%00000000
    .byte #%00001000;$0E
    .byte #%00011100;$06
    .byte #%00001000;$0E
    .byte #%00001000;$0E
    .byte #%00111110;$0E
    .byte #%01111111;$0E
    .byte #%00001000;$9A
    .byte #%00001000;--

P0Frame2:
    .byte #%00000000
    .byte #%00000100;$0E
    .byte #%00001110;$06
    .byte #%00000100;$0E
    .byte #%00000100;$0E
    .byte #%00001110;$0E
    .byte #%00011111;$0E
    .byte #%00000100;$9A
    .byte #%00000100;--

P1Frame1:
    .byte #%00000000
    .byte #%00010000;$0E
    .byte #%00111000;$06
    .byte #%00010000;$0E
    .byte #%00010000;$0E
    .byte #%00111000;$0E
    .byte #%01111100;$0E
    .byte #%00010000;$9A
    .byte #%00010000;--


;---Color Data from PlayerPal 2600---

P0ColorFrame0:
    .byte #$0E;
    .byte #$06;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$9A;
    .byte #$0E;

P0ColorFrame1:
    .byte #$0E;
    .byte #$06;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$9A;
    .byte #$0E;

P0ColorFrame2:
    .byte #$0E;
    .byte #$06;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$9A;
    .byte #$0E;

P1ColorFrame0:
    .byte #$0E;
    .byte #$06;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$9A;
    .byte #$0E;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Complete ROM size with exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    org $FFFC                 ; move to position $FFFC
    word Reset                ; write 2 bytes with the program reset address
    word Reset                ; write 2 bytes with the interruption vector