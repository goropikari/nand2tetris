module Tokenizer

import ..JackAnalyzer: Token, Keyword, Identifier, _Symbol, IntegerConstant, StringConstant, resolve_enum
export tokenize, dump

struct TokenizeError <: Exception
    msg::String
end
Base.showerror(io::IO, err::TokenizeError) = print(io, "TokenizeError: $(err.msg)")

mutable struct Lexer
    input::String
    start::Int # start of lexeme
    tokens::Vector{Token}

    function Lexer(input)
        new(input, 1, [])
    end
end

############
# Functions
############
"""
    tokenize(io::IO)

Tokenize Jack program.
"""
function tokenize(io::IO)
    input = read(io, String)
    l = Lexer(input)
    _scan(l)
    return l
end
tokenize(str::String) = tokenize(IOBuffer(str))

function _scan(l::Lexer)
    # initialize lexer
    l.tokens = []
    l.start = 1

    # ref: textbook p.208
    keyword = [
                "class", "constructor", "function", "method", "field", "static", "var", "int", "char",
                "boolean", "void", "true", "false", "null", "this", "let", "do", "if", "else", "while", "return"
              ]
    r_keyword = _regex(keyword)
    r_id = r"^[a-zA-Z_][a-zA-Z0-9_]*"
    r_int = r"^[0-9]+"
    r_string = r"^\"[^\"]*\""
    symbol = ["{", "}", "\\(", "\\)", "\\[", "\\]", "\\.", ",", ";",
              "\\+", "-", "\\*", "/", "&", "\\|", "<", ">", "=", "~"]
    r_symbol = _regex(symbol)
    token_regex = [
                   (Keyword        , r_keyword ),
                   (Identifier     , r_id      ),
                   (_Symbol        , r_symbol  ),
                   (IntegerConstant, r_int     ),
                   (StringConstant , r_string  )
                  ]

    while true
        _skip_nontoken(l) # skip comments and whitespace
        candidate = []

        for (typ, re) in token_regex
            m = match(re, l.input[l.start:end])
            isnothing(m) && continue
            push!(candidate, (typ, m.match))
        end

        if isempty(candidate)
            if length(l.input) > l.start
                throw(TokenizeError("Can't reach end of file."))
            end
            return
        end

        # longest lexeme's index
        len, idx = findmax(length.( (x -> x[2]).(candidate)))
        l.start += len
        token_typ, token_val = candidate[idx]
        push!(l.tokens, token_typ(token_val))
    end
end

function _skip_nontoken(l::Lexer)
    prev = 0
    while prev != l.start
        prev = l.start
        _skip_comment(l)
        _skip_whitespace(l)
    end
end

function _skip_comment(l::Lexer)
    r_oneline = r"^//[^\n]*"
    r_multiline = r"^/\*[\s\S]*?\*/"
    prev = 0
    while prev != l.start
        prev = l.start
        for re in (r_oneline, r_multiline)
            m = match(re, l.input[l.start:end])
            isnothing(m) && continue
            len = length(m.match)
            l.start += len
        end
    end
end

function _skip_whitespace(l::Lexer)
    r_whitespace = r"^[ \r\t\n]*"
    m = match(r_whitespace, l.input[l.start:end])
    isnothing(m) && return
    len = length(m.match)
    l.start += len
    nothing
end

"""
    _regex(kw)

Make regular expression from Array of String

```julia
julia> _regex(["foo", "bar"])
r"^foo|^bar"
```
"""
function _regex(kw)
    return Regex(join((x -> "^" * x).(kw), "|"))
end

function dump(io::IO, l::Lexer)
    println(io, "<tokens>")
    for token in l.tokens
        dump(io::IO, token)
    end
    println(io, "</tokens>")
end
dump(l::Lexer) = dump(stdout, l)

function dump(io::IO, token::Keyword)
    println(io, "<keyword> $(token.val) </keyword>")
end

function dump(io::IO, token::Identifier)
    println(io, "<identifier> $(token.val) </identifier>")
end

function dump(io::IO, token::_Symbol)
    val = token.val
    xmlrep = ""
    if val == "<"
        xmlrep = "&lt;"
    elseif val == ">"
        xmlrep = "&gt;"
    elseif val == "&"
        xmlrep = "&amp;"
    else
        xmlrep = val
    end
    println(io, "<symbol> $(xmlrep) </symbol>")
end

function dump(io::IO, token::IntegerConstant)
    println(io, "<integerConstant> $(token.val) </integerConstant>")
end

function dump(io::IO, token::StringConstant)
    println(io, "<stringConstant> $(token.val) </stringConstant>")
end

end # module
