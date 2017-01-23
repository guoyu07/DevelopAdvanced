[Shotgun debugging](https://en.wikipedia.org/wiki/Shotgun_debugging)

Shotgun debugging is a process of making relatively undirected changes to software in the hope that a bug will be perturbed out of existence. This has a relatively low success rate and can be very time consuming, except in very simple programs, or when used as an attempt to work around programming language features that one may be using improperly; it usually introduces more bugs[citation needed].

## Examples

Shotgun debugging can occur when working with multi-threaded applications. Attempting to debug a race condition by adding debugging code to the application is likely to change the speed of one thread in relation to another and could cause the problem to disappear. This is known as a Heisenbug. Although apparently a solution to the problem, it is a fix by pure chance and anything else that changes the behaviour of the threads could cause it to resurface — for example on a computer with a different scheduler. Code added to any part of the program could easily revert the effect of the "fix".

This article is based in part on the Jargon File, which is in the public domain.