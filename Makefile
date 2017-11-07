MAINFILE=tutorial.R

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  html      to produce tutorial with html format"
	@echo "  revealjs  to produce tutorial as a revealjs slideshow"
	@echo "  md        to produce tutorial with markdown format"
	@echo "  assets    to produce assets used in the documents"

html: ${MAINFILE}
	Rscript -e "rmarkdown::render(\"${MAINFILE}\", \"rmarkdown::html_document\")"

md: ${MAINFILE}
	Rscript -e "rmarkdown::render(\"${MAINFILE}\", \"rmarkdown::md_document\")"

revealjs: ${MAINFILE}
	Rscript -e "rmarkdown::render(\"${MAINFILE}\", \"revealjs::revealjs_presentation\", \"tutorial-slides.html\")"

assets: exercise-figures titanic-data

exercise-figures: assets/exercise-figures.R
	Rscript assets/exercise-figures.R
	mv exercise-figures.png assets/

titanic-data: assets/titanic-data.R
	Rscript assets/titanic-data.R
	mv titanic-data.png assets/
