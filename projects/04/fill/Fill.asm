// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.

// while true
//     if keyboard > 0
//         black
//     else
//         white
//     end
// end

@8192 // nrow * ncol = 256 * 32
D=A
@SCREEN_SIZE
M=D

(LOOP)
    @KBD
    D=M
    @BLACK
    D;JGT
    @WHITE
    0;JMP

// screen is black
(BLACK)
    @SCREEN
    D=A
    @addr
    M=D // addr = SCREEN

    @SCREEN_SIZE
    D=M
    @n
    M=D // n = SCREEN_SIZE
    
    @i
    M=0 // i = 0
    (LOOP_BLACK)
        @addr
        A=M
        M=-1 // RAM[addr] = -1

        @i
        M=M+1 // i = i + 1
        @addr
        M=M+1 // addr = addr + 1

        @i
        D=M
        @n
        D=D-M // i - n
        @LOOP
        D;JEQ

        @LOOP_BLACK
        0;JMP
@LOOP
    0;JMP

// screen is white
(WHITE)
    @SCREEN
    D=A
    @addr
    M=D // addr = SCREEN

    @SCREEN_SIZE
    D=M
    @n
    M=D // n = SCREEN_SIZE
    
    @i
    M=0 // i = 0
    (LOOP_WHITE)
        @addr
        A=M
        M=0 // RAM[addr] = 0

        @i
        M=M+1 // i = i + 1
        @addr
        M=M+1 // addr = addr + 1

        @i
        D=M
        @n
        D=D-M // i - n
        @LOOP
        D;JEQ

        @LOOP_WHITE
        0;JMP
@LOOP
    0;JMP