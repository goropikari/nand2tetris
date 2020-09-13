    @261
    D=A
    @SP
    M=D
    @Sys.init
    0;JMP
// From /home/arch/workspace/nand2tetris/projects/08/FunctionCalls/FibonacciElement/Main.vm
    // function Main.fibonacci 0
(Main.fibonacci)
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
    // lt
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    // SP--
    @SP
    M=M-1
    A=M
    D=M-D
    @then0
    D;JLT
    @SP
    A=M
    M=0
    @end0
    0;JMP
(then0)
    @SP
    A=M
    M=-1
(end0)
    // SP++
    @SP
    M=M+1
    // if-goto Main.fibonacci$IF_TRUE
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @Main.fibonacci$IF_TRUE
    D;JNE
    // goto Main.fibonacci$IF_FALSE
    @Main.fibonacci$IF_FALSE
    0;JMP
    // label Main.fibonacci$IF_TRUE
(Main.fibonacci$IF_TRUE)
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
    // label Main.fibonacci$IF_FALSE
(Main.fibonacci$IF_FALSE)
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
    // call Main.fibonacci 1
    // push (@RET_ADDR0)
    @RET_ADDR0
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@LCL)
    @LCL
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@ARG)
    @ARG
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@THIS)
    @THIS
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@THAT)
    @THAT
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // ARG = SP - n - 5
    @6
    D=A
    @SP
    D=M-D
    @ARG
    M=D
    // LCL = SP
    @SP
    D=M
    @LCL
    M=D
    // goto Main.fibonacci
    @Main.fibonacci
    0;JMP
(RET_ADDR0)
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
    // call Main.fibonacci 1
    // push (@RET_ADDR1)
    @RET_ADDR1
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@LCL)
    @LCL
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@ARG)
    @ARG
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@THIS)
    @THIS
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@THAT)
    @THAT
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // ARG = SP - n - 5
    @6
    D=A
    @SP
    D=M-D
    @ARG
    M=D
    // LCL = SP
    @SP
    D=M
    @LCL
    M=D
    // goto Main.fibonacci
    @Main.fibonacci
    0;JMP
(RET_ADDR1)
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

// From /home/arch/workspace/nand2tetris/projects/08/FunctionCalls/FibonacciElement/Sys.vm
    // function Sys.init 0
(Sys.init)
    // push constant 4
    @4
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // call Main.fibonacci 1
    // push (@RET_ADDR2)
    @RET_ADDR2
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@LCL)
    @LCL
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@ARG)
    @ARG
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@THIS)
    @THIS
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push (@THAT)
    @THAT
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // ARG = SP - n - 5
    @6
    D=A
    @SP
    D=M-D
    @ARG
    M=D
    // LCL = SP
    @SP
    D=M
    @LCL
    M=D
    // goto Main.fibonacci
    @Main.fibonacci
    0;JMP
(RET_ADDR2)
    // label Sys.init$WHILE
(Sys.init$WHILE)
    // goto Sys.init$WHILE
    @Sys.init$WHILE
    0;JMP

