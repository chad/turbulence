Hopefully-meaningful Metrics
============================

Based on Michael Feathers' [recent work](http://www.stickyminds.com/sitewide.asp?Function=edetail&ObjectType=COL&ObjectId=16679&tth=DYN&tt=siteemail&iDyn=2) in project churn and complexity.

Here is how to read the graph (extracted from the above article):

* The upper right quadrant is particularly important.
These files have a high degree of complexity, and they change quite frequently.
There are a number of reasons why this can happen.
The one to look out for, though, is something I call runaway conditionals.
Sometimes a class becomes so complex that refactoring seems too difficult.
Developers hack if-then-elses into if-then-elses, and the rat’s nest grows. These classes are particularly ripe for a refactoring investment.

* The lower left quadrant. is the healthy closure region.
Abstractions here have low complexity and don't change much.

* The upper left is what I call the cowboy region. This is complex code that sprang from someone's head and didn't seem to grow incrementally.

* The bottom right is very interesting. I call it the fertile ground.
It can consist of files that are somewhat configurational, but often there are also files that act as incubators for new abstractions.
People add code, it grows, and then they factor outward, extracting new classes. The files churn frequently, but their complexity remains low.


Installation
------------

    $ gem install turbulence

Usage
-----
In your project directory, run:

    $ bule

and it will generate (and open) turbulence/turbulence.html 

Supported SCM systems
---------------------
Currently, bule defaults to using git. If you are using Perforce, call it like so:

    $ bule --scm p4

You need to have an environment variable P4CLIENT set to the name of your client workspace.

WARNING
-------
When you run bule, it creates a JavaScript file which contains your file paths and names.  If those are sensitive, be careful where you put these generated files and who you share them with.
