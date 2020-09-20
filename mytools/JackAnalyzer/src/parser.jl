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

struct Program
    class
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
    then_stmts
    else_stmts
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

abstract type Expression end
struct Term <: Expression
    val
end

struct Parenthesis <: Expression
    val
end

struct UnaryOp <: Expression
    op
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
    parser.parse_tree = Program(class(parser))
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
    then_stmts = statements(parser)
    accept!(parser, RCPAREN)
    else_stmts = []
    if accept!(parser, ELSE)
        accept!(parser, LCPAREN)
        else_stmts = statements(parser)
        accept!(parser, RCPAREN)
    end

    return If(cond, then_stmts, else_stmts)
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
    !isnothing(expr) && push!(exprs, expr)
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
    elseif token.enum in (MINUS, TILDE)
        op = token
        advance!(parser)
        expr = term(parser)
        return Term(UnaryOp(op, expr))
    elseif token.enum == LPAREN
        accept!(parser, LPAREN)
        expr = expression(parser)
        accept!(parser, RPAREN)
        return Term(Parenthesis(expr))
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
_space(depth) = "  " ^ depth
function dump_xml(io::IO, x::Token, depth)
    print(io, "  " ^ depth)
    dump(io, x)
end
dump_tag(io, x, tag, depth) = println(io, ("  "^depth) * "<$tag> $x </$tag>")
dump_kw(io, x, depth) = dump_tag(io, x, "keyword", depth)
dump_sym(io, x, depth) = dump_tag(io, x, "symbol", depth)

function dump_xml(io, prog::Program)
    dump_xml(io, prog.class, 0)
end
function dump_xml(io::IO, class::Class, depth)
    println(io, _space(depth) * "<class>")
    dump_kw(io, "class", depth+1)
    dump_xml(io, class.name, depth+1)
    dump_sym(io, "{", depth+1)
    if !isempty(class.vardecs)
        for vardec in class.vardecs
            dump_xml(io, vardec, depth+1)
        end
    end
    if !isempty(class.subrdecs)
        for subrdec in class.subrdecs
            dump_xml(io, subrdec, depth+1)
        end
    end
    dump_sym(io, "}", 1)
    println(io, _space(depth) * "</class>")
end

function dump_xml(io::IO, vardec::ClassVarDec, depth)
    SPACE = "  " ^ depth
    println(io, SPACE * "<classVarDec>")
    dump_xml(io, vardec.deckw, depth+1)
    dump_xml(io, vardec.type, depth+1)
    for (i, name) in enumerate(vardec.varnames)
        i > 1 && dump_sym(io, ",", depth+1)
        dump_xml(io, name, depth+1)
    end
    dump_sym(io, ";", depth+1)
    println(io, SPACE * "</classVarDec>")
end
function dump_xml(io::IO, subrdec::SubroutineDec, depth)
    println(io, _space(depth) * "<subroutineDec>")
    dump_xml(io, subrdec.deckw, depth+1)
    dump_xml(io, subrdec.type, depth+1)
    dump_xml(io, subrdec.name, depth+1)

    dump_sym(io, "(", depth+1)
    println(io, _space(depth+1) * "<parameterList>")
    if !isempty(subrdec.params)
        for (i, param) in enumerate(subrdec.params)
            i > 1 && dump_sym(io, ",", depth+2)
            dump_xml(io, param, depth+2)
        end
    end
    println(io, _space(depth+1) * "</parameterList>")
    dump_sym(io, ")", depth+1)

    dump_xml(io, subrdec.body, depth)

    println(io, _space(depth) * "</subroutineDec>")
end
function dump_xml(io::IO, param::Parameter, depth)
    dump_xml(io, param.type, depth)
    dump_xml(io, param.name, depth)
end
function dump_xml(io::IO, body::SubroutineBody, depth)
    println(io, _space(depth) * "<subroutineBody>")
    dump_sym(io, "{", depth+1)
    if !isempty(body.vardecs)
        for vardec in body.vardecs
            dump_xml(io, vardec, depth+1)
        end
    end
    if !isempty(body.stmts)
        println(io, _space(depth+1) * "<statements>")
        for stmt in body.stmts
            dump_xml(io, stmt, depth+2)
        end
        println(io, _space(depth+1) * "</statements>")
    end
    dump_sym(io, "}", depth)
    println(io, _space(depth) * "</subroutineBody>")
end
function dump_xml(io::IO, vardec::SubroutineBodyVarDec, depth)
    println(io, _space(depth) * "<varDec>")
    dump_kw(io, "var", depth+1)
    dump_xml(io, vardec.type, depth+1)
    for (i, var) in enumerate(vardec.vars)
        i > 1 && dump_sym(io, ",", depth+1)
        dump_xml(io, var, depth+1)
    end
    dump_sym(io, ";", depth+1)
    println(io, _space(depth) * "</varDec>")
end
function dump_xml(io::IO, _term::Term, depth)
    println(io, _space(depth) * "<term>")
    dump_xml(io, _term.val, depth+1)
    println(io, _space(depth) * "</term>")
