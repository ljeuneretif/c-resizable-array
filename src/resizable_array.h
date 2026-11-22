/* File generated, any modification will be lost. */
#ifndef @RA_LIB_NAME@_H
#define @RA_LIB_NAME@_H


#include <stdlib.h>


#define RESIZABLE_ARRAY_OK 0
#define RESIZABLE_ARRAY_UNKNOWN_ERROR 1
#define RESIZABLE_ARRAY_MEMORY_ALLOCATION_ERROR 2
#define RESIZABLE_ARRAY_EMPTY_ERROR 3
#define RESIZABLE_ARRAY_OUT_OF_BOUND_ERROR 4
#define RESIZABLE_ARRAY_NULL_RA_ERROR 5
#define RESIZABLE_ARRAY_INVALID_ARG_ERROR 6


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
	@SCALAR_TYPE@** index_of_datablocks;
} @RA_LIB_NAME@;


@RA_LIB_NAME@* @RA_LIB_NAME@_init(void);
void @RA_LIB_NAME@_free(@RA_LIB_NAME@*);

int @RA_LIB_NAME@_push(@RA_LIB_NAME@*, @SCALAR_TYPE@);
int @RA_LIB_NAME@_locate(const @RA_LIB_NAME@* const, size_t, @SCALAR_TYPE@**);
int @RA_LIB_NAME@_pop(@RA_LIB_NAME@*, @SCALAR_TYPE@*);

#endif // #ifndef @RA_LIB_NAME@_H
