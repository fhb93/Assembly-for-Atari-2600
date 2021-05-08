    processor 6502
    include "../UTILS/vcs.h"
    include "../UTILS/macro.h"

    seg.u Variables
    org $80
Channel_1Duration = $80
Channel_1Counter = $81	; This is a pointer, needs 16 bits


    seg Code
    org $F000

RestartMusic:
    CLEAN_START 
	LDA	#1
	STA	Channel_1Duration
	LDA	#<MusicChannel_1
	STA	Channel_1Counter
	LDA	#>MusicChannel_1
	STA	Channel_1Counter+1



Game:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC            ; first scanline
    sta WSYNC            ; second scanline
    sta WSYNC            ; third scanline

    lda #0
    sta VSYNC            ; turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the TIA output the recommended 37 scanlines of VBLANK 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #37              ; X = 37
LoopVBlank:
    sta WSYNC           ; hit WSYNC and wait for the next scanline
    dex                 ; X--
    bne LoopVBlank      ; loop while X != 0
    lda #0
    sta VBLANK          ; turn off the VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 192 visible scanlines (kernel) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #192            ; counter for 192 visible scanlines
LoopVisible:
    ;stx COLUBK          ; set the background color
    sta WSYNC           ; wait for the next scanline
    dex                 ; X--
    bne LoopVisible     ; loop while X != 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output 30 more VBLANK lines (overscan) to complete our frame 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2              ; hit and turn on VBLANK again
    sta VBLANK

    ldx #30             ; counter for 30 scanlines
LoopOverscan:
    sta WSYNC           ; wait for the next scanline
    dex                 ; X--
    bne LoopOverscan    ; loop while X != 0
 
Music_Player:
LoadNext1:
	DEC	Channel_1Duration
	LDA	Channel_1Duration
	BNE	LoadNext2
	LDX	#Channel_1Counter
	LDA	(0,x)
	INC	0,x
	BNE	*+4
	INC	1,x
	CMP	#255
	BNE	Not255_1
	LDA	#<MusicChannel_1
	STA	Channel_1Counter
	LDA	#>MusicChannel_1
	STA	Channel_1Counter+1
	LDX	#Channel_1Counter
	LDA	(0,x)
	INC	0,x
	BNE	*+4
	INC	1,x
Not255_1:
	STA	AUDV0
	CMP	#0
	BEQ	GotoDuration1
	lsr
	lsr
	lsr
	lsr
	STA	AUDC0
	LDX	#Channel_1Counter
	LDA	(0,x)
	INC	0,x
	BNE	*+4
	INC	1,x
	STA	AUDF0
GotoDuration1:
	LDX	#Channel_1Counter
	LDA	(0,x)
	INC	0,x
	BNE	*+4
	INC	1,x
	STA	Channel_1Duration
LoadNext2:
LoadEnd:
	JMP	Game
 
MusicChannel_1:
	.BYTE	#%11001000
	.BYTE	#12
	.BYTE	#48
	.BYTE	#0
	.BYTE	#2
	.BYTE	#%01001000
	.BYTE	#26
	.BYTE	#48
	.BYTE	#0
	.BYTE	#2
	.BYTE	#%01001000
	.BYTE	#27
	.BYTE	#94
	.BYTE	#0
	.BYTE	#5
	.BYTE	#%11001000
	.BYTE	#12
	.BYTE	#48
	.BYTE	#0
	.BYTE	#3
	.BYTE	#%11001000
	.BYTE	#10
	.BYTE	#48
	.BYTE	#0
	.BYTE	#2
	.BYTE	#%11001000
	.BYTE	#11
	.BYTE	#94
	.BYTE	#0
	.BYTE	#5
	.BYTE	#%11001000
	.BYTE	#12
	.BYTE	#48
	.BYTE	#0
	.BYTE	#3
	.BYTE	#%01001000
	.BYTE	#26
	.BYTE	#48
	.BYTE	#0
	.BYTE	#2
	.BYTE	#%01001000
	.BYTE	#27
	.BYTE	#94
	.BYTE	#0
	.BYTE	#5
	.BYTE	#%11001000
	.BYTE	#12
	.BYTE	#48
	.BYTE	#0
	.BYTE	#3
	.BYTE	#%11001000
	.BYTE	#10
	.BYTE	#48
	.BYTE	#0
	.BYTE	#2
	.BYTE	#%11001000
	.BYTE	#11
	.BYTE	#94
	.BYTE	#0
	.BYTE	#105
	.BYTE	#%11001000
	.BYTE	#12
	.BYTE	#24
	.BYTE	#0
	.BYTE	#1
	.BYTE	#%11001000
	.BYTE	#10
	.BYTE	#12
	.BYTE	#0
	.BYTE	#1
	.BYTE	#%11001000
	.BYTE	#12
	.BYTE	#24
	.BYTE	#255

    org $fffc

    .word RestartMusic
    .word RestartMusic
