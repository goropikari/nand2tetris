import VMTranslator

using Test

@testset "Lexer" begin
    data = """
    push constant 1
    push argument 10
    pop local 23 // RAM[local+23] = *(--SP)
    add

    // this is a comment
    push constant x"""
    tokens = VMTranslator.Lexer.tokenize(data)
    @test tokens == [
                     (:push, "push"),
                     (:segment, "constant"),
                     (:digit, "1"),
                     (:push, "push"),
                     (:segment, "argument"),
                     (:digit, "10"),
                     (:pop, "pop"),
                     (:segment, "local"),
                     (:digit, "23"),
                     (:arithmetic, "add"),
                     (:push, "push"),
                     (:segment, "constant"),
                     (:symbol, "x")
                    ]
end

@testset "Parser" begin
    tokens = [
               (:push, "push"),
               (:segment, "constant"),
               (:digit, "1"),
               (:push, "push"),
               (:segment, "argument"),
               (:digit, "10"),
               (:pop, "pop"),
               (:segment, "local"),
               (:digit, "23"),
               (:arithmetic, "add"),
               (:push, "push"),
               (:segment, "constant"),
               (:symbol, "x")
              ]
    commands = VMTranslator.Parser.parse(tokens)
    @test commands == [
                       VMTranslator.Parser.Push("constant", "1")
                       VMTranslator.Parser.Push("argument", "10")
                       VMTranslator.Parser.Pop("local", "23")
                       VMTranslator.Parser.Add()
                       VMTranslator.Parser.Push("constant", "x")
                      ]
end

@testset "CodeWriter" begin
    commands = [
                VMTranslator.Parser.Push("constant", "1")
                VMTranslator.Parser.Push("argument", "10")
                VMTranslator.Parser.Pop("local", "23")
                VMTranslator.Parser.Add()
                VMTranslator.Parser.Push("constant", "x")
                VMTranslator.Parser.Push("static", "10")
                VMTranslator.Parser.Push("temp", "123")
                VMTranslator.Parser.Push("pointer", "0")
               ]
    io = IOBuffer()
    VMTranslator.CodeWriter.set_filename("foobar")
    VMTranslator.CodeWriter.cgen(io, commands)
    str = replace(String(io.data), " " => "")
    expected = """
        @1
        D=A
        @SP
        A=M
        M=D
        @SP
        M=M+1
        @ARG
        D=M
        @10
        A=D+A
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
        @LCL
        D=M
        @23
        D=D+A
        @LCL
        M=D
        @SP
        M=M-1
        A=M
        D=M
        @LCL
        A=M
        M=D
        @23
        D=A
        @LCL
        M=M-D
        @SP
        M=M-1
        A=M
        D=M
        @SP
        M=M-1
        A=M
        M=D+M
        @SP
        M=M+1
        @x
        D=A
        @SP
        A=M
        M=D
        @SP
        M=M+1
        @foobar.10
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
        @R128
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
        @R3
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
    """
    expected = replace(expected, " " => "")
    @test expected == str

    commands = [
                VMTranslator.Parser.Label("piyo")
                VMTranslator.Parser.Goto("IF_HOGE")
                VMTranslator.Parser.IfGoto("hogehoge")
               ]
    io = IOBuffer()
    VMTranslator.CodeWriter.cgen(io, commands)
    str = replace(String(io.data), " " => "")
    expected = """
    (piyo)
        @IF_HOGE
        0;JMP
        @SP
        M=M-1
        A=M
        D=M
        @hogehoge
        D;JNE
    """
    expected = replace(expected, " " => "")
    @test expected == str
end
