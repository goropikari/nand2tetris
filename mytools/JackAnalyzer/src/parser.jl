module CompilationEngine

import ..Tokenizer
import ..Tokenizer: dump
import ..JackAnalyzer: Token, NothingToken, Keyword, Identifier, _Symbol, IntegerConstant, StringConstant, resolve_enum
import ..JackAnalyzer: TokenType,
    IDENTIFIER,
    CLASS,
    CONSTRUCTOR,
    FUNCTION,
    METHOD,
    FIELD,
    STATIC,
    VAR,
    INT,
    STRING_CONST,
    INT_CONST,
    CHAR,
    BOOLEAN,
    VOID,
    TRUE,
    FALSE,
    NULL,
    THIS,
    LET,
    DO,
    IF,
    ELSE,
    WHILE,
    RETURN,
    LCPAREN,
    RCPAREN,
    LPAREN,
    RPAREN,
    LSQPAREN,
    RSQPAREN,
    PERIOD,
    COMMA,
    SEMICOLON,
    PLUS,
    MINUS,
    MUL,
    DIV,
    AND,
    OR,
    LT,
    GT,
    EQ,
    TILDE

#######
# type
#######
mutable struct Parser
    pos::Int
    tokens::Vector{Token}
    parse_tree
    input
end

struct Class
    name
    vardecs
    subrdecs
end

struct ClassVarDec
    deckw
    type
    varnames
end

struct SubroutineDec
    deckw # constructor, method, function
    type
    name
    params
    body
end

struct Parameter
    type
    name
end

struct SubroutineBodyVarDec
    type
    vars
end

abstract type Statement end

struct SubroutineBody
    vardecs::Vector{SubroutineBodyVarDec}
    stmts::Vector{Statement}
end

struct SubroutineCall
    obj
    name
    exprs
end

struct Let <: Statement
    var
    arr_idx
    expr
end

struct If <: Statement
    cond
    then_stmt
    else_stmt
end

struct While <: Statement
    cond
    stmts
end

struct Do <: Statement
    subr::SubroutineCall
end

struct Return <: Statement
    expr
end

struct _Array
    var
    idx
end

struct Operator
    op
    left
    right
end

struct Expression
    expr
end

struct UnaryOp
    op
    expr
end

struct Term
    val
end

########
# utils
########
function current(parser::Parser)
    if parser.pos <= length(parser.tokens)
        return parser.tokens[parser.pos]
    end
end

function next(parser::Parser)
    if parser.pos + 1 <= length(parser.tokens)
        return parser.tokens[parser.pos + 1]
    else
        return NothingToken()
    end
end

function advance!(parser::Parser)
    if (parser.pos > length(parser.tokens))
        return nothing
    end
    parser.pos += 1
end

function accept!(parser::Parser, typ::TokenType)
    if current(parser).enum == typ
        advance!(parser)
        return true
    end
    return false
end

function expect(parser::Parser, typ::TokenType)
    return current(parser).enum == typ
end

function istype(parser)
    return current(parser).enum in (INT, CHAR, BOOLEAN, IDENTIFIER)
end

##################
# parse functions
##################
function program(input::String)
    return program(IOBuffer(input))
end
function program(io::IO)
    input = read(io, String)
    lexer = Tokenizer.tokenize(input)
    parser = Parser(1, lexer.tokens, nothing, lexer.input)
    return program(parser)
end
function program(parser::Parser)
    parser.parse_tree = class(parser)
    return parser
end

function class(parser::Parser)
    function class_name(parser::Parser)
        if expect(parser, IDENTIFIER)
            token = current(parser)
            advance!(parser)
            return token
        end
    end

    accept!(parser, CLASS)
    name = class_name(parser)
    accept!(parser, LCPAREN)
    vardecs = class_var_decs(parser)
    subrdecs = subroutine_decs(parser)
    accept!(parser, RCPAREN)

    return Class(name, vardecs, subrdecs)
end

function class_var_decs(parser)
    vardecs = []
    while current(parser).enum in (STATIC, FIELD)
        push!(vardecs, class_var_dec(parser))
    end

    return vardecs
end
function class_var_dec(parser::Parser)
    if expect(parser, STATIC) || expect(parser, FIELD)
        deckw = current(parser)
        advance!(parser)
        typ = nothing
        if istype(parser)
            typ = current(parser)
            advance!(parser)
        end
        vars = []
        while expect(parser, IDENTIFIER)
            push!(vars, current(parser))
            advance!(parser)
            accept!(parser, COMMA)
        end
        accept!(parser, SEMICOLON)

        return ClassVarDec(deckw, typ, vars)
    end
end

function subroutine_decs(parser::Parser)
    subr_decs = []
    while current(parser).enum in (CONSTRUCTOR, FUNCTION, METHOD)
        push!(subr_decs, subroutine_dec(parser))
    end
    return subr_decs
