//
//  AddDBController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "Configure.h"
#import "AddDBController.h"

@implementation AddDBController

@synthesize dbname;
@synthesize user;
@synthesize password;
@synthesize dbInfo;

- (id)init {
    if (![super initWithWindowNibName:@"NewDB"]) return nil;
    return self;
}

- (void)dealloc {
    [dbname release];
    [user release];
    [password release];
    [dbInfo release];
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewDBWindowWillClose object:dbInfo];
    dbInfo = nil;
}

- (IBAction)cancel:(id)sender {
    dbInfo = nil;
    [self close];
}

- (IBAction)add:(id)sender {
    if ([ [dbname stringValue] length] == 0) {
        NSRunAlertPanel(@"Error", @"Database name could not be empty", @"OK", nil, nil);
        return;
    }
    NSArray *keys = [[NSArray alloc] initWithObjects:@"dbname", @"user", @"password", nil];
    NSString *dbstr = [[NSString alloc] initWithString:[dbname stringValue]];
    NSString *userStr = [[NSString alloc] initWithString:[user stringValue]];
    NSString *passStr = [[NSString alloc] initWithString:[password stringValue]];
    NSArray *objs = [[NSArray alloc] initWithObjects:dbstr, userStr, passStr, nil];
    [dbstr release];
    [userStr release];
    [passStr release];
    if (!dbInfo) {
        dbInfo = [[NSMutableDictionary alloc] initWithCapacity:3]; 
    }
    dbInfo = [NSMutableDictionary dictionaryWithObjects:objs forKeys:keys];
    [objs release];
    [keys release];
    [self close];
}
@end
