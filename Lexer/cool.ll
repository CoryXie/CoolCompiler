/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
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
 * This change makes it possible to use this scanner in
 * the Cool compiler.
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
 *  Add Your own definitions here
 */
%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
NEWLINE         \n
DOC_BEG         \(\*
DOC_END         \*\)
INT_NUM         [0-9]+         
ANY_CHAR        .
WHITESPACE      [ \t]
STRING          \"[a-zA-Z0-9]+\"
TYPE_ID         [A-Z][_a-zA-Z0-9]+
OBJECT_ID       [_a-z][_a-zA-Z0-9]+

/*
 * The keywords of cool are: class, else, false, fi, if, in, inherits, 
 * isvoid, let, loop, pool, then, while, case, esac, new, of, not, true. 
 * Except for the constants true and false, keywords are case insensitive.
 * To conform to the rules for other objects, the first letter of true 
 * and false must be lowercase; the trailing letters may be upper or lower 
 * case.
 */
KEYWORD_CLASS       [cC][lL][aA][sS][sS]
KEYWORD_ELSE        [eE][lL][sS][eE]
KEYWORD_FI          [fF][iI]
KEYWORD_IF          [iI][fF]
KEYWORD_IN          [iI][nN]
KEYWORD_INHERITS    [iI][nN][hH][eE][rR][iI][tT][sS]
KEYWORD_LET         [lL][eE][tT]
KEYWORD_LOOP        [lL][oO][oO][pP]
KEYWORD_POOL        [pP][oO][oO][lL]
KEYWORD_THEN        [tT][hH][eE][nN]
KEYWORD_WHILE       [wW][hH][iI][lL][eE]
KEYWORD_CASE        [cC][aA][sS][eE]
KEYWORD_ESAC        [eE][sS][aA][cC]
KEYWORD_OF          [oO][fF]
KEYWORD_NEW         [nN][eE][wW]
KEYWORD_ISVOID      [iI][sS][vV][oO][iI][dD]
KEYWORD_NOT         [nN][oO][tT]
KEYWORD_TRUE        [t][rR][uU][eE]
KEYWORD_FALSE       [f][aA][lL][sS][eE]

OP_ADD          +
OP_SUB          -
OP_MUL          *
OP_DIV          /

OP_LS           <
OP_LE           <=
OP_EQ           =

OP_ASSIGN       [<][-]
OP_REV          ~   /* The expression ~<expr> is the integer complement of <expr> */

OPERATOR        ['+']|['/']|['-']|['*']|['=']|['<']|['.']|['~']|[',']|[';']|[':']|['(']|[')']|['@']|['{']|['}']

/*
 * Define lexer states
 */
%x COMMENTS

%%

 /*
  *  Nested comments
  */


{DOC_BEG}           {
    BEGIN(COMMENTS); // start of a comment: go to a 'COMMENTS' state.
}
    
<COMMENTS>{DOC_END} {
    BEGIN(INITIAL);  // end of a comment: go back to normal parsing.
}
    
<COMMENTS>{NEWLINE} { 
    ++curr_lineno;  // still have to increment line numbers inside of comments!
}

<COMMENTS>{ANY_CHAR}    ;   // ignore every other character while we're in this state

{WHITESPACE}            ; /* skip whitespace */

 /*
  *  The multiple-character operators.
  */
{DARROW}		    { 
        return (DARROW); 
}

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
  
{KEYWORD_CLASS}     {
        return  CLASS;
}
  
{KEYWORD_ELSE}      {
        return  ELSE;
}

{KEYWORD_FI}        {
        return  FI;
}

{KEYWORD_IF}        {
        return  IF;
}   
   
{KEYWORD_IN}        {
        return  IN;
}
      
{KEYWORD_INHERITS}  {
        return  INHERITS;
}

{KEYWORD_LET}       {
        return  LET;
}

{KEYWORD_LOOP}      {
        return  LOOP;
}
 
{KEYWORD_POOL}      {
        return  POOL;
}  

{KEYWORD_THEN}      {
        return  THEN;
} 

{KEYWORD_WHILE}     {
        return  WHILE;
}

{KEYWORD_CASE}      {
        return  CASE;
}

{KEYWORD_ESAC}      {
        return  ESAC;
}

{KEYWORD_OF}        {
        return  OF;
}

{KEYWORD_NEW}       {
        return  NEW;
} 

{KEYWORD_ISVOID}    {
        return  ISVOID;
}

{KEYWORD_NOT}       {
        return  NOT;
}   

{KEYWORD_TRUE}      {
        cool_yylval.boolean = true;
        return BOOL_CONST;
}

{KEYWORD_FALSE}     {
        cool_yylval.boolean = false;
        return BOOL_CONST;
} 


{NEWLINE}           {
        ++curr_lineno; // increment line numbers!
}

{INT_NUM}           {
        cool_yylval.symbol = inttable.add_int(atoi(yytext));
        return INT_CONST;
}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

 {STRING}           {
        cool_yylval.symbol = stringtable.add_string(yytext);
        return STR_CONST;     
 }

 /*
  * Identifiers are strings (other than keywords) consisting of letters, 
  * digits, and the underscore character. Type identifiers begin with a 
  * capital letter. object identifiers begin with a lower case letter.
  */
 
 {TYPE_ID}          {
        cool_yylval.symbol = idtable.add_string(yytext);
        return TYPEID;       
 }
 
 {OBJECT_ID}        {
        cool_yylval.symbol = idtable.add_string(yytext);
        return OBJECTID;       
 }

 {OP_ASSIGN}        {
        return ASSIGN;
 } 
 
 {OPERATOR}         {
        return yytext[0];
 }
 
 
%%
