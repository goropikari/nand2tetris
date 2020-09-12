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
