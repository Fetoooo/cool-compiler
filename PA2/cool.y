/*
 *  cool.y
 *              Parser definition for the COOL language.
 *
 */
%{
#include <iostream>
#include "cool-tree.h"
#include "stringtab.h"
#include "utilities.h"

extern char *curr_filename;

/* Locations */
#define YYLTYPE int              /* the type of locations */
#define cool_yylloc curr_lineno  /* use the curr_lineno from the lexer
                                    for the location of tokens */

extern int node_lineno;          /* set before constructing a tree node
                                    to whatever you want the line number
                                    for the tree node to be */

#define YYLLOC_DEFAULT(Current, Rhs, N)         \
  Current = Rhs[1];                             \
  node_lineno = Current;

#define SET_NODELOC(Current)  \
  node_lineno = Current;

void yyerror(char *s);        /*  defined below; called for each parse error */
extern int yylex();           /*  the entry point to the lexer  */

/************************************************************************/
/*                DONT CHANGE ANYTHING IN THIS SECTION                  */

Program ast_root;            /* the result of the parse  */
Classes parse_results;       /* for use in semantic analysis */
int omerrs = 0;              /* number of errors in compile */
%}

/* A union of all the types that can be the result of parsing actions. */
%union {
  Boolean boolean;
  Symbol symbol;
  Program program;
  Class_ class_;
  Classes classes;
  Feature feature;
  Features features;
  Formal formal;
  Formals formals;
  Case case_;
  Cases cases;
  Expression expression;
  Expressions expressions;
  char *error_msg;
}

/* 
   Declare the terminals; a token serves as both a way for the parser
   to recognize tokens and as a mechanism for the lexer to pass the
   associated value to the parser.
*/
%token CLASS 258 ELSE 259 FI 260 IF 261 IN 262 
%token INHERITS 263 LET 264 LOOP 265 POOL 266 THEN 267 WHILE 268
%token CASE 269 ESAC 270 OF 271 DARROW 272 NEW 273 ISVOID 274
%token <symbol>  STR_CONST 275 INT_CONST 276 
%token <boolean> BOOL_CONST 277
%token <symbol>  TYPEID 278 OBJECTID 279 
%token ASSIGN 280 NOT 281 LE 282 ERROR 283

/*  DON'T CHANGE ANYTHING ABOVE THIS LINE, OR YOUR PARSER WONT WORK       */
/**************************************************************************/

   /* Complete the nonterminal list, give a type to each and then
      declare them below. */

/* Declaring types for non-terminals */
%type <program> program
%type <classes> class_list
%type <class_> class
%type <features> feature_list
%type <feature> feature
%type <formals> formal_list
%type <formals> formal_list_nonempty
%type <formal> formal
%type <cases> case_list
%type <case_> case
%type <expression> expr
%type <expression> let_expr
%type <expressions> expr_block
%type <expressions> actual_list
%type <expressions> actual_list_nonempty

/* Precedence declarations */
%nonassoc LETPREC
%right ASSIGN
%nonassoc NOT
%nonassoc LE '<' '='
%left '+' '-'
%left '*' '/'
%nonassoc ISVOID
%nonassoc '~'
%nonassoc '@'
%nonassoc '.'

%%
/* 
   Save the root of the tree in the global variable ast_root.
*/
program
    : class_list
      { @$ = @1;
        ast_root = program($1); }
    ;

class_list
    : class
      { $$ = single_Classes($1);
        parse_results = $$; }
    | class_list class
      { $$ = append_Classes($1, single_Classes($2));
        parse_results = $$; }
    | class_list error ';'
      { $$ = $1; }
    | error ';'
      { $$ = nil_Classes(); }
    ;

/* If no parent is specified, the class inherits from the Object class. */
class
    : CLASS TYPEID '{' feature_list '}' ';'
      { $$ = class_($2, idtable.add_string("Object"), $4, stringtable.add_string(curr_filename)); }
    | CLASS TYPEID INHERITS TYPEID '{' feature_list '}' ';'
      { $$ = class_($2, $4, $6, stringtable.add_string(curr_filename)); }
    ;

/* Feature list may be empty, but no empty features in list. */
feature_list
    : /* empty */
      { $$ = nil_Features(); }
    | feature_list feature
      { $$ = append_Features($1, single_Features($2)); }
    | feature_list error ';'
      { $$ = $1; }
    ;

