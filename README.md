# Overview

Polymorphic C library implementing the Resizable Arrays in Optimal Time and Space as presented in https://cs.uwaterloo.ca/~imunro/cs840/ResizableArrays.pdf


The resizable arrays presented in the article and implemented here have:
- amortized constant time in their operations of push and pop on the biggest index,
- always constant time for read/write at any index.


As explained in the research article, the resizable array has a space overhead of `O(sqrt(n))`.


The algorithms `Grow` and `Shrink` presented in the article become `push` and `pop` respectively.


The return values of the functions `locate`, `push` and `pop` are status codes defined in the header.


The comments point to the lines of the algorithms detailed in the article.


Interruption of computations due to out-of-memory errors leave the resizable array in a valid state. These structures can be freed without creating any memory leak.



# Build

## Build modes
There are 3 build modes: `release`, `debug` and `trace`.

## Polymorphism
The variables implementing the polymorphism are `SCALAR_TYPE` and `RA_LIB_NAME`. They can be passed to the compilation by running the following
```
make SCALAR_TYPE=float RA_LIB_NAME=resizable_array_float
```

`SCALAR_TYPE` is the type of value stored in the resizable array. Defaults to `int`.

`RA_LIB_NAME` is the name the library takes once compiled. All the file names and the symbols take that name. Defaults to `resizable_array`.

If any of these two values is changed, the unit-tests do not run.

If compiling the library with non-default values, the best approach is:
- to compile the default library by running `make`, the tests are run,
- then to compile the library in release mode with the proper `SCALAR_TYPE` and `RA_LIB_NAME`.



# Release

Once compiled with `make`, the library to distribute is in the folder `out`.



# Unit-tests

They test the operations with and without out-of-memory errors.



# Installation
The library artifacts can be installed or uninstalled by running `make install` or `make uninstall`.


Several variables define the installation path for the library artifacts.

`INSTALL_DIR_DEFAULT` defines the root of the installation tree. Defaults to `/usr/local`.

`INSTALL_HDR_SUBDIR_DEFAULT` defines the subpath rooted in `INSTALL_DIR_DEFAULT` to store the header files. Defaults to `include/$(RA_LIB_NAME)`.
`INSTALL_LIB_SUBDIR_DEFAULT` defines the subpath rooted in `INSTALL_DIR_DEFAULT` to store the library files. Defaults to `lib/$(RA_LIB_NAME)`.
`INSTALL_PKG_SUBDIR_DEFAULT` defines the subpath rooted in `INSTALL_DIR_DEFAULT` to store the `pkg-config` files. Defaults to `lib/pkgconfig`.

`INSTALL_HDR_DIR` defines the absolute path to store the header files.
`INSTALL_LIB_DIR` defines the absolute path to store the library files.
`INSTALL_PKG_DIR` defines the absolute path to store the `pkg-config` files.

Each absolute path has priority over its subpath counterpart.

Note that the same values for these variables should be used when uninstalling as when installing.



# System

Tested on Linux Mint 20.3, with gcc version 9.4.0 and GNU Make 4.2.1.



# See also

There is an implementation of these resizable arrays in Ruby: https://github.com/nlfiedler/optarray



# Source

https://cs.uwaterloo.ca/~imunro/cs840/ResizableArrays.pdf


The fallback memory manager in the mock lib was greatly inspired by https://howtech.substack.com/p/shared-library-interposition-how
