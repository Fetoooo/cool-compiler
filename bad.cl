(*
 * Test File for COOL Parser Error Handling and Recovery (bad.cl)
 * Tests parser recovery in all 4 required scenarios:
 * 1. Error in a class definition (recovers at next class).
 * 2. Error in a feature (recovers at next feature).
 * 3. Error in a let binding (recovers at next variable).
 * 4. Error in an expression inside a { ... } block (recovers at next expression).
 *)

-- ======================================================================
-- 1. Error in class definition:
-- Parser recovers at terminating ';' and restarts at the next valid class.
-- ======================================================================

class ErroneousClass1 inherits { (* Syntax error: missing parent class type identifier *)
    x : Int <- 1;
};

-- Next class should parse correctly:
class ValidClassAfterClassError1 {
    val : Int <- 10;
    get_val() : Int { val };
};

class ErroneousClass2 123 { (* Syntax error: invalid class identifier *)
    bad_syntax
};

-- Next class should parse correctly:
class ValidClassAfterClassError2 {
    str : String <- "Recovered successfully from class error";
};

-- ======================================================================
-- 2. Error in features within a class:
-- Parser recovers at ';' and continues to the next feature.
-- ======================================================================

class FeatureErrorRecoveryClass {
    -- Good attribute 1:
    attr1 : Int <- 1;

    -- Error in attribute definition (missing type):
    bad_attr1 : <- 10;

    -- Good attribute 2 (parser must successfully parse this):
    attr2 : String <- "Good attribute after error";

    -- Error in method definition (malformed formal parameter list):
    bad_method(x : , y : Int) : Int { 5 };

    -- Good method 1 (parser must successfully parse this):
    good_method1() : Int {
        attr1 + 10
    };

    -- Error in feature (random bad tokens terminated by semicolon):
    some_random_bad_token_sequence + * / ;

    -- Good method 2 (parser must successfully parse this):
    good_method2(msg : String) : Object {
        attr2 <- msg
    };
};

-- ======================================================================
-- 3. Error in a let binding:
-- Parser recovers at ',' and goes on to the next variable binding.
-- ======================================================================

class LetErrorRecoveryClass {
    test_let_recovery() : Int {
        let
            -- Valid first binding:
            a : Int <- 10,
            -- Malformed binding 1 (syntax error in declaration):
            bad_binding1 :,
            -- Valid middle binding:
            b : Int <- 20,
            -- Malformed binding 2 (missing type declaration):
            bad_binding2 <- 30,
            -- Valid final binding:
            c : Int <- 40
        in
            a + b + c
    };
};

-- ======================================================================
-- 4. Error in an expression inside a { ... } block:
-- Parser recovers at ';' and continues to the next expression in the block.
-- ======================================================================

class BlockErrorRecoveryClass {
    test_block_recovery() : Object {
        {
            -- Valid expression 1:
            1 + 1;

            -- Error in expression 1 (invalid binary operator syntax):
            2 + * 3;

            -- Valid expression 2 (parser recovers and parses this):
            4 + 5;

            -- Error in expression 2 (empty or malformed expression):
            ;

            -- Valid expression 3 (parser recovers and parses this):
            100;
        }
    };
};

-- Final valid class ensuring parser reaches completion:
class FinalValidClass {
    done : Bool <- true;
};

