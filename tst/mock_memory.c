#include <dlfcn.h>
#include <execinfo.h>
#include "mock_memory.h"
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>



// Logs from the fallback memory should be written using write, no printf.

// Wrapper for write().
static void _write(int __fd, const void *__buf, size_t __n) {
	if (write(__fd, __buf, __n) < 0) {
		perror("Error when write().");
		_exit(1);
	}
}

// size_t has max value 2^64 when it is unsigned long long int.
// 2^64 roughly equals 1.8e19.
// Representation of size_t needs 19 decimal digits.
// 19 is rounded to 24, the nearest multiple of 8 for alignment on 64-bit systems.
#define WRITE_BUFFER_SIZE 24

// Helper to write values of type size_t.
static void write_size_t(int fd, size_t n) {
	char buf[WRITE_BUFFER_SIZE];
	int i = WRITE_BUFFER_SIZE - 1;

	do {
		buf[i] = (char) ('0' + (n % 10));
	} while ((n /= 10) != 0 && (--i) >= 0);

	if (i < 0) {
		_write(fd, "write_size_t overflow.\n", 16);
		return;
	}

	_write(fd, &buf[i], WRITE_BUFFER_SIZE - (size_t) i);
}

#ifdef TRACE
// Helper to write pointer addresses.
// Only used in traces.
static void write_ptr(int fd, const void* const ptr) {
	char buf[WRITE_BUFFER_SIZE];
	int i = WRITE_BUFFER_SIZE;

	unsigned long long val = (unsigned long long) ptr;

	for(; i; val >>= 4)
		buf[--i] = "0123456789abcdef"[val & 0xF];

	if (i < 0) {
		_write(fd, "write_ptr overflow.\n", 20);
		return;
	}

	_write(fd, buf, WRITE_BUFFER_SIZE);
}
#endif



// Fallback buffer of 2 MB.
// Used when the real allocators are not ready.
#define FALLBACK_BUFFER_SIZE 2097152

static char fallback_buffer[FALLBACK_BUFFER_SIZE];
static size_t fallback_offset = 0;


static void* get_fallback_memory(size_t size) {
	size_t new_offset = fallback_offset + size;

	if (new_offset > FALLBACK_BUFFER_SIZE) {
		_write(2, "[mock] Error: Emergency buffer overflow, need ", 46);
		write_size_t(2, new_offset - FALLBACK_BUFFER_SIZE);
		_write(2, " extra bytes.\n", 14);
		return NULL;
	}

	void* ptr = (void*) &(fallback_buffer[fallback_offset]);
	fallback_offset += size;

	return ptr;
}


static bool is_fallback_memory(const void* const ptr) {
	return (void*) fallback_buffer <= ptr && ptr < (void*) (fallback_buffer + FALLBACK_BUFFER_SIZE);
}



// Track memory allocated and freed by the mocked allocators.
#define MAX_PTR_COUNT 1024

typedef struct {
	void* ptr;
	size_t size;
} ptr_data;

static ptr_data ptr_rec[MAX_PTR_COUNT];

static size_t unknown_free = 0;



static void ptr_rec_init(void) {
	unknown_free = 0;

	for (int i = 0; i < MAX_PTR_COUNT; ++i) {
		ptr_rec[i].ptr = NULL;
		ptr_rec[i].size = 0;
	}
}


static void ptr_rec_add(const void* const ptr, size_t size) {
	if (!ptr) return;

	for (int i = 0; i < MAX_PTR_COUNT; ++i) {
		ptr_data* p = &(ptr_rec[i]);

		if (!p->ptr) {
			p->ptr = (void*) ptr;
			p->size = size;
			return;
		}
	}

	_write(2, "[mock] Pointer record table out of memory.\n", 43);
}


static size_t ptr_rec_del(const void* const ptr) {
	if (!ptr) return 0;

	for (int i = 0; i < MAX_PTR_COUNT; ++i) {
		ptr_data* p = &(ptr_rec[i]);

		if (ptr == p->ptr) {
			p->ptr = NULL;
			size_t size = p->size;
			p->size = 0;
			return size;
		}
	}

	// Can be either a double-free or an unknown pointer being freed.
	++unknown_free;
	return 0;
}


