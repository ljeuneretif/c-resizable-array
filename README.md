# Overview

Polymorphic C library implementing the Resizable Arrays in Optimal Time and Space as presented in https://cs.uwaterloo.ca/~imunro/cs840/ResizableArrays.pdf


The resizable arrays presented in the article and implemented here have:
- **amortized constant time** for **push/pop on biggest index**,
- **always constant time** for **read/write at any index**.


As explained in the research article, the resizable array has a space overhead of `O(sqrt(n))`.


The algorithms `Grow`, `Shrink`, `Locate` presented in the article become `push`, `pop`, `get` respectively.


The return values of `push`, `pop`, `get` are status codes defined in the header.


The comments point to the lines of the algorithms detailed in the article.


Interruption of computations due to out-of-memory errors leave the resizable array in a valid state. These structures can be freed without creating any memory leak.



# Build

## Build modes
There are 3 build modes: `release`, `debug` and `trace`. Defaults to `release`.

The build mode is passed with the variable `BUILD`:
```
make BUILD=debug
```



## Polymorphism
The variables implementing the polymorphism are `SCALAR_TYPE` and `RA_LIB_NAME`. They can be passed to the compilation by running the following
```
make SCALAR_TYPE=float RA_LIB_NAME=resizable_array_float
```

`SCALAR_TYPE` is the type of value stored in the resizable array. Defaults to `int`.

`RA_LIB_NAME` is the name the library takes once compiled. All the files and symbols use that name. Defaults to `resizable_array`.

If any of these two values is changed, **the unit-tests do not run**.

If compiling the library with non-default `SCALAR_TYPE` or `RA_LIB_NAME`, the best approach is:
- compile the default library with `make`, the unit-tests are run,
- clean the artifacts with `make clean`,
- compile the library in release mode with the proper `SCALAR_TYPE` and `RA_LIB_NAME`.

Giving the following commands:
```
make && make clean && make SCALAR_TYPE=float RA_LIB_NAME=resizable_array_float
```



## Artifacts
The artifacts to distribute are in the folder `out`.



# Unit-tests
They test the operations with and without out-of-memory errors.



# Installation

## Command
The artifacts are installed with `make install`/uninstalled with `make uninstall`.



## Variables
`INSTALL_DIR`: absolute path to the root of the installation tree. Defaults to `/usr/local`.

`INSTALL_SUBDIR`: name of the subfolder of `include` where the header should be installed, and the name of the subfolder of `lib` where the library should be installed.

For example `INSTALL_SUBDIR=ra_float` will install:
- the header inside `/usr/local/include/ra_float`
- the library inside `/usr/local/lib/ra_float/`.


`INSTALL_HDR_DIR`: absolute path of installation of the header files.

`INSTALL_LIB_DIR`: absolute path of the installation of the library files.

`INSTALL_PKG_DIR`: absolute path of the installation of the `pkg-config` file.

Each absolute path `INSTALL_..._DIR` has priority over the variables `INSTALL_DIR` and `INSTALL_SUBDIR`.

The same values for these variables and `RA_LIB_NAME` should be used when uninstalling.



## Example
```
make SCALAR_TYPE=float RA_LIB_NAME=resizable_array_float INSTALL_DIR=/usr/other_local INSTALL_SUBDIR=ra_float INSTALL_LIB_DIR=/usr/local/other_lib install
```
will install
```
/usr/
├── local
│   └── other_lib
│       ├── libresizable_array_float.a
│       ├── libresizable_array_float.so -> libresizable_array_float.so.4
│       ├── libresizable_array_float.so.4 -> libresizable_array_float.so.4.0.0
│       └── libresizable_array_float.so.4.0.0
└── other_local
    ├── include
    │   └── ra_float
    │       └── resizable_array_float.h
    └── lib
        └── pkgconfig
            └── resizable_array_float.pc
```



# System

Tested on Linux Mint 20.3, with gcc version 9.4.0 and GNU Make 4.2.1.



# See also

There is an implementation of these resizable arrays in Ruby: https://github.com/nlfiedler/optarray



# Source

https://cs.uwaterloo.ca/~imunro/cs840/ResizableArrays.pdf


The fallback memory manager in the mock lib is greatly inspired by https://howtech.substack.com/p/shared-library-interposition-how
