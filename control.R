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
### CONDITIONAL EXECUTION
###

## This is what happens when the condition in 'if' does not evaluate
## to a single TRUE or FALSE value.
x <- c(-2, 3, 5)
if (x > 0) x + 2 else x^2

## Typical use of 'if' in a function: checking validity of the
## arguments. Such tests are best carried out at the beginning
## of the function, resulting in immediate exit from the
## function with 'stop' as soon as one argument is invalid.
## Note that there is no 'else' clause, below.
f <- function(x, y)
{
    if (any(x < 0))
        stop("'fun' valid for positive values of x only")

    mean(x[x > y])
}
f(x, 5)
f(c(5, 10, 20), 5)

###
### REPEATED EXECUTION (LOOPS AND FLOW CONTROL)
###

## We illustrate loop usage with the fixed-point method. It is
## a simple, yet powerful numerical method to solve an
## equation of the form
##
##   x = f(x).
##
## The method consists in setting a starting value and then to
## successively evaluate f(x), f(f(x)), f(f(f(x))), ... until
## the value does not change "too much". The algorithm is
## therefore very simple:
##
## 1. Set a starting value x[0].
## 2. For n = 1, 2, 3, ...
##    2.1 Compute x[n] = f(x[n - 1])
##    2.2 If |x[n] - x[n - 1]|/|x[n]| < TOL, goto step 3.
## 3. Return the value x[n].

## As a first, simple, illustration we assume we need to
## compute the square root of a number x, that is the positive
## value y such that y^2 = x. Written in fixed-point form, we
## have:
##
##   y = x/y.
##
## The fixed-point method does not converge for this function
## (the algorithm indefinitely oscillates between two values).
##
## The following variant of the equation y^2 = x works better
## (actually, we may prove that the algorithm always converges
## for this function):
##
##   y = (y - x/y)/2.
##
## Here is a first implementation of our shiny new 'sqrt'
## function based on the fixed-point method.
sqrt <- function(x, start = 1, TOL = 1E-10)
{
    repeat
    {
        y <- (start + x/start)/2
        if (abs(y - start)/y < TOL)
            break
        start <- y
    }
    y
}
sqrt(9, 1)
sqrt(225, 1)
sqrt(3047, 50)

## The problem with this implementation is that we need to
## rewrite the function for each and every equation we want to
## solve! Upon close inspection, we see that the only thing
## that would change, though, is the evaluation of the
## function f(x) for which we search the fised-point.
##
## Using functional programming, let us just write a general
## fixed-point function that takes f(x) in argument.
fixed_point <- function(FUN, start, TOL = 1E-10)
{
    repeat
    {
        x <- FUN(start)
        if (abs(x - start)/x < TOL)
            break
        start <- x
    }
    x
}

## We may then rewrite our 'sqrt' function to use
## 'fixed_point'. While we're at it, we add an argument
## validity test to the function, for good measure.
sqrt <- function(x)
{
    if (x < 0)
        stop("cannot compute square root of negative value")

    fixed.point(function(y) (y + x/y)/2, start = 1)
}
sqrt(9)
sqrt(25)
sqrt(3047)
