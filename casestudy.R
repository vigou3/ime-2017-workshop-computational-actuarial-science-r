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
### REQUIRED PACKAGES
###

## Package actuar provides functions for zero truncated
## discrete distribution, for simulation of compound models
## and for simulation of discrete mixtures.
library(actuar)

## Package MASS provides function 'fitdistr' to estimate
## parameters using maximum likelihood.
library(MASS)

###
### POISSON PARAMETERS FOR THE THREE TYPES OF PERIL
###

## We skip modeling of those and just use the following
## values (they are sensible).
lambda.A <- 0.008
lambda.F <- 0.0003
lambda.W <- 0.005


###
### MODELING OF THE NUMBER OF ITEMS IN A COLLECTION
### AND THE MARKET VALUE OF ITEMS
###

### Import the data of a prior inventory.

## The data set is structured as follows: there is one line
## per item for the collections of all the clients. The
## variable in the data set are the following:
##
##   ID: unique id for a client [string]
##   Value: market value of an item [numeric]
##   DateEntry: date of entry of the item in the collection
##              [string in format YYYY-MM-DD]
##   DateExit: date of exit from the collection; NA if still
##             present
##
## We use function 'read.csv' to read in the data. We also
## specify the class of each column because R does not always
## correctly the correct type we will need.
inventory <- read.csv("Inventory.csv",
                      colClasses = c(ID = "factor",
                                     Value = "numeric",
                                     DateEntry = "Date",
                                     DateExit = "Date"))

## First summary of our data set. Note the missing values. We
## already have an idea of the sizes of the largest
## collections.
summary(inventory)

### Clean up of the data

## We will only keep the items that are still in the
## inventory, that is those that have DateExit NA.
##
## We put our work data set in another object so that we do
## not have to import again the data set if (when) we mess up.
data <- subset(inventory, is.na(DateExit))

## We will no longer need the dates of entry and exit.
data <- subset(data, select = c(ID, Value))

## There are missing market values (about 4%). We drop them.
data <- droplevels(data[complete.cases(data), ])
data <- droplevels(data[!is.na(data$Value), ]) # same (here)

## New summary of our simplified data set. No more missing
## values.
summary(data)

## The market values are very heavy tailed. Here's a graphic
## of the empirical distribution function of the market
## values.
plot(ecdf(data$Value))

## For modeling purposes, we will keep only the items with a
## market value of $1,000 and below.
data <- subset(data, Value <= 1000)

## To simplify future manipulations, we store frequently use
## data in new objects.
mv <- data$Value         # individual market values (~150,000)
names(mv) <- data$ID     # label data with client ID
nb <- by(mv, data$ID, length)  # number of items per collection
mv.tot <- by(mv, data$ID, sum) # total value per collection

## Closer inspection of the collection values.
summary(mv.tot)
plot(ecdf(mv.tot))

## We will do the rest of the analysis for the range of total
## market value between $5,000 and $25,000. We drop the other
## data points.
mv <- mv[names(mv) %in% names(mv.tot[mv.tot > 5000 & mv.tot < 25000])]
nb <- by(mv, names(mv), length)  # reset with new data
mv.tot <- by(mv, names(mv), sum) # idem

## This is the distribution of the total collection values we
## will be working with.
summary(mv.tot)
plot(ecdf(mv.tot))

### Modeling

## For the number of affected items by peril accident, we will
## use a zero-truncated Poisson distribution with parameter
## lambda set by judgment (!) to 7.
par.A <- 7

## The number of items affected by perils fire and water
## depend on the number of items in a collection.
##
## This is quick look at the distribution of this quantity in
## our data set.
summary(nb)
hist(nb)

## We will use zero-truncated negative binomials to model the
## number of items affected by perils fire and water.
##
## First, estimation for peril fire by maximum likelihood. We
## use estimators for a negative binomial as starting values
## for the optimization carried by 'fitdistr'.
##
## Note: 'fitdistr' returns estimates for the size parameter
## of the negative binomial and for the mean equal to r(1 -
## p)/p (where r is the size and p the probability of
## success).
start <- fitdistr(nb, "negative binomial")$estimate
r <- start[1]                  # estimate of size
p <- 1/(1 + start[2]/start[1]) # conversion mean -> p

