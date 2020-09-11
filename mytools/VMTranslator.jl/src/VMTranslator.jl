module VMTranslator

# module Lexer
include("lexer.jl")

# module Parser end
include("parser.jl")

# module CodeWriter end
include("code_writer.jl")

import .Lexer
import .Parser
import .CodeWriter

function translate(filepath)
    filepath = abspath(filepath)
    filename, extension = match(r"(.*)\.([^\.])*", basename(filepath)).captures
    dir = dirname(filepath)

    tokens = []
    open(filepath, "r") do fr
        tokens = Lexer.tokenize(fr)
    end
    commands = Parser.parse(tokens)
    println(joinpath(dir, filename * ".asm"))
    open(joinpath(dir, filename * ".asm"), "w") do fp
        CodeWriter.cgen(fp, commands)
    end
end

end # module