feature
    : OBJECTID '(' formal_list ')' ':' TYPEID '{' expr '}' ';'
      { $$ = method($1, $3, $6, $8); }
    | OBJECTID ':' TYPEID ';'
      { $$ = attr($1, $3, no_expr()); }
    | OBJECTID ':' TYPEID ASSIGN expr ';'
      { $$ = attr($1, $3, $5); }
    ;

formal_list
    : /* empty */
      { $$ = nil_Formals(); }
    | formal_list_nonempty
      { $$ = $1; }
    ;

formal_list_nonempty
    : formal
      { $$ = single_Formals($1); }
    | formal_list_nonempty ',' formal
      { $$ = append_Formals($1, single_Formals($3)); }
    ;

formal
    : OBJECTID ':' TYPEID
      { $$ = formal($1, $3); }
    ;

case_list
    : case
      { $$ = single_Cases($1); }
    | case_list case
      { $$ = append_Cases($1, single_Cases($2)); }
    ;

case
    : OBJECTID ':' TYPEID DARROW expr ';'
      { $$ = branch($1, $3, $5); }
    ;

actual_list
    : /* empty */
      { $$ = nil_Expressions(); }
    | actual_list_nonempty
      { $$ = $1; }
    ;

actual_list_nonempty
    : expr
      { $$ = single_Expressions($1); }
    | actual_list_nonempty ',' expr
      { $$ = append_Expressions($1, single_Expressions($3)); }
    ;

expr_block
    : expr ';'
      { $$ = single_Expressions($1); }
    | expr_block expr ';'
      { $$ = append_Expressions($1, single_Expressions($2)); }
    | expr_block error ';'
      { $$ = $1; }
    | error ';'
      { $$ = nil_Expressions(); }
    ;

let_expr
    : OBJECTID ':' TYPEID IN expr %prec LETPREC
      { $$ = let($1, $3, no_expr(), $5); }
    | OBJECTID ':' TYPEID ASSIGN expr IN expr %prec LETPREC
      { $$ = let($1, $3, $5, $7); }
    | OBJECTID ':' TYPEID ',' let_expr
      { $$ = let($1, $3, no_expr(), $5); }
    | OBJECTID ':' TYPEID ASSIGN expr ',' let_expr
      { $$ = let($1, $3, $5, $7); }
    | error ',' let_expr
      { $$ = $3; yyerrok; }
    ;

expr
    : OBJECTID ASSIGN expr
      { $$ = assign($1, $3); }
    | expr '@' TYPEID '.' OBJECTID '(' actual_list ')'
      { $$ = static_dispatch($1, $3, $5, $7); }
    | expr '.' OBJECTID '(' actual_list ')'
      { $$ = dispatch($1, $3, $5); }
    | OBJECTID '(' actual_list ')'
      { $$ = dispatch(object(idtable.add_string("self")), $1, $3); }
    | IF expr THEN expr ELSE expr FI
      { $$ = cond($2, $4, $6); }
    | WHILE expr LOOP expr POOL
      { $$ = loop($2, $4); }
    | '{' expr_block '}'
      { $$ = block($2); }
    | LET let_expr
      { $$ = $2; }
    | CASE expr OF case_list ESAC
      { $$ = typcase($2, $4); }
    | NEW TYPEID
      { $$ = new_($2); }
    | ISVOID expr
      { $$ = isvoid($2); }
    | expr '+' expr
      { $$ = plus($1, $3); }
    | expr '-' expr
      { $$ = sub($1, $3); }
    | expr '*' expr
      { $$ = mul($1, $3); }
    | expr '/' expr
      { $$ = divide($1, $3); }
    | '~' expr
      { $$ = neg($2); }
    | expr '<' expr
      { $$ = lt($1, $3); }
    | expr LE expr
      { $$ = leq($1, $3); }
    | expr '=' expr
      { $$ = eq($1, $3); }
    | NOT expr
      { $$ = comp($2); }
    | '(' expr ')'
      { $$ = $2; }
    | OBJECTID
      { $$ = object($1); }
    | INT_CONST
      { $$ = int_const($1); }
    | STR_CONST
      { $$ = string_const($1); }
    | BOOL_CONST
      { $$ = bool_const($1); }
    ;

%%

/* This function is called automatically when Bison detects a parse error. */
void yyerror(char *s)
{
  extern int curr_lineno;

  cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
       << s << " at or near ";
  print_cool_token(yychar);
  cerr << endl;
  omerrs++;

  if(omerrs>50) {fprintf(stdout, "More than 50 errors\n"); exit(1);}
}