end
function subroutine_dec(parser::Parser)
    function type!(parser)
        token = current(parser)
        if token.enum == VOID || istype(parser)
            advance!(parser)
            return token
        end
    end
    function subrname(parser)
        token = current(parser)
        if expect(parser, IDENTIFIER)
            advance!(parser)
            return token
        end
    end
    subr = current(parser)
    advance!(parser)
    typ = type!(parser)
    name = subrname(parser)
    accept!(parser, LPAREN)
    params = parameters(parser)
    accept!(parser, RPAREN)
    accept!(parser, LCPAREN)
    body = subroutinebody(parser)
    accept!(parser, RCPAREN)

    return SubroutineDec(subr, typ, name, params, body)
end

function parameters(parser::Parser)
    params = []
    while istype(parser)
        push!(params, parameter(parser))
        accept!(parser, COMMA)
    end

    return params
end


function parameter(parser::Parser)
    typ = current(parser)
    advance!(parser)
    varname = if expect(parser, IDENTIFIER)
        token = current(parser)
        advance!(parser)
        token
    else
        nothing
    end

    if isnothing(typ) && isnothing(varname)
        return nothing
    else
        Parameter(typ, varname)
    end
end


function subroutinebody(parser::Parser)
    vars = body_var_decs(parser)
    stmts = statements(parser)

    return SubroutineBody(vars, stmts)
end

function body_var_decs(parser::Parser)
    decs = []
    while accept!(parser, VAR)
        vars = []
        typ = nothing
        istype(parser) || return println("hoge")
        typ = current(parser)
        advance!(parser)
        while expect(parser, IDENTIFIER)
            push!(vars, current(parser))
            advance!(parser)
            accept!(parser, COMMA)
        end
        accept!(parser, SEMICOLON)
        push!(decs, SubroutineBodyVarDec(typ, vars))
    end
    return decs
end


function isstatement(parser::Parser)
    return current(parser).enum in (LET, IF, WHILE, DO, RETURN)
end

function statements(parser::Parser)
    stmts = []
    while isstatement(parser)
        if expect(parser, LET)
            stmt = let_stmt(parser)
            push!(stmts, stmt)
        elseif expect(parser, IF)
            stmt = if_stmt(parser)
            push!(stmts, stmt)
        elseif expect(parser, WHILE)
            stmt = while_stmt(parser)
            push!(stmts, stmt)
        elseif expect(parser, DO)
            stmt = do_stmt(parser)
            push!(stmts, stmt)
        elseif expect(parser, RETURN)
            stmt = return_stmt(parser)
            push!(stmts, stmt)
        end
    end

    return stmts
end

function let_stmt(parser)
    advance!(parser)
    var = nothing
    arr_idx = nothing
    expr = nothing
    if expect(parser, IDENTIFIER)
        var = current(parser)
        advance!(parser)
        if accept!(parser, LSQPAREN) # array
            arr_idx = expression(parser)
            accept!(parser, RSQPAREN)
            # var = _Array(var, arr_idx)
        end
    end
    accept!(parser, EQ)
    expr = expression(parser)
    accept!(parser, SEMICOLON)

    return Let(var, arr_idx, expr)
end


function if_stmt(parser)
    advance!(parser)
    accept!(parser, LPAREN)
    cond = expression(parser)
    accept!(parser, RPAREN)
    accept!(parser, LCPAREN)
    then_stmt = statements(parser)
    accept!(parser, RCPAREN)
    else_stmt = nothing
    if accept!(parser, ELSE)
        accept!(parser, LCPAREN)
        else_stmt = statements(parser)
        accept!(parser, RCPAREN)
    end

    return If(cond, then_stmt, else_stmt)
end


function while_stmt(parser::Parser)
    advance!(parser)
    accept!(parser, LPAREN)
    cond = expression(parser)
    accept!(parser, RPAREN)
    accept!(parser, LCPAREN)
    stmts = statements(parser)
    accept!(parser, RCPAREN)

    return While(cond, stmts)
end


function do_stmt(parser::Parser)
    advance!(parser)
    call = subroutine_call(parser)
    accept!(parser, SEMICOLON)
    return Do(call)
end

function subroutine_call(parser::Parser)
    if expect(parser, IDENTIFIER)
        obj = nothing
        name = nothing
        if next(parser).enum == PERIOD
            obj = current(parser)
            advance!(parser)
            advance!(parser)
            name = current(parser)
        else
            name = current(parser)
        end
        advance!(parser)
        accept!(parser, LPAREN)
        exprs = expressions(parser)
        accept!(parser, RPAREN)

        return SubroutineCall(obj, name, exprs)
    end
end


function return_stmt(parser::Parser)
    advance!(parser)
    if accept!(parser, SEMICOLON)
        return Return(nothing)
    else
        expr = expression(parser)
        accept!(parser, SEMICOLON)
        return Return(expr)
    end
end


function expressions(parser::Parser)
    exprs = []
    expr = expression(parser)
    push!(exprs, expr)
    while accept!(parser, COMMA)
        expr = expression(parser)
        push!(exprs, expr)
    end

    return exprs
end

function expression(parser::Parser)
    node = term(parser)
    while isoperator(parser)
        op = current(parser)
        advance!(parser)
        right = term(parser)
        node = Operator(op, node, right)
    end

    return node
