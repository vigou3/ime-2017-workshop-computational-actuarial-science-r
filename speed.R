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
### COOKIE PAN SYNDROME
###

## The Fibonacci sequence is a famous sequence of integer numbers. The
## first two terms are 0 and 1, and the following ones are the sum of
## the two previous terms in the sequence:
##
##   f(0) = 0
##   f(1) = 1
##   f(n) = f(n - 1) + f(n - 2), n = 2, 3, ...
##
## The ratio of two consecutive terms in the sequence converges to the
## golden ratio (1 + sqrt(5))/2.

## Let's write a function to compute the first 'n' (we assume n > 2)
## terms of the Fibonaci sequence.
##
## This version is very inefficient. Why?
fib1 <- function(n)
{
    res <- c(0, 1)
    for (i in 3:n)
        res[i] <- res[i - 1] + res[i - 2]
    res
}
fib1(10)
fib1(20)





## [This space intentionally left blank]





## This next version should be more efficient because we initialize
## from the outset a container of the correct length in which we store
## the results afterwards.
fib2 <- function(n)
{
    res <- numeric(n)      # container initialization
    res[2] <- 1            # res[1] is already 0
    for (i in 3:n)
        res[i] <- res[i - 1] + res[i - 2]
    res
}
fib2(10)
fib2(20)

## Did we really gain anything? Let's compare the time required to
## create a long Fibonacci sequence with both functions.
system.time(fib1(100000))   # inefficient version
system.time(fib2(100000))   # efficient version

###
### USING C/C++ CODE THROUGH Rcpp
###

## This part is essentially lifted from a keynote presentation by Dirk
## Eddelbuettel at "R à Québec 2017". The slides also provide much
## background details and constitue recommended reading:
## http://dirk.eddelbuettel.com/papers/r_a_quebec_2017.pdf

## We will need packages Rcpp and rbenchmark.
install.packages("Rcpp")
install.packages("rbenchmark")

## To illustrate how using C/C++ code may dramatically increase
## execution speed, we will work on a variation of the problem above.
##
## Instead of generating the 'n' first number of the Fibonacci
## sequence, we will only return the 'n'th value.
##
## A recursive implementation in R is as follows.
f <- function(n)
{
    if (n < 2)
        return(n)
    f(n - 1) + f(n - 2)
}

## Execution speed rapidly increases.
library(rbenchmark)
benchmark(f(10), f(15), f(20))[,1:4]

## Let's now look at a C implementation called using the Rcpp
## interface.
Rcpp::cppFunction("int g(int n) {
    if (n < 2) return(n); return(g(n-1) + g(n-2)); }")
benchmark(f(25), g(25), order = "relative")[,1:4]
