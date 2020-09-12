module CodeWriter
export cgen

import ..Parser: VM, Arithmetic, Add, Sub, Neg, Eq, Gt, Lt, And, Or, Not, Push, Pop, Label, Goto, IfGoto

FILENAME = ""
LABEL_CNT = 0
INDENT = " "^4
sp = "@SP"


function set_filename(name)
    global FILENAME = name
    return nothing
end

"""
    cgen(io, commands::Union{VM, Vector{VM}})

Genarate Hack assembly from VM code.
"""
function cgen(io, commands)
    for command in commands
        cgen(io, command)
    end
end

##############
# Arithmetic
##############
function cgen(io::IO, command::Add)
    _addsub(io, "+")
end
function cgen(io::IO, command::Sub)
    _addsub(io, "-")
end

function _addsub(io, op)
    # D = y
    _spdec(io)
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M")

    # x + y or x - y
    _spdec(io)
    println(io, INDENT * "A=M")
    if op == "-"
        println(io, INDENT * "M=M-D") # x - y
    elseif op == "+"
        println(io, INDENT * "M=D+M") # y + x
    end

    _spinc(io)
end

function cgen(io::IO, command::Neg)
    _negnot(io, "-")
end

function cgen(io::IO, command::Not)
    _negnot(io, "!")
end

function _negnot(io::IO, op)
    # M=-M or M=!M
    _spdec(io)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=$(op)M")
    _spinc(io)
end

function cgen(io::IO, command::Eq)
    _compare(io, "JEQ")
end

function cgen(io::IO, command::Gt)
    _compare(io, "JGT")
end

function cgen(io::IO, command::Lt)
    _compare(io, "JLT")
end

function _compare(io::IO, jump)
    # D=y
    _spdec(io)
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M")

    # x - y
    _spdec(io)
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M-D")

    println(io, INDENT * "@then$(LABEL_CNT)")
    println(io, INDENT * "D;$(jump)")
    # else
    #   *SP = false
    println(io, INDENT * sp)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=0") # false
    println(io, INDENT * "@end$(LABEL_CNT)")
    println(io, INDENT * "0;JMP")
    # then
    #   *SP = true
    println(io, "(then$(LABEL_CNT))")
    println(io, INDENT * sp)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=-1") # true
    println(io, "(end$(LABEL_CNT))")

    _spinc(io)

    global LABEL_CNT += 1
    return nothing
end

function cgen(io::IO, comannd::And)
    _andor(io, "&")
end

function cgen(io::IO, command::Or)
    _andor(io, "|")
end

function _andor(io::IO, op)
    _spdec(io)

    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M")

    _spdec(io)

    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D$(op)M")

    _spinc(io)
end


############
# push, pop
############

function cgen(io::IO, command::Push)
    command.arg1 == "constant" && _push_constant(io, command.arg2)
    command.arg1 == "local"    && _push_segment(io, "LCL", command.arg2)
    command.arg1 == "argument" && _push_segment(io, "ARG", command.arg2)
    command.arg1 == "this"     && _push_segment(io, "THIS", command.arg2)
    command.arg1 == "that"     && _push_segment(io, "THAT", command.arg2)
    command.arg1 == "temp"     && _push_temp(io, command.arg2)
    command.arg1 == "pointer"  && _push_pointer(io, command.arg2)
    command.arg1 == "static"   && _push_static(io, command.arg2)
end

function _push_constant(io, arg)
    # *SP = arg
    println(io, INDENT * "@$(arg)")
    println(io, INDENT * "D=A")
    println(io, INDENT * sp)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")

    _spinc(io)
end

function _push_segment(io::IO, seg, arg)
    # SEG = SEG + arg
    println(io, INDENT * "@$(seg)")
    println(io, INDENT * "D=M")
    println(io, INDENT * "@$(arg)")
    println(io, INDENT * "A=D+A")

    # *SEG
    println(io, INDENT * "D=M")

    # *SP = *SEG
    println(io, INDENT * sp)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")

    _spinc(io)
end

function _push_temp(io::IO, arg)
    # *(R5 + arg)
    ith = parse(Int, arg)
    println(io, INDENT * "@R$(5+ith)")
    println(io, INDENT * "D=M")

    # *SP = *(R5 + arg)
    println(io, INDENT * sp)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")

    _spinc(io)
end

function _push_pointer(io::IO, arg)
    # *(R3 + arg)
    ith = parse(Int, arg)
    println(io, INDENT * "@R$(3+ith)")
    println(io, INDENT * "D=M")

    # *SP = *(R3 + arg)
    println(io, INDENT * sp)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")

    _spinc(io)
end

function _push_static(io::IO, arg)
    # *SP = *(Xxx.i)
    println(io, INDENT * "@$(FILENAME).$(arg)")
    println(io, INDENT * "D=M")
    println(io, INDENT * sp)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")
    _spinc(io)
end


function cgen(io::IO, command::Pop)
    command.arg1 == "local"    && _pop_segment(io, "LCL", command.arg2)
    command.arg1 == "argument" && _pop_segment(io, "ARG", command.arg2)
    command.arg1 == "this"     && _pop_segment(io, "THIS", command.arg2)
    command.arg1 == "that"     && _pop_segment(io, "THAT", command.arg2)
    command.arg1 == "temp"     && _pop_temp(io, command.arg2)
    command.arg1 == "pointer"  && _pop_pointer(io, command.arg2)
    command.arg1 == "static"   && _pop_static(io, command.arg2)
end

function _pop_segment(io::IO, seg, arg)
    # change base address
    # SEG = SEG + arg
    println(io, INDENT * "@$(seg)")
    println(io, INDENT * "D=M")
    println(io, INDENT * "@$(arg)")
    println(io, INDENT * "D=D+A")
    println(io, INDENT * "@$(seg)")
    println(io, INDENT * "M=D")

    _spdec(io)

    # *SP
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M")

    # *SEG = *SP
    println(io, INDENT * "@$(seg)")
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")

    # restore base address
    # SEG = SEG - arg
    println(io, INDENT * "@$(arg)")
    println(io, INDENT * "D=A")
    println(io, INDENT * "@$(seg)")
    println(io, INDENT * "M=M-D")
end

function _pop_temp(io::IO, arg)
    # *SP
    _spdec(io)
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M")

    # *(R5 + ith) = *SP
    ith = parse(Int, arg)
    println(io, INDENT * "@R$(5+ith)")
    println(io, INDENT * "M=D")
end

function _pop_pointer(io::IO, arg)
    # *SP
    _spdec(io)
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M")

    # *(R3 + ith) = *SP
    ith = parse(Int, arg)
    println(io, INDENT * "@R$(3+ith)")
    println(io, INDENT * "M=D")
end

function _pop_static(io::IO, arg)
    # *SP
    _spdec(io)
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M")

    # *Xxx.arg = *SP
    println(io, INDENT * "@$(FILENAME).$(arg)")
    println(io, INDENT * "M=D")
end


#########
# branch
#########
function cgen(io::IO, label::Label)
    println(io, "($(label.label))")
end

function cgen(io::IO, goto::Goto)
    println(io, INDENT * "@$(goto.label)")
    println(io, INDENT * "0;JMP")
end

function cgen(io::IO, ifgoto::IfGoto)
    _spdec(io)
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M")
    println(io, INDENT * "@$(ifgoto.label)")
    println(io, INDENT * "D;JNE")
end

# SP++
function _spinc(io::IO)
    println(io, INDENT * sp)
    println(io, INDENT * "M=M+1")
end

# SP--
function _spdec(io::IO)
    println(io, INDENT * sp)
    println(io, INDENT * "M=M-1")
end

end # module
