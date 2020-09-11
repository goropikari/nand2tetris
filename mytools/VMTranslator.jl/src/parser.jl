module Parser

struct VMParseError <: Exception
    msg::String
end
Base.showerror(io::IO, e::VMParseError) = print(io, e.msg)

abstract type VM end
abstract type Arithmetic <: VM end
for op in [:Add, :Sub, :Neg, :Eq, :Gt, :Lt, :And, :Or, :Not]
    eval(quote
        struct $op <: VM end
     end)
end

struct Push <: VM
    arg1::String
    arg2::String
end
struct Pop <: VM
    arg1::String
    arg2::String
end
struct None <: VM end

const arithmetic = Dict(
    "add" => Add(),
    "sub" => Sub(),
    "neg" => Neg(),
    "eq" => Eq(),
    "gt" => Gt(),
    "lt" => Lt(),
    "and" => And(),
    "or" => Or(),
    "not" => Not()
)

function parse(tokens::Vector{Tuple{Symbol, String}})
    commands = VM[]
    command = None()
    cnt = 1
    while !isnothing(iterate(tokens, cnt))
        token, cnt = iterate(tokens, cnt)
        typ = token[1]
        val = token[2]
        if typ == :arithmetic
            command = arithmetic[val]
        elseif typ == :push
            command, cnt = _pushpop(:push, tokens, cnt)
        elseif typ == :pop
            command, cnt = _pushpop(:pop, tokens, cnt)
        else
            throw(VMParseError("This token type isn't supported: $(string(op))"))
        end
        push!(commands, command)
    end

    return commands
end

function _pushpop(sym, tokens, cnt)
    arg1, cnt = iterate(tokens, cnt)
    arg1[1] != :segment && throw(VMParseError("$(arg1[1]) ($(arg1[2])) is not argument of push."))
    arg2, cnt = iterate(tokens, cnt)
    arg2[1] ∉ (:digit, :symbol) && throw(VMParseError("$arg2[1] ($(arg2[2]) is not argument of push."))

    if sym == :push
        return Push(arg1[2], arg2[2]), cnt
    elseif sym == :pop
        return Pop(arg1[2], arg2[2]), cnt
    else
        throw(VMParseError(""))
    end
end

end # module
