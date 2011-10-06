Hopefully-meaningful Metrics
============================

Based on Michael Feathers' [recent work](http://www.stickyminds.com/sitewide.asp?Function=edetail&ObjectType=COL&ObjectId=16679&tth=DYN&tt=siteemail&iDyn=2) in project churn and complexity.

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
