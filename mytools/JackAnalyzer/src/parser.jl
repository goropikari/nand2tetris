module CompilationEngine

import ..JackAnalyzer: Token, Keyword, Identifier, _Symbol, IntegerConstant, StringConstant, resolve_enum
import ..JackAnalyzer: TokenType,
    IDENTIFIER,
    CLASS,
    CONSTRUCTOR,
    FUNCTION,
    METHOD,
    FIELD,
    STATIC,
    # CLASS_VAR_DEC,
    VAR,
    INT,
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
    BAR,
    LT,
    GT,
    EQ,
    TILDE

mutable struct Parser
    pos::Int
    tokens::Vector{Token}
    parse_tree
end

struct Class
    name
    class_var_decs
    subr_decs
end

struct ClassVarDec
    vardec
    type
    idents
end

function current_token(parser::Parser)
    return parser.tokens[parser.pos]
end

function nexttoken(parser::Parser)
    if (parser.pos + 1 > length(parser.tokens))
        return nothing
    end
    parser.pos += 1
end

function accept(parser::Parser, typ::TokenType)
    if current_token(parser).enum == typ
        nexttoken(parser)
        return true
    end
    return false
end

function expect(parser::Parser, typ::TokenType)
    return current_token(parser).enum == typ
end

function class(parser::Parser)
    accept(parser, CLASS)
    name = class_name(parser)
    accept(parser, LCPAREN)
    var_decs = class_var_decs(parser)
    subr_decs = subroutine_decs(parser)
    accept(parser, RCPAREN)

    return Class(name, var_decs, subr_decs)
end

function class_name(parser::Parser)
    if expect(parser, IDENTIFIER)
        token = current_token(parser)
        nexttoken(parser)
        return token
    end
end

function subroutine_decs(parser::Parser)
    subr_decs = []
    while current_token(parser).enum in (CONSTRUCTOR, FUNCTION, METHOD)
        push!(subr_decs, subroutine_dec(parser))
    end
    return subr_decs
end

function subroutine_dec(parser::Parser)
    function type(parser)
        token = current_token(parser)
        if token.enum == VOID || istype(parser)
            nexttoken(parser)
            return token
        end
    end
    function subrname(parser)
        token = current_token(parser)
        if expect(parser, IDENTIFIER)
            nexttoken(parser)
            return token
        end
    end
    subr = current_token(parser)
    nexttoken(parser)
    typ = type(parser)
    name = subrname(parser)
    accept(parser, LPAREN)
    params = parameters(parser)
    accept(parser, RPAREN)
    accept(parser, LCPAREN)
    body = subroutinebody(parser)
    accept(parser, RCPAREN)

    return SubroutineDec(subr, typ, name, params, body)
end

struct SubroutineDec
    subr
    typ
    name
    params
    body
end

function parameters(parser::Parser)
    params = []
    while istype(parser)
        push!(params, parameter(parser))
        accept(parser, COMMA)
    end

    return params
end

function istype(parser)
    return current_token(parser).enum in (INT, CHAR, BOOLEAN, IDENTIFIER)
end

function parameter(parser::Parser)
    function type(parser)
        if istype(parser)
            token = current_token(parser)
            nexttoken(parser)
            return token
        end
    end

    typ = type(parser)
    varname = if expect(parser, IDENTIFIER)
        token = current_token(parser)
        nexttoken(parser)
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

struct Parameter
    type
    name
end

function subroutinebody(parser::Parser)
    accept(parser, LCPAREN)
    vars = body_var_decs(parser)
    stmts = staments(parser)
    accept(parser, RCPAREN)

    return SubroutineBody(vars, stmts)
end


function body_var_decs(parser::Parser)
    decs = []
    while accept(parser, VAR)
        vars = []
        typ = nothing
        istype(parser) || return nothing
        typ = current_token(parser)
        nexttoken(parser)
        while expect(parser, IDENTIFIER)
            push!(vars, current_token(parser))
            nexttoken(parser)
            accept(parser, COMMA)
        end
        accept(parser, SEMICOLON)
        push!(decs, SubroutineBodyVarDec(typ, vars))
    end
    return decs
end

struct SubroutineBodyVarDec
    typ
    vars
end

struct SubroutineBody
    vars::Vector{Union{Nothing, SubroutineBodyVarDec}}
    stmts
end

function staments(parser::Parser)
end

function class_var_decs(parser)
    vardecs = []
    while current_token(parser).enum in (STATIC, FIELD)
        push!(vardecs, class_var_dec(parser))
    end

    return vardecs
end

function class_var_dec(parser::Parser)
    function type(parser::Parser)
        token = current_token(parser)
        if token.enum in (INT, CHAR, BOOLEAN, IDENTIFIER)
            nexttoken(parser)
            return token
        end
    end

    if expect(parser, STATIC) || expect(parser, FIELD)
        vardec = current_token(parser)
        nexttoken(parser)
        typ = type(parser)
        vardecs = []
        while expect(parser, IDENTIFIER)
            push!(vardecs, current_token(parser))
            nexttoken(parser)
            accept(parser, COMMA)
        end
        accept(parser, SEMICOLON)

        return ClassVarDec(vardec, typ, vardecs)
    end
end

end # module
