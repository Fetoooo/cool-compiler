# CS 143 Compilers - COOL Compiler Project
## Programming Assignment I (PA1) & Programming Assignment II (PA2)

This repository contains the complete implementation for **PA1 (Lexical Analysis)** and **PA2 (Syntax Analysis / Parsing)** for the COOL (Classroom Object-Oriented Language) compiler.

---

## 📁 Project Directory Structure

```text
Assignment 1 - Compiler/
├── PA1/                                 # Programming Assignment 1 (Lexer)
│   ├── cool.flex                        # Complete Lexical Specification (Flex)
│   ├── test.cl                          # Comprehensive Lexer Test File
│   └── README                           # PA1 submission documentation
├── PA2/                                 # Programming Assignment 2 (Parser)
│   ├── cool.y                           # Complete Bison Parser Specification & AST Construction
│   ├── good.cl                          # Valid COOL programs testing all grammar rules
│   ├── bad.cl                           # Tests 4 mandatory error recovery mechanisms
│   └── README                           # PA2 submission documentation
├── cool.flex                            # Root copy for direct PA1 build
├── test.cl                              # Root copy for direct PA1 testing
├── cool.y                               # Root copy for direct PA2 build
├── good.cl                              # Root copy for direct PA2 testing
├── bad.cl                               # Root copy for direct PA2 testing
└── README.md                            # Main project guide
```

---

## PA1: Lexical Analysis (`cool.flex`)

### Files:
- **`cool.flex`**: Defines regular expressions and actions for all COOL tokens:
  - **Keywords**: Case-insensitive (e.g., `CLASS`, `IF`, `THEN`, `ELSE`, `FI`, `WHILE`, etc.).
  - **Booleans**: `true` / `false` must start with lowercase `t` / `f` (capitalized `True` / `False` are `TYPEID`).
  - **Identifiers**: `TYPEID` starts with uppercase `[A-Z]`; `OBJECTID` starts with lowercase `[a-z]`.
  - **Strings**:
    - Maximum length of 1024 characters (`MAX_STR_CONST = 1025`). Overlong strings report `"String constant too long"`.
    - Escape sequences: `\b`, `\t`, `\n`, `\f`, `\\`, `\"`, `\c`.
    - `\0` (backslash zero) converts to the character `'0'` (ASCII 48).
    - Literal null byte (`\0`) triggers `"String contains null character"`.
    - Unescaped newline triggers `"Unterminated string constant"`.
    - EOF inside string triggers `"EOF in string constant"`.
    - Line number (`curr_lineno`) is properly updated on newlines (including escaped `\\n`).
  - **Comments**:
    - Single-line `-- ...`
    - Multi-line nested `(* ... (* ... *) ... *)` with depth tracking.
    - Unmatched `*)` outside a comment reports `"Unmatched *)"`.
    - EOF in comment reports `"EOF in comment"`.
  - **Single & Compound Operators**: `=>`, `<-`, `<=`, `+`, `-`, `*`, `/`, `~`, `<`, `=`, `.`, `@`, `;`, `:`, `,`, `{`, `}`, `(`, `)`.
  - **Invalid Characters**: Catch-all `.` returns `ERROR` with the unrecognized character.
- **`test.cl`**: Complete suite testing keywords, case sensitivity, identifier precedence, booleans, escape sequences, comments, and realistic COOL classes.

### Building & Testing PA1:
```bash
# Build the lexer
make lexer

# Test the lexer on test.cl
./lexer test.cl

# Compare with reference lexer
/afs/ir/class/cs143/bin/lexer test.cl
```

---

## PA2: Syntax Analysis & AST Construction (`cool.y`)

### Files:
- **`cool.y`**: GNU Bison grammar specification implementing:
  - Full AST construction using Cool tree constructors (`program`, `class_`, `method`, `attr`, `assign`, `dispatch`, `static_dispatch`, `cond`, `loop`, `block`, `let`, `typcase`, `branch`, arithmetic, comparison, and literals).
  - Proper resolution of the "Let-in" ambiguity using `%prec LETPREC` where `LETPREC` has lowest precedence, ensuring `let` expressions extend as far to the right as possible.
  - Complete error recovery using Bison's `error` token:
    1. **Class level**: Recovers at `;` and restarts at the next valid class.
    2. **Feature level**: Recovers at `;` and continues to the next feature.
    3. **Let binding level**: Recovers at `,` and continues to the next variable declaration.
    4. **Block level**: Recovers at `;` and continues to the next expression in `{ ... }`.
- **`good.cl`**: Exercises every single legal grammatical construct defined in the Cool Reference Manual.
- **`bad.cl`**: Exercises and verifies the 4 error recovery requirements.

### Building & Testing PA2:
```bash
# Build the parser
make parser

# Run your parser (with reference or your own lexer)
./myparser good.cl
./myparser bad.cl

# Compare output with the reference parser
/afs/ir/class/cs143/bin/parser good.cl
```

---

## 📤 Submission Instructions

1. Verify that there are no remaining debug print statements.
2. Run the submission script from your project directory:
   ```bash
   make submit
   ```

