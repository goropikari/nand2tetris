module CodeGenerators

import ..JackCompiler: Keyword
import ..Parsers: Parser,
    Program,
    Class,
    ClassVarDec,
    SubroutineDec,
    Parameter,
    SubroutineBodyVarDec,
    SubroutineBody,
    SubroutineCall,
    Let,
    If,
    While,
    Do,
    Return,
    Term,
    Parenthesis,
    UnaryOp,
    _Array,
    Operator


mutable struct CodeGenerator
    class_name
    class_symtable
    subroutine_symtable
    parse_tree
end
function CodeGenerator(parser::Parser)
    CodeGenerator("", ClassSymbolTable(), SubroutineSymbolTable(), parser.parse_tree)
end

mutable struct Variable
    type
    kind
    number::Int
end
function Variable(type, kind)
    return Variable(type, kind, 0)
end

mutable struct ClassSymbolTable
    symtable::Dict
    static::Int
    field::Int

    function ClassSymbolTable()
        return new(Dict(), 0, 0)
    end
end

mutable struct SubroutineSymbolTable
    symtable
    argumentid::Int
    localid::Int

    function SubroutineSymbolTable()
        return new(Dict(), 0, 0)
    end
end

function Base.setindex!(x::ClassSymbolTable, val::Variable, key)
    if !(val.kind in ("static", "field"))
        error()
    end
    x.symtable[key] = val
end
function Base.setindex!(x::SubroutineSymbolTable, val::Variable, key)
    x.symtable[key] = val
end


function cgen(io::IO, codegen::CodeGenerator)
    cgen(io, codegen, codegen.parse_tree)
end
function cgen(io::IO, codegen::CodeGenerator, prog::Program)
    cgen(io, codegen, prog.class)
end
function cgen(io::IO, codegen::CodeGenerator, class::Class)
    codegen.class_name = class.name.val
    _register_classvar!(codegen.class_symtable, class)

    for subr in class.subrdecs
        cgen(io, codegen, subr)
    end
end

function cgen(io::IO, codegen::CodeGenerator, subr::SubroutineDec)
    function _header(io::IO)
        class_name = codegen.class_name
        subr_name = subr.name.val
        nlocals = _count_localvar(subr)
        println(io, "function $(class_name).$(subr_name) $(nlocals)")
    end
    # initialize subroutine symbol table
    codegen.subroutine_symtable = SubroutineSymbolTable()
    define = subr.deckw.val
    _header(io)
    if define == "constructor"
        # println(io, "push constant 0")
        print_const(io)
        println(io, "call Memory.alloc 1")
        println(io, "pop pointer 0")
        for stmt in subr.body.stmts
            cgen(io, codegen, stmt)
        end
    elseif define == "function"
    elseif define == "method"
    else
        error()
    end
end

function cgen(io::IO, codegen::CodeGenerator, ret::Return)
    if isnothing(ret.expr)
        # println(io, "push constant 0")
        print_const(io)
    else
        cgen(io, codegen, ret.expr)
    end
    println(io, "return")
end

function cgen(io::IO, codegen::CodeGenerator, term::Term)
    cgen(io, codegen, term.val)
end

function cgen(io::IO, codegen::CodeGenerator, kw::Keyword)
    if kw.val == "this"
        print_const(io)
    else # TODO
        error()
    end
end

function _register_classvar!(symtb::ClassSymbolTable, class::Class)
    for vardec in class.vardecs
        kind = vardec.deckw.val
        type = vardec.type.val
        for var in vardec.varnames
            name = var.val
            num = _getid(symtb, kind)
            _incid!(symtb, kind)
            symtb[name] = Variable(type, kind, num)
        end
    end
end

function _getid(symtb::ClassSymbolTable, kind)
    if kind == "static"
        return symtb.static
    elseif kind == "field"
        return symtb.field
    else
        error()
    end
end

function _incid!(symtb::ClassSymbolTable, kind)
    if kind == "static"
        symtb.static += 1
    elseif kind == "field"
        symtb.field += 1
    else
        error()
    end
    nothing
end

function _count_localvar(subr::SubroutineDec)
    nlocals = 0
    for vardec in subr.body.vardecs
        nlocals += length(vardec.vars)
    end
    return nlocals
end

print_const(io, n=0) = println(io, "push constant $(n)")

end # module