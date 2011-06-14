# MongoHub [![stillmaintained](http://stillmaintained.com/bububa/MongoHub-Mac.png)](http://stillmaintained.com/bububa/MongoHub-Mac)

## What is MongoHub
**[MongoHub](http://mongohub.todayclose.com/)** is a **[mongodb](http://mongodb.org)** GUI application.
This repository is a mac native version of MongoHub. If you are using windows or linux please download use the source from [http://github.com/bububa/MongoHub](http://github.com/bububa/MongoHub) which is made by Titanium Desktop.

![mongohub splash](https://github.com/downloads/bububa/MongoHub-Mac/MongoHubWall.png)

## System Requirements

Mac OS X(10.6.x), intel(64bit) based.

## Installation

You can either download the compiled executable file from [here](https://github.com/downloads/bububa/MongoHub-Mac/MongoHub.zip) 
or clone the source code and compile it on your own system.

## Build

Before builing ensure the following frameworks are present:
	/Library/PrivateFrameworks
		BWToolkitFramework.framework
		Sparkle.framework
		MCPKit_bundled.framework
		RegexKit.framework

The project also expects Boost libraries and the MongoDB client libraries.

The following Xcode project settings were changed from the master project:
	Header Search Paths: /usr/local/include/
	Library Search Paths: /opt/local/lib ~/source/mongo (path to mongo source)
	User Header Search Paths: /opt/local/include ~/source (path to source projects)

Thanks [HybridDBA](https://github.com/HybridDBA) add this build guide.

## Current Status

This project is very new. Any issues or bug reports are welcome. And I still don't have time to write a **usage guide**.

## History

** [Last Update 2.3.2] **
	
	- Fixed a bug in jsoneditor related to Date() object;
	- Add import/export to JSON/CSV functions;
	- Add support for ssh access use public key;
	- Add a function to remove single record in find query window;
	- Fixed a bug to create collection in a database which doesn't have collection;
	
** [Last Update 2.3.1] **
	
	- Fixed a bug in jsoneditor related to Date() object;
	- Add execution time in find panel;
	- Add reconnect support;
	- Fixed a bug in remove function.

** [2.3.0] **
	
	- Add mongo stat monitor;
	- Add replica set connection support;
	- Add reconnect support;
	- Add an JSON editor for found results with syntax highlight;
	- More flexible query style in find window;
	- Fixed long long int value overflow;
	- Fixed application crash during open/close connection window.

** [2.2.0] **
	
	- SSH Tunnel connection support;
	- Fixed a bug in display ObjectID type fields;
	- Fixed some UI bugs;
	- Fixed some memory leaks and random crashes;
	- Add confirm panel before drop database or collection;
	- Run queries in a seperate thread so that won't block the UI;
	- Fixed a bug to install on some 10.6.x(64bit) system.

** [2.1.0] **
	
	- Auto expand and collaspe finding results;
	- Display Date_t or Timestamp as GMT time format;
	- Fixed a bug in display ObjectIds in Array element;
	- Import data from mysql database to mongodb;
	- Export data from mongodb to mysql database.

** [2.0.9] **
	
	- Add support for mongohq.com;
	- Changed update behavior;
	- Fixed a bug to detect NumberLong type of BSONElement;
	- Fixed a bug in Array type of BSONElement.

** [2.0.8] **
	
	- Fix several UI bugs in Query Window;
	- Fix bugs in Find Query and Update Query;
	- Fix bugs related to ObjectId;
	- Fix copy&paste bugs.

** [2.0.7] **
	
	- Add sparkle framework to check application updates.

** [2.0.6] **
	
	- fixed some UI bugs;
	- add admin auth support.

## Contribute

I'd love to include your contributions, friend. Make sure your methods are
[TomDoc](http://tomdoc.org)'d properly, that existing tests pass, and
that any new functionality includes appropriate tests.

Then [send me a pull request](https://github.com/bububa/MongoHub-Mac/pull/new/master)!

## Contact Me

[Syd](mailto:prof.syd.xu@gmail.com) made this. Ping me on Twitter —[@bububa](http://twitter.com/bububa) — or [email](mailto:prof.syd.xu@gmail.com) me if you're having issues, or want me to merge in your pull request.