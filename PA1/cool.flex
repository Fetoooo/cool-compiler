/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 *  to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This used to be defined in the skeleton, but we duplicate it
 * here in case the skeleton does not define it.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add any additional declarations here:
 */
static int comment_depth = 0;
%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
ASSIGN          <-
LE              <=
DIGIT           [0-9]
INT_CONST       [0-9]+

/*
 * Exclusive start conditions:
 * COMMENT      - inside nested (* ... *) comments
 * STRING       - inside a string constant " ... "
 * STRING_ERROR - inside a string constant after an error has occurred
 */
%x COMMENT
%x STRING
%x STRING_ERROR

%%

 /*
  * Define Cool lexical rules below.
  */

 /*
  *  Comments
  */

 /* Single-line comment: ignores everything until newline */
"--".*                  { /* skip single-line comments */ }

 /* Multi-line nested comments */
"(*"                    {
                            comment_depth = 1;
                            BEGIN(COMMENT);
                        }

"*)"                    {
                            cool_yylval.error_msg = "Unmatched *)";
                            return (ERROR);
                        }

<COMMENT>"(*"           {
                            comment_depth++;
                        }

<COMMENT>"*)"           {
                            comment_depth--;
                            if (comment_depth == 0) {
                                BEGIN(INITIAL);
                            }
                        }

<COMMENT>\n             {
                            curr_lineno++;
                        }

<COMMENT>.              {
                            /* ignore any non-newline character inside comments */
                        }

<COMMENT><<EOF>>        {
                            cool_yylval.error_msg = "EOF in comment";
                            BEGIN(INITIAL);
                            return (ERROR);
                        }

 /*
  *  Keywords (Case-insensitive, except true/false which start with lowercase)
  */

[cC][lL][aA][sS][sS]                    { return (CLASS); }
[eE][lL][sS][eE]                        { return (ELSE); }
[fF][iI]                                { return (FI); }
[iI][fF]                                { return (IF); }
[iI][nN]                                { return (IN); }
[iI][nN][hH][eE][rR][iI][tT][sS]        { return (INHERITS); }
[iI][sS][vV][oO][iI][dD]                { return (ISVOID); }
[lL][eE][tT]                            { return (LET); }
[lL][oO][oO][pP]                        { return (LOOP); }
[pP][oO][oO][lL]                        { return (POOL); }
[tT][hH][eE][nN]                        { return (THEN); }
[wW][hH][iI][lL][eE]                    { return (WHILE); }
[cC][aA][sS][eE]                        { return (CASE); }
[eE][sS][aA][cC]                        { return (ESAC); }
[nN][eE][wW]                            { return (NEW); }
[oO][fF]                                { return (OF); }
[nN][oO][tT]                            { return (NOT); }

 /*
  *  Boolean Constants
  *  Must begin with lowercase 't' or 'f'; remaining letters are case-insensitive.
  */

t[rR][uU][eE]           {
                            cool_yylval.boolean = 1;
                            return (BOOL_CONST);
                        }

f[aA][lL][sS][eE]       {
                            cool_yylval.boolean = 0;
                            return (BOOL_CONST);
                        }

 /*
  *  Identifiers
  */

 /* Type identifiers begin with an uppercase letter */
[A-Z][a-zA-Z0-9_]*      {
                            cool_yylval.symbol = idtable.add_string(yytext);
                            return (TYPEID);
                        }

 /* Object identifiers begin with a lowercase letter */
[a-z][a-zA-Z0-9_]*      {
                            cool_yylval.symbol = idtable.add_string(yytext);
                            return (OBJECTID);
                        }

 /*
  *  Integer Constants
  */

{INT_CONST}             {
                            cool_yylval.symbol = inttable.add_string(yytext);
                            return (INT_CONST);
                        }

 /*
  *  Compound Operators
  */

{DARROW}                { return (DARROW); }
{ASSIGN}                { return (ASSIGN); }
{LE}                    { return (LE); }

 /*
  *  Single-Character Operators and Punctuation
  */

