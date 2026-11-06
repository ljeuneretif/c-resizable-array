#ifndef RESIZABLE_ARRAY_TEST_MOCK_MEMORY_H
#define RESIZABLE_ARRAY_TEST_MOCK_MEMORY_H


#include <stddef.h>


// Manage the behaviour of the mocked allocators.
void mock_start(void);

void mock_malloc_fail_in(unsigned int);
void mock_malloc_no_fail(void);

void mock_calloc_fail_in(unsigned int);
void mock_calloc_no_fail(void);

void mock_realloc_fail_in(unsigned int);
void mock_realloc_no_fail(void);


// The mocked allocators.
void* malloc(size_t);
void* calloc(size_t, size_t);
void* realloc(void*, size_t);
void free(void*);


// Assert no memory error.
void assert_memory_ok(void);


#endif // #ifndef RESIZABLE_ARRAY_TEST_MOCK_MEMORY_H