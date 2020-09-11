module Assembler

include("parser.jl")
include("code_generator.jl")
import .Parser
import .CodeGenerator

export parse_asm, gen_code
parse_asm = Parser.parse
gen_code = CodeGenerator.gen_code

end # module
