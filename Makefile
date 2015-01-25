# Makefile

# Desired behaviors: 
# - Build all challenges with "make"
# - Build current experiment with "make love"
# - Keep binaries in the "bin/" 

# This basically doesn't work at all right now though

CC=gcc
CFLAGS=-Wno-format 
DBGOPTS=-g -O0

COMMONC=$(wildcard common/*.c)
COMMONH=$(wildcard common/*.h)
$(warning Found these common source files: $(COMMONC) $(COMMONH))

CODE=$(wildcard src/*.c)
BINS=$(patsubst src/%.c,%,$(CODE))
$(warning Found these main() source files: $(CODE))
$(warning Will compile to these binaries: $(BINS))

###########################

all: challenges

challenges: bin $(BINS) 
$(BINS): $(CODE) $(COMMONC) $(COMMONH)
	$(CC) $(CFLAGS) $(DBGOPTS) $(COMMONC) src/$@.c -o bin/$@

bin:
	mkdir bin

#challenges: $(CHALLENGES) $(COMMONC) $(COMMONH) 
#	$(CC) $(CHALLENGES) $(COMMONC)

# "make love". it's funny bc sex. 
# love.c contains current experiments. 
# other files in that directory (ex-loves) contain old experiments.
# they should not depend on each other
# they should all be compilable with something like this:
#love: love.exe love/love.c $(COMMONC) $(COMMONH)
#	$(CC) $(DBGOPTS) $(COMMONC) love/love.c -o love.exe
#	gdb ./love.exe -ex run
#	./love.exe

clean: 
	-rmdir /s /q bin
