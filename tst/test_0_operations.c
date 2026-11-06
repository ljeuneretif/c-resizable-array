#include <assert.h>
#include "preload_symbols.h"
#include "resizable_array.h"
#include "test_0_operations.h"



static const int VALUE1 = 5;
static const int VALUE2 = 9;



void init_free(void) {
	mock_start();

	resizable_array* ra = resizable_array_init();
	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void free_null(void) {
	resizable_array_free(NULL);
	LOG;
}



void push(void) {
	int c = 0;
	mock_start();

	resizable_array* ra = resizable_array_init();
	c = resizable_array_push(ra, VALUE1);
	assert(c == RESIZABLE_ARRAY_OK);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void pop(void) {
	int c = 0, v = 0;
	mock_start();

	resizable_array* ra = resizable_array_init();
	resizable_array_push(ra, VALUE1);

	c = resizable_array_pop(ra, &v);
	assert(c == RESIZABLE_ARRAY_OK);
	assert(v == VALUE1);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void pop_into_null(void) {
	int c = 0;
	mock_start();

	resizable_array* ra = resizable_array_init();
	resizable_array_push(ra, VALUE1);

	c = resizable_array_pop(ra, NULL);
	assert(c == RESIZABLE_ARRAY_OK);
	assert(ra->n == 0);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void pop_empty(void) {
	int c = 0;
	mock_start();

	resizable_array* ra = resizable_array_init();

	c = resizable_array_pop(ra, NULL);
	assert(c == RESIZABLE_ARRAY_EMPTY_ERROR);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void locate(void) {
	int* pvalue = NULL;
	mock_start();

	resizable_array* ra = resizable_array_init();
	resizable_array_push(ra, VALUE1);

	pvalue = resizable_array_locate(ra, 0);
	assert(*pvalue == VALUE1);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void locate_oob(void) {
	int* pvalue = NULL;
	mock_start();

	resizable_array* ra = resizable_array_init();
	resizable_array_push(ra, VALUE1);
	resizable_array_push(ra, VALUE2);

	pvalue = resizable_array_locate(ra, 2);
	assert(pvalue == NULL);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void push_locate_pop_32(void) {
	const int offset = 15;
	const int max = 32;

	int c, v, *pvalue;


	mock_start();

	resizable_array* ra = resizable_array_init();


	for (int i = 0; i < max; ++i) {
		c = resizable_array_push(ra, i+offset);
		assert(c == RESIZABLE_ARRAY_OK);
	}


	for (int i = 0; i < max; ++i) {
		pvalue = resizable_array_locate(ra, (size_t) i);
		assert(*pvalue == i+offset);
	}


	for (int i = 0; i < max; ++i) {
		v = 0;
		c = resizable_array_pop(ra, &v);
		assert(c == RESIZABLE_ARRAY_OK);
		assert(v == max - i - 1 + offset);
	}


	resizable_array_free(ra);

	assert_memory_ok();
	LOG;
}



void reuse_empty_ra(void) {
	int c = 0;
	mock_start();

	resizable_array* ra = resizable_array_init();
	resizable_array_push(ra, VALUE1);
	resizable_array_pop(ra, NULL);

	c = resizable_array_push(ra, VALUE2);
	assert(c == RESIZABLE_ARRAY_OK);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



int main(void) {
	init_free();
	free_null();
	push();
	pop();
	pop_into_null();
	pop_empty();
	locate();
	locate_oob();
	push_locate_pop_32();
	reuse_empty_ra();

	return 0;
}
