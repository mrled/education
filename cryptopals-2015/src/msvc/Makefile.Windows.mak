# This doesn't work at all at this point

!include vsvars.include.mak
	
all: challenge01.exe

.c.obj:
	$(cc) $(cflags) $(cvars) $*.c

challenge01.exe: challenge01.obj
	$(link) $(link) $(ldebug) $(conflags) -out:challenge01.exe challenge01.obj $(conlibs) 

