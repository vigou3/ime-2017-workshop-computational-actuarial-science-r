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
### LIBRARY AND PACKAGES
###

## List of currently loaded packages in the R session.
search()

## List of the libraries searched by R.
.libPaths()

## Lists of the packages loaded by default at R startup.
options("defaultPackages")

## Loading a package of the standard library in memory.
library(MASS)
search()

## Installing a package from the austrian mirror of CRAN
## (replace with closest mirror for your country).
install.packages("actuar", repos = "http://cran.at.r-project.org")

## Installing a package does not load it in the R session. We
## have to load it with 'library' afterwards.
library(actuar)
search()
