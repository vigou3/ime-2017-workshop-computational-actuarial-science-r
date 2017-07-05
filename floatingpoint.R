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
### ILLUSTRATION OF THE NON-EQUIVALENCE OF ALGREBRAIC AND
### NUMERICAL COMPUTATIONS
###

## Consider the translated Pareto distribution with
## distribution function
##
##   F(x; m, a) = 1 - (m/x)^a, x > m.
##
## We can show that the maximum likelihood estimation (MLE) of
## parameter 'a' is
##
##   n/log(x_1 ... x_n/(min(x)^n)),
##
## where x_1, ..., x_n are the sample points is their min(x)
## minimum.

## For the sake of the exercise, we first create a sample of
## size 100,000 from a translated Pareto distribution of mean
## 5000 using the simple inversion algorithm.
x <- 2000/(runif(100000)^(1/1.4))

## Trying to compute the MLE from this sample using the above
## formula quickly overflows and, therefore, the result is
## NaN.
prod(x)                                 # overflow
min(x)^length(x)                        # overflow
length(x)/log(prod(x)/min(x)^length(x))

## Let's look at alternative, algebraically equivalent,
## formulas. Perhaps just rescaling the sample values would be
## enough, that is, computing the MLE with
##
##   n/log((x_1/min(x)) ... (x_n/min(x))).
##
## Let's see.
length(x)/log(prod(x/min(x)))           # underflow

## There is another, better way: work in log scale. The
## formula for the MLE can be rewritten as
##
##   n/(sum(log(x)) - n * log(min(x)))
##
## This time, we get an answer.
length(x)/(sum(log(x)) - length(x) * log(min(x)))
