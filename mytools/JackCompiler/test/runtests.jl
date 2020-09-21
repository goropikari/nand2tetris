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
    io = IOBuffer()
    print(io, x.parse_tree)
    expected = "JackCompiler.Parsers.Program(JackCompiler.Parsers.Class(JackCompiler.Identifier(\"Main\", JackCompiler.IDENTIFIER), Any[JackCompiler.Parsers.ClassVarDec(JackCompiler.Keyword(\"static\", JackCompiler.STATIC), JackCompiler.Keyword(\"int\", JackCompiler.INT), Any[JackCompiler.Identifier(\"x\", JackCompiler.IDENTIFIER), JackCompiler.Identifier(\"y\", JackCompiler.IDENTIFIER)]), JackCompiler.Parsers.ClassVarDec(JackCompiler.Keyword(\"field\", JackCompiler.FIELD), JackCompiler.Keyword(\"int\", JackCompiler.INT), Any[JackCompiler.Identifier(\"z\", JackCompiler.IDENTIFIER)])], Any[JackCompiler.Parsers.SubroutineDec(JackCompiler.Keyword(\"function\", JackCompiler.FUNCTION), JackCompiler.Keyword(\"void\", JackCompiler.VOID), JackCompiler.Identifier(\"main\", JackCompiler.IDENTIFIER), Any[], JackCompiler.Parsers.SubroutineBody(JackCompiler.Parsers.SubroutineBodyVarDec[JackCompiler.Parsers.SubroutineBodyVarDec(JackCompiler.Keyword(\"boolean\", JackCompiler.BOOLEAN), Any[JackCompiler.Identifier(\"a\", JackCompiler.IDENTIFIER), JackCompiler.Identifier(\"b\", JackCompiler.IDENTIFIER)]), JackCompiler.Parsers.SubroutineBodyVarDec(JackCompiler.Keyword(\"int\", JackCompiler.INT), Any[JackCompiler.Identifier(\"c\", JackCompiler.IDENTIFIER), JackCompiler.Identifier(\"d\", JackCompiler.IDENTIFIER)])], JackCompiler.Parsers.Statement[JackCompiler.Parsers.Return(nothing)])), JackCompiler.Parsers.SubroutineDec(JackCompiler.Keyword(\"function\", JackCompiler.FUNCTION), JackCompiler.Keyword(\"void\", JackCompiler.VOID), JackCompiler.Identifier(\"foo\", JackCompiler.IDENTIFIER), Any[JackCompiler.Parsers.Parameter(JackCompiler.Keyword(\"int\", JackCompiler.INT), JackCompiler.Identifier(\"a\", JackCompiler.IDENTIFIER))], JackCompiler.Parsers.SubroutineBody(JackCompiler.Parsers.SubroutineBodyVarDec[JackCompiler.Parsers.SubroutineBodyVarDec(JackCompiler.Keyword(\"int\", JackCompiler.INT), Any[JackCompiler.Identifier(\"x\", JackCompiler.IDENTIFIER), JackCompiler.Identifier(\"y\", JackCompiler.IDENTIFIER)])], JackCompiler.Parsers.Statement[JackCompiler.Parsers.If(JackCompiler.Parsers.Term(JackCompiler.Keyword(\"true\", JackCompiler.TRUE)), Any[JackCompiler.Parsers.Let(JackCompiler.Identifier(\"x\", JackCompiler.IDENTIFIER), nothing, JackCompiler.Parsers.Term(JackCompiler.IntegerConstant(\"123\", JackCompiler.INT_CONST)))], Any[JackCompiler.Parsers.Let(JackCompiler.Identifier(\"y\", JackCompiler.IDENTIFIER), nothing, JackCompiler.Parsers.Term(JackCompiler.IntegerConstant(\"456\", JackCompiler.INT_CONST)))]), JackCompiler.Parsers.While(JackCompiler.Parsers.Term(JackCompiler.Keyword(\"true\", JackCompiler.TRUE)), Any[JackCompiler.Parsers.Let(JackCompiler.Identifier(\"abc\", JackCompiler.IDENTIFIER), nothing, JackCompiler.Parsers.Term(JackCompiler.Identifier(\"hogehoge\", JackCompiler.IDENTIFIER)))]), JackCompiler.Parsers.Let(JackCompiler.Identifier(\"x\", JackCompiler.IDENTIFIER), JackCompiler.Parsers.Term(JackCompiler.Identifier(\"i\", JackCompiler.IDENTIFIER)), JackCompiler.Parsers.Term(JackCompiler.IntegerConstant(\"1\", JackCompiler.INT_CONST))), JackCompiler.Parsers.Let(JackCompiler.Identifier(\"x\", JackCompiler.IDENTIFIER), nothing, JackCompiler.Parsers.Term(JackCompiler.Parsers._Array(JackCompiler.Identifier(\"arr\", JackCompiler.IDENTIFIER), JackCompiler.Parsers.Term(JackCompiler.IntegerConstant(\"10\", JackCompiler.INT_CONST))))), JackCompiler.Parsers.Let(JackCompiler.Identifier(\"y\", JackCompiler.IDENTIFIER), nothing, JackCompiler.Parsers.Term(JackCompiler.Parsers.Parenthesis(JackCompiler.Parsers.Term(JackCompiler.Parsers.UnaryOp(JackCompiler._Symbol(\"-\", JackCompiler.MINUS), JackCompiler.Parsers.Term(JackCompiler.IntegerConstant(\"2\", JackCompiler.INT_CONST))))))), JackCompiler.Parsers.Do(JackCompiler.Parsers.SubroutineCall(JackCompiler.Identifier(\"Output\", JackCompiler.IDENTIFIER), JackCompiler.Identifier(\"printInt\", JackCompiler.IDENTIFIER), Any[JackCompiler.Parsers.Term(JackCompiler.Identifier(\"x\", JackCompiler.IDENTIFIER))])), JackCompiler.Parsers.Do(JackCompiler.Parsers.SubroutineCall(JackCompiler.Identifier(\"Output\", JackCompiler.IDENTIFIER), JackCompiler.Identifier(\"printInt\", JackCompiler.IDENTIFIER), Any[JackCompiler.Parsers.Term(JackCompiler.Identifier(\"y\", JackCompiler.IDENTIFIER))])), JackCompiler.Parsers.Do(JackCompiler.Parsers.SubroutineCall(JackCompiler.Identifier(\"Output\", JackCompiler.IDENTIFIER), JackCompiler.Identifier(\"printString\", JackCompiler.IDENTIFIER), Any[JackCompiler.Parsers.Term(JackCompiler.StringConstant(\"Hello world\", JackCompiler.STRING_CONST))])), JackCompiler.Parsers.Return(JackCompiler.Parsers.Operator(JackCompiler._Symbol(\"+\", JackCompiler.PLUS), JackCompiler.Parsers.Term(JackCompiler.Identifier(\"x\", JackCompiler.IDENTIFIER)), JackCompiler.Parsers.Term(JackCompiler.IntegerConstant(\"10\", JackCompiler.INT_CONST))))]))]))"
    @test string(x.parse_tree) == expected
end
