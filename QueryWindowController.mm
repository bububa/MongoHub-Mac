//
//  QueryWindowController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "Configure.h"
#import "QueryWindowController.h"
#import "DatabasesArrayController.h"
#import "ResultsOutlineViewController.h"
#import "Connection.h"
#import "MongoDB.h"
#import <BWToolkitFramework/BWToolkitFramework.h>

@implementation QueryWindowController

@synthesize managedObjectContext;
@synthesize databasesArrayController;
@synthesize findResultsViewController;
@synthesize mongoDB;
@synthesize conn;
@synthesize dbname;
@synthesize collectionname;

@synthesize criticalTextField;
@synthesize fieldsTextField;
@synthesize skipTextField;
@synthesize limitTextField;
@synthesize sortTextField;
@synthesize totalResultsTextField;

@synthesize updateCriticalTextField;
@synthesize updateSetTextField;
@synthesize upsetCheckBox;
@synthesize updateResultsTextField;

@synthesize removeCriticalTextField;
@synthesize removeResultsTextField;

@synthesize insertDataTextView;
@synthesize insertResultsTextField;

@synthesize indexTextField;
@synthesize indexesOutlineViewController;


- (id)init {
    if (![super initWithWindowNibName:@"QueryWindow"]) return nil;
    return self;
}

- (void)dealloc {
    [managedObjectContext release];
    [databasesArrayController release];
    [findResultsViewController release];
    [conn release];
    [mongoDB release];
    [dbname release];
    [collectionname release];
    
    [criticalTextField release];
    [fieldsTextField release];
    [skipTextField release];
    [limitTextField release];
    [sortTextField release];
    [totalResultsTextField release];
    
    [updateCriticalTextField release];
    [updateSetTextField release];
    [upsetCheckBox release];
    [updateResultsTextField release];
    
    [removeCriticalTextField release];
    [removeResultsTextField release];
    
    [insertDataTextView release];
    [insertResultsTextField release];
    
    [indexTextField release];
    [indexesOutlineViewController release];
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSString *title = [[NSString alloc] initWithFormat:@"Query in %@.%@", dbname, collectionname];
    [self.window setTitle:title];
    [title release];
}

- (void)windowWillClose:(NSNotification *)notification {
    [self release];
}

- (IBAction)findQuery:(id)sender
{
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *critical = [criticalTextField stringValue];
    NSString *fields = [fieldsTextField stringValue];
    NSString *sort = [sortTextField stringValue];
    NSNumber *skip = [NSNumber numberWithInt:[skipTextField intValue]];
    NSNumber *limit;
    if ([skipTextField intValue] == 0) {
        limit = [NSNumber numberWithInt:30];
    }else {
        limit = [NSNumber numberWithInt:[skipTextField intValue]];
    }
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:[mongoDB findInDB:dbname 
                                                                           collection:collectionname 
                                                                                 user:user 
                                                                             password:password 
                                                                             critical:critical 
                                                                               fields:fields 
                                                                                 skip:skip 
                                                                                limit:limit
                                                                                 sort:sort]];
    int total = [mongoDB countInDB:dbname 
                       collection:collectionname 
                             user:user 
                         password:password 
                         critical:critical];
    [totalResultsTextField setStringValue:[NSString stringWithFormat:@"Total Results: %d", total]];
    findResultsViewController.results = results;
    [findResultsViewController.myOutlineView reloadData];
    [results release];
}

- (IBAction)updateQuery:(id)sender
{
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *critical = [updateCriticalTextField stringValue];
    NSString *fields = [updateSetTextField stringValue];
    NSNumber *upset = [NSNumber numberWithInt:[upsetCheckBox state]];
    int total = [mongoDB countInDB:dbname 
                        collection:collectionname 
                              user:user 
                          password:password 
                          critical:critical];
    [mongoDB updateInDB:dbname 
           collection:collectionname 
                 user:user 
             password:password 
             critical:critical 
               fields:fields 
                 upset:upset];
    [updateResultsTextField setStringValue:[NSString stringWithFormat:@"Affected Rows: %d", total]];
}

- (IBAction)removeQuery:(id)sender
{
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *critical = [updateCriticalTextField stringValue];
    int total = [mongoDB countInDB:dbname 
                        collection:collectionname 
                              user:user 
                          password:password 
                          critical:critical];
    [mongoDB removeInDB:dbname 
             collection:collectionname 
                   user:user 
               password:password 
               critical:critical];
    [removeResultsTextField setStringValue:[NSString stringWithFormat:@"Affected Rows: %d", total]];
}

- (IBAction) insertQuery:(id)sender
{
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *insertData = [insertDataTextView string];
    [mongoDB insertInDB:dbname 
             collection:collectionname 
                   user:user 
               password:password 
               insertData:insertData];
    [insertResultsTextField setStringValue:@"Completed!"];
}

- (IBAction) indexQuery:(id)sender
{
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:[mongoDB indexInDB:dbname 
                                                                            collection:collectionname 
                                                                                  user:user 
                                                                              password:password]];
    indexesOutlineViewController.results = results;
    [indexesOutlineViewController.myOutlineView reloadData];
    [results release];
}

- (IBAction) ensureIndex:(id)sender
{
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *indexData = [indexTextField stringValue];
    [mongoDB ensureIndexInDB:dbname 
             collection:collectionname 
                   user:user 
               password:password 
             indexData:indexData];
    [self indexQuery:nil];
}

- (IBAction) reIndex:(id)sender
{
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    [mongoDB reIndexInDB:dbname 
                  collection:collectionname 
                        user:user 
                    password:password];
    [self indexQuery:nil];
}

- (IBAction) dropIndex:(id)sender
{
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *indexName = [indexTextField stringValue];
    [mongoDB dropIndexInDB:dbname 
                  collection:collectionname 
                        user:user 
                    password:password 
                   indexName:indexName];
    [self indexQuery:nil];
}

@end
