import VMTranslator
import VMTranslator.Lexer: tokenize

using Test

@testset "Lexer" begin
    data = """
        push constant 1
        push argument 10
        pop local 23 // RAM[local+23] = *(--SP)
        add
        // this is a comment
        push constant x"""
    tokens = tokenize(data)
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
