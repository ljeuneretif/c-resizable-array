#include <assert.h>
#include "preload_symbols.h"
#include "resizable_array.h"



static const int VALUE1 = 5;
static const int VALUE2 = 9;



static void init_free(void) {
	mock_start();

	resizable_array* ra = resizable_array_init();
	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



static void free_null(void) {
	resizable_array_free(NULL);
	LOG;
}



static void push(void) {
	int c = 0;
	mock_start();

	resizable_array* ra = resizable_array_init();
	c = resizable_array_push(ra, VALUE1);
	assert(c == RESIZABLE_ARRAY_OK);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



static void push_null(void) {
	int c = 0;

	c = resizable_array_push(NULL, VALUE1);
	assert(c == RESIZABLE_ARRAY_NULL_RA_ERROR);

	LOG;
}



static void pop(void) {
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



static void pop_null_arg(void) {
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



static void pop_empty(void) {
	int c = 0;
	mock_start();

	resizable_array* ra = resizable_array_init();

	c = resizable_array_pop(ra, NULL);
	assert(c == RESIZABLE_ARRAY_EMPTY_ERROR);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



static void pop_null_ra(void) {
	int c = 0, v = 0;

	c = resizable_array_pop(NULL, &v);
	assert(c == RESIZABLE_ARRAY_NULL_RA_ERROR);
	assert(v == 0);

	LOG;
}



static void locate(void) {
	int c = 0, *pv = NULL;
	mock_start();

	resizable_array* ra = resizable_array_init();
	resizable_array_push(ra, VALUE1);

	c = resizable_array_locate(ra, 0, &pv);
	assert(c == RESIZABLE_ARRAY_OK);
	assert(*pv == VALUE1);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



static void locate_null_ra(void) {
	int c = 0, *pv = NULL;

	c = resizable_array_locate(NULL, 0, &pv);
	assert(c == RESIZABLE_ARRAY_NULL_RA_ERROR);
	assert(pv == NULL);

	LOG;
}



static void locate_null_arg(void) {
	int c = 0;
	mock_start();

	resizable_array* ra = resizable_array_init();
	resizable_array_push(ra, VALUE1);

	c = resizable_array_locate(ra, 0, NULL);
	assert(c == RESIZABLE_ARRAY_INVALID_ARG_ERROR);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



static void locate_oob(void) {
	int c = 0, *pv = NULL;
	mock_start();

	resizable_array* ra = resizable_array_init();

	c = resizable_array_locate(ra, 0, &pv);
	assert(c == RESIZABLE_ARRAY_OUT_OF_BOUND_ERROR);
	assert(pv == NULL);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



static void push_locate_pop_32(void) {
	const int offset = 15;
	const int max = 32;

	int c = 0, v = 0, *pv = NULL;


	mock_start();

	resizable_array* ra = resizable_array_init();


	for (int i = 0; i < max; ++i) {
		c = resizable_array_push(ra, i+offset);
		assert(c == RESIZABLE_ARRAY_OK);
	}


	for (int i = 0; i < max; ++i) {
		pv = NULL;
		c = resizable_array_locate(ra, (size_t) i, &pv);
		assert(c == RESIZABLE_ARRAY_OK);
		assert(*pv == i+offset);
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



static void reuse_empty_ra(void) {
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
	push_null();

	pop();
	pop_null_arg();
	pop_empty();
	pop_null_ra();

	locate();
	locate_null_ra();
	locate_null_arg();
	locate_oob();

	push_locate_pop_32();
	reuse_empty_ra();

	return 0;
}
