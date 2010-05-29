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
#import "NSString+Extras.h"

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
@synthesize findQueryTextField;

@synthesize updateCriticalTextField;
@synthesize updateSetTextField;
@synthesize upsetCheckBox;
@synthesize updateResultsTextField;
@synthesize updateQueryTextField;

@synthesize removeCriticalTextField;
@synthesize removeResultsTextField;
@synthesize removeQueryTextField;

@synthesize insertDataTextView;
@synthesize insertResultsTextField;

@synthesize indexTextField;
@synthesize indexesOutlineViewController;

@synthesize mapFunctionTextView;
@synthesize reduceFunctionTextView;
@synthesize mrcriticalTextField;
@synthesize mroutputTextField;
@synthesize mrOutlineViewController;


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
    [findQueryTextField release];
    
    [updateCriticalTextField release];
    [updateSetTextField release];
    [upsetCheckBox release];
    [updateResultsTextField release];
    [updateQueryTextField release];
    
    [removeCriticalTextField release];
    [removeResultsTextField release];
    [removeQueryTextField release];
    
    [insertDataTextView release];
    [insertResultsTextField release];
    
    [indexTextField release];
    [indexesOutlineViewController release];
    
    [mapFunctionTextView release];
    [reduceFunctionTextView release];
    [mrcriticalTextField release];
    [mroutputTextField release];
    [mrOutlineViewController release];
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
    if ([limitTextField intValue] == 0) {
        limit = [NSNumber numberWithInt:30];
    }else {
        limit = [NSNumber numberWithInt:[limitTextField intValue]];
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

- (IBAction) mapReduce:(id)sender
{
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *mapFunction = [mapFunctionTextView string];
    NSString *reduceFunction = [reduceFunctionTextView string];
    NSString *critical = [mrcriticalTextField stringValue];
    NSString *output = [mroutputTextField stringValue];
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:[mongoDB mapReduceInDB:dbname 
                                                                                collection:collectionname 
                                                                                      user:user 
                                                                                  password:password 
                                                                                     mapJs:mapFunction 
                                                                                  reduceJs:reduceFunction 
                                                                                  critical:critical 
                                                                                    output:output]];
    mrOutlineViewController.results = results;
    [mrOutlineViewController.myOutlineView reloadData];
    [results release];
}

- (void)controlTextDidChange:(NSNotification *)nd
{
	NSTextField *ed = [nd object];
    
	if (ed == criticalTextField || ed == fieldsTextField || ed == sortTextField || ed == skipTextField || ed == limitTextField)
    {
        [self findQueryComposer:nil];
    }else if (ed == updateCriticalTextField || ed == updateSetTextField) {
        [self updateQueryComposer:nil];
    }else if (ed == removeCriticalTextField) {
        [self removeQueryComposer:nil];
    }

}

- (IBAction) findQueryComposer:(id)sender
{
    NSString *critical;
    if ([[criticalTextField stringValue] isPresent]) {
        critical = [[NSString alloc] initWithString:[criticalTextField stringValue]];
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    
    NSString *jsFields;
    if ([[fieldsTextField stringValue] isPresent]) {
        NSArray *keys = [[NSArray alloc] initWithArray:[[fieldsTextField stringValue] componentsSeparatedByString:@","]];
        NSMutableArray *tmpstr = [[NSMutableArray alloc] initWithCapacity:[keys count]];
        for (NSString *str in keys) {
            [tmpstr addObject:[NSString stringWithFormat:@"%@:1", str]];
        }
        jsFields = [[NSString alloc] initWithFormat:@", {%@}", [tmpstr componentsJoinedByString:@","] ];
        [keys release];
        [tmpstr release];
    }else {
        jsFields = [[NSString alloc] initWithString:@""];
    }
    
    NSString *sort;
    if ([[sortTextField stringValue] isPresent]) {
        sort = [[NSString alloc] initWithFormat:@".sort(%@)"];
    }else {
        sort = [[NSString alloc] initWithString:@""];
    }
    
    NSString *skip = [[NSString alloc] initWithFormat:@".skip(%d)", [skipTextField intValue]];
    NSString *limit = [[NSString alloc] initWithFormat:@".limit(%d)", [limitTextField intValue]];
    NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
    
    NSString *query = [NSString stringWithFormat:@"db.%@.find(%@%@)%@%@%@", col, critical, jsFields, sort, skip, limit];
    [critical release];
    [jsFields release];
    [sort release];
    [skip release];
    [limit release];
    [findQueryTextField setStringValue:query];
}

- (IBAction)updateQueryComposer:(id)sender
{
    NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
    NSString *critical;
    if ([[updateCriticalTextField stringValue] isPresent]) {
        critical = [[NSString alloc] initWithString:[updateCriticalTextField stringValue]];
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    NSString *sets;
    if ([[updateSetTextField stringValue] isPresent]) {
        //sets = [[NSString alloc] initWithFormat:@", {$set:%@}", [updateSetTextField stringValue]];
        sets = [[NSString alloc] initWithFormat:@", %@", [updateSetTextField stringValue]];
    }else {
        sets = [[NSString alloc] initWithString:@""];
    }
    NSString *upset;
    if ([upsetCheckBox state] == 1) {
        upset = [[NSString alloc] initWithString:@", true"];
    }else {
        upset = [[NSString alloc] initWithString:@", false"];
    }

    NSString *query = [NSString stringWithFormat:@"db.%@.update(%@%@%@)", col, critical, sets, upset];
    [critical release];
    [sets release];
    [upset release];
    [updateQueryTextField setStringValue:query];
}

- (IBAction)removeQueryComposer:(id)sender
{
    NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
    NSString *critical;
    if ([[removeCriticalTextField stringValue] isPresent]) {
        critical = [[NSString alloc] initWithString:[removeCriticalTextField stringValue]];
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    NSString *query = [NSString stringWithFormat:@"db.%@.remove(%@)", col, critical];
    [critical release];
    [removeQueryTextField setStringValue:query];
}
@end
