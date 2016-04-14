
Idk if there's a better way to do this, but all these shits are done as Scala scripts. 

However, to use the AtomicTest library, you have to compile it first: 

    scalac AtomicTest.scala

Before you can run your Scala script: 

    scala -nocompdaemon ./atom32.classarguments.scala

Note that the `-nocompdaemon` argument shouldn't be required BUT IT IS because of a shitty bug. Ugh. 
