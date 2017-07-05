### -*-Makefile-*- to prepare "Computational actuarial science with R
### - IME 2017 Workshop"
##
## Copyright (C) 2017 Vincent Goulet
##
## 'make tex' creates .tex files from .Rnw with Sweave.
##
## 'make pdf' does 'make tex' and compiles the master document with
## XeLaTeX.
##
## 'make release' creates a release on GitHub and uploads the material
## as a .zip archive.
##
## 'make all' is equivalent to 'make pdf'.
##
## Author: Vincent Goulet
##
## This file is part of the project "Computational actuarial
## science with R - IME 2017 Workshop"
## http://github.com/vigou3/ime-2017-workshop-computational-actuarial-science-r


## Key files
ARCHIVE = ime-2017-workshop-computational-actuarial-science-r.zip
SLIDES = ime-2017-workshop-computational-actuarial-science-r.pdf
README = README.md
SCRIPTS = \
	fundamentals.R \
	mapping.R \
	control.R \
	extensions.R \
	wrong.R \
	floatingpoint.R \
	speed.R \
DATA = \
OTHER = \
	LICENSE

## Temporary directory to build archive
TMPDIR = tmpdir

## Version number
VERSION = $(shell cat VERSION)

## Ensemble des sources du document.
RNWFILES = \
	presentation.Rnw \
	fundamentals.Rnw \
	datatypes.Rnw \
	floatingpoint.Rnw
TEXFILES = \
	frontcover.tex \
	frontispice.tex \
	licence.tex \
	control.tex \
	mapping.tex \
	extensions.tex \
	speed.tex \
	colophon.tex \
	backcover.tex

## Outils de travail
SWEAVE = R CMD SWEAVE --encoding="utf-8"
TEXI2DVI = LATEX=xelatex texi2dvi -b
RM = rm -rf


all: pdf

.PHONY: tex pdf clean

pdf: ${SLIDES}

tex: ${RNWFILES:.Rnw=.tex}

release: create-release upload publish

%.tex: %.Rnw
	${SWEAVE} '$<'

${SLIDES}: ${SLIDES:.pdf=.tex} ${RNWFILES:.Rnw=.tex} ${TEXFILES}
	${TEXI2DVI} ${SLIDES:.pdf=.tex}

zip: ${SLIDES} ${README} ${SCRIPTS} ${DATA} ${OTHER}
	if [ -d ${TMPDIR} ]; then ${RM} ${TMPDIR}; fi
	mkdir -p ${TMPDIR} ${TMPDIR}/data
	touch ${TMPDIR}/${README} && \
	  awk 'state==0 && /^# / { state=1 }; \
	       /^## Author/ { printf("## Version\n\n%s\n\n", "${VERSION}") } \
	       state' ${README} >> ${TMPDIR}/${README}
	cp ${SLIDES} ${SCRIPTS} ${DATA} ${OTHER} ${TMPDIR}
	cd ${TMPDIR} && zip --filesync -r ../${ARCHIVE} *
	${RM} ${TMPDIR}

create-release:
	@echo ----- Creating release on GitHub...
	@if [ -n "$(shell git status --porcelain | grep -v '^??')" ]; then \
	    echo "uncommitted changes in repository; not creating release"; exit 2; fi
	@if [ -n "$(shell git log origin/master..HEAD)" ]; then \
	    echo "unpushed commits in repository; pushing to origin"; \
	     fi
	if [ -e relnotes.in ]; then rm relnotes.in; fi
	touch relnotes.in
	awk 'BEGIN { ORS=" "; print "{\"tag_name\": \"v${VERSION}\"," } \
	      /^$$/ { next } \
	      /^## Changelog/ { state=0; next } \
              (state==0) && /^### / { state = 1; out = $$2; \
	                             for(i=3; i<=NF; i++) { out = out" "$$i }; \
	                             printf "\"name\": \"Version %s\", \"body\": \"", out; \
	                             next } \
	      (state==1) && /^### / { exit } \
	      state==1 { printf "%s\\n", $$0 } \
	      END { print "\", \"draft\": false, \"prerelease\": false}" }' \
	      ${README} >> relnotes.in
	curl --data @relnotes.in ${REPOSURL}/releases?access_token=${OAUTHTOKEN}
	rm relnotes.in
	@echo ----- Done creating the release

upload:
	@echo ----- Getting upload URL from GitHub...
	$(eval upload_url=$(shell curl -s ${REPOSURL}/releases/latest \
	 			  | awk -F '[ {]' '/^  \"upload_url\"/ \
	                                    { print substr($$4, 2, length) }'))
	@echo ${upload_url}
	@echo ----- Uploading archive to GitHub...
	curl -H 'Content-Type: application/zip' \
	     -H 'Authorization: token ${OAUTHTOKEN}' \
	     --upload-file ${ARCHIVE} \
             -i "${upload_url}?&name=${ARCHIVE}" -s
	@echo ----- Done uploading files

publish :
	@echo ----- Publishing the web page...
	${MAKE} -C docs
	@echo ----- Done publishing

clean:
	${RM} ${RNWFILES:.Rnw=.tex} \
	      *-[0-9][0-9][0-9].pdf \
	      *.aux *.log  *.blg *.bbl *.out *.rel *~ Rplots.ps


