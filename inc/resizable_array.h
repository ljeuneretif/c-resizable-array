#include <stdlib.h>



#define RESIZABLE_ARRAY_OK 0
#define RESIZABLE_ARRAY_UNKNOWN_ERROR 1
#define RESIZABLE_ARRAY_MEMORY_ALLOCATION_ERROR 2
#define RESIZABLE_ARRAY_EMPTY_ERROR 3
#define RESIZABLE_ARRAY_OUT_OF_BOUND_ERROR 4
#define RESIZABLE_ARRAY_NULL_RA_ERROR 5
#define RESIZABLE_ARRAY_INVALID_ARG_ERROR 6



#define RA_CONCAT_AUX(a, b) a##b
#define RA_CONCAT(a, b) RA_CONCAT_AUX(a, b)
#define RA_FUNC_SUFFIX(suffix) RA_CONCAT(RA_LIB_NAME, suffix)

#define RESIZABLE_ARRAY_INIT RA_FUNC_SUFFIX(_init)
#define RESIZABLE_ARRAY_FREE RA_FUNC_SUFFIX(_free)
#define RESIZABLE_ARRAY_PUSH RA_FUNC_SUFFIX(_push)
#define RESIZABLE_ARRAY_LOCATE RA_FUNC_SUFFIX(_locate)
#define RESIZABLE_ARRAY_POP RA_FUNC_SUFFIX(_pop)



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
} RA_LIB_NAME;


RA_LIB_NAME* RESIZABLE_ARRAY_INIT(void);
void RESIZABLE_ARRAY_FREE(RA_LIB_NAME*);

int RESIZABLE_ARRAY_PUSH(RA_LIB_NAME*, SCALAR_TYPE);
int RESIZABLE_ARRAY_LOCATE(const RA_LIB_NAME* const, size_t, SCALAR_TYPE**);
int RESIZABLE_ARRAY_POP(RA_LIB_NAME*, SCALAR_TYPE*);
