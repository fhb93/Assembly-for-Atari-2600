; Final Project code stub - paused in lecture 55

    processor 6502

    include "vcs.h"
    include "macro.h"

    seg Code
    org $F000

Reset:



    org $FFFC
    word Reset
    word Reset