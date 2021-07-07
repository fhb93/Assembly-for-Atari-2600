; Final Project code stub - paused in lecture 70

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
Score           byte          ; 2-digit score stored as BCD
Timer           byte          ; 2-digit timer stored as BCD
Temp            byte          ; auxiliary variable to store temp score values
OnesDigitOffset word          ; lookup table offset for the score 1's digit
TensDigitOffset word          ; lookup table offset for the score 10's digit
P0SpritePtr     word          ; pointer to player0 sprite lookup table
P0ColorPtr      word          ; pointer to player0 color lookup table
P1SpritePtr     word          ; pointer to enemy sprite lookup table
P1ColorPtr      word          ; pointer to enemy color lookup table
P0AnimOffset    byte          ; player0 sprite frame offset for "animation"
Random          byte          ; random number generated to set enemy position
ScoreSprite     byte          ; store the sprite bit pattern for the score
TimerSprite     byte          ; store the sprite bit pattern for the timer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Define constants  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0_HEIGHT = 9                 ; player0 sprite height (# rows in lookup table)
P1_HEIGHT = 9                 ; player1 sprite height (# rows in lookup table)
DIGITS_HEIGHT = 5             ; scoreboard digit height (#rows in lookup table)

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
    lda #68
    sta JetXPos               ; JetXPos = 0
    lda #83
    sta BomberYPos
    lda #62
    sta BomberXPos
    lda #%11010100
    sta Random                ; Random = $D4
    lda #4
    sta Score
    lda #8
    sta Timer                 ; Score = Timer = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Initialize the pointers to the correct lookup table addresses 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #<P0Frame1
    sta P0SpritePtr           ; lo-byte pointer for player sprite lookup table
    lda #>P0Frame1   
    sta P0SpritePtr+1         ; hi-byte pointer for player sprite lookup table

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
    REPEAT 33
        sta WSYNC            ; display the recommended lines of VBLANK
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Calculations and tasks performed in the pre-VBlank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda JetXPos
    ldy #0
    jsr SetObjectXPos        ; set player0 horizontal position

    lda BomberXPos
    ldy #1
    jsr SetObjectXPos        ; set player1 horizontal position

    jsr CalculateDigitOffset ; calculate the scoreboard digit lookup table offset  

    sta WSYNC
    sta HMOVE                ; apply the horizontal offsets previously set

    lda #0
    sta VBLANK               ; turn off VBLANK                      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Display the scoreboard lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0                   
    sta PF0
    sta PF1 
    sta PF2
    sta GRP0
    sta GRP1                 
    sta COLUBK               ; reset TIA registers before displaying the score
    sta CTRLPF               ; disable playfield reflection
    
    lda #$1E                 ;
    sta COLUPF               ; set the scoreboard playfield color with yellow

    ldx #DIGITS_HEIGHT       ; start X counter with 5 (height of digits)

.ScoreDigitLoop:
    ldy TensDigitOffset      ; get the tens digit offset for the Score
    lda Digits,Y             ; load the bit pattern from lookup table
    and #$F0                 ; mask/remove the graphics for the ones digit
    sta ScoreSprite          ; save the score tens digit pattern in a variable
    ldy OnesDigitOffset      ; get the ones digit offset for the Score
    lda Digits,Y             ; load the digit bit pattern from lookup table
    and #$0F                 ; mask/remove the graphics for the tens digit
    ora ScoreSprite          ; merge it with the saved tens digit sprite
    sta ScoreSprite          ; and save it   
    sta WSYNC                ; wait for the end of scanline
    sta PF1                  ; update the playfield to display the Score sprite
    
    ldy TensDigitOffset+1    ; get the left digit offset for the Timer
    lda Digits,Y             ; load the digit pattern from lookup table
    and #$F0                 ; mask/remove the graphics for the ones digit
    sta TimerSprite          ; save the timer tens digit pattern in a variable

    ldy OnesDigitOffset+1    ; get the ones digit offset for the Timer
    lda Digits,Y             ; load digit pattern from the lookup table
    and #$0F                 ; mask/remove the graphics for the tens digit
    ora TimerSprite          ; merge with the saved tens digit graphics
    sta TimerSprite          ; and save it

    ; waste some cycles
    jsr Sleep12Cycles        ; wastes some cycles         

    sta PF1                  ; update the playfield for Timer display

    ldy ScoreSprite          ; preload for the next scanline
    sta WSYNC                ; wait for the next scanline
    
    sty PF1                  ; update playfield for the score display
    inc TensDigitOffset       
    inc TensDigitOffset+1
    inc OnesDigitOffset
    inc OnesDigitOffset+1    ; increment all digits for the next line of data

    jsr Sleep12Cycles        ; wastes some cycles

    dex                      ; X--
    sta PF1
    bne .ScoreDigitLoop      ; if dex != 0, then branch to ScoreDigitLoop

    sta WSYNC
    lda #0
    sta PF0
    sta PF1
    sta PF2
    sta WSYNC
    sta WSYNC
    sta WSYNC
    ; REPEAT 20
    ;     sta WSYNC            ; display 20 scanlines where the scoreboard goes
    ; REPEND    

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

    ldx #85                   ; X counts the number of remaining scanlines
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
    sta WSYNC                 ; wait for a scanline

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
    jsr GetRandomBomberPos    ; call subroutine for random x-position

EndPositionUpdate:            ; fallback for the position update code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Check for object collision 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckCollisionP0P1:
    lda #%10000000            ; CXPPMM bit 7 detects P0 and P1 collision
    bit CXPPMM                ; check CXPPMM bit 7 with the above pattern
    bne .CollisionP0P1        ; if collision P0 and P1 happened, game over
    jmp CheckCollisionP0PF    ; else, skip to next check
.CollisionP0P1:
    jsr GameOver              ; call GameOver subroutine

CheckCollisionP0PF:
    lda #%10000000            ; CXP0FB bit 7 detects P0 and PF collision
    bit CXP0FB                ; check CXP0FB bit 7 with the above pattern
    bne .CollisionP0PF        ; if collision P0 and P1 happened
    jmp EndCollisionCheck     ; else, skip to the end check

.CollisionP0PF:
    jsr GameOver              ; call gameOver subroutine

EndCollisionCheck:            ; fallback
    sta CXCLR                 ; clear all collision flags before the next frame

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Game Over subroutine 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameOver subroutine
    lda #$30
    sta COLUBK
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Subroutine to generate a Linear-Feedback Shift Register random number 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Generate a LFSR random number
;;  Divide the random value by 4 to limit the size of the result to match river 
;;  Add 30 to compensate for the left green playfield
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetRandomBomberPos subroutine
    lda Random
    asl
    eor Random
    asl 
    eor Random
    asl
    asl
    eor Random
    asl
    rol Random

    lsr
    lsr                      ; divide by 4
    sta BomberXPos           ; save it to the variable BomberXPos
    lda #30
    adc BomberXPos           ; adds 30 + BomberXPos to compensate left PF
    sta BomberXPos           ; and sets to the new value to the bomber x-position
    
    lda #96
    sta BomberYPos           ; set the y-posotion to the top of the screen
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Subroutine to handle scoreboard digits to be displayed on the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert the high and low nibbles of the variable Score and Timer
;; into the offsets of digits lookup table so the values can be displayed.
;; Each digit has a height of 5 bytes in the lookup table.
;;
;; For the low nibble we need to multiply by 5
;;   - we can use left shifts to perform multiplication by 2
;;   - for any number N, the value of [N*5 = (N*2*2)+N]
;; For the upper nibble, since its already times 16, we need to divide it 
;; and then multiply by 5:
;;   - we can use right shifts to perform division by 2
;;   - for any number N, the value of (N/16)*5=(N/2/2)+(N/2/2/2/2)  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

CalculateDigitOffset subroutine
    ldx #1                   ; X register is the loop counter
.PrepareScoreLoop            ; this will loop twice, first X=1, and then X=0

    lda Score,X              ; load A with Timer (X=1) or Score (X=0)
    and #$0F                 ; remove the tens digit by masking 4 bits 00001111  
    sta Temp                 ; save the value of A into Temp
    asl                      ; shift left (it is now N*2)
    asl                      ; shift left (it is now N*4)
    adc Temp                 ; add the value saved in Temp (+N)
    sta OnesDigitOffset,X    ; save A in OnesDigitOffset+1 or OnesDigitOffset  
    
    lda Score,X              ; load A with Timer (X=1) or Score(X=0)
    and #$F0                 ; remove the ones digit by masking 4 bits 11110000
    lsr                      ; shift right (it is now N/2)
    lsr                      ; shift right (it is now N/4)
    sta Temp                 ; save the vale of A into Temp
    lsr                      ; shift right (it is now N/8)
    lsr                      ; shift right (it is now N/16)
    adc Temp                 ; add the value saved in Temp (N/16 + N/4)
    sta TensDigitOffset,X    ; store A in TensDigitOffset+1 or TensDigitOffset
   
    dex                      ; X--
    bpl .PrepareScoreLoop    ; while X >= 0, loop to pass a second time

    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Subroutine to waste 12 cycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; jsr takes 6 cycles
;; rts takes 6 cycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Sleep12Cycles subroutine
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Declare ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Digits:
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00110011          ;  ##  ##
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %00100010          ;  #   #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01100110          ; ##  ##
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #

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