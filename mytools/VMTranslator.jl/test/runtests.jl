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