## Estimation of the parameters of the zero-truncated negative
## binomial. Function 'dztnbinom' comes from actuar.
(par.F <- fitdistr(nb, dztnbinom,
                   start = list(size = r, prob = p))$estimate)

## Visual assessment of the fit.
hist(nb, prob = TRUE)
x <- seq(min(nb), max(nb), by = 10)
points(x, dztnbinom(x, par.F[1], par.F[2]),
       col = "orange", pch = 19)

## We repeat the same procedure for peril water. Here, we need
## a model for 25% of the items in a collection.
nb.W <- round(nb/4)      # support of distribution is integers
start <- fitdistr(nb.W, "negative binomial")$estimate
r <- start[1]
p <- 1/(1 + start[2]/start[1])
(par.W <- fitdistr(nb.W, dztnbinom,
                   start = list(size = r, prob = p))$estimate)

## Visual assessment of the fit.
hist(nb.W, prob = TRUE)
hist(nb.W, breaks = c(0, 10, 20, 30, 40, 50, 60, 80, 100, 120))
x <- seq(min(nb.W), max(nb.W), by = 10)
points(x, dztnbinom(x, par.W[1], par.W[2]),
       col = "orange", pch = 19)

### Modeling of market values

## Quick look at the distribution. Still very heavy tailed
## even if we kept only the items with a value <= $1,000.
summary(mv)
hist(mv)
hist(mv[mv < 500])
hist(mv[mv < 500],
     breaks = c(0, 20, 50, 70, 100, 150, 200, 280, 400, 500))

## We skip detail here, but further analysis showed that a
## model fitted on values smaller than $500 worked best for
## our application. We use a lognormal distribution.
(par.mv <- fitdistr(mv[mv <= 500], "lognormal")$estimate)

###
### SIMULATION
###

## Parameters for the simulation.
nb.sim <- 10000            # number of simulations
nb.clients <- 100          # number of clients

## We first write an expression to simulate 'nb.sim' variates
## from:
##
## 1. a compound Poisson distribution with Poisson parameter
##    equal to the sum of lambda.A, lambda.F and lambda.W;
## 2. with claim amounts distributed as a discrete mixture of
##    - one compound zero-truncated Poisson distribution, and
##    - two compound zero-truncated negative binomial distributions;
## 3. withe item values lognormal distributed.
##
## We use 'substitute' to "compute on the language" and insert
## the parameter values in the correct places. Yeah, it is a
## mouthful.
call <- substitute(
    rcomppois(n, sum(c(lambda.A, lambda.F, lambda.W)),
              rmixture(c(lambda.A, lambda.F, lambda.W),
                       expression(A = rcompound(rztpois(7), rlnorm(mu, s)),
                                  F = rcompound(rztnbinom(r.F, p.F), rlnorm(mu, s)),
                                  W = rcompound(rztnbinom(r.W, p.W), rlnorm(mu, s))))),
    list(n = nb.sim,
         r.F = par.F[1],
         p.F = par.F[2],
         r.W = par.W[1],
         p.W = par.W[2],
         mu = par.mv[1],
         s = par.mv[2]))

## The result is a function call ready to be evaluated.
call

## Running the simulation amounts to evaluate our above call
## 'nb.clients' times. This is a job for 'replicate'.
##
## The results are 'nb.simul' simulated total claim amounts
## for each of 'nb.clients' clients.
Sk <- replicate(nb.clients, eval(expr))

## Average total claim amount in the portfolio.
Wk <- rowSums(Sk)/nb.clients

## Pure premium.
mean(Wk)

## Premium with safety loading.
level <- 0.9
(VaR.Wk <- quantile(Wk, level)) # VaR(W)
w <- which(Wk > VaR.Wk)         # values Wk > var
(TVaR.Wk <- mean(Wk[w]))        # TVaR(Wk)
