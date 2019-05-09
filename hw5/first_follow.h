#ifndef first_follow
#define first_follow
#include<stdio.h>
#include<string.h>
#include<assert.h>
#define MAXBUF 1000
#define MAX_NONTERMINALS 100
int NUM_NONTERMINALS;
#define MAX_TERMINALS 100
int NUM_TERMINALS;
#define MAX_PRODUCTIONS 100
#define MAX_RHS_LENGTH 100
#define VOCABULARY ((MAX_NONTERMINALS)+(MAX_TERMINALS))
int VOC_SIZE;
#define LAMBDA_INDEX (VOCABULARY)
typedef int symbol;
typedef struct prod{
        symbol lhs;
        int rhs_length;
        symbol rhs[MAX_RHS_LENGTH];
} production;
typedef struct gram{
    symbol terminals[MAX_TERMINALS];
    symbol nonterminals[MAX_NONTERMINALS];
    symbol start_symbol;
    int num_productions;
    production productions[MAX_PRODUCTIONS];
    symbol vocabulary[VOCABULARY];
} grammar;

typedef symbol terminal;
typedef symbol nonterminal;
typedef short boolean;
typedef boolean marked_vocabulary[VOCABULARY];
typedef struct termset_{
    // symbol value -> exists flag
    int set[VOCABULARY+1]; // terminal + lambda(index == VOCABULARY)
} termset;
termset follow_set[VOCABULARY];
termset first_set[VOCABULARY];

typedef struct Symbol_map_{
    char symbol2string[VOCABULARY][MAX_RHS_LENGTH];
    int is_terminal[VOCABULARY];
    int end_index;
}Symbol_map;
Symbol_map symbol_map = {.is_terminal = {0}, .end_index = 0};

// Input a str, check whether this string exists in symbol map table
short mapping_exists(char *str){
    // loop over symbol map to check whether exist
    int end_index = symbol_map.end_index;
    for(int i = 0; i < end_index; i++){
        if(strcmp(str, symbol_map.symbol2string[i]) == 0){
            return 1;
        }
    }
    return 0;
}
int map_insert(char *str){
    sprintf(symbol_map.symbol2string[symbol_map.end_index], "%s", str);
    // is terminal
    if(str[0] != '<') symbol_map.is_terminal[symbol_map.end_index] = 1;
    else symbol_map.is_terminal[symbol_map.end_index] = 0;
    symbol_map.end_index++;
    return symbol_map.end_index-1;
}
int map_find(char *str){
    int end_index = symbol_map.end_index;
    for(int i = 0; i < end_index; i++){
        if(strcmp(str, symbol_map.symbol2string[i]) == 0){
            return i;
        }
    }
    return -1;
}

