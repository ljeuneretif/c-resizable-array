#ifndef RESIZABLE_ARRAY_H
#define RESIZABLE_ARRAY_H



#include <stdlib.h>



#define RESIZABLE_ARRAY_OK 0
#define RESIZABLE_ARRAY_MEMORY_ALLOCATION_ERROR 1
#define RESIZABLE_ARRAY_EMPTY_ERROR 2
#define RESIZABLE_ARRAY_OUT_OF_BOUND_ERROR 3



typedef struct {
	size_t n; // number of elements.
	size_t s; // number of superblocks.
	size_t d; // number of non-empty datablocks.

	size_t size_of_last_non_empty_datablock;
	size_t occupancy_of_last_non_empty_datablock; // occupancy measured in elements.

	size_t size_of_last_superblock;
	size_t occupancy_of_last_superblock; // occupancy measured in datablocks.

	size_t count_of_empty_datablock;

	size_t length_of_index;
	int** index_of_datablocks;
} resizable_array;


resizable_array* resizable_array_init(void);
void resizable_array_free(resizable_array*);

int resizable_array_push(resizable_array*, int);
int* resizable_array_locate(const resizable_array* const, size_t);
int resizable_array_pop(resizable_array*, int*);



#endif // #ifndef RESIZABLE_ARRAY_H