#include "resizable_array.h"



resizable_array* resizable_array_init(void) {

	resizable_array* ra;
	if (!(ra = malloc(sizeof(resizable_array)))) return NULL;


	ra->n = 0;
	ra->s = 0;
	ra->d = 0;

	ra->size_of_last_non_empty_datablock = 0;
	ra->occupancy_of_last_non_empty_datablock = 0;

	ra->size_of_last_superblock = 0;
	ra->occupancy_of_last_superblock = 0;

	ra->count_of_empty_datablock = 0;
	
	ra->length_of_index = 0;
	ra->index_of_datablocks = NULL;


	return ra;
}



void resizable_array_free(resizable_array* ra) {

	if (!ra) return;

	for (size_t i = 0; i < ra->d + ra->count_of_empty_datablock; ++i) {
		free(ra->index_of_datablocks[i]);
		ra->index_of_datablocks[i] = NULL;
	}

	free(ra->index_of_datablocks);
	ra->index_of_datablocks = NULL;

	free(ra);
}



int resizable_array_push(resizable_array* ra, int value) {
/*
	The growth happens in the following manner:
	The k-th superblock has 2^floor(k/2) datablocks each of length 2^ceiling(k/2)

	k = 0: datablocks 1, length 1
	k = 1: datablocks 1, length 2
	k = 2: datablocks 2, length 2
	k = 3: datablocks 2, length 4
	k = 4: datablocks 4, length 4
	...

	We observe an alternation in the doubling.

	k in interval [0, ra->s[

	We observe that:
	at k = 0, there are 2^1 - 1 data
	at k = 1, there are 2^2 - 1 data
	at k = 2, there are 2^3 - 1 data
	at k = 3, there are 2^4 - 1 data
	at k = 4, there are 2^5 - 1 data
	...
*/

	// Computations are performed on the copy of the data structure.
	size_t n = ra->n;
	size_t s = ra->s;
	size_t d = ra->d;

	size_t size_of_last_non_empty_datablock = ra->size_of_last_non_empty_datablock;
	size_t occupancy_of_last_non_empty_datablock = ra->occupancy_of_last_non_empty_datablock;

	size_t size_of_last_superblock = ra->size_of_last_superblock;
	size_t occupancy_of_last_superblock = ra->occupancy_of_last_superblock;

	size_t count_of_empty_datablock = ra->count_of_empty_datablock;

	size_t length_of_index = ra->length_of_index;
	int** index_of_datablocks = ra->index_of_datablocks;


	// 1)
	if (occupancy_of_last_non_empty_datablock == size_of_last_non_empty_datablock) {
		// The last datablock is full.
		// A new datablock must be created.

		// a)
		if (occupancy_of_last_superblock == size_of_last_superblock) {
			// The last superblock is full.
			// A new superblock must be created.

			// i)
			++s;

			if (s == 1) {
				size_of_last_non_empty_datablock = 1;
				size_of_last_superblock = 1;
			} else {
				if (s & 1) {
					// ii) ra->s odd.
					if (size_of_last_superblock == 0) {
						size_of_last_superblock = 1;
					} else {
						size_of_last_superblock *= 2;
					}
				} else {
					// iii) ra->s even.
					if (size_of_last_non_empty_datablock == 0) {
						size_of_last_non_empty_datablock = 1;
					} else {
						size_of_last_non_empty_datablock *= 2;
					}
				}
			}

			// iv)
			// New superblock was created.
			occupancy_of_last_superblock = 0;
		}


		// b)
		if (count_of_empty_datablock == 0) {
			// There is no empty datablock.
			// A new datablock must be created at the end of the index.

			// i)
			if (d == length_of_index) {
				// Index is full.
				// Extend index to twice its size.

				if (length_of_index == 0) {
					length_of_index = 1;
				} else {
					length_of_index *= 2;
				}

				if (!(index_of_datablocks = realloc(index_of_datablocks, length_of_index * sizeof(int*)))) {
					return RESIZABLE_ARRAY_MEMORY_ALLOCATION_ERROR;
				}

				// These fields should be stored in the resizable array because the realloc
				// potentially invalidated the pointer ra->index_of_datablocks.
				ra->length_of_index = length_of_index;
				ra->index_of_datablocks = index_of_datablocks;
			}

			// ii)
			// Create a new last datablock.
			int *datablock = NULL;
			if (!(datablock = calloc(size_of_last_non_empty_datablock, sizeof(int)))) {
				return RESIZABLE_ARRAY_MEMORY_ALLOCATION_ERROR;
			}
			
			// Store the new datablock into the index.
			// The new datablock is empty.
			ra->index_of_datablocks[d] = datablock;
		}


		// c)

		++d;
		++occupancy_of_last_superblock;
		count_of_empty_datablock = 0;


		// d)

		occupancy_of_last_non_empty_datablock = 0;
	}


	// 2)

	++n;
	++occupancy_of_last_non_empty_datablock;

	ra->index_of_datablocks[d-1][occupancy_of_last_non_empty_datablock-1] = value;


	// Modify the rest of the data structure only if all the computations succeeded.
	ra->n = n;
	ra->s = s;
	ra->d = d;

	ra->size_of_last_non_empty_datablock = size_of_last_non_empty_datablock;
	ra->occupancy_of_last_non_empty_datablock = occupancy_of_last_non_empty_datablock;

	ra->size_of_last_superblock = size_of_last_superblock;
	ra->occupancy_of_last_superblock = occupancy_of_last_superblock;

	ra->count_of_empty_datablock = count_of_empty_datablock;


	return RESIZABLE_ARRAY_OK;
}



