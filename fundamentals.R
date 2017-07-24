## Emacs: -*- coding: utf-8; fill-column: 62; comment-column: 27; -*-
##
## Copyright (C) 2017 Vincent Goulet
##
## This file is part of the project "Computational actuarial
## science with R - IME 2017 Workshop"
## http://github.com/vigou3/ime-2017-workshop-computational-actuarial-science-r
##
## This work is licensed under a Creative Commons
## Attribution-ShareAlike 4.0 International License.
## http://creativecommons.org/licenses/by-sa/4.0/

###
### BASIC DATA TYPES AND OPERATORS
###

## We concentrate on special values.

## Boolean values. 'TRUE' and 'FALSE' are reserved names to
## identify corresponding boolean values.
mode(TRUE)                 # mode "logical"
! FALSE                    # logical negation
TRUE & FALSE               # logical AND
TRUE | FALSE               # logical OR

## Boolean values may be used in arithmetic expressions. In
## such circumstances, 'TRUE' is equal to 1 and 'FALSE' is
## equal to 0.
2 + TRUE                   # == 2 + 1
3 + FALSE                  # == 3 + 0
sum(c(TRUE, TRUE, FALSE))  # number of 'TRUE' in the vector

## Missing value. 'NA' is a reserved name to represent missing
## values.
c(65, NA, 72, 88)          # treated as a value
NA + 2                     # *any* computation with 'NA' is NA
NA == NA                   # ... including comparison
is.na(c(65, NA))           # testing for 'NA' values

## Infinite and indeterminate values. 'Inf', '-Inf' and 'NaN'
## are reserved names.
1/0                        # +infinity
-1/0                       # -infinity
0/0                        # indeterminate value
x <- c(65, Inf, NaN, 88)   # used like regular values
is.finite(x)               # which values are real?
is.nan(x)                  # which values are indeterminate?

## Null value. 'NULL' is a reserved name to represent "void",
## "nothing".
mode(NULL)                 # mode of 'NULL' is NULL
length(NULL)               # null length
c(NULL, NULL)              # from void results only void

## Character strings. In R, a character string, whatever its
## length, is still one element of a vector.
"foobar"                   # *one* string of 6 characters
length("foobar")           # length 1
c("foo", "bar")            # *two* strings of 3 characters
length(c("foo", "bar"))    # length 2

## New objects are created with the assignment operator '<-'.
## *Do not* use '=' for assignment.
x <- 5                     # assign 5 to object 'x'
x                          # contents of 'x'
(x <- 5)                   # assign and display at once
y <- x                     # assign value of 'x' to 'y'
x <- y <- 5                # same, in one statement
y                          # 5
x <- 0                     # changing value of 'x'...
y                          # ... does not change 'y'

###
### VECTORS
###

## The basic function to create vectors is 'c'. It is
## sometimes useful to name (label) the elements of a vector.
x <- c(a = -1, b = 2, c = 8, d = 10) # vector creation
names(x)                             # names extraction
names(x) <- letters[1:length(x)]     # name changes

## Functions 'numeric', 'logical', 'complex' and 'character'
## initialize vectors with default values.
numeric(5)                 # vector initialized with 0
logical(5)                 # initialized with FALSE
complex(5)                 # initialized with 0 + 0i
character(5)               # initialized with empty strings

## Indexing serves two important purposes: extraction of
## elements with a construction 'x[i]' and replacement with a
## construction 'x[i] <- y'.
##
## There exists five different ways to index a vector in R.
##
## 1. with positive integers (extraction by position);
## 2. with negative integers (deletion by position);
## 3. with a boolean vector (extraction par criteria);
## 4. with character strings (extraction by name);
## 5. with an empty vector (extraction of all elements).
x[1]                       # extraction by position
x[-2]                      # deletion by position
x[x > 5]                   # extraction by criteria
x["c"]                     # extraction by name
x[]                        # all elements (not useful here)

## In usual vector arithmetic, lengths must match otherwise
## the operation is not defined.
##
## R allows more flexibility by recycling the shorter vectors
## to match the longest one in an operation.
##
## This means that length errors occur very rarely, if ever,
## in R! This characteristic of the language is really a
## two-edged sword: coding is thereby much simpler, but a
## syntactically valid statement may yield completely wrong
## results.
8 + 1:10                   # 8 is recycled 10 times
c(2, 5) * 1:10             # c(2, 5) is recycled 5 times
c(-2, 3, -1, 4)^(1:4)      # four different powers

