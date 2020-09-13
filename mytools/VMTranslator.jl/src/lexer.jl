# ref: https://github.com/BioJulia/Automa.jl/blob/v0.8.0/example/tokenizer.jl
module Lexer
export tokenize

import Automa
import Automa.RegExp: @re_str
const re = Automa.RegExp

newline    = re"\r?\n"
whitespace = re"[ \t]+"
comment    = re"//[^\n]*"
arithmetic = re"add|sub|neg|eq|gt|lt|and|or|not"
segment    = re"argument|local|static|constant|this|that|pointer|temp"
branch     = re"label|goto|if-goto"
_function  = re"function|call|return"
_push      = re"push"
_pop       = re"pop"
symbol     = re"[a-zA-Z_.$:][0-9a-zA-Z_.$:]*"
digit      = re"[0-9]+"

const vm = Automa.compile(
    newline    => :(()), # do nothing
    whitespace => :(()), # do nothing
    comment    => :(()), # do nothing
    digit      => :(emit(:digit)),
    arithmetic => :(emit(:arithmetic)),
    segment    => :(emit(:segment)),
    branch     => :(emit(:branch)),
    _function  => :(emit(:function)),
    _push      => :(emit(:push)),
    _pop       => :(emit(:pop)),
    symbol     => :(emit(:symbol))
)

context = Automa.CodeGenContext()
@eval function tokenize(data::String)
    $(Automa.generate_init_code(context, vm))
    tokens = Tuple{Symbol,String}[]
    p_end = p_eof = lastindex(data)

    emit(kind) = push!(tokens, (kind, data[ts:te]))

    while p ≤ p_eof && cs > 0
        $(Automa.generate_exec_code(context, vm))
    end
    if cs < 0
        error("failed to tokenize")
    end
    return tokens
end
function tokenize(io::IO)
    data = read(io, String)
    return tokenize(data)
end

end # module
