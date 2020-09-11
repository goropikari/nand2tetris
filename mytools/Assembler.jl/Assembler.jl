include("src/Assembler.jl")
import .Assembler

length(ARGS) != 1 && error("Usage: julia Assembler.jl foo.asm")

asm_path = ARGS[1]
asm_path = abspath(asm_path)
filename = splitext(asm_path)[1]
open(asm_path) do rf
    lines = Assembler.parse_asm(rf)

    output = filename * ".hack"
    open(output, "w") do wf
        Assembler.gen_code(wf, lines)
        println("Assembling $(asm_path)")
    end
end

