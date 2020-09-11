module Lexer

import Automa
import Automa.RegExp: @re_str
const re = Automa.RegExp

whitespace = re"[ \n]"
comment    = re"//[^\n]*"
arithmetic = re"add|sub|neg|eq|gt|lt|and|or|not"
segment    = re"argument|local|static|constant|this|that|pointer|temp"
_push      = re"push"
_pop       = re"pop"
symbol     = re"[a-zA-Z_.$:][0-9a-zA-Z_.$:]*"
digit      = re"[0-9]+"
word       = comment | whitespace | arithmetic | segment | _push | _pop | symbol | digit
program    = re.cat(re.opt(word), re.rep(re"[ \n]+" * word), re"[ \n]*")
comment.actions[:enter] = [:mark]
whitespace.actions[:enter] = [:mark]
word.actions[:enter]      = [:mark]
whitespace.actions[:exit] = [:do_nothing]
digit.actions[:exit]      = [:digit]
arithmetic.actions[:exit] = [:arithmetic]
segment.actions[:exit]    = [:segment]
_push.actions[:exit]      = [:_push]
_pop.actions[:exit]       = [:_pop]
symbol.actions[:exit]     = [:symbol]
comment.actions[:exit]    = [:comment]

machine = Automa.compile(program)

actions = Dict(
    :mark       => :(mark = p),
    :do_nothing => :(do_nothing()),
    :digit      => :(emit(:digit)),
    :arithmetic => :(emit(:arithmetic)),
    :segment    => :(emit(:segment)),
    :_push      => :(emit(:push)),
    :_pop       => :(emit(:pop)),
    :symbol     => :(emit(:symbol)),
    :comment    => :(emit(:comment))
)

context = Automa.CodeGenContext()
@eval function tokenize(data::String)
    tokens = Tuple{Symbol,String}[]
    mark = 0
    $(Automa.generate_init_code(context, machine))
    p_end = p_eof = lastindex(data)
    emit(kind) = push!(tokens, (kind, data[mark:p-1]))
    do_nothing() = nothing
    $(Automa.generate_exec_code(context, machine, actions))
    return tokens, cs == 0 ? :ok : cs < 0 ? :error : :incomplete
end
function tokenize(io::IO)
    data = read(io, String)
    return tokenize(data)
end


# tokens, status = tokenize("push constant 1\nadd")
end # module
