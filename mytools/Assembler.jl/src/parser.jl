module Parser
export parse, AbstractInstruction, AInstruction, CInstruction, Label

mutable struct _InstructionString
    pos::Int
    str::String
    length::Int

    function _InstructionString(str)
        new(1, str, length(str))
    end
end

function _get_char(inst::_InstructionString)::Union{Char, Nothing}
    if inst.pos > inst.length
        return nothing
    end
    c = inst.str[inst.pos]
    inst.pos += 1

    return c
end

function _clean_up_inst(str)::String
    num_slash = 0
    inst = _InstructionString(str)

    instlist = Char[]
    while true
        c = _get_char(inst)
        if c == ' '
            # do nothing
        elseif c == '\n' || isnothing(c)
            return join(instlist)
        elseif c == '/'
            num_slash += 1
            if num_slash == 2
                return join(instlist)
            end
        else
            push!(instlist, c)
        end
    end
end

abstract type AbstractInstruction end
struct AInstruction <: AbstractInstruction
    value::String
    type::String # address or symbol
end

struct CInstruction <: AbstractInstruction
    dest::String
    comp::String
    jump::String
end

struct Label <: AbstractInstruction
    symbol::String
end

function _parse_inst(str)
    mod_str = _clean_up_inst(str)
    if isempty(mod_str)
        return nothing
    end

    (mod_str[1] == '(' && mod_str[end] == ')') && return Label(mod_str[2:end-1])
    mod_str[1] == '@' && return _parse_ainst(mod_str[2:end])
    return _parse_cinst(mod_str)
end

function _parse_ainst(str)
    if occursin(r"^[0-9]+$", str)
        return AInstruction(str, "address")
    elseif occursin(r"^[a-zA-Z_.$:][a-zA-Z_.$:0-9]*$", str)
        return AInstruction(str, "symbol")
    else
        _error("invalid numeric constant @$str")
    end
end

function _parse_cinst(str)
    dest_comp_jump = r"(.)*=(.*);(...)"
    dest_comp = r"(.*)=(.*)"
    comp_jump = r"(.*);(...)"
    if occursin(dest_comp_jump, str)
        dest, comp, jump = match(dest_comp_jump, str).captures
    elseif occursin(dest_comp, str)
        dest, comp, jump = match(dest_comp, str).captures..., ""
    elseif occursin(comp_jump, str)
        dest, comp, jump = "", match(comp_jump, str).captures...
    else
        _error("invalid C-instruction $str")
    end

    return CInstruction(dest, comp, jump)
end

_error(msg) = error("syntax: $msg")


function parse(io::IO)
    raw_lines = readlines(io)
    lines = AbstractInstruction[]
    for line in raw_lines
        inst = _parse_inst(line)
        if isnothing(inst)
            # do nothing
        else
            push!(lines, inst)
        end
    end

    return lines
end
parse(program::String) = parse(IOBuffer(program))

end # Parser module
