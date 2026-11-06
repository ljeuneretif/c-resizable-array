#ifndef RESIZABLE_ARRAY_MOCK_SYMBOLS_H
#define RESIZABLE_ARRAY_MOCK_SYMBOLS_H


#include <dlfcn.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>


#define MOCK_SYMBOLS_LIST \
	X(void, mock_start, (void)) \
	X(void, mock_malloc_fail_in, (unsigned int)) \
	X(void, mock_malloc_no_fail, (void)) \
	X(void, mock_calloc_fail_in, (unsigned int i)) \
	X(void, mock_calloc_no_fail, (void)) \
	X(void, mock_realloc_fail_in, (unsigned int i)) \
	X(void, mock_realloc_no_fail, (void)) \
	X(void, assert_memory_ok, (void))


// Declare each mock symbol as a top-level variable.
#define X(type, name, args) __attribute__((unused)) static type (*name) args = NULL;
MOCK_SYMBOLS_LIST
#undef X


// Before execution of main(), the symbols are loaded from libmock.so which is in LD_PRELOAD.
__attribute__((constructor))
static void mock_symbols_init(void) {
#define X(type, name, args) *((void* *)(&name)) = dlsym(RTLD_DEFAULT, #name);
	MOCK_SYMBOLS_LIST
#undef X
}


#define LOG do { \
	printf("%s OK.\n", __func__); \
} while(0)


#endif // #ifndef RESIZABLE_ARRAY_MOCK_SYMBOLS_H