"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"~"                     { return '~'; }
"<"                     { return '<'; }
"="                     { return '='; }
"."                     { return '.'; }
"@"                     { return '@'; }
";"                     { return ';'; }
":"                     { return ':'; }
","                     { return ','; }
"{"                     { return '{'; }
"}"                     { return '}'; }
"("                     { return '('; }
")"                     { return ')'; }

 /*
  *  White Space and Newlines
  */

\n                      {
                            curr_lineno++;
                        }

[ \t\r\f\v]+            {
                            /* ignore whitespace */
                        }

 /*
  *  String Constants
  */

\"                      {
                            string_buf_ptr = string_buf;
                            BEGIN(STRING);
                        }

<STRING>\"              {
                            BEGIN(INITIAL);
                            *string_buf_ptr = '\0';
                            cool_yylval.symbol = stringtable.add_string(string_buf);
                            return (STR_CONST);
                        }

<STRING>\n              {
                            curr_lineno++;
                            cool_yylval.error_msg = "Unterminated string constant";
                            BEGIN(INITIAL);
                            return (ERROR);
                        }

<STRING>\0              {
                            cool_yylval.error_msg = "String contains null character";
                            BEGIN(STRING_ERROR);
                            return (ERROR);
                        }

<STRING>\\\n            {
                            curr_lineno++;
                            if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) {
                                cool_yylval.error_msg = "String constant too long";
                                BEGIN(STRING_ERROR);
                                return (ERROR);
                            }
                            *string_buf_ptr++ = '\n';
                        }

<STRING>\\b             {
                            if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) {
                                cool_yylval.error_msg = "String constant too long";
                                BEGIN(STRING_ERROR);
                                return (ERROR);
                            }
                            *string_buf_ptr++ = '\b';
                        }

<STRING>\\t             {
                            if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) {
                                cool_yylval.error_msg = "String constant too long";
                                BEGIN(STRING_ERROR);
                                return (ERROR);
                            }
                            *string_buf_ptr++ = '\t';
                        }

<STRING>\\n             {
                            if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) {
                                cool_yylval.error_msg = "String constant too long";
                                BEGIN(STRING_ERROR);
                                return (ERROR);
                            }
                            *string_buf_ptr++ = '\n';
                        }

<STRING>\\f             {
                            if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) {
                                cool_yylval.error_msg = "String constant too long";
                                BEGIN(STRING_ERROR);
                                return (ERROR);
                            }
                            *string_buf_ptr++ = '\f';
                        }

<STRING>\\0             {
                            /* Sequence \0 is converted to the character '0' (ASCII 48) */
                            if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) {
                                cool_yylval.error_msg = "String constant too long";
                                BEGIN(STRING_ERROR);
                                return (ERROR);
                            }
                            *string_buf_ptr++ = '0';
                        }

<STRING>\\.             {
                            if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) {
                                cool_yylval.error_msg = "String constant too long";
                                BEGIN(STRING_ERROR);
                                return (ERROR);
                            }
                            *string_buf_ptr++ = yytext[1];
                        }

<STRING>[^\\\"\n\0]+     {
                            char *p = yytext;
                            while (*p) {
                                if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) {
                                    cool_yylval.error_msg = "String constant too long";
                                    BEGIN(STRING_ERROR);
                                    return (ERROR);
                                }
                                *string_buf_ptr++ = *p++;
                            }
                        }

<STRING><<EOF>>         {
                            cool_yylval.error_msg = "EOF in string constant";
                            BEGIN(INITIAL);
                            return (ERROR);
                        }

 /*
  *  String Error Handling State
  *  Consumes remainder of invalid string until closing quote or unescaped newline.
  */

<STRING_ERROR>\"        {
                            BEGIN(INITIAL);
                        }

<STRING_ERROR>\n        {
                            curr_lineno++;
                            BEGIN(INITIAL);
                        }

<STRING_ERROR>\\\n      {
                            curr_lineno++;
                        }

<STRING_ERROR>\\.       {
                            /* consume escaped character */
                        }

<STRING_ERROR>.         {
                            /* consume regular characters */
                        }

<STRING_ERROR><<EOF>>   {
                            BEGIN(INITIAL);
                        }

 /*
  *  Catch-all for invalid characters
  */

.                       {
                            cool_yylval.error_msg = yytext;
                            return (ERROR);
                        }

%%

