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
### 'apply' FUNCTION
###

### For a matrix

## Creation of a matrix for examples out of a random sample of size 20
## of integers between 1 and 100.
m <- matrix(sample(1:100, 20), nrow = 4, ncol = 5)

## Functions 'rowSums', 'colSums', 'rowMeans' and 'colMeans' are
## shortcuts for the most common uses of 'apply'.
rowSums(m)                 # sum by row
apply(m, 1, sum)           # same, but less legible
colMeans(m)                # means by column
apply(m, 2, mean)          # same, but less legible

## Since there are functions such as 'rowMax' or 'colProds', we must
## revert to 'apply' to compute these summaries.
apply(m, 1, max)           # maximum by row
apply(m, 2, prod)          # products by column

### For an array

## Creation of a three dimensional array for examples.
a <- array(sample(1:20, 60, replace = TRUE), dim = 3:5)

## There no predefined functions for array summaries, we must always
## use 'apply'.
##
## Using 'apply' on arrays can quickly get disconcerting if we do not
## clearly "visualize" its effect.
##
## Mnemonic trick: dimensions *not* in argument MARGIN are those
## that disappear after the array goes through 'apply'.
apply(a, 1, sum)           # sums on horizontal slices
sum(a[1, , ])              # same for the first slice

apply(a, 3, sum)           # sums on sideways slices (bread like)
sum(a[, , 1])              # same for the first slice

apply(a, c(1, 2), sum)     # sums on horizontal rods
sum(a[1, 1, ])             # same for the first rod

apply(a, c(1, 3), sum)     # sums on sideways rods
sum(a[1, , 1])             # same for the first rod

apply(a, c(2, 3), sum)     # sums on vertical rods
sum(a[, 1, 1])             # same for the first rod

###
### 'tapply' FUNCTION
###

## The 'airquality' data set included in R contains daily air quality
## measurements in New York, May to September 1973.
?airquality                # help page for the data set

## Column 'Temp' contains the temperature of the day and column
## 'Month', the month as an integer from 5 to 9.
##
## With 'tapply', we can easily the average temperature per month.
tapply(airquality$Temp, airquality$Month, mean)

## Same (but for display of results).
by(airquality$Temp, airquality$Month, mean)

###
### 'lapply' AND 'sapply' FUNCTIONS
###

## Function 'lapply' applies a function to each element of a vector or
## list and always returns a list.
##
## Function 'sapply' does the same, but returns a vector or a matrix
## if all results are the same length.
##
## Internal sums of the elements of a list.
(x <- list(1:10, c(-2, 5, 6), matrix(3, 4, 5)))
sum(x)                     # error
lapply(x, sum)             # internal sums (as list)
sapply(x, sum)             # internal sums (as vector)

## Creation of the sequence 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, ...,
## 1, 2, ..., 9, 10.
lapply(1:10, seq)          # as a list
unlist(lapply(1:10, seq))  # conversion to vector

## Creation of a list containing four random samples of different
## sizes.
##
## The statement below takes advantage of argument '...' of 'lapply'.
## Given that the definition of function 'sample' is
##
##   sample(x, size, replace = FALSE, prob = NULL)
##
## can you decipher the statement?
(x <- lapply(c(8, 12, 10, 9),
             sample,
             x = 1:10, replace = TRUE))

## The following function computes the arithmetic mean of the data of
## a vector 'x' larger than some value 'y'. Notice that this function
## is not vectorial for 'y'; it is valid for 'y' a vector of length 1
## only.
fun <- function(x, y) mean(x[x > y])

## Let us use the above function to compute the mean excess value of
## each element of our list 'x'. We may use 'sapply' since each result
## is of length 1.
##
## Function 'fun' requires two arguments, so we need to provide it
## with the value of 'y'. That is what the '...' argument of 'sapply'
## is there for.
sapply(x, fun, 7)          # average of values > 7

## Function 'sapply' is also very useful to vectorize an otherwise non
## vectorial function. We may generalize our function 'fun' as follows
## to have it accept a vector of thresholds 'y'.
fun2 <- function(x, y)
    sapply(y, function(y) mean(x[x > y]))

## Mean excess values for each element of the list 'x' and for three
## different thresholds. Notice how we implicitly did two nested
## loops.
sapply(x, fun2, y = c(3, 5, 7))

###
### 'mapply' FUNCTION
###

## Application of function 'fun' on each sample of the list 'x' with a
## different threshold for each.
mapply(fun, x, c(3, 5, 7, 7))

###
### 'replicate' FUNCTION
###

## Function 'replicate' repeats 'n' times a given statement.
##
## The function is mostly useful in simulations.
##
## For example, simulating 10 independent random samples of length 12
## each requires to execute the same statement 10 times. This is a job
## for 'replicate'. Notice that the random sample are in the columns
## of the resulting matrix.
replicate(10, sample(1:100, 12))
