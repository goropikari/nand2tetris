module CodeWriter
export cgen

import ..Parser: VM, Arithmetic, Add, Sub, Neg, Eq, Gt, Lt,
                 And, Or, Not, Push, Pop, Label, Goto, IfGoto,
                 Callee, Caller, Return

FILENAME   = ""
LABEL_CNT  = 0
RETURN_CNT = 0
INDENT     = " "^4
SP         = "@SP"
FRAME      = "@R13"
RET        = "@R14"
THAT       = "@THAT"
THIS       = "@THIS"
ARG        = "@ARG"
LCL        = "@LCL"


function set_filename(name)
    global FILENAME = name
    return nothing
end

function _print(io::IO, msg)
    println(io, INDENT * "// " * msg)
end

"""
    cgen(io, commands::Union{VM, Vector{VM}})

Genarate Hack assembly from VM code.
"""
function cgen end

function cgen(io::IO, commands::Vector{T}) where T <: VM
    for command in commands
        cgen(io, command)
    end
end

##############
# Arithmetic
##############
function cgen(io::IO, command::Add)
    _print(io, "Add")
    _addsub(io, "+")
end
function cgen(io::IO, command::Sub)
    _print(io, "Sub")
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
    _print(io, "neg")
    _negnot(io, "-")
end

function cgen(io::IO, command::Not)
    _print(io, "not")
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
    _print(io, "eq")
    _compare(io, "JEQ")
end

function cgen(io::IO, command::Gt)
    _print(io, "gt")
    _compare(io, "JGT")
end

function cgen(io::IO, command::Lt)
    _print(io, "lt")
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
    println(io, INDENT * SP)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=0") # false
    println(io, INDENT * "@end$(LABEL_CNT)")
    println(io, INDENT * "0;JMP")
    # then
    #   *SP = true
    println(io, "(then$(LABEL_CNT))")
    println(io, INDENT * SP)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=-1") # true
    println(io, "(end$(LABEL_CNT))")

    _spinc(io)

    global LABEL_CNT += 1
    return nothing
end

function cgen(io::IO, comannd::And)
    _print(io, "and")
    _andor(io, "&")
end

function cgen(io::IO, command::Or)
    _print(io, "or")
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
    segment = command.arg1
    offset = command.arg2
    _print(io, "push $(segment) $(offset)")
    segment == "constant" && _push_constant(io, offset)
    segment == "local"    && _push_segment(io, "LCL", offset)
    segment == "argument" && _push_segment(io, "ARG", offset)
    segment == "this"     && _push_segment(io, "THIS", offset)
    segment == "that"     && _push_segment(io, "THAT", offset)
    segment == "temp"     && _push_temp(io, offset)
    segment == "pointer"  && _push_pointer(io, offset)
    segment == "static"   && _push_static(io, offset)
end

function _push_constant(io, arg)
    # *SP = arg
    println(io, INDENT * "@$(arg)")
    println(io, INDENT * "D=A")
    println(io, INDENT * SP)
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
    println(io, INDENT * SP)
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
    println(io, INDENT * SP)
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
    println(io, INDENT * SP)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")

    _spinc(io)
end

function _push_static(io::IO, arg)
    # *SP = *(Xxx.i)
    println(io, INDENT * "@$(FILENAME).$(arg)")
    println(io, INDENT * "D=M")
    println(io, INDENT * SP)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")
    _spinc(io)
end


function cgen(io::IO, command::Pop)
    segment = command.arg1
    offset = command.arg2
    _print(io, "pop $(segment) $(offset)")
    segment == "local"    && _pop_segment(io, "LCL", offset)
    segment == "argument" && _pop_segment(io, "ARG", offset)
    segment == "this"     && _pop_segment(io, "THIS", offset)
    segment == "that"     && _pop_segment(io, "THAT", offset)
    segment == "temp"     && _pop_temp(io, offset)
    segment == "pointer"  && _pop_pointer(io, offset)
    segment == "static"   && _pop_static(io, offset)
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

    # TEMP = R5
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

    # POINTER = R3
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
    _print(io, "label $(label.label)")
    println(io, "($(label.label))")
end

function cgen(io::IO, goto::Goto)
    _print(io, "goto $(goto.label)")
    println(io, INDENT * "@$(goto.label)")
    println(io, INDENT * "0;JMP")
end