void assert_memory_ok(void) {
	size_t memory_leaked = 0, blocks_leaked = 0;

	for (int i = 0; i < MAX_PTR_COUNT; ++i) {
		if (ptr_rec[i].ptr) {
			memory_leaked += ptr_rec[i].size;
			++blocks_leaked;
		}
	}

	if (!memory_leaked && !blocks_leaked && !unknown_free) {
		_write(2, "[mock] Memory OK.\n", 18);
		return;
	}

	_write(2, "[mock] Leaked ", 14);
	write_size_t(2, blocks_leaked);
	_write(2, " blocks.\n", 9);

	_write(2, "[mock] Leaked ", 14);
	write_size_t(2, memory_leaked);
	_write(2, " bytes.\n", 8);

	_write(2, "[mock] ", 7);
	write_size_t(2, unknown_free);
	_write(2, " unknown frees.\n", 16);

	_exit(1);
}



// The symbols from libc.
static void* (*real_malloc)(size_t) = NULL;
static void* (*real_calloc)(size_t, size_t) = NULL;
static void* (*real_realloc)(void*, size_t) = NULL;
static void (*real_free)(void*) = NULL;

static void real_symbols_init(void) {
	if (real_malloc && real_calloc && real_realloc && real_free)
		return;

	*(void* *) (&real_malloc) = dlsym(RTLD_NEXT, "malloc");
	*(void* *) (&real_calloc) = dlsym(RTLD_NEXT, "calloc");
	*(void* *) (&real_realloc) = dlsym(RTLD_NEXT, "realloc");
	*(void* *) (&real_free) = dlsym(RTLD_NEXT, "free");

	if (!real_malloc || !real_calloc || !real_realloc || !real_free) {
		_write(2, "Cannot load real symbols.\n", 26);
		_exit(1);
	}
}

// Runs before main() starts.
__attribute__((constructor))
static void mock_init(void) {
	setvbuf(stdout, NULL, _IONBF, 0);
	ptr_rec_init();
	real_symbols_init();
}



// Prevent infinite loop during initialization of the mocked allocators.
static __thread bool in_mock = false;


// Mock activity management.
static volatile bool is_mock_active = false;

static __thread volatile unsigned int countdown_when_malloc_should_fail = 0;
static __thread volatile unsigned int countdown_when_calloc_should_fail = 0;
static __thread volatile unsigned int countdown_when_realloc_should_fail = 0;


// Initialize the behaviour of the mocked allocators.
void mock_start(void) {
	in_mock = false;

	countdown_when_malloc_should_fail = 0;
	countdown_when_calloc_should_fail = 0;
	countdown_when_realloc_should_fail = 0;

	is_mock_active = true;
}

// Set a countdown for when the call to malloc should fail by returning NULL.
void mock_malloc_fail_in(unsigned int i) {
	countdown_when_malloc_should_fail = i;
}
void mock_malloc_no_fail(void) {
	countdown_when_malloc_should_fail = 0;
}

void mock_calloc_fail_in(unsigned int i) {
	countdown_when_calloc_should_fail = i;
}
void mock_calloc_no_fail(void) {
	countdown_when_calloc_should_fail = 0;
}

void mock_realloc_fail_in(unsigned int i) {
	countdown_when_realloc_should_fail = i;
}
void mock_realloc_no_fail(void) {
	countdown_when_realloc_should_fail = 0;
}



// The mocked allocators.
void* malloc(size_t size) {
	if (!real_malloc) {
		// Try loading the real symbols.
		real_symbols_init();

		if (!real_malloc) {
			// If the loading failed, use the fallback memory.
			return get_fallback_memory(size);
		}
	}

	if (!is_mock_active || in_mock) {
		// The current call to malloc is not initialized or is recursive.
		// Calling the real malloc avoids infinite recursion.
		return real_malloc(size);
	}


	// The next code block should call the real symbols,
	// even recursively.
	in_mock = true;

	void* ptr = NULL;

#ifdef TRACE
	// Inspect call stack, [0] = current malloc, [1] = caller.
	void* buffer[2];
	int nptrs = backtrace(buffer, 2);

	if (nptrs >= 2) {
			_write(2, "At ", 3);
			backtrace_symbols_fd(&buffer[1], 1, STDERR_FILENO);
	} else {
		_write(2, "[mock] ", 7);
	}
#endif

	if (countdown_when_malloc_should_fail != 1) {
		ptr = real_malloc(size);
		ptr_rec_add(ptr, size);

#ifdef TRACE
		_write(2, "malloc-ed ", 10);
		write_size_t(2, size);
		_write(2, " bytes at ", 10);
		write_ptr(2, ptr);
		_write(2, ".\n", 2);
#endif

		if (countdown_when_malloc_should_fail) {
			--countdown_when_malloc_should_fail;
		}
	}
#ifdef TRACE
	else {
		_write(2, "malloc failed.\n", 16);
	}
#endif

	in_mock = false;

	return ptr;
}