end


function isoperator(parser::Parser)
    return current(parser).enum in (PLUS, MINUS, MUL, DIV, AND, OR, LT, GT, EQ)
end

function term(parser::Parser)
    token = current(parser)
    if token.enum in (INT_CONST, STRING_CONST, TRUE, FALSE, NULL, THIS)
        advance!(parser)
        return Term(token)
    elseif token.enum in (PLUS, MINUS)
        op = token
        advance!(parser)
        expr = term(parser)
        return Term(UnaryOp(op, Term(expr)))
    elseif token.enum == LPAREN
        accept!(parser, LPAREN)
        expr = expression(parser)
        accept!(parser, RPAREN)
        return Term(expr)
    elseif token.enum == IDENTIFIER
        nexttoken = next(parser)
        if nexttoken.enum == LSQPAREN # array
            advance!(parser)
            advance!(parser)
            expr = expression(parser)
            accept!(parser, RSQPAREN)
            return  Term(_Array(token, expr))
        elseif nexttoken.enum == PERIOD # external class subroutine
            return Term(subroutine_call(parser))
        elseif nexttoken.enum == LPAREN # subroutine
            return Term(subroutine_call(parser))
        else # simple variable
            advance!(parser)
            return Term(token)
        end
    end
end

############
# print xml
############

dump_tag(io, x, tag) = println(io, "<$tag> $x </$tag>")
dump_kw(io, x) = dump_tag(io, x, "keyword")
dump_sym(io, x) = dump_tag(io, x, "sym")

function dump(io::IO, class::Class)
    println(io, "<class>")
    dump_kw(io, "class")
    dump(io, class.name)
    dump_sym(io, "{")
    if !isempty(class.vardecs)
        for vardec in class.vardecs
            dump(io, vardec)
        end
    end
    if !isempty(class.subrdecs)
        for subrdec in class.subrdecs
            dump(io, subrdec)
        end
    end
    dump_sym(io, "}")
    println(io, "</class>")
end

function dump(io::IO, vardec::ClassVarDec)
    println(io, "<classVarDec>")
    dump(io, vardec.deckw)
    dump(io, vardec.type)
    for (i, name) in enumerate(vardec.varnames)
        i > 1 && dump_sym(io, ",")
        dump(io, name)
    end
    dump_sym(io, ";")
    println(io, "</classVarDec>")
end
function dump(io::IO, subrdec::SubroutineDec)
    println(io, "<subroutineDec>")
    dump(io, subrdec.deckw)
    dump(io, subrdec.type)
    dump(io, subrdec.name)
    dump_sym(io, "(")
    if !isempty(subrdec.params)
        println(io, "<parameterList>")
        for (i, param) in enumerate(subrdec.params)
            i > 1 && dump_sym(io, ",")
            dump(io, param)
        end
        println(io, "</parameterList>")
    end
    dump(io, subrdec.body)
    dump_sym(io, ")")

    println(io, "</subroutineDec>")
end
function dump(io::IO, param::Parameter)
    dump(io, param.type)
    dump(io, param.name)
end
function dump(io::IO, body::SubroutineBody)
    dump_sym(io, "{")
    if !isempty(body.vardecs)
        for vardec in body.vardecs
            dump(io, vardec)
        end
    end
    if !isempty(body.stmts)
        for stmt in body.stmts
            dump(io, stmt)
        end
    end
    dump_sym(io, "}")
end
function dump(io::IO, vardec::SubroutineBodyVarDec)
    println(io, "<varDec>")
    dump_kw(io, "var")
    dump(io, vardec.type)
    for (i, var) in enumerate(vardec.vars)
        i > 1 && dump_sym(io, ",")
        dump(io, var)
    end
    dump_sym(io, ";")
    println(io, "</varDec>")
end
function dump(io::IO, _term::Term)
    println(io, "<term>")
    dump(io, _term.val)
    println(io, "</term>")
end
function dump(io::IO, _let::Let)
    println(io, "<letStatement>")
    dump_kw(io, "let")
    dump(io, _let.var)
    if !isnothing(_let.arr_idx)
        dump_sym(io, "[")
        println(io, "<expression>")
        dump(io, _let.arr_idx)
        println(io, "</expression>")
        dump_sym(io, "]")
    end
    dump_sym(io, "=")
    println(io, "<expression>")
    dump(io, _let.expr)
    dump_sym(io, ";")
    println(io, "</expression>")
    println(io, "</letStatement>")
end
function dump(io::IO, class::If) end
function dump(io::IO, class::While) end
function dump(io::IO, class::Do) end
function dump(io::IO, class::Return) end
function dump(io::IO, class::SubroutineCall) end
function dump(io::IO, arr::_Array)
    dump(io, arr.var)
    dump_sym(io, "[")
    println(io, "<expression>")
    dump(io, arr.idx)
    println(io, "</expression>")
    dump_sym(io, "]")
end
function dump(io::IO, class::Operator) end
function dump(io::IO, class::Expression) end
function dump(io::IO, class::UnaryOp) end



end # module
