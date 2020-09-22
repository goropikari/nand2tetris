module CodeGenerators

import ..JackCompiler: IntegerConstant,
    StringConstant,
    Keyword,
    Identifier

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
    staticid::Int
    fieldid::Int

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
    if !(val.kind in ("static", "this"))
        error()
    end
    x.symtable[key] = val
end
function Base.setindex!(x::SubroutineSymbolTable, val::Variable, key)
    x.symtable[key] = val
end
function Base.getindex(x::ClassSymbolTable, key)
    return x.symtable[key]
end
function Base.getindex(x::SubroutineSymbolTable, key)
    return x.symtable[key]
end
function Base.keys(x::ClassSymbolTable)
    return keys(x.symtable)
end
function Base.keys(x::SubroutineSymbolTable)
    return keys(x.symtable)
end
function Base.values(x::ClassSymbolTable)
    return values(x.symtable)
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
        println(io)
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
        numfield = _count_field(codegen.class_symtable)
        print_push_const(io, numfield)
        println(io, "call Memory.alloc 1")
        println(io, "pop pointer 0")
    elseif define == "function"
        # only cgen(statements)
    elseif define == "method"
        codegen.subroutine_symtable["this"] = Variable(codegen.class_name, "argument", 0)
        _incid!(codegen.subroutine_symtable, "argument")
        print_push_arg(io)
        print_pop_pointer(io)
    else
        error()
    end
    _register_subroutinevar!(codegen.subroutine_symtable, subr)
    for stmt in subr.body.stmts
        cgen(io, codegen, stmt)
    end
end

function cgen(io::IO, codegen::CodeGenerator, _do::Do)
    cgen(io, codegen, _do.subr)
    print_pop_temp(io)
end

function cgen(io::IO, codegen::CodeGenerator, ret::Return)
    if isnothing(ret.expr)
        print_push_const(io)
    else
        cgen(io, codegen, ret.expr)
    end
    println(io, "return")
end

function cgen(io::IO, codegen::CodeGenerator, term::Term)
    cgen(io, codegen, term.val)
end

function cgen(io::IO, codegen::CodeGenerator, int::IntegerConstant)
    print_push_const(io, int.val)
end

function cgen(io::IO, codegen::CodeGenerator, strconst::StringConstant)
    str = strconst.val
    len = length(str)
    print_push_const(io, len)
    println(io, "call String.new 1")
    for c in str
        print_push_const(io, Int(c))
        println(io, "call String.appendChar 2")
    end
end

function cgen(io::IO, codegen::CodeGenerator, keyword::Keyword)
    kw = keyword.val
    if kw == "true"
        print_push_const(io)
        println(io, "neg")
    elseif kw == "false"
        print_push_const(io)
    elseif kw == "null"
        print_push_const(io)
    elseif kw == "this"
        print_push_const(io)
    else
        error()
    end
end

function cgen(io::IO, codegen::CodeGenerator, ident::Identifier)
    id = ident.val
    varinfo::Variable = _varinfo(codegen, id)
    print_push(io, varinfo.kind, varinfo.number)
end

function cgen(io::IO, codegen::CodeGenerator, arr::_Array)
    cgen(io, codegen, arr.idx)
    id = arr.var.val
    varinfo::Variable = _varinfo(codegen, id)
    print_push(io, varinfo.kind, varinfo.number)
    println(io, "add")
    print_pop_pointer(io, "1")
    print_push_that(io)
end

