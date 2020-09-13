    @261
    D=A
    @SP
    M=D
    @Sys.init
    0;JMP
// From /home/arch/workspace/nand2tetris/projects/08/FunctionCalls/SimpleFunction/SimpleFunction.vm
    // function SimpleFunction.test 2
(SimpleFunction.test)
    @SP
    A=M
    M=0
    // SP++
    @SP
    M=M+1
    @SP
    A=M
    M=0
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
    // push local 1
    @LCL
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
    // not
    // SP--
    @SP
    M=M-1
    A=M
    M=!M
    // SP++
    @SP
    M=M+1
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
    // return
    @LCL
    D=M
    @R13
    M=D
    // *(@R14) = *(FRAME - 5)
    @R13
    D=M
    @5
    A=D-A
    D=M
    @R14
    M=D
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @ARG
    A=M
    M=D
    @ARG
    A=M
    D=A+1
    @SP
    M=D
    // *(@THAT) = *(FRAME - 1)
    @R13
    D=M
    @1
    A=D-A
    D=M
    @THAT
    M=D
    // *(@THIS) = *(FRAME - 2)
    @R13
    D=M
    @2
    A=D-A
    D=M
    @THIS
    M=D
    // *(@ARG) = *(FRAME - 3)
    @R13
    D=M
    @3
    A=D-A
    D=M
    @ARG
    M=D
    // *(@LCL) = *(FRAME - 4)
    @R13
    D=M
    @4
    A=D-A
    D=M
    @LCL
    M=D
    @R14
    A=M
    0;JMP

