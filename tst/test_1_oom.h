#ifndef RESIZABLE_ARRAY_TEST_1_OOM_H
#define RESIZABLE_ARRAY_TEST_1_OOM_H


void init_failed_malloc(void);

void push_failed_empty_index_realloc(void);
void push_failed_index_realloc(void);

void push_failed_empty_datablock_calloc(void);
void push_failed_datablock_calloc(void);

void pop_failed_index_realloc(void);

int main(void);


#endif // #ifndef RESIZABLE_ARRAY_TEST_1_OOM_H