function cgen(io::IO, codegen::CodeGenerator, subrcall::SubroutineCall)
    class_name = ""
    cl_obj_name = ""
    isobj = false
    if isnothing(subrcall.cl_obj)
        class_name = codegen.class_name
    else
        cl_obj_name = subrcall.cl_obj.val
        isobj = (cl_obj_name in keys(codegen.class_symtable) ||
                 cl_obj_name in keys(codegen.subroutine_symtable))
    end
    subroutine_name = subrcall.name.val
    nargs = length(subrcall.exprs)

    if isnothing(subrcall.cl_obj)  # subroutine(exprs)
        nargs += 1
        print_push_pointer(io)
    elseif !isobj  # classname.subroutine(exprs)
        class_name = subrcall.cl_obj.val
    elseif isobj  # obj.subroutine(exprs)
        # Update class_name
        class_name = if cl_obj_name in keys(codegen.subroutine_symtable)
            codegen.subroutine_symtable[cl_obj_name].type
        elseif cl_obj_name in keys(codegen.class_symtable)
            codegen.class_symtable[cl_obj_name].type
        else
            error()
        end
        cgen(io, codegen, subrcall.cl_obj)
        nargs += 1
    else
        error()
    end
    for expr in subrcall.exprs
        cgen(io, codegen, expr)
    end
    println(io, "call $(class_name).$(subroutine_name) $(nargs)")
end

function cgen(io::IO, codegen::CodeGenerator, paren::Parenthesis)
    cgen(io, codegen, paren.val)
end



function _register_classvar!(symtb::ClassSymbolTable, class::Class)
    for vardec in class.vardecs
        kind = vardec.deckw.val
        if kind == "field"
            kind = "this"
        end
        type = vardec.type.val
        for var in vardec.varnames
            name = var.val
            num = _getid(symtb, kind)
            _incid!(symtb, kind)
            symtb[name] = Variable(type, kind, num)
        end
    end
end

function _register_subroutinevar!(symtb::SubroutineSymbolTable, subr::SubroutineDec)
    params = subr.params
    vardecs = subr.body.vardecs
    for vardec in vardecs
        type = vardec.type.val
        kind = "local"
        for var in vardec.vars
            name = var.val
            num = _getid(symtb, kind)
            _incid!(symtb, kind)
            symtb[name] = Variable(type, kind, num)
        end
    end
    for param in params
        name = param.name.val
        type = param.type.val
        kind = "argument"
        num = _getid(symtb, kind)
        _incid!(symtb, kind)
        symtb[name] = Variable(type, kind, num) # type, kind, number
    end
    symtb.symtable
end

function _getid(symtb::ClassSymbolTable, kind)
    if kind == "static"
        return symtb.staticid
    elseif kind == "this"
        return symtb.fieldid
    else
        error()
    end
end
function _getid(symtb::SubroutineSymbolTable, kind)
    if kind == "argument"
        return symtb.argumentid
    elseif kind == "local"
        return symtb.localid
    else
        error()
    end
end

function _incid!(symtb::ClassSymbolTable, kind)
    if kind == "static"
        symtb.staticid += 1
    elseif kind == "this"
        symtb.fieldid += 1
    else
        error()
    end
    nothing
end
function _incid!(symtb::SubroutineSymbolTable, kind)
    if kind == "argument"
        symtb.argumentid += 1
    elseif kind == "local"
        symtb.localid += 1
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

function _count_field(symtb::ClassSymbolTable)
    nfield = 0
    for var in values(symtb.symtable)
        # segment `this` correspond to `field` variables
        if var.kind == "this"
            nfield += 1
        end
    end
    return nfield
end

function _varinfo(codegen::CodeGenerator, id)
    subr_symtb = codegen.subroutine_symtable
    class_symtb = codegen.class_symtable
    if id in keys(subr_symtb)
        return subr_symtb[id]
    elseif id in keys(class_symtb)
        return class_symtb[id]
    else
        error()
    end
end

print_push(io, seg, n="0") = println(io, "push $(seg) $(n)")
print_push_const(io, n="0") = print_push(io, "constant", n)
print_push_arg(io, n="0") = print_push(io, "argument", n)
print_push_that(io, n="0") = print_push(io, "that", n)
print_push_pointer(io, n="0") = print_push(io, "pointer", n)

print_pop(io, seg, n="0") = println(io, "pop $(seg) $(n)")
print_pop_temp(io, n="0") = print_pop(io, "temp", n)
print_pop_pointer(io, n="0") = print_pop(io, "pointer", n)

end # module
