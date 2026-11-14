(* 
 * Comprehensive Test File for COOL Lexical Analyzer (PA1)
 * Tests all tokens, edge cases, escape sequences, comments, and potential errors.
 *)

-- 1. Testing Single Line Comments
-- This is a standard single line comment.
-- The following line contains keywords inside a comment that should be ignored:
-- class Main inherits IO { out_string("ignored"); };

-- 2. Testing Multi-line & Nested Comments
(*
   Basic multi-line comment spanning multiple lines.
   Line 2 of comment.
*)

(* Nested comment level 1
   (* Nested comment level 2
      (* Nested comment level 3: inner most comment *)
      Back to level 2
   *)
   Back to level 1
*)

(* Comments containing symbols and strings:
   "-- not a single comment"
   "class", "if", "<=", "<-", "=>"
   * / + - ~ @ ( ) { } ; : , .
*)

-- 3. Testing Keywords (Case-Insensitive)
class CLASS Class cLaSs
else ELSE Else eLsE
fi FI Fi fI
if IF If iF
in IN In iN
inherits INHERITS Inherits
isvoid ISVOID IsVoid
let LET Let lEt
loop LOOP Loop
pool POOL Pool
then THEN Then
while WHILE While
case CASE Case
esac ESAC Esac
new NEW New
of OF Of
not NOT Not

-- 4. Testing Boolean Constants vs Identifiers
-- True booleans must begin with lowercase 't' or 'f'
true
false
tRuE
fAlSe
tRUe
fALsE

-- Capitalized True / False are TYPEID, NOT booleans!
True
False
TRUE_TYPE
FALSE_TYPE

-- 5. Testing Type Identifiers vs Object Identifiers
Object
IO
Int
String
Bool
SELF_TYPE
My_Class_123
A_Very_Long_Class_Identifier_With_Numbers_0123456789

self
x
y
z
a_variable_name
camelCaseName
under_score_var_123

-- 6. Testing Integer Constants
0
1
42
1234567890
000123

-- 7. Testing Operators and Punctuation
+
-
*
/
~
<
<=
=
<-
=>
:
;
,
.
@
(
)
{
}

-- 8. Testing String Constants and Escape Sequences
""
"Simple string"
"String with numbers 123456789 and punctuation !@#$%^&*()"
"String with escaped newline: line1\nline2"
"String with escaped tab:\ttabbed"
"String with escaped backspace:\bbackspaced"
"String with escaped formfeed:\fformfeed"
"String with escaped double quote: \"quoted\""
"String with escaped backslash: \\backslash\\"
"String with escaped zero: \0 -> should become character '0'"
"String with escaped characters: \a\b\c\d\e"

-- Multi-line string using escaped newline (valid COOL syntax)
"This is a \
valid multi-line \
string constant in COOL."

-- 9. Complete Realistic Cool Class Structure
class Main inherits IO {
    count : Int <- 0;
    flag : Bool <- true;
    message : String <- "Hello, Cool World!\n";

    main() : Object {
        let x : Int <- 10, y : Int <- 20 in
            if x <= y then
                while count < x loop
                    {
                        count <- count + 1;
                        out_string(message);
                    }
                pool
            else
                out_string("Condition false\n")
            fi
    };

    test_case(o : Object) : String {
        case o of
            i : Int => "Integer";
            s : String => s;
            b : Bool => if b then "True" else "False" fi;
            o : Object => "Unknown Object";
        esac
    };
};