void* calloc(size_t nmemb, size_t size) {
	size_t total_size = nmemb * size;

	if (!real_calloc) {
		real_symbols_init();

		if (!real_calloc) {
			void* ptr = get_fallback_memory(size);
			if (ptr) {
				memset(ptr, 0, total_size);
			}
			return ptr;
		}
	}

	if (!is_mock_active || in_mock) {
		return real_calloc(nmemb, size);
	}


	in_mock = true;

	void* ptr = NULL;

#ifdef TRACE
	// Inspect call stack, [0] = current malloc, [1] = caller.
	void* buffer[2];
	int nptrs = backtrace(buffer, 2);

	if (nptrs >= 2) {
			_write(2, "At ", 3);
			backtrace_symbols_fd(&buffer[1], 1, STDERR_FILENO);
	} else {
		_write(2, "[mock] ", 7);
	}
#endif

	if (countdown_when_calloc_should_fail != 1) {
		ptr = real_calloc(nmemb, size);
		ptr_rec_add(ptr, total_size);

#ifdef TRACE
		_write(2, "calloc-ed ", 10);
		write_size_t(2, nmemb);
		_write(2, " * ", 3);
		write_size_t(2, size);
		_write(2, " = ", 3);
		write_size_t(2, total_size);
		_write(2, " bytes at ", 10);
		write_ptr(2, ptr);
		_write(2, ".\n", 2);
#endif

		if (countdown_when_calloc_should_fail) {
			--countdown_when_calloc_should_fail;
		}
	}
#ifdef TRACE
	else {
		_write(2, "calloc failed.\n", 16);
	}
#endif

	in_mock = false;

	return ptr;
}


void* realloc(void* ptr, size_t size) {
	if (!real_realloc) {
		real_symbols_init();

		if (!real_realloc) {
			void* new_ptr = get_fallback_memory(size);
			if (new_ptr && ptr) {
				memmove(new_ptr, ptr, size);
			}
			return new_ptr;
		}
	}

	if (!is_mock_active || in_mock) {
		return real_realloc(ptr, size);
	}


	in_mock = true;

	void* new_ptr = NULL;

#ifdef TRACE
	// Inspect call stack, [0] = current malloc, [1] = caller.
	void* buffer[2];
	int nptrs = backtrace(buffer, 2);

	if (nptrs >= 2) {
			_write(2, "At ", 3);
			backtrace_symbols_fd(&buffer[1], 1, STDERR_FILENO);
	} else {
		_write(2, "[mock] ", 7);
	}
#endif

	if (countdown_when_realloc_should_fail != 1) {
		new_ptr = real_realloc(ptr, size);

		if (new_ptr) {
#ifdef TRACE
			size_t old_size = 
#endif
			ptr_rec_del(ptr);
			ptr_rec_add(new_ptr, size);

#ifdef TRACE
			_write(2, "realloc-ed ", 11);
			write_size_t(2, old_size);
			_write(2, " bytes from ", 12);
			write_ptr(2, ptr);
			_write(2, " to ", 4);
			write_size_t(2, size);
			_write(2, " bytes at ", 10);
			write_ptr(2, new_ptr);
			_write(2, ".\n", 2);
#endif
		}

		if (countdown_when_realloc_should_fail) {
			--countdown_when_realloc_should_fail;
		}
	}
#ifdef TRACE
	else {
		_write(2, "realloc failed.\n", 17);
	}
#endif

	in_mock = false;

	return new_ptr;
}


void free(void* ptr) {
	// No free-ing the fallback memory.
	if (is_fallback_memory(ptr)) {
		return;
	}

	if (!real_free) {
		real_symbols_init();

		if (!real_free) {
			return;
		}
	}

	if (!is_mock_active || in_mock) {
		real_free(ptr);
		return;
	}


	in_mock = true;

#ifdef TRACE
	size_t size = 
#endif
	ptr_rec_del(ptr);

#ifdef TRACE
	// Inspect call stack, [0] = current malloc, [1] = caller.
	void* buffer[2];
	int nptrs = backtrace(buffer, 2);

	if (nptrs >= 2) {
			_write(2, "At ", 3);
			backtrace_symbols_fd(&buffer[1], 1, STDERR_FILENO);
	} else {
		_write(2, "[mock] ", 7);
	}

	_write(2, "freed ", 6);
	write_size_t(2, size);
	_write(2, " bytes at ", 10);
	write_ptr(2, ptr);
	_write(2, ".\n", 2);
#endif

	in_mock = false;
}
