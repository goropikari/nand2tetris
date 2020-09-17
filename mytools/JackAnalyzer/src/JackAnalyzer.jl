module JackAnalyzer
export tokenize, dump

# module Tokenizer end
include("tokenizer.jl")
import .Tokenizer: tokenize, dump

end # module
