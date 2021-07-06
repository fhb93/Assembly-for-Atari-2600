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
JetYPos         byte          ; player0 y-position
BomberXPos      byte          ; player1 x-position (enemy x)
BomberYPos      byte          ; player1 y-position (enemy y)
P0SpritePtr     word          ; pointer to player0 sprite lookup table
P0ColorPtr      word          ; pointer to player0 color lookup table
P1SpritePtr     word          ; pointer to enemy sprite lookup table
P1ColorPtr      word          ; pointer to enemy color lookup table
P0AnimOffset    byte          ; player0 sprite frame offset for "animation"

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
    lda #0
    sta JetXPos               ; JetXPos = 0
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Start the main display loop and frame rendering 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Calculations and tasks performed in the pre-VBlank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda JetXPos
    ldy #0
    jsr SetObjectXPos        ; set player0 horizontal position

    lda BomberXPos
    ldy #1
    jsr SetObjectXPos        ; set player1 horizontal position

    sta WSYNC
    sta HMOVE                ; apply the horizontal offsets previously set

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Display VSYNC and VBLANK 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;  Display the 96 visible scanlines of our main game (2-line kernel)
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

    ldx #96                   ; X counts the number of remaining scanlines
.GameLineLoop:
.AreWeInsidePlayerSprite:
    txa                       ; transfer X to A
    sec                       ; make sure the carry flag is set before subtraction 
    sbc JetYPos               ; subtract sprite Y-coordinate
    cmp P0_HEIGHT             ; are we inside the sprite height bounds?
    bcc .DrawSpriteP0         ; if result < SpriteHeight, call the draw routine
    lda #0                    ; else, set lookup index to zero
.DrawSpriteP0:
    clc                       ; clear carry flag before addition
    adc P0AnimOffset          ; jump to the correct sprite frame address in memory
    tay                       ; load Y so we can work with the pointer
    lda (P0SpritePtr),Y       ; load player0 bitmap data from lookup table
    sta WSYNC                 ; wait for scanline
    sta GRP0                  ; set graphics for player0
    lda (P0ColorPtr),Y        ; load player color from lookup table
    sta COLUP0                ; set graphics of player0
   
.AreWeInsideBomberSprite:
    txa                       ; transfer X to A
    sec                       ; make sure the carry flag is set before subtraction 
    sbc BomberYPos               ; subtract sprite Y-coordinate
    cmp P1_HEIGHT             ; are we inside the sprite height bounds?
    bcc .DrawSpriteP1         ; if result < SpriteHeight, call the draw routine
    lda #0                    ; else, set lookup index to zero
.DrawSpriteP1:
    tay                       ; load Y so we can work with the pointer
    lda #%00000101
    sta NUSIZ1
    lda (P1SpritePtr),Y       ; load player0 bitmap data from lookup table
    sta WSYNC                 ; wait for scanline
    sta GRP1                  ; set graphics for player0
    lda (P1ColorPtr),Y        ; load player color from lookup table
    sta COLUP1                ; set graphics of player0
   
    dex                       ; X--
    bne .GameLineLoop         ; repeat next main game scanline until finished

    lda #0
    sta P0AnimOffset          ; reset player animation frame to zero each frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Display Overscan 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    lda #2
    sta VBLANK                ; turn VBLANK on again
    REPEAT 30                 
        sta WSYNC             ; display 30 recommended lines of VBLANK Overscan
    REPEND
    lda #0
    sta VBLANK                ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Process joystick input for player0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    lda #%00010000            ; player0 joystick up
    bit SWCHA
    bne CheckP0Down           ; if bit pattern doesnt match, bypass Up block
    inc JetYPos
    lda #0
    sta P0AnimOffset

CheckP0Down:
    lda #%00100000            ; player0 joystick down
    bit SWCHA
    bne CheckP0Left           ; if bit pattern doesnt match, bypass Down block
    dec JetYPos
    lda #0
    sta P0AnimOffset

CheckP0Left:
    lda #%01000000            ; player0 joystick left
    bit SWCHA
    bne CheckP0Right          ; if bit pattern doesnt match, bypass Left block
    dec JetXPos
    lda P0_HEIGHT             ; 9
    sta P0AnimOffset          ; set animation offset 

CheckP0Right:
    lda #%10000000            ; player0 joystick right
    bit SWCHA
    bne EndInputCheck         ; if bit pattern doesnt match, bypass Right block
    inc JetXPos
    lda P0_HEIGHT             ; 9
    sta P0AnimOffset          ; set animation offset 

EndInputCheck:                ; fallback when no input was performed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Calculations to update position for next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UpdateBomberPosition:
    lda BomberYPos
    clc
    cmp #0                    ; compare bomber y-position with 0
    bmi .ResetBomberPosition  ; if it is < 0, then reset y-position to the top
    dec BomberYPos            ; else, decrement enemy y-position for next frame 
    jmp EndPositionUpdate

.ResetBomberPosition
    lda #96
    sta BomberYPos
    ; TODO: set bomber X position to random number

EndPositionUpdate:            ; fallback for the position update code
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Loop back to start a brand new frame 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame            ; continue to display the next frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Subroutine to handle object horizontal position with fine offset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  A is the target x-coordinate position in pixels of our object
;;  Y is the object type (0:player0, 1:player1, 2:missile0, 3:missile1, 4:ball)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetObjectXPos subroutine
    sta WSYNC                 ; start a fresh new scanline
    sec                       ; make sure carry-flag is set before subtraction
.Div15Loop
    sbc #15                   ; subtract 15 from accumulator
    bcs .Div15Loop            ; loop until carry-flag is clear
    eor #7                    ; handle offset range from -8 to 7
    asl
    asl
    asl
    asl
    sta HMP0,Y                ; four shift lefts to get only the top 4 bits 
    sta RESP0,Y               ; store the fine offset to the correct HMxx
    rts                       ; fix object position in 15-step increment

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

P1Frame0:
    .byte #%00000000;$00
    .byte #%00001000;$40
    .byte #%00101010;$AE
    .byte #%01111111;$44
    .byte #%00011100;$44
    .byte #%00001000;$44
    .byte #%00001000;$44
    .byte #%00011100;$40
    .byte #%00001000;$40


;---Color Data from PlayerPal 2600---

P0ColorFrame0:
    .byte #$00
    .byte #$0E;
    .byte #$06;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$9A;
    .byte #$0E;
    
P0ColorFrame1:
    .byte #$00
    .byte #$0E;
    .byte #$06;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$9A;
    .byte #$0E;

P0ColorFrame2:
    .byte #$00
    .byte #$0E;
    .byte #$06;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$9A;
    .byte #$0E;

P1ColorFrame0:
    .byte #$00
    .byte #$40
    .byte #$AE;
    .byte #$44;
    .byte #$44;
    .byte #$44;
    .byte #$44;
    .byte #$40;
    .byte #$40;
    .byte #$0E

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Complete ROM size with exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    org $FFFC                 ; move to position $FFFC
    word Reset                ; write 2 bytes with the program reset address
    word Reset                ; write 2 bytes with the interruption vector