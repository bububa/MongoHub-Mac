//
//  AuthWindowController.m
//  MongoHub
//
//  Created by Syd on 10-5-6.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "Configure.h"
#import "AuthWindowController.h"
#import "DatabasesArrayController.h"
#import "Database.h"
#import "Connection.h"

@implementation AuthWindowController

@synthesize userTextField;
@synthesize passwordTextField;
@synthesize dbname;
@synthesize conn;
@synthesize managedObjectContext;
@synthesize databasesArrayController;

- (id)init {
    if (![super initWithWindowNibName:@"Auth"]) return nil;
    return self;
}

- (void)dealloc {
    [userTextField release];
    [passwordTextField release];
    [dbname release];
    [managedObjectContext release];
    [databasesArrayController release];
    [conn release];
    [super dealloc];
}

- (void)windowDidLoad {
    //NSLog(@"New Connection Window Loaded");
    [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthWindowWillClose object:nil];
    dbname = nil;
}

- (IBAction)cancel:(id)sender {
    dbname = nil;
    [self close];
}

- (IBAction)save:(id)sender {
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        db.user = [userTextField stringValue];
        db.password = [passwordTextField stringValue];
    }else {
        db = [databasesArrayController newObjectWithConn:conn name:dbname user:[userTextField stringValue] password:[passwordTextField stringValue]];
        [databasesArrayController addObject:db];
        [db release];
    }
    [self saveAction];
    [self close];
}

- (void) saveAction {
    
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

@end
