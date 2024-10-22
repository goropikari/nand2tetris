// From /home/arch/workspace/nand2tetris/projects/08/ProgramFlow/FibonacciSeries/FibonacciSeries.vm
    // push argument 1
    @ARG
    D=M
    @1
    A=D+A
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // pop pointer 1
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @R4
    M=D
    // push constant 0
    @0
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // pop that 0
    @THAT
    D=M
    @0
    D=D+A
    @THAT
    M=D
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @THAT
    A=M
    M=D
    @0
    D=A
    @THAT
    M=M-D
    // push constant 1
    @1
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // pop that 1
    @THAT
    D=M
    @1
    D=D+A
    @THAT
    M=D
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @THAT
    A=M
    M=D
    @1
    D=A
    @THAT
    M=M-D
    // push argument 0
    @ARG
    D=M
    @0
    A=D+A
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push constant 2
    @2
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // Sub
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    // SP--
    @SP
    M=M-1
    A=M
    M=M-D
    // SP++
    @SP
    M=M+1
    // pop argument 0
    @ARG
    D=M
    @0
    D=D+A
    @ARG
    M=D
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @ARG
    A=M
    M=D
    @0
    D=A
    @ARG
    M=M-D
    // label MAIN_LOOP_START
(MAIN_LOOP_START)
    // push argument 0
    @ARG
    D=M
    @0
    A=D+A
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // if-goto COMPUTE_ELEMENT
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @COMPUTE_ELEMENT
    D;JNE
    // goto END_PROGRAM
    @END_PROGRAM
    0;JMP
    // label COMPUTE_ELEMENT
(COMPUTE_ELEMENT)
    // push that 0
    @THAT
    D=M
    @0
    A=D+A
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push that 1
    @THAT
    D=M
    @1
    A=D+A
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // Add
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    // SP--
    @SP
    M=M-1
    A=M
    M=D+M
    // SP++
    @SP
    M=M+1
    // pop that 2
    @THAT
    D=M
    @2
    D=D+A
    @THAT
    M=D
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @THAT
    A=M
    M=D
    @2
    D=A
    @THAT
    M=M-D
    // push pointer 1
    @R4
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push constant 1
    @1
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // Add
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    // SP--
    @SP
    M=M-1
    A=M
    M=D+M
    // SP++
    @SP
    M=M+1
    // pop pointer 1
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @R4
    M=D
    // push argument 0
    @ARG
    D=M
    @0
    A=D+A
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push constant 1
    @1
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // Sub
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    // SP--
    @SP
    M=M-1
    A=M
    M=M-D
    // SP++
    @SP
    M=M+1
    // pop argument 0
    @ARG
    D=M
    @0
    D=D+A
    @ARG
    M=D
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @ARG
    A=M
    M=D
    @0
    D=A
    @ARG
    M=M-D
    // goto MAIN_LOOP_START
    @MAIN_LOOP_START
    0;JMP
    // label END_PROGRAM
(END_PROGRAM)

