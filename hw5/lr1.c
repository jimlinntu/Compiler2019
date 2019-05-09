#include<stdio.h>
#include "first_follow.h"
typedef struct configuration{
    production p;
    int dot_pos; // [*] a dot is in front of p.rhs[dos_pos] (or say between p.rhs[dos_pos-1] and p.rhs[dos_pos])
    symbol lookahead; // [*] l in textbool
} config;
#define MAX_CONFIGURATION_SET 1000
typedef struct configuration_set_{
    config set[MAX_CONFIGURATION_SET];
    int end_index;
} configuration_set;

// [*] brute-force search to find whether there is an equal configuration in set
// TODO: Merge this function into `set_add`
boolean check_configuration_exist(configuration_set *s, config *new_conf){
    boolean has_same = 0;
    config *old_conf = NULL;
    for(int i = 0; i < s->end_index; i++){
        old_conf = &s->set[i];
        // if dos_pos is not the same, then it must not be the same
        if(old_conf->dot_pos != new_conf->dot_pos) continue; 
        // if lookahead is not the same, then it must not be the same
        if(old_conf->lookahead != new_conf->lookahead) continue;
        // check production is the same
        if(old_conf->p.lhs != new_conf->p.lhs) continue;
        if(old_conf->p.rhs_length != new_conf->p.rhs_length) continue;
        assert(old_conf->p.rhs_length == new_conf->p.rhs_length);
        boolean production_same = 1;
        for(int j = 0; j < old_conf->p.rhs_length; j++){
            // if there is one symbol that is not the same, then break
            if(old_conf->p.rhs[j] != new_conf->p.rhs[j]){
                production_same = 0;
                break;
            }
        }
        if(production_same == 0) continue;
        // if all things are same, then we are sure there exist a configuration that is same as new_conf
        has_same = 1;
        break;
    }
    return has_same;
}

void set_add(configuration_set *s, config *new_conf){
    s->set[s->end_index] = *new_conf; // deep copy
    s->end_index++; // increment end_index
}
int copy_symbol(symbol *dest, symbol *src, int src_start_idx, int src_end_idx){
    assert(src_start_idx <= src_end_idx);
    int length = 0;
    for(int i = src_start_idx; i < src_end_idx; i++){
        dest[length] = src[i];
        length++;
    }
    return length;
}
boolean loop_add_conf(grammar *g, configuration_set *s){
    // [*] loop over one time
    boolean changed = 0;
    int now_end_index = s->end_index;
    config *conf;
    symbol A;
    symbol rho_l[MAXBUF]; // \rho l 
    production *p;
    for(int i = 0; i < now_end_index; i++){
        conf = &s->set[i];
        // dot is in front of end( which means dot is at the end)
        assert(conf->dot_pos <= conf->p.rhs_length); // dot_pos should not exceed rhs_length
        if(conf->dot_pos == conf->p.rhs_length) continue;
        // check if the symbol after the dot is a nonterminal
        A = conf->p.rhs[conf->dot_pos]; // B -> \delta . A \rho
        if(symbol_map.is_terminal[A]) continue; // if it is a terminal, continue
        // Add configurations
        for(int j = 0; j < g->num_productions; j++){
            p = &g->productions[j];
            // A -> . \gamma
            if(p->lhs == A){
                // Copy \rho into a symbol array
                int length = copy_symbol(rho_l, conf->p.rhs, conf->dot_pos+1, conf->p.rhs_length);
                rho_l[length] = conf->lookahead;
                length++;
                termset u_set = compute_first(rho_l, length);
                config new_conf = {.p = *p, .dot_pos = 0, .lookahead = -1};
                // check whether u is in set
                for(int u = 0; u < VOC_SIZE; u++){
                    // exists
                    if(u_set.set[u] == 1){
                        new_conf.lookahead = u;
                        // if this configuration exists
                        if(check_configuration_exist(s, &new_conf) == 0){
                            changed = 1;
                            set_add(s, &new_conf);
                        }
                    }
                }
                if(u_set.set[LAMBDA_INDEX] == 1){
                    new_conf.lookahead = LAMBDA_INDEX;
                    // if this configuration exists
                    if(check_configuration_exist(s, &new_conf) == 0){
                        changed = 1;
                        set_add(s, &new_conf);
                    }
                }
            }
        }
    }
    return changed;
}

configuration_set closure1(grammar *g, configuration_set *s){
    configuration_set s_prime = *s;
    boolean changed = 0;
    do{
        // [*] Try to loop over each set element and add
        // if there is no change in this function, then we are done
        changed = 0;
        if(loop_add_conf(g, &s_prime)){
            changed = 1;
        }
    }while(changed);
    
    return s_prime;
}
configuration_set go_to1(grammar *g, configuration_set *s, symbol X){
    assert(X < VOC_SIZE);
    configuration_set s_b = {.end_index = 0};
    config c;
    for(int i = 0; i < s->end_index; i++){
        c = s->set[i];
        // A -> \beta . X \gamma, l
        if(c.dot_pos == c.p.rhs_length) continue; // reach the end, continue
        if(c.p.rhs[c.dot_pos] == X){
            // to preserve uniqueness of each element
            c.dot_pos++; // move forward: i.e. A -> \beta X . \gamma
            // only add when not exist
            if(check_configuration_exist(&s_b, &c) == 0) set_add(&s_b, &c);
        }
    }
    return closure1(g, &s_b);
}

void print_configuration_set(int number, configuration_set *s){
    printf("State: %d\n", number);
    config *conf;
    production *p;
    for(int i = 0; i < s->end_index; i++){
        conf = &s->set[i];
        p = &conf->p;
        printf("%s ->", symbol_map.symbol2string[p->lhs]);
        for(int j = 0; j < p->rhs_length; j++){
            if(j == conf->dot_pos) printf(" .");
            printf(" %s", symbol_map.symbol2string[p->rhs[j]]);
        }
        if(conf->lookahead == LAMBDA_INDEX) printf(", {|lambda|}\n");
        else printf(", {%s}\n", symbol_map.symbol2string[conf->lookahead]);
    }
}
int main(){
    grammar g;
    scan_grammars(&g);
    boolean *derives_lambda = mark_lambda(&g);
    fill_first_set(&g, derives_lambda);
    fill_follow_set(&g);
#ifdef DEBUG
    print_grammars(&g);
    print_derives_lambda(derives_lambda);
    print_first_set();
    print_follow_set();
#endif
    //
    config start_conf = { .p = g.productions[0], .dot_pos=0, .lookahead = LAMBDA_INDEX};
    configuration_set s = {.end_index = 0};
    set_add(&s, &start_conf);
    assert(s.end_index == 1);
    configuration_set s_0 = closure1(&g, &s);
    print_configuration_set(0, &s_0);
    char buf[MAXBUF] = "<E>";
    configuration_set s_1 = go_to1(&g, &s_0, map_find(buf));
    print_configuration_set(1, &s_1); 
    buf[0] = '+';
    buf[1] = '\0';
    configuration_set s_3 = go_to1(&g, &s_1, map_find(buf));
    print_configuration_set(3, &s_3);
    return 0;
}
