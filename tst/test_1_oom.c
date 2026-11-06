#include <assert.h>
#include "preload_symbols.h"
#include "resizable_array.h"
#include "test_1_oom.h"
#include <unistd.h>



static const int VALUE1 = 5;



void init_failed_malloc(void) {
	mock_start();

	mock_malloc_fail_in(1);
	resizable_array* ra = resizable_array_init();
	assert(ra == NULL);

	assert_memory_ok();
	LOG;
}



void push_failed_empty_index_realloc(void) {
	mock_start();
	resizable_array* ra = resizable_array_init();

	// Assert index_of_datablocks should be reallocated.
	assert(
		ra->occupancy_of_last_non_empty_datablock == ra->size_of_last_non_empty_datablock &&
		ra->count_of_empty_datablock == 0 &&
		ra->d == ra->length_of_index
	);

	mock_realloc_fail_in(1);
	resizable_array_push(ra, VALUE1);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void push_failed_index_realloc(void) {
	mock_start();
	resizable_array* ra = resizable_array_init();

	resizable_array_push(ra, VALUE1);
	resizable_array_push(ra, VALUE1);
	resizable_array_push(ra, VALUE1);

	// Assert index_of_datablocks should be reallocated.
	assert(
		ra->occupancy_of_last_non_empty_datablock == ra->size_of_last_non_empty_datablock &&
		ra->count_of_empty_datablock == 0 &&
		ra->d == ra->length_of_index
	);

	mock_realloc_fail_in(1);
	resizable_array_push(ra, VALUE1);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void push_failed_empty_datablock_calloc(void) {
	mock_start();
	resizable_array* ra = resizable_array_init();

	// Assert a new datablock will be calloc-ed.
	assert(
		ra->occupancy_of_last_non_empty_datablock == ra->size_of_last_non_empty_datablock &&
		ra->count_of_empty_datablock == 0
	);

	mock_calloc_fail_in(1);
	resizable_array_push(ra, VALUE1);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void push_failed_datablock_calloc(void) {
	mock_start();
	resizable_array* ra = resizable_array_init();

	resizable_array_push(ra, VALUE1);

	// Assert a new datablock will be calloc-ed.
	assert(
		ra->occupancy_of_last_non_empty_datablock == ra->size_of_last_non_empty_datablock &&
		ra->count_of_empty_datablock == 0
	);

	mock_calloc_fail_in(1);
	resizable_array_push(ra, VALUE1);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



void pop_failed_index_realloc(void) {
	mock_start();
	resizable_array* ra = resizable_array_init();

	// Grow the index of datablocks.
	// It creates 1 datablock of size 1, 3 of size 2, 1 of size 4.
	// The datablock of size 4 has only one element.
	for (int i = 0; i < 8; ++i) {
		resizable_array_push(ra, VALUE1);
	}
	// Empty the datablock of size 4, he last 2 datablocks of size 2,
	// leave one element in the first datablock of size 2.
	for (int i = 0; i < 6; ++i) {
		resizable_array_pop(ra, NULL);
	}

	// Assert index_of_datablocks should be reallocated.
	assert(
		ra->occupancy_of_last_non_empty_datablock == 1 &&
		4 * ra->d <= ra->length_of_index
	);

	mock_realloc_fail_in(1);
	resizable_array_pop(ra, NULL);

	resizable_array_free(ra);
	assert_memory_ok();
	LOG;
}



int main(void) {
	init_failed_malloc();
	
	push_failed_empty_index_realloc();
	push_failed_index_realloc();

	push_failed_empty_datablock_calloc();
	push_failed_datablock_calloc();

	pop_failed_index_realloc();

	return 0;
}
