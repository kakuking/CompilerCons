%{
    #include "y.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define MAX_TOKEN_L 256
    #define HASH_TABLE_SIZE 100

    struct symbol{
        char name[MAX_TOKEN_L];
        int type;
    };

    struct hash_table{
        struct symbol *table[HASH_TABLE_SIZE];
    };

    struct hash_table symbol_table;
    
    int hash(char* str){
        int hash = 5381;
        int c;

        while((c=*str++)){
            hash = ((hash << 5) + hash) + c;
        }

        return hash % HASH_TABLE_SIZE;
    }

    void insertSymbol(char *name, int type){
        int index = hash(name);
        // printf("\nIndex: %d", index);

        if(symbol_table.table[index] == NULL){
            // printf("\nGoin to table");
            symbol_table.table[index] = (struct symbol *) malloc(sizeof(struct symbol));
            strcpy(symbol_table.table[index]->name, name);
            symbol_table.table[index]->type = type;
        }
    }

    int getSymbolType(char* name){
        int idx = hash(name);
        if(symbol_table.table[idx] != NULL && strcmp(symbol_table.table[idx]->name, name) == 0){
            return symbol_table.table[idx]->type;
        }

        return -1;
    }

    int count_format_specifiers(char *text) {
    // count the number of %d, %c, and %f specifiers in the text
        int count = 0;
        while (*text) {
            if (*text == '%') {
                text++;
                if (*text == 'd' || *text == 'c' || *text == 'f') {
                    count++;
                }
            }
            text++;
        }
        return count;
    }

    int count_variables(char *vars) {
        // count the number of variables in the list
        int count = 0;
        char *tok = strtok(vars, ",");
        while (tok) {
            count++;
            tok = strtok(NULL, ",");
        }
        return count;
    }

    int invalidPrint = 0;
    int invalidScan = 0;

    int inPrint = 0, inScan = 0;
    int varsInPrint = 0, varsProv = 0;
%}  


%%
    
(("int")|("float")|("char"))  {
    // printf("\nData Type");
    insertSymbol(yytext, 0);
    if(strcmp(yytext, "int") == 0)
        return INT;
    if(strcmp(yytext, "float") == 0)
        return FLOAT;
    if(strcmp(yytext, "char") == 0)
        return CHAR;
}


"printf"|"scanf"    {
    if(inPrint == 0)
        inPrint++;

    if(strcmp(yytext, "printf") == 0)
        return PRINTF;
    return SCANF;
}

"if"    {
    return IF;
}

"else"  {
    return ELSE;
}

"for"   {
    return FOR;
}

"while" {
    return WHILE;
}

"switch"    {
    return SWITCH;
}

"case"  {
    return CASE;
}

"default" {
    return DEFAULT;
}

"\""    {

    //for printf or scanf
    if(inPrint == 2){
        inPrint = 3;
        // printf("mode 3");
    }else if(inPrint == 3){
        inPrint ++;
        // printf("mode 4");
    }

        
    
}

"%d"|"%c"|"%f" {
    //For printf or scanf
    if(inPrint == 3){
        // printf(" varsInPrint  ");
        varsInPrint++;
    }
}

&?[a-zA-Z_][a-zA-Z0-9_]*  {
    // printf("\nIdentifier");
    int type = getSymbolType(yytext);
    if(inPrint == 4){
        // printf(" varsProv  ");
        varsProv ++;
    }
    if(type == -1){
        // printf(" inserting");
        insertSymbol(yytext, 1);    //Means identifier
    }
    if(type == 2)
        printf("\nInvalid identifier %s\n", yytext);
}

[0-9]+ {
    // printf("\nNumber");
    // yylval = atoi(yytext);
    insertSymbol(yytext, 3);
}

"+"|"-"|"/"|"*"|"="|"=="|"<"|">"|"<="|">="|"!="|"&&"|"||" {
    // printf("\noperator");
    insertSymbol(yytext, 4);
}

";"|"{"|"}"|"("|")"|"," {
    // for printf or scanf
    if(yytext[0] == '(' && inPrint == 1){
        // printf("mode 2");
        inPrint = 2;
    }
    if(yytext[0] == ')' && inPrint == 4){
        if(varsProv != varsInPrint){
            printf("Invalid print or scan statement");
        }
        // printf("reset");
        varsProv = 0;
        inPrint = 0;
        varsInPrint = 0;
    }


    insertSymbol(yytext, 5);
}

. {}
%%

int yywrap(){}

int main(){
        for(int i = 0; i < HASH_TABLE_SIZE; i++)
            symbol_table.table[i] = NULL;
        
        FILE *fp = fopen("input.txt", "r");

        yyin = fp;
        yylex();
        fclose(fp);

        // for(int i = 0; i < HASH_TABLE_SIZE; i++){
        //     if(symbol_table.table[i] != NULL){
        //         printf("\n%s: %d", symbol_table.table[i]->name, symbol_table.table[i]->type);
        //     }
        // }

        return 0;
}
