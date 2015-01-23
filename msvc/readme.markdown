Was trying to get an MS compatible Makefile that would invoke cl.exe. 

Gave up after a couple of hours. This project is just for fun so I didn't wanna spend too much time on it. 

The most useful thing I got out of it was a Powershell script that would write the variables set when you run the `vsdevcmd.bat` file that ships with Visual Studio out to a file that can be included from an MS makefile. That way, I don't have to launch a cmd.exe instance (lmao) to run compiles on the command line. 