###
### FUNCTIONS
###

## Functions in R are treated like any other object.
seq                        # contents is the source code
mode(seq)                  # mode is "function"
rep(seq(5), 3)             # function in argument of a function
lapply(1:5, seq)           # same
mode(ecdf(rpois(100, 1)))  # result of 'ecdf' is a function
ecdf(rpois(100, 1))(5)     # evaluation in one point
c(seq, rep)                # vector of functions!

### Call and argument matching rules

## The R interpreter identifies a function call by the fact
## that the name of an object is followed by parentheses ( ).
##
## A function can have no or any number of arguments. There is
## no practical limit to the number of arguments.
##
## Arguments may be specified following their order in the
## function definition. This is the most natural way to
## specify arguments.
##
## However, arguments may be listed in any order provided
## their name is then specified with a construction 'name =
## value'.
##
## It is good practice and *strongly recommended* to specify
## arguments by name following the first two or three most
## common arguments.
##
## Some arguments have a default value that is used when the
## argument is not specified in the function call.
##
## Let us examine the arguments of function 'matrix', which is
## used to create, well, a matrix from a vector of values.
args(matrix)

## The function has five arguments and each has a default
## value (this is not standard). What is the result of the
## following function call?
matrix()

## The function calls below are all equivalent. Pay attention
## whether arguments are specified by name or by position.
matrix(1:12, 3, 4)
matrix(1:12, ncol = 4, nrow = 3)
matrix(nrow = 3, ncol = 4, data = 1:12)
matrix(nrow = 3, ncol = 4, byrow = FALSE, 1:12)
matrix(nrow = 3, ncol = 4, 1:12, FALSE)

### Definition of new functions

## User functions are first class objects in R, meaning they
## can be used just like any other object.
##
## We define a trivial function for examples that follow.
square <- function(x) x * x

## Call to this function.
square(10)

### Lexical scope

## The scoping rules of R imply that a variable defined in a
## function does not clash with a variable of the same name in
## the workspace (fortunately!).
x <- 5                     # object in workspace
square(10)                 # in 'square' x equals 10
x                          # value unchanged
square(x)                  # passing value of 'x' to 'square'
square(x = x)              # tricky one... meaning?

## Let us go further with lexical scoping rules.
##
## When an object does not exist in an evaluation frame, R
## looks up in the parent environment to find a name-value
## pair.
##
## In practice, this implies that we can sometimes avoid
## explicitly passing values to a function to instead rely on
## lexical scoping.
##
## Suppose we have to write a function to compute
##
##   f(x, y) = x (1 + xy)^2 + y (1 - y) + (1 + xy)(1 - y).
##
## Two terms are repeated in this expression. We thus have
##
##   a = 1 + xy
##   b = 1 - y
##
## and f(x, y) = x a^2 + y b + a b.
##
## Here is an elegant implementation that relies on lexical
## scope to avoid cluttering the code with argument management.
f <- function(x, y)
{
    g <- function(a, b)
        x * a^2 + y * b + a * b
    g(1 + x * y, 1 - y)
}
f(2, 3)
f(2, 4)

### Argument '...'

## We illustrate usage of argument '...' as follows for now.
## There are more examples in mapping.R.
##
## Function 'curve' takes an R mathematical expression in
## argument and plots the function on a given interval.
curve(x^2, from = 0, to = 2)

## Assume with want all are 'curve' graphics (and only those)
## to be in orange.
curve(x^2, from = 0, to = 2, col = "orange")

## Instead of redefining 'curve' with all its arguments, we
## can simply write a small function that, thanks to '...',
## accepts all the arguments of 'curve'.
ocurve <- function(...) curve(..., col = "orange")
ocurve(x^2, from = 0, to = 2)

### Anonymous functions

## We go back to the lexical scope example to generalize
## function 'f' to accept any expression for terms 'a' and
## 'b'. The arguments of 'f' are now 'x', 'y' and functions to
## compute 'a' and 'b'.
##
## When the latter two function are short and not used
## elsewhere, we can just pass them in argument as anonymous
## functions.
f <- function(x, y, fa, fb)
{
    g <- function(a, b)
        x * a^2 + y * b + a * b
    g(fa(x, y), fb(x, y))
}
f(2, 3,
  function(x, y) 1 + x * y,
  function(x, y) 1 - y)
