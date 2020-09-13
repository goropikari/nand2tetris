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

function translate(filepath, src_dir=true)
    vmfiles = []
    outpath = ""
    if isdir(filepath)
        if occursin(r".*\/$", filepath)
            filepath = filepath[1:end-1]
        end
        bname = basename(filepath)
        outpath = joinpath(filepath, bname * ".asm")
        files = filter(s -> occursin(r"\.vm$", s), readdir(filepath))
        append!(vmfiles, joinpath.(filepath, files))
    else
        outpath = filepath[1:end-2] * "asm"
        push!(vmfiles, filepath)
    end

    open(outpath, "w") do out
        # In order to pass test of ProgramFlow in project 8,
        # followning print statement should be removed because
        # these settings overwrite the base addressed of SP, ARG, and so on.
        INDENT = " "^4
        println(out, INDENT * "@261")
        println(out, INDENT * "D=A")
        println(out, INDENT * "@SP")
        println(out, INDENT * "M=D")
        println(out, INDENT * "@Sys.init")
        println(out, INDENT * "0;JMP")
        for vm in vmfiles
            println(out, "// From $(vm)")
            _translate_file(vm, out)
            println(out)
        end
    end
    println(abspath(outpath))
end

function _translate_file(filepath, out::IO)
    filepath = abspath(filepath)
    filename, extension = match(r"(.*)\.([^\.])*", basename(filepath)).captures
    dir = dirname(filepath)

    tokens = []
    open(filepath, "r") do fr
        tokens = Lexer.tokenize(fr)
    end
    commands = Parser.parse(tokens)
    CodeWriter.set_filename(filename)
    CodeWriter.cgen(out, commands)
end

end # module
