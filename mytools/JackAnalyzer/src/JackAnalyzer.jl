module JackAnalyzer
export tokenize, dump

@enum TokenType begin
    IDENTIFIER
    CLASS
    CONSTRUCTOR
    FUNCTION
    METHOD
    FIELD
    STATIC
    # CLASS_VAR_DEC
    VAR
    INT
    STRING_CONST
    INT_CONST
    CHAR
    BOOLEAN
    VOID
    TRUE
    FALSE
    NULL
    THIS
    LET
    DO
    IF
    ELSE
    WHILE
    RETURN
    LCPAREN   = Int('{')
    RCPAREN   = Int('}')
    LPAREN    = Int('(')
    RPAREN    = Int(')')
    LSQPAREN  = Int('[')
    RSQPAREN  = Int(']')
    PERIOD    = Int('.')
    COMMA     = Int(',')
    SEMICOLON = Int(';')
    PLUS      = Int('+')
    MINUS     = Int('-')
    MUL       = Int('*')
    DIV       = Int('/')
    AND       = Int('&')
    OR        = Int('|')
    LT        = Int('<')
    GT        = Int('>')
    EQ        = Int('=')
    TILDE     = Int('~')
end


########
# Types
########
abstract type Token end
for typ in ("Keyword", "Identifier", "_Symbol", "IntegerConstant")
    sym = Symbol(typ)
    eval(quote
        struct $sym <: Token
            val
            enum
            function $(sym)(val)
                new(val, resolve_enum(val))
            end
        end
    end)
end
struct StringConstant <: Token
    val
    enum
    function StringConstant(val)
        new(match(r"\"?([^\"]*)\"?", val).captures[1], STRING_CONST)
    end
end
struct NothingToken <: Token
    val
    enum

    function NothingToken()
        new(nothing, nothing)
    end
end

function resolve_enum(val::AbstractString)
    if !isnothing(match(r"[0-9]+", val))
        return INT_CONST
    end
    dict = Dict{AbstractString, TokenType}(
        "{"           => LCPAREN,
        "}"           => RCPAREN,
        "("           => LPAREN,
        ")"           => RPAREN,
        "["           => LSQPAREN,
        "]"           => RSQPAREN,
        "."           => PERIOD,
        ","           => COMMA,
        ";"           => SEMICOLON,
        "+"           => PLUS,
        "-"           => MINUS,
        "*"           => MUL,
        "/"           => DIV,
        "&"           => AND,
        "|"           => OR,
        "<"           => LT,
        ">"           => GT,
        "="           => EQ,
        "~"           => TILDE,
        "class"       => CLASS,
        "constructor" => CONSTRUCTOR,
        "function"    => FUNCTION,
        "method"      => METHOD,
        "field"       => FIELD,
        "static"      => STATIC,
        # "field"       => CLASS_VAR_DEC,
        # "static"      => CLASS_VAR_DEC,
        "var"         => VAR,
        "int"         => INT,
        "char"        => CHAR,
        "boolean"     => BOOLEAN,
        "void"        => VOID,
        "true"        => TRUE,
        "false"       => FALSE,
        "null"        => NULL,
        "this"        => THIS,
        "let"         => LET,
        "do"          => DO,
        "if"          => IF,
        "else"        => ELSE,
        "while"       => WHILE,
        "return"      => RETURN
    )

    return get(dict, val, IDENTIFIER)
end


# module Tokenizer end
include("tokenizer.jl")
import .Tokenizer: tokenize, dump

include("parser.jl")

end # module
