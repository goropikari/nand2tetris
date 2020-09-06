module Assembler

include("code_generator.jl")
import .CodeGenerator

export parse_asm, gen_code
parse_asm = CodeGenerator.Parser.parse
gen_code = CodeGenerator.gen_code

end # module
