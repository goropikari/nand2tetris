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

    return Class(name, class_var_decs, subr_decs)
end


function subroutine_decs(x) end


function class_name(parser::Parser)
    if expect(parser, IDENTIFIER)
        token = current_token(parser)
        nexttoken(parser)
        return token
    end
end

function class_var_decs(parser)
    vardecs = []
    while current_token(parser) in (STATIC, FIELD)
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
