module CodeWriter
import ..Parser: VM, Arithmetic, Add, Sub, Neg, Eq, Gt, Lt, And, Or, Not, Push, Pop

FILENAME = ""
LABEL_CNT = 0
INDENT = " "^4
sp = "@SP"


function set_filename(name)
    global FILENAME = name
    return nothing
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
    println(io, INDENT * sp)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=0") # false
    println(io, INDENT * "@end$(LABEL_CNT)")
    println(io, INDENT * "0;JMP")
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
end

function cgen(io::IO, command::Pop)
end

function _push_constant(io, arg)
    println(io, INDENT * "@$(arg)")
    println(io, INDENT * "D=A")
    println(io, INDENT * sp)
    println(io, INDENT * "A=M")
    println(io, INDENT * "M=D")

    _spinc(io)
end

function cgen(io, commands)
    for command in commands
        cgen(io, command)
    end
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
