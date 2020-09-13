// From /home/arch/workspace/nand2tetris/projects/08/ProgramFlow/BasicLoop/BasicLoop.vm
    // push constant 0
    @0
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // pop local 0
    @LCL
    D=M
    @0
    D=D+A
    @LCL
    M=D
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @LCL
    A=M
    M=D
    @0
    D=A
    @LCL
    M=M-D
    // label LOOP_START
(LOOP_START)
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
    // push local 0
    @LCL
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
    // pop local 0
    @LCL
    D=M
    @0
    D=D+A
    @LCL
    M=D
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @LCL
    A=M
    M=D
    @0
    D=A
    @LCL
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
    // if-goto LOOP_START
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @LOOP_START
    D;JNE
    // push local 0
    @LCL
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

