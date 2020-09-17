module Tokenizer

function tokenize(io::IO)
end

mutable struct Lexer
    input::String
    start::Int # start of lexeme
    tokens

    function Lexer(input)
        new(input, 1, [])
    end
end

function scan(l::Lexer)
    keyword = ["class", "constructor", "function"]
    r_keyword = _regex(keyword)

    r_id = r"^[a-zA-Z_][a-zA-Z0-9_]*"
    r_int = r"^[0-9]+"
    r_string = r"^\"[^\"]*\""

    symbol = ["{", "}", "\\(", "\\)", "\\[", "\\]", "\\.", ",", ";",
              "\\+", "-", "\\*", "/", "&", "\\|", "<", ">", "=", "-"]
    r_symbol = _regex(symbol)
    token_regex = [
                   ("KEYWORD", r_keyword),
                   ("IDENTIFIER", r_id),
                   ("SYMBOL", r_symbol),
                   ("INT_CONST", r_int),
                   ("STRING_CONST", r_string)
                  ]

    while true
        # _skip_comment(l)
        _skip_whitespace(l)

        candidate = []

        for (typ, re) in token_regex
            m = match(re, l.input[l.start:end])
            isnothing(m) && continue
            push!(candidate, (typ, m.match))
        end

        if isempty(candidate)
            return
        end

        # longest lexeme's index
        len, idx = findmax(length.( (x -> x[2]).(candidate)))
        l.start += len
        push!(l.tokens, candidate[idx])
    end
end

function _skip_comment(l::Lexer) end
function _skip_whitespace(l::Lexer)
    r_whitespace = r"^[ \t\n]*"
    m = match(r_whitespace, l.input[l.start:end])
    isnothing(m) && return
    len = length(m.match)
    l.start += len
    nothing
end

function _regex(kw)
    return Regex(join((x -> "^" * x).(kw), "|"))
end

x = """
class Main {
    function void main() {
        var int x, y;
        let x = 1;
        let y = 2;
        do Output.printInt(x);
        do Output.printInt(y);
        do Output.printString("Hello world");
    }
}
"""
end # module
