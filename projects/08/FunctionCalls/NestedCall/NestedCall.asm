    @261
    D=A
    @SP
    M=D
    @Sys.init
    0;JMP
// From /home/arch/workspace/nand2tetris/projects/08/FunctionCalls/NestedCall/Sys.vm
    // function Sys.init 0
(Sys.init)
    // push constant 4000
    @4000
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // pop pointer 0
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @R3
    M=D
    // push constant 5000
    @5000
    D=A
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
    // call Sys.main 0
    // push (@RET_ADDR3)
    @RET_ADDR3
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
    // goto Sys.main
    @Sys.main
    0;JMP
(RET_ADDR3)
    // pop temp 1
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @R6
    M=D
    // label Sys.init$LOOP
(Sys.init$LOOP)
    // goto Sys.init$LOOP
    @Sys.init$LOOP
    0;JMP
    // function Sys.main 5
(Sys.main)
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
    @SP
    A=M
    M=0
    // SP++
    @SP
    M=M+1
    // push constant 4001
    @4001
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // pop pointer 0
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @R3
    M=D
    // push constant 5001
    @5001
    D=A
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
    // push constant 200
    @200
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // pop local 1
    @LCL
    D=M
    @1
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
    @1
    D=A
    @LCL
    M=M-D
    // push constant 40
    @40
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // pop local 2
    @LCL
    D=M
    @2
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
    @2
    D=A
    @LCL
    M=M-D
    // push constant 6
    @6
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // pop local 3
    @LCL
    D=M
    @3
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
    @3
    D=A
    @LCL
    M=M-D
    // push constant 123
    @123
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // call Sys.add12 1
    // push (@RET_ADDR4)
    @RET_ADDR4
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
    // goto Sys.add12
    @Sys.add12
    0;JMP
(RET_ADDR4)
    // pop temp 0
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @R5
    M=D
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
    // push local 2
    @LCL
    D=M
    @2
    A=D+A
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push local 3
    @LCL
    D=M
    @3
    A=D+A
    D=M
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // push local 4
    @LCL
    D=M
    @4
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
    // function Sys.add12 0
(Sys.add12)
    // push constant 4002
    @4002
    D=A
    @SP
    A=M
    M=D
    // SP++
    @SP
    M=M+1
    // pop pointer 0
    // SP--
    @SP
    M=M-1
    A=M
    D=M
    @R3
    M=D
    // push constant 5002
    @5002
    D=A
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
    // push constant 12
    @12
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

