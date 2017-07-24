### -*-Makefile-*- to update the web page of "Computational actuarial
### science with R - IME 2017 Workshop"
##
## Copyright (C) 2017 Vincent Goulet
##
## Author: Vincent Goulet
##
## This file is part of the project "Computational actuarial
## science with R - IME 2017 Workshop"
## http://github.com/vigou3/ime-2017-workshop-computational-actuarial-science-r


## Version number
VERSION = $(shell cat ../VERSION)

update-pages:
	awk 'BEGIN { FS = "/"; OFS = "/" } \
	     /^## Version/ { print; getline; print; getline; \
	                     gsub(/[0-9]+\.[0-9]+/, "${VERSION}") } \
	     /\[documentation\]/ { $$3 = "v${VERSION}" } 1' \
	    index.md > tmpfile && \
	  mv tmpfile index.md
	cd _layouts && \
	  awk 'BEGIN { FS = "/"; OFS = "/" } \
	       /{{ site.github.releases_url }}/ { $$3 = "v${VERSION}" } 1' \
	       default.html > tmpfile && \
	  mv tmpfile default.html
	git commit index.md _layouts/default.html \
	     -m "Updated web page for version ${VERSION}" && \
	   git push


