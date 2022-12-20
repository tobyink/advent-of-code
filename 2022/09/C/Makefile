.PHONY: all
all: run

.PHONY: clean
clean:
	rm -f main

main:
	gcc -o main `pkg-config --cflags glib-2.0` main.c `pkg-config --libs glib-2.0`

.PHONY: run
run: main
	./main
