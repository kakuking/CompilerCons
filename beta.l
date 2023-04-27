%{
    #include <stdio.h>
    #include "y.tab.h"
%}

%%
"int"           {/*printf("\n%s",yytext);*/return INT;}
"float"         {/*printf("\n%s",yytext);*/return FLOAT;}
"char"          {/*printf("\n%s",yytext);*/return CHAR;}
"if"            {/*printf("\n%s",yytext);*/return IF;}
"else"          {/*printf("\n%s",yytext);*/return ELSE;}
"for"           {/*printf("\n%s",yytext);*/return FOR;}
"while"         {/*printf("\n%s",yytext);*/return WHILE;}
"switch"        {/*printf("\n%s",yytext);*/return SWITCH;}
"case"          {/*printf("\n%s",yytext);*/return CASE;}
"default"       {/*printf("\n%s",yytext);*/return DEFAULT;}
"printf"        {/*printf("\n%s",yytext);*/return PRINTF;}
"scanf"         {/*printf("\n%s",yytext);*/return SCANF;}
[[:alpha:]_][[:alnum:]_]*   {/*printf("\n%s",yytext);*/yylval.id = strdup(yytext); return IDENTIFIER;}
[0-9]+          {/*printf("\n%s",yytext);*/yylval.num = atoi(yytext); return INTEGER;}
[0-9]*\.[0-9]+  {/*printf("\n%s",yytext);*/yylval.fnum = atof(yytext); return FLOATING;}
\"[^\n\"]*\"    {/*printf("\n%s",yytext);*/yylval.str = strdup(yytext); return STRING;}
\'[^\\\n]\'     {/*printf("\n%s",yytext);*/yylval.chr = yytext[1]; return CHARLIT;}
[\t]            {}
[ ]             {}
.               {/*printf("\n%s", yytext);*/return yytext[0];}

%%

int yywrap()    {
    return 1;
}

int main(int argc, char** argv){
    FILE *ipFile = fopen(argv[1], "r");
    if(!ipFile){
        fprintf(stderr, "Error in opening\n");
        exit(1);
    }

    yyin = ipFile;
    yyparse();

    fclose(ipFile);
    yylex_destroy();
    
    return 0;
}

