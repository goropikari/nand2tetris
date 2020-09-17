import JackAnalyzer

using Test

@testset "Lexer" begin
    program = """

    /** hoge */

    /* piyo */

    class Main {
        function void main() {
            var int x, y;
            let x = 1; // piyo
            let y = 2; /* fuga */
            do Output.printInt(x);
            do Output.printInt(y);
            do Output.printString("Hello world");
        }
    }
    """

    l = JackAnalyzer.Tokenizer.tokenize(program)
    io = IOBuffer()
    JackAnalyzer.Tokenizer.dump(io, l)
    expected = """<tokens>
    <keyword> class </keyword>
    <identifier> Main </identifier>
    <symbol> { </symbol>
    <keyword> function </keyword>
    <keyword> void </keyword>
    <identifier> main </identifier>
    <symbol> ( </symbol>
    <symbol> ) </symbol>
    <symbol> { </symbol>
    <keyword> var </keyword>
    <keyword> int </keyword>
    <identifier> x </identifier>
    <symbol> , </symbol>
    <identifier> y </identifier>
    <symbol> ; </symbol>
    <keyword> let </keyword>
    <identifier> x </identifier>
    <symbol> = </symbol>
    <integerConstant> 1 </integerConstant>
    <symbol> ; </symbol>
    <keyword> let </keyword>
    <identifier> y </identifier>
    <symbol> = </symbol>
    <integerConstant> 2 </integerConstant>
    <symbol> ; </symbol>
    <keyword> do </keyword>
    <identifier> Output </identifier>
    <symbol> . </symbol>
    <identifier> printInt </identifier>
    <symbol> ( </symbol>
    <identifier> x </identifier>
    <symbol> ) </symbol>
    <symbol> ; </symbol>
    <keyword> do </keyword>
    <identifier> Output </identifier>
    <symbol> . </symbol>
    <identifier> printInt </identifier>
    <symbol> ( </symbol>
    <identifier> y </identifier>
    <symbol> ) </symbol>
    <symbol> ; </symbol>
    <keyword> do </keyword>
    <identifier> Output </identifier>
    <symbol> . </symbol>
    <identifier> printString </identifier>
    <symbol> ( </symbol>
    <stringConstant> Hello world </stringConstant>
    <symbol> ) </symbol>
    <symbol> ; </symbol>
    <symbol> } </symbol>
    <symbol> } </symbol>
    </tokens>
    """
    @test expected == String(io.data)
end