int match_nonterminal(char *str, int length, int start_index, char *dest){
    int dest_index = 0;
    int end_index = 0;
    for(int i = start_index; i < length; i++){
        // find first <
        if(str[i] == '<'){
            for(int j = i; j < length; j++){
                dest[dest_index] = str[j];
                dest_index++;
                // search until >
                if(str[j] == '>'){
                    dest[dest_index] = '\0';
                    end_index = j;
                    break;
                }
            }
            break;
        }
    }
    return end_index;
}
int match_arrow(char *str, int length, int start_index){
    int end_index = 0;
    for(int i = start_index; i < length; i++){
        if(str[i] == '-'){
            end_index = i+1; // ->
            break;
        }
    }
    return end_index;
}
int match_token(char *str, int length, int start_index, char *dest){
    int dest_index = 0;
    int end_index = 0;
    for(int i = start_index; i < length; i++){
        // first non whitespace character
        if(str[i] != ' '){
            if(str[i] == '<'){
                end_index = match_nonterminal(str, length, i, dest);
            }else{ 
                // find until next whitespace or newline
                for(int j = i; j < length; j++){
                    if(str[j] == ' '){
                        dest[dest_index] = '\0';
                        end_index = j-1;
                        break;
                    }else if(str[j] == '\n'){
                        dest[dest_index] = '\0';
                        if(dest_index == 0) end_index = -1;
                        else end_index = j-1;
                        break;
                    }else{
                        dest[dest_index] = str[j];
                        dest_index++;
                    }
                }
            }
            break;
        }
    }
    return end_index;
}
// [*] Set 
void set_num_terminal_and_nonterminal_number_and_voc_size(){
    NUM_TERMINALS = 0;
    NUM_NONTERMINALS = 0;
    for(int i = 0; i < symbol_map.end_index; i++){
        if(symbol_map.is_terminal[i]){
            NUM_TERMINALS++;
        }else NUM_NONTERMINALS++;
    }
    VOC_SIZE = NUM_TERMINALS + NUM_NONTERMINALS;
}
void scan_grammars(grammar *g){
    char buf[MAXBUF];
    char substr_buf[MAXBUF];
    int g_terminal_index = 0;
    int g_nonterminal_index = 0;
    g->num_productions = 0;
    while(1){
        fgets(buf, MAXBUF, stdin);
        if(feof(stdin)) break;
        int length = strlen(buf);
        int end_index = match_nonterminal(buf, length, 0, substr_buf);
#ifdef DEBUG
        printf("%s|\n", substr_buf);
#endif
        
        if(mapping_exists(substr_buf) == 0){
            int tmp_index = map_insert(substr_buf);
            g->nonterminals[g_nonterminal_index] = tmp_index;
            g_nonterminal_index++;
            if(strcmp(substr_buf, "<system goal>") == 0){
                g->start_symbol = tmp_index;
            }
        }
        // add lhs
        g->productions[g->num_productions].lhs = map_find(substr_buf);
        // match arrow
        end_index = match_arrow(buf, length, end_index+1);
        
        // initialize g rhs_length
        int rhs_length = g->productions[g->num_productions].rhs_length = 0;
        // match until new line character
        while(1){
            end_index = match_token(buf, length, end_index+1, substr_buf);
            if(end_index == -1) break;
#ifdef DEBUG
            printf("%s|\n", substr_buf);
#endif
            if(mapping_exists(substr_buf) == 0){
                int tmp_index = map_insert(substr_buf);
                if(substr_buf[0] == '<'){
                    g->nonterminals[g_nonterminal_index] = tmp_index;
                    g_nonterminal_index++;
                }else{
                    g->terminals[g_terminal_index] = tmp_index;
                    g_terminal_index++;
                }
            }
            // add rhs symbol
            g->productions[g->num_productions].rhs[rhs_length++] = map_find(substr_buf);
        }
        g->productions[g->num_productions].rhs_length = rhs_length;
        g->num_productions++;
#ifdef DEBUG
        printf("===================\n");
#endif
    }
    // set vocabulary in grammar `g`
    for(int i = 0; i < symbol_map.end_index; i++){
        g->vocabulary[i] = i; // i is symbol(or say, index)
    }
    // [*] Set global variable given symbol_map
    set_num_terminal_and_nonterminal_number_and_voc_size();
    return;
}
void print_grammars(grammar *g){
    printf("Terminals:\n");
    for(int i = 0; i < NUM_TERMINALS; i++){
        printf("%d: |%s|, is_terminal: %d\n", i, symbol_map.symbol2string[g->terminals[i]], symbol_map.is_terminal[g->terminals[i]]);
    }
    printf("=====================\n");
    printf("Nonterminals:\n");
    for(int i = 0; i < NUM_NONTERMINALS; i++){
        printf("%d: |%s|, is_terminal: %d\n", i, symbol_map.symbol2string[g->nonterminals[i]], symbol_map.is_terminal[g->nonterminals[i]]);
    }
    printf("=====================\n");
    printf("Productions rules:\n");
    for(int i = 0; i < g->num_productions; i++){
        printf("|%s| -> ", symbol_map.symbol2string[g->productions[i].lhs]);
        int rhs_length = g->productions[i].rhs_length;
        for(int j = 0; j < rhs_length; j++){
            printf("|%s| ", symbol_map.symbol2string[g->productions[i].rhs[j]]);
        }
        printf("\n");
    }
}

boolean* mark_lambda(grammar *g){
    static marked_vocabulary derives_lambda;
    boolean changes;
    boolean rhs_derives_lambda;
    symbol v;
    production *p;
    for(v = 0; v < VOC_SIZE; v++){
        derives_lambda[v] = 0;
    }
    do{
        changes = 0;
        int num_productions = g->num_productions;
        for(int i = 0; i < num_productions; i++){
            p = &(g->productions[i]);
            if(!derives_lambda[p->lhs]){
                if(p->rhs_length == 0){
                    changes = derives_lambda[p->lhs] = 1;
                    continue;
                }
                rhs_derives_lambda = derives_lambda[p->rhs[0]];
                for(int j = 1; j < p->rhs_length; j++){
                    rhs_derives_lambda = rhs_derives_lambda && derives_lambda[p->rhs[j]];
                }
                if(rhs_derives_lambda){
                    changes = 1;
                    derives_lambda[p->lhs] = 1;
                }
            }
        }
    }while(changes);
    return derives_lambda;
}
void print_derives_lambda(marked_vocabulary derives_lambda){
    printf("Derives lambda:\n");
    for(int i = 0; i < VOC_SIZE; i++){
        printf("|%s|: %d\n", symbol_map.symbol2string[i], derives_lambda[i]);
    }
    printf("===============\n");
}

