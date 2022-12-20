.PHONY: all
all: deps run

.PHONY: deps
deps:
	cpanm --cpanfile cpanfile --installdeps .

.PHONY: clean
clean:

.PHONY: run
run:
	perl -Ilib bin/main.pl
