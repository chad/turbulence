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

For now it just dumps out a hash of churn + flog metrics

WARNING
-------
When you run bule, it creates a JavaScript file which contains your file paths and names.  If those are sensitive, be careful where you put these generated files and who you share them with.