// return whether target is changed
boolean union_termset(termset *target, termset *src, short without_lambda){
    // target = target union src
    int end_index = (without_lambda)? (LAMBDA_INDEX):(LAMBDA_INDEX+1);
    boolean changed = 0;
    for(int i = 0; i < end_index; i++){
        if(target->set[i] == 0 && src->set[i] == 1){
            // union
            target->set[i] = 1;
            changed = 1;
        }
    }
    return changed;
}
termset compute_first(symbol alpha[], int length){
    int i;
    int k = length;
    termset result;
    memset(&result.set, 0, sizeof(result.set)); // = EMPTY() 
    if(k == 0) result.set[LAMBDA_INDEX] = 1; // SET_OF(lambda)
    else{
        result = first_set[alpha[0]];
        for(i = 1; i < k && first_set[alpha[i-1]].set[LAMBDA_INDEX] == 1; i++){
            union_termset(&result, &first_set[alpha[i]], 1);
        }
        if(i == k && first_set[alpha[k-1]].set[LAMBDA_INDEX] == 1) 
            result.set[LAMBDA_INDEX] = 1; // union over lambda
    }
    return result;
}
void fill_first_set(grammar *g, marked_vocabulary derives_lambda){
    nonterminal A;
    terminal a;
    production *p;
    boolean changes;
    for(int i = 0; i < NUM_NONTERMINALS; i++){
        A = g->nonterminals[i];
        assert(A < VOC_SIZE);
        memset(first_set[A].set, 0, sizeof(first_set[A].set)); //  = EMPTY()
        if(derives_lambda[A]) first_set[A].set[LAMBDA_INDEX] = 1; // = SET_OF( lambda )
    }
    for(int i = 0; i < NUM_TERMINALS; i++){
        a = g->terminals[i];
        assert(a < VOC_SIZE);
        memset(first_set[a].set, 0, sizeof(first_set[a].set));
        first_set[a].set[a] = 1; // SET_OF(a);
        for(int j = 0; j < NUM_NONTERMINALS; j++){
            A = g->nonterminals[j];
            // search over all production rules
            boolean exist_A_a_beta = 0;
            for(int k = 0; k < g->num_productions; k++){
                // A -> a \beta
                // [*] Be careful of rhs_length == 0 case, also note that this line might trigger short-circuit logic
                if(g->productions[k].rhs_length > 0 && g->productions[k].lhs == A && g->productions[k].rhs[0] == a){
                    exist_A_a_beta = 1;
                    break;
                }
            }
            if(exist_A_a_beta) first_set[A].set[a] = 1; // first_set[A] union SET_OF(a)
        }
    }
    do{
        changes = 0;
        for(int i = 0; i < g->num_productions; i++){
            p = &g->productions[i];
            termset res = compute_first(p->rhs, p->rhs_length);
            boolean first_set_changed = union_termset(&first_set[p->lhs], &res, 0);
            if(first_set_changed) changes = 1;
        }
    }while(changes);
}

void print_first_set(){
    printf("first_set:\n");
    for(int i = 0; i < VOC_SIZE; i++){
        if(symbol_map.is_terminal[i] == 1) continue;
        printf("|%s|:", symbol_map.symbol2string[i]);
        // set
        for(int j = 0; j < VOC_SIZE; j++){
            if(first_set[i].set[j] == 1)
                printf(" |%s|", symbol_map.symbol2string[j]);
        }
        // lambda
        if(first_set[i].set[LAMBDA_INDEX] == 1) printf(" |lambda|");
        printf("\n");
    }
    printf("======================\n");
}
// [*] WARNING: this function must be run after fill_first_set
void fill_follow_set(grammar *g){
    nonterminal A, B;
    symbol *beta;
    int beta_length;
    production *p;
    boolean changes;
    for(int i = 0; i < NUM_NONTERMINALS; i++){
        A = g->nonterminals[i];
        memset(follow_set[A].set, 0, sizeof(follow_set[A].set));
    }
    follow_set[g->start_symbol].set[LAMBDA_INDEX] = 1;
    do{
        changes = 0;
        int num_productions = g->num_productions;
        for(int i = 0; i < num_productions; i++){
            p = &(g->productions[i]);
            int rhs_length = p->rhs_length;
            for(int j = 0; j < rhs_length; j++){
                // search for A -> alpha B beta (where B is nonterminal symbol)
                if(symbol_map.is_terminal[p->rhs[j]] == 1) continue;
                A = p->lhs;
                B = p->rhs[j];
                boolean follow_set_B_changed = 0;
                beta = &(p->rhs[j]) + 1; // might be invalid address, but compute_first(?, length) will handle it
                beta_length = rhs_length - j - 1; // might be 0
                termset res = compute_first(beta, beta_length);
                follow_set_B_changed |= union_termset(&follow_set[B], &res, 1); // without_lambda flag is on
                if(res.set[LAMBDA_INDEX] == 1){
                    follow_set_B_changed |= union_termset(&follow_set[B], &follow_set[A], 0);
                }
                if(follow_set_B_changed) changes = 1; 
            }
        }

    }while(changes);
}
void print_follow_set(){
    printf("follow_set:\n");
    for(int i = 0; i < VOC_SIZE; i++){
        if(symbol_map.is_terminal[i] == 1) continue;
        printf("|%s|:", symbol_map.symbol2string[i]);
        // set
        for(int j = 0; j < VOC_SIZE; j++){
            if(follow_set[i].set[j] == 1)
                printf(" |%s|", symbol_map.symbol2string[j]);
        }
        // lambda
        if(follow_set[i].set[LAMBDA_INDEX] == 1) printf(" |lambda|");
        printf("\n");
    }
    printf("======================\n");
}
#endif
