.PHONY: all
all: deps run

.PHONY: deps
deps:
	cpanm -n Exporter::Shiny

.PHONY: clean
clean:

.PHONY: run
run:
	perl -Ilib devel.advent/main.pl
