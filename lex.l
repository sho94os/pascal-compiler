%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "yacc.tab.h"
int line_no = 0;

// compile with C
extern "C"
{
    void commentError();
    int yywrap(void);
    int yylex(void);
}

%}

A [aA]
B [bB]
C [cC]
D [dD]
E [eE]
F [fF]
G [gG]
H [hH]
I [iI]
J [jJ]
K [kK]
L [lL]
M [mM]
N [nN]
O [oO]
P [pP]
Q [qQ]
R [rR]
S [sS]
T [tT]
U [uU]
V [vV]
W [wW]
X [xX]
Y [yY]
Z [zZ]
NQUOTE [^']

%%
"false" {yylval.syscon = SYS_CON_FALSE;return SYS_CON;}
"true" {yylval.syscon = SYS_CON_TRUE;return SYS_CON;}
"maxint" {yylval.syscon = SYS_CON_MAXINT;return SYS_CON;}

"abs" {yylval.sysFunc=SYS_FUNCT_ABS;return SYS_FUNCT;}
"chr" {yylval.sysFunc=SYS_FUNCT_CHR;return SYS_FUNCT;}
"odd" {yylval.sysFunc=SYS_FUNCT_ODD;return SYS_FUNCT;}
"ord" {yylval.sysFunc=SYS_FUNCT_ORD;return SYS_FUNCT;}
"pred" {yylval.sysFunc=SYS_FUNCT_PRED;return SYS_FUNCT;}
"sqr" {yylval.sysFunc=SYS_FUNCT_SQR;return SYS_FUNCT;}
"sqrt" {yylval.sysFunc=SYS_FUNCT_SQRT;return SYS_FUNCT;}
"succ" {yylval.sysFunc=SYS_FUNCT_SUCC;return SYS_FUNCT;}

"write" {yylval.sysProc=SYS_PROC_WRITE;return SYS_PROC;}
"writeln" {yylval.sysProc=SYS_PROC_WRITELN;return SYS_PROC;}


"boolean" {yylval.sysType = SYS_TYPE_BOOL;return SYS_TYPE;}
"char" {yylval.sysType = SYS_TYPE_CHAR;return SYS_TYPE;}
"integer" {yylval.sysType = SYS_TYPE_INTEGER;return SYS_TYPE;}
"real" {yylval.sysType = SYS_TYPE_REAL;return SYS_TYPE;}

{A}{N}{D} return AND;
{A}{R}{R}{A}{Y} return ARRAY;
{B}{E}{G}{I}{N} return PBEGIN;
{C}{A}{S}{E} return CASE;
{C}{O}{N}{S}{T} return CONST;
{D}{O} return DO;
{D}{O}{W}{N}{T}{O} return DOWNTO;
{E}{L}{S}{E} return ELSE;
{E}{N}{D} return END;
{F}{O}{R} return FOR;
{F}{U}{N}{C}{T}{I}{O}{N} return FUNCTION;
{G}{O}{T}{O} return GOTO;
{I}{F} return IF;
{M}{O}{D} return MOD;
{N}{O}{T} return NOT;
{O}{F} return OF;
{O}{R} return OR;
{P}{R}{O}{C}{E}{D}{U}{R}{E} return PROCEDURE;
{P}{R}{O}{G}{R}{A}{M} return PROGRAM;
{R}{E}{C}{O}{R}{D} return RECORD;
{R}{E}{P}{E}{A}{T} return REPEAT;
{T}{H}{E}{N} return THEN;
{T}{O} return TO;
{T}{Y}{P}{E} return TYPE;
{U}{N}{T}{I}{L} return UNTIL;
{V}{A}{R} return VAR;
{W}{H}{I}{L}{E} return WHILE;

[a-zA-Z]([a-zA-Z0-9_])* {
    yylval.sValue = (char*)malloc(strlen(yytext)+1);
    strcpy(yylval.sValue,yytext); 
    return ID;
}


'({NQUOTE}|'')({NQUOTE}|'')+' {
    char *p=(char*)malloc(strlen(yytext)+1);
    strcpy(p,yytext);
    yylval.sValue=p;
    return STRING;
}

'({NQUOTE}|'')' {
    yylval.cValue=yytext[1];
    return CHAR;
}

[0-9]+ {
    yylval.iValue=atoi(yytext);
    return INTEGER;
}

[0-9]+"\."[0-9]+ {
    yylval.rValue=atof(yytext);
    return REAL;
}


":=" return ASSIGN;
":" return COLON;
"," return COMMA;
"." return DOT;
".." return DOTDOT;
"=" return EQUAL;
">=" return GE;
">" return GT;
"[" return LB;
"<=" return LE;
"(" return LP;
"<" return LT;
"-" return MINUS;
"<>" return UNEQUAL;
"+" return PLUS;
"]" return RB;

")" return RP;
";" return SEMI;
"/" return DIV;
"*" return MUL;

"{" {
    register int c;
    while ((c = yyinput()))
    {
        if (c == '}')
            break;
        else if (c == '\n')
            line_no++;
        else if (c == -1)
            commentError();
    }
}

"(*" {
    register int c;
    while ((c = yyinput()))
    {
        if (c=='*')
        {
            if ((c = yyinput()) == ')')
                break;
            else
                unput (c);
        }
        else if (c == '\n')
            line_no++;
        else if(c == -1)
            commentError();
    }
}

[\t\f] {}

"\n" { line_no ++; }

" " {}

. { fprintf (stderr, "'%c' (0%o): illegal charcter at line %d\n",
              yytext[0], yytext[0], line_no); }
 
%%

void commentError()
{
    fprintf (stderr, "unexpected EOF inside comment at line %d\n",line_no);
    exit (1);
}

int yywrap ()
{
	std::cout<<"token finish(line: "<<line_no<<")"<<std::endl;
    return 1;
}