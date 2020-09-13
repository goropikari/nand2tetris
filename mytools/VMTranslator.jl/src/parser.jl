module Parser
export parse

struct VMParseError <: Exception
    msg::String
end
Base.showerror(io::IO, e::VMParseError) = print(io, e.msg)

abstract type VM end

abstract type Arithmetic <: VM end
for op in [:Add, :Sub, :Neg, :Eq, :Gt, :Lt, :And, :Or, :Not]
    eval(quote
        struct $op <: Arithmetic end
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

abstract type Branch <: VM end
mutable struct Label <: Branch
    label::String
end

mutable struct Goto <: Branch
    label::String
end

mutable struct IfGoto <: Branch
    label::String
end

abstract type _Function <: VM end
struct Callee <: _Function
    name::String
    numlocal::Int
    body::Vector{VM}
end
# function Base.show(io::IO, x::Callee)
#     println(io, "Function name: $(x.name)")
#     println(io, "The number of local var: $(x.numlocal)")
#     println(io, "Body:")
#     Base.print_array(io, x.body)
# end

struct Caller <: _Function
    name::String
    numargs::Int
end

struct Return <: _Function end


struct None <: VM end

const arithmetic = Dict(
    "add" => Add(),
    "sub" => Sub(),
    "neg" => Neg(),
    "eq"  => Eq(),
    "gt"  => Gt(),
    "lt"  => Lt(),
    "and" => And(),
    "or"  => Or(),
    "not" => Not()
)

function parse(tokens::Vector{Tuple{Symbol, String}})
    commands = VM[]
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
        elseif typ == :branch
            command, cnt = _branch(val, tokens, cnt)
        elseif typ == :function
            if val == "return"
                command = Return()
            else
                command, cnt = _function(val, tokens, cnt) # val = function or call
            end
        else
            println(cnt)
            throw(VMParseError("This token type isn't supported: $(token)"))
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

function _branch(val, tokens, cnt)
    label, cnt = iterate(tokens, cnt)
    label[1] != :symbol && throw(VMParseError("$(label[1]) ($(label[2])) is not argument of push."))
    if val == "label"
        return Label(label[2]), cnt
    elseif val == "goto"
        return Goto(label[2]), cnt
    elseif val ==  "if-goto"
        return IfGoto(label[2]), cnt
    else
        throw(VMParseError(""))
    end
end

function _function(name, tokens, cnt)
    name == "function" && return _callee(tokens, cnt)
    name == "call" && return _caller(tokens, cnt)
end

function _callee(tokens::Vector{Tuple{Symbol, String}}, cnt)
    fn, cnt = iterate(tokens, cnt)
    fn[1] != :symbol && throw(VMParseError("$(fn[1]) ($(fn[2])) is not argument of call."))
    numlocal, cnt = iterate(tokens, cnt)
    numlocal[1] != :digit && throw(VMParseError("$(numlocal[1]) ($(numlocal[2])) is not argument of function."))

    fn_idx = findnext(x -> x == (:function, "function"), tokens, cnt)
    last_idx = isnothing(fn_idx) ? length(tokens) : fn_idx - 1
    body::Vector{VM} = parse(tokens[cnt:last_idx])
    for item in body
        if item isa Branch
            item.label = "$(fn[2])\$$(item.label)"
        end
    end

    return Callee(fn[2], Base.parse(Int, numlocal[2]), body), last_idx + 1
end

function _caller(tokens, cnt)
    fn, cnt = iterate(tokens, cnt)
    fn[1] != :symbol && throw(VMParseError("$(fn[1]) ($(fn[2])) is not argument of call."))
    nargs, cnt = iterate(tokens, cnt)
    nargs[1] != :digit && throw(VMParseError("$(nargs[1]) ($(nargs[2])) is not argument of call."))

    return Caller(fn[2], Base.parse(Int, nargs[2])), cnt
end

end # module