int* resizable_array_locate(const resizable_array* const ra, size_t i) {

	if (ra->n <= i) {
		return NULL;
	}

	// The i-th data is at superblock k, datablock b (within superblock k), element e.

	// 1) 2)
	// a)
	// On 64-bit systems, size_t is usually 64-bit long,
	// which is equivalent to unsigned long long int.
	// __builtin_clzll takes in unsigned long long int.
	// See https://gcc.gnu.org/onlinedocs/gcc/Bit-Operation-Builtins.html
	size_t j = i + 1;

	int j_bitlength = (int) (sizeof(size_t) * 8) - __builtin_clzll((unsigned long long int) j);
	int k = j_bitlength - 1;
	int k_half = k / 2;

	// b) c)
	int e_bitlength = k_half + (k & 1); // ceiling(k/2)

	size_t size1 = 1;

	size_t right_limit_of_b = (size1 << e_bitlength);

	size_t b_mask = (size1 << k) - right_limit_of_b;
	size_t e_mask = right_limit_of_b - 1;

	size_t b = (j & b_mask) >> e_bitlength;
	size_t e = j & e_mask;

	// 3)
	// p counts the datablocks before superblock k.
	// p is the sum of 2^floor(a/2) for 0 <= a < k.
	// The formula below corrects the one stated in the article.
	size_t size2 = 2;
	size_t p = ((size2 + (k & 1)) << k_half) - 2;

	// 4)
	return ra->index_of_datablocks[p + b] + e;
}



int resizable_array_pop(resizable_array* ra, int* pvalue) {

	if (ra->n == 0) {
		return RESIZABLE_ARRAY_EMPTY_ERROR;
	}


	// 1)
	if (pvalue) {
		*pvalue = ra->index_of_datablocks[ra->d-1][ra->occupancy_of_last_non_empty_datablock-1];
	}

	// Computations are performed on the copy of the data structure.
	size_t n = ra->n;
	size_t s = ra->s;
	size_t d = ra->d;

	size_t size_of_last_non_empty_datablock = ra->size_of_last_non_empty_datablock;
	size_t occupancy_of_last_non_empty_datablock = ra->occupancy_of_last_non_empty_datablock;

	size_t size_of_last_superblock = ra->size_of_last_superblock;
	size_t occupancy_of_last_superblock = ra->occupancy_of_last_superblock;

	size_t count_of_empty_datablock = ra->count_of_empty_datablock;

	size_t length_of_index = ra->length_of_index;
	int** index_of_datablocks = ra->index_of_datablocks;


	--n;
	--occupancy_of_last_non_empty_datablock;

	// 2)
	if (occupancy_of_last_non_empty_datablock == 0) {

		// a)
		if (count_of_empty_datablock == 1) {
			// There is always 0 or 1 empty datablock.
			// The empty datablock, if it exists, is always the last one.
			free(index_of_datablocks[d]);
			index_of_datablocks[d] = NULL;
		}

		count_of_empty_datablock = 1;

		// b)
		if (4 * d <= length_of_index) {
			length_of_index /= 2;

			if (length_of_index != 0) {
				if (!(index_of_datablocks = realloc(index_of_datablocks, length_of_index * sizeof(int*)))) {
					return RESIZABLE_ARRAY_MEMORY_ALLOCATION_ERROR;
				}
			} else {
				free(index_of_datablocks);
				index_of_datablocks = NULL;
			}
		}

		// c)
		--d;
		--occupancy_of_last_superblock;

		// d)
		if (occupancy_of_last_superblock == 0) {
			// i)
			--s;

			if (s == 0) {
				size_of_last_non_empty_datablock = 0;
				size_of_last_superblock = 0;
			} else {
				if (s & 1) {
					// iii) ra->s odd.
					// The case ra->size_of_last_non_empty_datablock == 0 is handled by the base case of push.
					size_of_last_non_empty_datablock /= 2;
				} else {
					// ii) ra->s even.
					// The case ra->size_of_last_superblock == 0 is handled by the base case of push.
					size_of_last_superblock /= 2;
				}
			}

			// iv)
			occupancy_of_last_superblock = size_of_last_superblock;
		}

		// e)
		occupancy_of_last_non_empty_datablock = size_of_last_non_empty_datablock;
	}


	// Modify the data structure only if all the computations succeeded.
	ra->n = n;
	ra->s = s;
	ra->d = d;

	ra->size_of_last_non_empty_datablock = size_of_last_non_empty_datablock;
	ra->occupancy_of_last_non_empty_datablock = occupancy_of_last_non_empty_datablock;

	ra->size_of_last_superblock = size_of_last_superblock;
	ra->occupancy_of_last_superblock = occupancy_of_last_superblock;

	ra->count_of_empty_datablock = count_of_empty_datablock;

	ra->length_of_index = length_of_index;
	ra->index_of_datablocks = index_of_datablocks;


	return RESIZABLE_ARRAY_OK;
}
