(*
 * Comprehensive Test File for COOL Parser (PA2) - Valid Programs (good.cl)
 * Exercises EVERY legal syntactic construction defined by the Cool Grammar.
 *)

-- 1. Class without explicit inheritance (defaults to Object)
class EmptyClass {
};

-- 2. Class inheriting from another class
class Animal {
    name : String;
    age : Int <- 0;

    init(n : String, a : Int) : Animal {
        {
            name <- n;
            age <- a;
            self;
        }
    };

    speak() : String {
        "Sound"
    };
};

class Dog inherits Animal {
    breed : String <- "Golden Retriever";

    speak() : String {
        "Woof"
    };

    get_dog_info() : String {
        -- Testing dynamic dispatch and static dispatch
        let s_dispatch : String <- self@Animal.speak() in
            speak().concat(" (Parent said: ").concat(s_dispatch).concat(")")
    };
};

-- 3. Complex Class testing all expression types
class ComplexGrammarTest inherits IO {
    -- Attributes with and without initialization
    uninit_int : Int;
    init_int : Int <- 10 + 20 * 30 / 5 - 2;
    uninit_str : String;
    init_str : String <- "Initialized string";
    init_bool : Bool <- true;

    -- Methods with 0, 1, and multiple arguments
    no_args_method() : Int {
        42
    };

    one_arg_method(a : Int) : Int {
        ~a
    };

    multi_args_method(a : Int, b : String, c : Bool) : Object {
        {
            out_int(a);
            out_string(b);
            if c then out_string("True\n") else out_string("False\n") fi;
        }
    };

    -- Testing all expressions in full depth
    test_expressions() : Object {
        let
            a : Int <- 5,
            b : Int <- 10,
            c : Bool <- false,
            d : Object,
            res : Int
        in
            {
                -- Assignment
                a <- b <- 100;

                -- Arithmetic operators
                res <- ((a + b) * (b - a)) / 2;
                res <- ~res;

                -- Relational operators
                c <- a < b;
                c <- a <= b;
                c <- a = b;
                c <- not c;

                -- If-Then-Else-Fi
                if not (a < b) then
                    out_string("a >= b\n")
                else
                    out_string("a < b\n")
                fi;

                -- While-Loop-Pool
                while 0 < a loop
                    {
                        a <- a - 1;
                    }
                pool;

                -- Case-Of-Esac
                case d of
                    i : Int => out_string("Integer branch\n");
                    s : String => out_string(s);
                    b : Bool => if b then out_string("True\n") else out_string("False\n") fi;
                    o : Object => out_string("General Object branch\n");
                esac;

                -- New and Isvoid
                if isvoid d then
                    d <- new Object
                else
                    d
                fi;

                -- Nested and chained Let expressions
                let x : Int in
                    let y : Int <- x + 1, z : String <- "test" in
                        x <- y + z.length();

                -- Dispatch forms: self dispatch, object dispatch, static dispatch
                no_args_method();
                self.no_args_method();
                self@IO.out_string("Static dispatch called\n");

                -- Parenthesized expressions
                res <- (a + (b * (res - 1)));
            }
    };
};

-- 4. Main Class with entry point
class Main inherits IO {
    test : ComplexGrammarTest <- new ComplexGrammarTest;

    main() : Object {
        {
            out_string("All syntactic constructions parsed successfully!\n");
            test.test_expressions();
        }
    };
};