function cgen(io::IO, ifgoto::IfGoto)
    _print(io, "if-goto $(ifgoto.label)")
    _spdec(io)
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M")
    println(io, INDENT * "@$(ifgoto.label)")
    println(io, INDENT * "D;JNE")
end

############
# function
############
function cgen(io::IO, callee::Callee)
    _print(io, "function $(callee.name) $(callee.numlocal)")
    println(io, "($(callee.name))")

    for i in 1:callee.numlocal
        println(io, INDENT * SP)
        println(io, INDENT * "A=M")
        println(io, INDENT * "M=0")
        _spinc(io)
    end

    for item in callee.body
        cgen(io, item)
    end
end

function cgen(io::IO, ret::Return)
    _print(io, "return")
    # FRAME = LCL
    println(io, INDENT * LCL)
    println(io, INDENT * "D=M")
    println(io, INDENT * FRAME)
    println(io, INDENT * "M=D")

    # RET = *(FRAME - 5)
    _relative_addr_frame(io, RET, 5)

    # *ARG = pop()
    _spdec(io)
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=M")
    println(io, INDENT * ARG)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")

    # SP = ARG + 1
    println(io, INDENT * ARG)
    println(io, INDENT * "A=M")
    println(io, INDENT * "D=A+1")
    println(io, INDENT * SP)
    println(io, INDENT * "M=D")

    # THAT = *(FRAME - 1)
    _relative_addr_frame(io, THAT, 1)

    # THIS = *(FRAME - 2)
    _relative_addr_frame(io, THIS, 2)

    # ARG = *(FRAME - 3)
    _relative_addr_frame(io, ARG, 3)

    # LCL = *(FRAME - 4)
    _relative_addr_frame(io, LCL, 4)

    # goto RET
    println(io, INDENT * RET)
    println(io, INDENT * "A=M")
    println(io, INDENT * "0;JMP")
end

function cgen(io::IO, caller::Caller)
    _print(io, "call $(caller.name) $(caller.numargs)")
    # push return-address
    return_address_label = "RET_ADDR" * string(RETURN_CNT)
    global RETURN_CNT += 1
    return_address = "@" * return_address_label


    # push return-address
    _print(io, "push ($(return_address))")
    println(io, INDENT * return_address)
    println(io, INDENT * "D=A") # D=M if you use _push_stack
    println(io, INDENT * SP)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")
    _spinc(io)

    # push LCL
    _push_stack(io, LCL)

    # push ARG
    _push_stack(io, ARG)

    # push THIS
    _push_stack(io, THIS)

    # push THAT
    _push_stack(io, THAT)

    # ARG = SP - n - 5 where n = caller.numargs
    _print(io, "ARG = SP - n - 5")
    println(io, INDENT * "@$(caller.numargs + 5)")
    println(io, INDENT * "D=A")
    println(io, INDENT * SP)
    println(io, INDENT * "D=M-D")
    println(io, INDENT * ARG)
    println(io, INDENT * "M=D")

    # LCL = SP
    _print(io, "LCL = SP")
    println(io, INDENT * SP)
    println(io, INDENT * "D=M")
    println(io, INDENT * LCL)
    println(io, INDENT * "M=D")

    # goto f
    _print(io, "goto $(caller.name)")
    println(io, INDENT * "@$(caller.name)")
    println(io, INDENT * "0;JMP")

    # (return-address)
    println(io, "($(return_address_label))")
end

function _relative_addr_frame(io::IO, addr, offset)
    _print(io, "*($(addr)) = *(FRAME - $(offset))")
    println(io, INDENT * FRAME)
    println(io, INDENT * "D=M")
    println(io, INDENT * "@$(offset)")
    println(io, INDENT * "A=D-A")
    println(io, INDENT * "D=M")
    println(io, INDENT * addr)
    println(io, INDENT * "M=D")
end

# SP++
function _spinc(io::IO)
    _print(io, "SP++")
    println(io, INDENT * SP)
    println(io, INDENT * "M=M+1")
end

# SP--
function _spdec(io::IO)
    _print(io, "SP--")
    println(io, INDENT * SP)
    println(io, INDENT * "M=M-1")
end

function _push_stack(io::IO, addr)
    _print(io, "push ($(addr))")
    println(io, INDENT * addr)
    println(io, INDENT * "D=M")
    println(io, INDENT * SP)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")
    _spinc(io)
end

end # module
