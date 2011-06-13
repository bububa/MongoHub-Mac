//
//  Tunnel.h
//  MongoHub
//
//  Created by Syd on 10-12-15.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Tunnel : NSObject <NSCoding> {
	id delegate;
	
	NSLock* lock;	
	NSTask* task;
	NSPipe* pipe;
	NSString* pipeData;
	NSDate* startDate;
	NSString* retStatus;
	BOOL isRunning;
	
	NSString* uid;
	NSString* name;
	NSString* host;
	int port;
	NSString* user;
	NSString* password;
    NSString* keyfile;
	int aliveInterval;
	int aliveCountMax;
	BOOL tcpKeepAlive;
	BOOL compression;
	NSString* additionalArgs;
	NSMutableArray* portForwardings;
}

@property(retain) NSString* uid;
@property(retain) NSString* name;
@property(retain) NSString* host;
@property(assign) int port;
@property(retain) NSString* user;
@property(retain) NSString* password;
@property(retain) NSString* keyfile;
@property(assign) int aliveInterval;
@property(assign) int aliveCountMax;
@property(assign) BOOL tcpKeepAlive;
@property(assign) BOOL compression;
@property(retain) NSString* additionalArgs;
@property(retain) NSMutableArray* portForwardings;

- (void)setDelegate:(id)val;
- (id)delegate;

-(BOOL) running; 
-(BOOL) checkProcess;
-(void) start;
-(void) stop;
-(void) readStatus;
-(NSArray*) prepareSSHCommandArgs;

-(void) tunnelLoaded;
-(void) tunnelSaved;
-(void) tunnelRemoved;

-(BOOL) keychainItemExists;
-(BOOL) keychainAddItem;
-(BOOL) keychainModifyItem;
-(BOOL) keychainDeleteItem;
-(NSString*) keychainGetPassword;
-(NSString*) keychainGetPasswordFromItemRef: (SecKeychainItemRef)item;

@end

@interface NSObject (Tunnel)

- (void) tunnelStatusChanged: (Tunnel*) tunnel status: (NSString*) status;

@end