end
function dump_xml(io::IO, _let::Let, depth)
    println(io, _space(depth) * "<letStatement>")
    dump_kw(io, "let", depth+1)
    dump_xml(io, _let.var, depth+1)
    if !isnothing(_let.arr_idx)
        dump_sym(io, "[", depth+1)
        println(io, _space(depth+1) * "<expression>")
        dump_xml(io, _let.arr_idx, depth+2)
        println(io, _space(depth+1) * "</expression>")
        dump_sym(io, "]", depth+1)
    end
    dump_sym(io, "=", depth+1)
    println(io, _space(depth+1) * "<expression>")
    dump_xml(io, _let.expr, depth+2)
    println(io, _space(depth+1) * "</expression>")
    dump_sym(io, ";", depth+2)
    println(io, _space(depth) * "</letStatement>")
end
function dump_xml(io::IO, _if::If, depth)
    println(io, _space(depth) * "<ifStatement>")
    dump_kw(io, "if", depth+1)
    dump_sym(io, "(", depth+1)
    println(io, _space(depth+1) * "<expression>")
    dump_xml(io, _if.cond, depth+2)
    println(io, _space(depth+1) * "</expression>")
    dump_sym(io, ")", depth+1)

    dump_sym(io, "{", depth+1)
    println(io, _space(depth+1) * "<statements>")
    for stmt in _if.then_stmts
        dump_xml(io, stmt, depth+2)
    end
    println(io, _space(depth+1) * "</statements>")
    dump_sym(io, "}", depth+1)

    if !isempty(_if.else_stmts)
        dump_kw(io, "else", depth+1)
        dump_sym(io, "{", depth+1)
        println(io, _space(depth+1) * "<statements>")
        for stmt in _if.else_stmts
            dump_xml(io, stmt, depth+2)
        end
        println(io, _space(depth+1) * "</statements>")
        dump_sym(io, "}", depth+1)
    end

    println(io, _space(depth) * "</ifStatement>")
end
function dump_xml(io::IO, _while::While, depth)
    println(io, _space(depth) * "<whileStatement>")
    dump_kw(io, "while", depth+1)

    dump_sym(io, "(", depth+1)
    println(io, _space(depth+1) * "<expression>")
    dump_xml(io, _while.cond, depth+2)
    println(io, _space(depth+1) * "</expression>")
    dump_sym(io, ")", depth+1)

    dump_sym(io, "{", depth+1)
    println(io, _space(depth+1) * "<statements>")
    for stmt in _while.stmts
        dump_xml(io, stmt, depth+2)
    end
    println(io, _space(depth+1) * "</statements>")
    dump_sym(io, "}", depth+1)

    println(io, _space(depth) * "</whileStatement>")
end
function dump_xml(io::IO, _do::Do, depth)
    println(io, _space(depth) * "<doStatement>")
    dump_kw(io, "do", depth+1)
    dump_xml(io, _do.subr, depth+1)
    dump_sym(io, ";", depth)
    println(io, _space(depth) * "</doStatement>")
end
function dump_xml(io::IO, ret::Return, depth)
    println(io, _space(depth) * "<returnStatement>")
    dump_kw(io, "return", depth+1)
    if !isnothing(ret.expr)
        println(io, _space(depth+1) * "<expression>")
        dump_xml(io, ret.expr, depth+2)
        println(io, _space(depth+1) * "</expression>")
    end
    dump_sym(io, ";", depth+1)
    println(io, _space(depth) * "</returnStatement>")
end
function dump_xml(io::IO, call::SubroutineCall, depth)
    if !isnothing(call.obj)
        dump_xml(io, call.obj, depth)
        dump_sym(io, ".", depth)
    end
    dump_xml(io, call.name, depth)
    dump_sym(io, "(", depth)
    println(io, _space(depth) * "<expressionList>")
    for (i, expr) in enumerate(call.exprs)
        i > 1 && dump_sym(io, ",", depth+1)
        println(io, _space(depth+1) * "<expression>")
        dump_xml(io, expr, depth+2)
        println(io, _space(depth+1) * "</expression>")
    end
    println(io, _space(depth) * "</expressionList>")
    dump_sym(io, ")", depth)
end
function dump_xml(io::IO, arr::_Array, depth)
    dump_xml(io, arr.var, depth)
    dump_sym(io, "[", depth)
    println(io, _space(depth) * "<expression>")
    dump_xml(io, arr.idx, depth)
    println(io, _space(depth) * "</expression>")
    dump_sym(io, "]", depth)
end
function dump_xml(io::IO, op::Operator, depth)
    dump_xml(io, op.left, depth)
    dump_xml(io, op.op, depth)
    dump_xml(io, op.right, depth)
end
function dump_xml(io::IO, unaryop::UnaryOp, depth)
    dump_xml(io, unaryop.op, depth+1)
    dump_xml(io, unaryop.expr, depth+1)
end
function dump_xml(io::IO, paren::Parenthesis, depth)
    dump_sym(io, "(", depth)
    println(io, _space(depth) * "<expression>")
    dump_xml(io, paren.val, depth+1)
    println(io, _space(depth) * "</expression>")
    dump_sym(io, ")", depth)
end

end # module
