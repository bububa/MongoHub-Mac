//
//  AddCollectionController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "Configure.h"
#import "AddCollectionController.h"


@implementation AddCollectionController

@synthesize dbname;
@synthesize collectionname;
@synthesize dbInfo;

- (id)init {
    if (![super initWithWindowNibName:@"NewCollection"]) return nil;
    return self;
}

- (void)dealloc {
    [dbname release];
    [collectionname release];
    [dbInfo release];
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewCollectionWindowWillClose object:dbInfo];
    dbInfo = nil;
}

- (IBAction)cancel:(id)sender {
    dbInfo = nil;
    [self close];
}

- (IBAction)add:(id)sender {
    if ([ [collectionname stringValue] length] == 0) {
        NSRunAlertPanel(@"Error", @"Collection name could not be empty", @"OK", nil, nil);
        return;
    }
    NSArray *keys = [[NSArray alloc] initWithObjects:@"dbname", @"collectionname", nil];
    NSString *colname = [[NSString alloc] initWithString:[collectionname stringValue]];
    NSArray *objs = [[NSArray alloc] initWithObjects:dbname, colname, nil];
    [colname release];
    if (!dbInfo) {
        dbInfo = [[NSMutableDictionary alloc] initWithCapacity:2]; 
    }
    dbInfo = [NSMutableDictionary dictionaryWithObjects:objs forKeys:keys];
    [objs release];
    [keys release];
    [self close];
}
@end
