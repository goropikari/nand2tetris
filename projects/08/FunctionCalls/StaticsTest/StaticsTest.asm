    @261
    D=A
    @SP
    M=D
    @Sys.init
    0;JMP
// From /home/arch/workspace/nand2tetris/projects/08/FunctionCalls/StaticsTest/Class1.vm
    // function Class1.set 0
(Class1.set)
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
    // pop static 0
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @Class1.0
    M=D
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
    // pop static 1
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @Class1.1
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
    // function Class1.get 0
(Class1.get)
    // push static 0
    @Class1.0
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push static 1
    @Class1.1
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

// From /home/arch/workspace/nand2tetris/projects/08/FunctionCalls/StaticsTest/Class2.vm
    // function Class2.set 0
(Class2.set)
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
    // pop static 0
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @Class2.0
    M=D
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
    // pop static 1
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @Class2.1
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
    // function Class2.get 0
(Class2.get)
    // push static 0
    @Class2.0
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push static 1
    @Class2.1
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

// From /home/arch/workspace/nand2tetris/projects/08/FunctionCalls/StaticsTest/Sys.vm
    // function Sys.init 0
(Sys.init)
    // push constant 6
    @6
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push constant 8
    @8
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // call Class1.set 2
    // push (@RET_ADDR5)
    @RET_ADDR5
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
    @7
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
    // goto Class1.set
    @Class1.set
    0;JMP
(RET_ADDR5)
    // pop temp 0
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @R5
    M=D
    // push constant 23
    @23
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push constant 15
    @15
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // call Class2.set 2
    // push (@RET_ADDR6)
    @RET_ADDR6
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
    @7
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
    // goto Class2.set
    @Class2.set
    0;JMP
(RET_ADDR6)
    // pop temp 0
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @R5
    M=D
    // call Class1.get 0
    // push (@RET_ADDR7)
    @RET_ADDR7
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
    @5
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
    // goto Class1.get
    @Class1.get
    0;JMP
(RET_ADDR7)
    // call Class2.get 0
    // push (@RET_ADDR8)
    @RET_ADDR8
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
    @5
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
    // goto Class2.get
    @Class2.get
    0;JMP
(RET_ADDR8)
    // label Sys.init$WHILE
(Sys.init$WHILE)
    // goto Sys.init$WHILE
    @Sys.init$WHILE
    0;JMP

