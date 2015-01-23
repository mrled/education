# Makefile

# Desired behaviors: 
# - Build all challenges with "make"
# - Build current experiment with "make love"
# - Keep binaries in the "bin/" 

# This basically doesn't work at all right now though

CC=gcc
DBGOPTS=-g -O0

COMMONC=common/*.c
COMMONH=common/*.h

CHALLENGES=challenge/*.c

###########################

challenges: $(CHALLENGES) $(COMMONC) $(COMMONH) 
	$(CC) $(CHALLENGES) $(COMMONC)

# "make love". it's funny bc sex. 
# love.c contains current experiments. 
# other files in that directory (ex-loves) contain old experiments.
# they should not depend on each other
# they should all be compilable with something like this:
love: love.exe love/love.c $(COMMONC) $(COMMONH)
	$(CC) $(DBGOPTS) $(COMMONC) love/love.c -o love.exe
#	gdb ./love.exe -ex run
	./love.exe

clean:
	rm -rf build