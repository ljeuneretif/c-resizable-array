# Overview

Library implementing in the language C the Resizable Arrays in Optimal Time and Space as presented in https://cs.uwaterloo.ca/~imunro/cs840/ResizableArrays.pdf


The resizable arrays presented in the article and implemented here have:
- amortized constant time in their operations of push and pop on the biggest index,
- always constant time for read/write at any index.


As explained in the research article, the resizable array has a space overhead of `O(sqrt(n))`.


The library is written to store integers into the resizable arrays. The source code can be adapted for any type.


The return values of the functions `push` and `pop` are status codes defined in the header.


The comments point to the lines of the algorithms detailed in the article.


Interruption of computations due to out-of-memory errors leave the resizable array in a valid state. These structures can be freed without creating any memory leak.


# Release

Once compiled with `make`, the library to distribute is in the folder `out`.


# Debugging

Two levels of debugging are available:
- `DEBUG=1 make`
- `DEBUG=1 TRACE=1 make`

The first level exports the debugging symbols.

The second level exports the debugging symbols and enable the traces in the mocked allocators that are used when testing the resilience to the out-of-memory errors.



# Unit-tests

They test the operations with and without out-of-memory errors.



# System

Tested on Linux Mint 20.3, with gcc version 9.4.0.



# See also

There is an implementation of these resizable arrays in Ruby: https://github.com/nlfiedler/optarray



# Source

https://cs.uwaterloo.ca/~imunro/cs840/ResizableArrays.pdf


The fallback memory manager in the mock lib was greatly inspired by https://howtech.substack.com/p/shared-library-interposition-how
