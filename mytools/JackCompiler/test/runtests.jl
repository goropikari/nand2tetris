import JackCompiler

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

    l = JackCompiler.Lexers.tokenize(program)
    io = IOBuffer()
    JackCompiler.Lexers.dump(io, l)
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


@testset "Parser" begin
    program = """

    /** hoge */

    /* piyo */

    class Main {
        static int x, y;
        field int z;
        function void main() {
            var boolean a, b;
            var int c, d;

            return;
        }
        function void foo(int a) {
            var int x, y;
            if (true) {
                let x = 123;
            } else {
                let y = 456;
            }
            while (true) {
                let abc = hogehoge;
            }
            let x[i] = 1
            let x = arr[10]; // piyo
            let y = (-2); /* fuga */
            do Output.printInt(x);
            do Output.printInt(y);
            do Output.printString("Hello world");

            return x + 10;
        }
    }
    """
    x = JackCompiler.Parsers.program(program)
    JackCompiler.Parsers.dump(stdout, x.parse_tree)
end
