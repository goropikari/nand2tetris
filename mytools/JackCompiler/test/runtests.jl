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


@testset "CodeGenerator" begin
    program = """
        class Main {

    function void main() {
        var Array a, b, c;

        let a = Array.new(10);
        let b = Array.new(5);
        let c = Array.new(1);

        let a[3] = 2;
        let a[4] = 8;
        let a[5] = 4;
        let b[a[3]] = a[3] + 3;  // b[2] = 5
        let a[b[a[3]]] = a[a[5]] * b[((7 - a[3]) - Main.double(2)) + 1];  // a[5] = 8 * 5 = 40
        let c[0] = null;
        let c = c[0];

        do Output.printString("Test 1: expected result: 5; actual result: ");
        do Output.printInt(b[2]);
        do Output.println();
        do Output.printString("Test 2: expected result: 40; actual result: ");
        do Output.printInt(a[5]);
        do Output.println();
        do Output.printString("Test 3: expected result: 0; actual result: ");
        do Output.printInt(c);
        do Output.println();

        let c = null;

        if (c = null) {
            do Main.fill(a, 10);
            let c = a[3];
            let c[1] = 33;
            let c = a[7];
            let c[1] = 77;
            let b = a[3];
            let b[1] = b[1] + c[1];  // b[1] = 33 + 77 = 110;
        }

        do Output.printString("Test 4: expected result: 77; actual result: ");
        do Output.printInt(c[1]);
        do Output.println();
        do Output.printString("Test 5: expected result: 110; actual result: ");
        do Output.printInt(b[1]);
        do Output.println();
        return;
    }

    function int double(int a) {
    	return a * 2;
    }

    function void fill(Array a, int size) {
        while (size > 0) {
            let size = size - 1;
            let a[size] = Array.new(3);
        }
        return;
    }
}
    """

    expected = """
        function Main.main 3
        push constant 10
        call Array.new 1
        pop local 0
        push constant 5
        call Array.new 1
        pop local 1
        push constant 1
        call Array.new 1
        pop local 2
        push local 0
        push constant 3
        add
        push constant 2
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
        push local 0
        push constant 4
        add
        push constant 8
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
        push local 0
        push constant 5
        add
        push constant 4
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
        push local 1
        push constant 3
        push local 0
        add
        pop pointer 1
        push that 0
        add
        push constant 3
        push local 0
        add
        pop pointer 1
        push that 0
        push constant 3
        add
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
        push local 0
        push constant 3
        push local 0
        add
        pop pointer 1
        push that 0
        push local 1
        add
        pop pointer 1
        push that 0
        add
        push constant 5
        push local 0
        add
        pop pointer 1
        push that 0
        push local 0
        add
        pop pointer 1
        push that 0
        push constant 7
        push constant 3
        push local 0
        add
        pop pointer 1
        push that 0
        sub
        push constant 2
        call Main.double 1
        sub
        push constant 1
        add
        push local 1
        add
        pop pointer 1
        push that 0
        call Math.multiply 2
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
        push local 2
        push constant 0
        add
        push constant 0
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
        push constant 0
        push local 2
        add
        pop pointer 1
        push that 0
        pop local 2
        push constant 43
        call String.new 1
        push constant 84
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 49
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 120
        call String.appendChar 2
        push constant 112
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 99
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 100
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 114
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 53
        call String.appendChar 2
        push constant 59
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 97
        call String.appendChar 2
        push constant 99
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 97
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 114
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        call Output.printString 1
        pop temp 0
        push constant 2
        push local 1
        add
        pop pointer 1
        push that 0
        call Output.printInt 1
        pop temp 0
        call Output.println 0
        pop temp 0
        push constant 44
        call String.new 1
        push constant 84
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 50
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 120
        call String.appendChar 2
        push constant 112
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 99
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 100
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 114
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 52
        call String.appendChar 2
        push constant 48
        call String.appendChar 2
        push constant 59
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 97
        call String.appendChar 2
        push constant 99
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 97
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 114
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        call Output.printString 1
        pop temp 0
        push constant 5
        push local 0
        add
        pop pointer 1
        push that 0
        call Output.printInt 1
        pop temp 0
        call Output.println 0
        pop temp 0
        push constant 43
        call String.new 1
        push constant 84
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 51
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 120
        call String.appendChar 2
        push constant 112
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 99
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 100
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 114
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 48
        call String.appendChar 2
        push constant 59
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 97
        call String.appendChar 2
        push constant 99
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 97
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 114
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        call Output.printString 1
        pop temp 0
        push local 2
        call Output.printInt 1
        pop temp 0
        call Output.println 0
        pop temp 0
        push constant 0
        pop local 2
        push local 2
        push constant 0
        eq
        not
        if-goto END0
        push local 0
        push constant 10
        call Main.fill 2
        pop temp 0
        push constant 3
        push local 0
        add
        pop pointer 1
        push that 0
        pop local 2
        push local 2
        push constant 1
        add
        push constant 33
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
        push constant 7
        push local 0
        add
        pop pointer 1
        push that 0
        pop local 2
        push local 2
        push constant 1
        add
        push constant 77
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
        push constant 3
        push local 0
        add
        pop pointer 1
        push that 0
        pop local 1
        push local 1
        push constant 1
        add
        push constant 1
        push local 1
        add
        pop pointer 1
        push that 0
        push constant 1
        push local 2
        add
        pop pointer 1
        push that 0
        add
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
        label END0
        push constant 44
        call String.new 1
        push constant 84
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 52
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 120
        call String.appendChar 2
        push constant 112
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 99
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 100
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 114
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 55
        call String.appendChar 2
        push constant 55
        call String.appendChar 2
        push constant 59
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 97
        call String.appendChar 2
        push constant 99
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 97
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 114
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        call Output.printString 1
        pop temp 0
        push constant 1
        push local 2
        add
        pop pointer 1
        push that 0
        call Output.printInt 1
        pop temp 0
        call Output.println 0
        pop temp 0
        push constant 45
        call String.new 1
        push constant 84
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 53
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 120
        call String.appendChar 2
        push constant 112
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 99
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 100
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 114
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 49
        call String.appendChar 2
        push constant 49
        call String.appendChar 2
        push constant 48
        call String.appendChar 2
        push constant 59
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 97
        call String.appendChar 2
        push constant 99
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 97
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        push constant 114
        call String.appendChar 2
        push constant 101
        call String.appendChar 2
        push constant 115
        call String.appendChar 2
        push constant 117
        call String.appendChar 2
        push constant 108
        call String.appendChar 2
        push constant 116
        call String.appendChar 2
        push constant 58
        call String.appendChar 2
        push constant 32
        call String.appendChar 2
        call Output.printString 1
        pop temp 0
        push constant 1
        push local 1
        add
        pop pointer 1
        push that 0
        call Output.printInt 1
        pop temp 0
        call Output.println 0
        pop temp 0
        push constant 0
        return

        function Main.double 0
        push argument 0
        push constant 2
        call Math.multiply 2
        return

        function Main.fill 0
        label BEGIN1
        push argument 1
        push constant 0
        gt
        not
        if-goto END1
        push argument 1
        push constant 1
        sub
        pop argument 1
        push argument 0
        push argument 1
        add
        push constant 3
        call Array.new 1
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
        goto BEGIN1
        label END1
        push constant 0
        return
        """

    io = IOBuffer()
    JackCompiler.CodeGenerators._set_label_id(0)
    parser = JackCompiler.Parsers.program(program)
    codegen = JackCompiler.CodeGenerators.CodeGenerator(parser)
    JackCompiler.CodeGenerators.cgen(io, codegen)
    data = String(io.data)
    @test replace(replace(data, " " => ""), "\n" => "") == replace(replace(expected, " " => ""), "\n" => "")
end
