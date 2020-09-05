// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// The program assumes that R0>=0, R1>=0, and R0*R1<32768.
// Put your code here.


// RAM[2] = 0
// for i = 1:RAM[1]
//     RAM[2] += RAM[0]
// end

@R2
M=0 // RAM[R2] = 0
@i
M=1 // i = 1

(LOOP)
    @i
    D=M
    @R1
    D=D-M // i - RAM[R1]
    @END
    D;JGT

    @R2
    D=M

    @R0
    D=D+M // RAM[2] + RAM[0]

    @R2
    M=D // RAM[2] = RAM[2] + RAM[2]

    @i
    M=M+1 // i = i + 1

    @LOOP
    0;JMP
(END)
    @END
    0;JMP
