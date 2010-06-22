//
//  ImportWindowController.m
//  MongoHub
//
//  Created by Syd on 10-6-16.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "ImportWindowController.h"
#import "Configure.h"
#import "DatabasesArrayController.h"
#import "Database.h"
#import "Connection.h"
#import "NSString+Extras.h"
#import "MongoDB.h"
#import <MCPKit_bundled/MCPKit_bundled.h>

@implementation ImportWindowController
@synthesize dbname;
@synthesize conn;
@synthesize db;
@synthesize mongoDB;
@synthesize databasesArrayController;
@synthesize managedObjectContext;
@synthesize dbsArrayController;
@synthesize tablesArrayController;
@synthesize hostTextField;
@synthesize portTextField;
@synthesize userTextField;
@synthesize passwdTextField;
@synthesize chunkSizeTextField;
@synthesize collectionTextField;
@synthesize progressIndicator;
@synthesize tablesPopUpButton;

- (id)init {
    if (![super initWithWindowNibName:@"Import"]) return nil;
    return self;
}

- (void)dealloc {
    [dbname release];
    [managedObjectContext release];
    [databasesArrayController release];
    [conn release];
    [db release];
    [mongoDB release];
    [dbsArrayController release];
    [tablesArrayController release];
    [hostTextField release];
    [portTextField release];
    [userTextField release];
    [passwdTextField release];
    [chunkSizeTextField release];
    [collectionTextField release];
    [progressIndicator release];
    [tablesPopUpButton release];
    [super dealloc];
}

- (void)windowDidLoad {
    //NSLog(@"New Connection Window Loaded");
    [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kImportWindowWillClose object:dbname];
    dbname = nil;
    db = nil;
    [dbsArrayController setContent:nil];
    [tablesArrayController setContent:nil];
    [progressIndicator setDoubleValue:0.0];
}

- (IBAction)import:(id)sender {
    [progressIndicator setUsesThreadedAnimation:YES];
    [progressIndicator startAnimation: self];
    [progressIndicator setDoubleValue:0];
    NSString *collection = [[NSString alloc] initWithString:[collectionTextField stringValue]];
    int chunkSize = [chunkSizeTextField intValue];
    if (![collection isPresent]) {
        NSRunAlertPanel(@"Error", @"Collection name could not be empty!", @"OK", nil, nil);
        return;
    }
    if (chunkSize == 0) {
        NSRunAlertPanel(@"Error", @"Chunk Size could not be 0!", @"OK", nil, nil);
        return;
    }
    NSString *tablename = [[NSString alloc] initWithString:[tablesPopUpButton titleOfSelectedItem]];
    int total = [self importCount:tablename];
    NSString *user=nil;
    NSString *password=nil;
    Database *mongodb = [databasesArrayController dbInfo:conn name:dbname];
    if (mongodb) {
        user = mongodb.user;
        password = mongodb.password;
    }
    [mongodb release];
    [self doImportFromTable:tablename toCollection:collection withChunkSize:chunkSize fromId:0 totalResults:total user:user password:password];
    [progressIndicator stopAnimation: self];
    [tablename release];
    [collection release];
}

- (long long int)importCount:(NSString *)tableName
{
    NSString *query = [[NSString alloc] initWithFormat:@"select count(*) counter from %@", tableName];
    MCPResult *theResult = [db queryString:query];
    [query release];
    NSArray *row = [theResult fetchRowAsArray];
    NSLog(@"count: %@", [row objectAtIndex:0]);
    return [[row objectAtIndex:0] intValue];
}

- (void)doImportFromTable:(NSString *)tableName toCollection:(NSString *)collection withChunkSize:(int)chunkSize fromId:(int)fromId totalResults:(int)total user:(NSString *)user password:(NSString *)password
{
    if (total == 0) return;
    NSString *query = [[NSString alloc] initWithFormat:@"select * from %@ limit %d, %d", tableName, fromId, chunkSize];
    NSLog(@"query: %@", query);
    MCPResult *theResult = [db queryString:query];
    [query release];
    if ([theResult numOfRows] == 0) {
        return;
    }
    NSArray *theFields = [theResult fetchFieldNames];
    NSDictionary *fieldTypes = [theResult fetchTypesAsDictionary];
    int i = 1;
    while (NSDictionary *row = [theResult fetchRowAsDictionary]) {
        [progressIndicator setDoubleValue:(double)(fromId+i)/total];
        [mongoDB insertInDB:dbname 
                 collection:collection
                       user:user 
                   password:password 
                       data:row 
                     fields:theFields 
                 fieldTypes:(NSDictionary *)fieldTypes];
        i++;
    }
    if ([theResult numOfRows] < chunkSize) {
        return;
    }
    [self doImportFromTable:tableName toCollection:collection withChunkSize:chunkSize fromId:(fromId + chunkSize) totalResults:total user:user password:password];
}

- (IBAction)connect:(id)sender {
    if (db) {
        [dbsArrayController setContent:nil];
        [tablesArrayController setContent:nil];
        [progressIndicator setDoubleValue:0.0];
        [db release];
    }
    db = [[MCPConnection alloc] initToHost:[hostTextField stringValue] withLogin:[userTextField stringValue] password:[passwdTextField stringValue] usingPort:[portTextField intValue] ];
    NSLog(@"Connect: %d", [db isConnected]);
    if (![db isConnected])
    {
        NSRunAlertPanel(@"Error", @"Could not connect to the mysql server!", @"OK", nil, nil);
    }
    [db queryString:@"SET NAMES utf8"];
    [db queryString:@"SET CHARACTER SET utf8"];
    [db queryString:@"SET COLLATION_CONNECTION='utf8_general_ci'"];
    [db setEncoding:NSUTF8StringEncoding];
    MCPResult *dbs = [db listDBs];
    NSArray *row;
    NSMutableArray *databases = [[NSMutableArray alloc] initWithCapacity:[dbs numOfRows]];
    while (row = [dbs fetchRowAsArray]) {
        NSDictionary *database = [[NSDictionary alloc] initWithObjectsAndKeys:[row objectAtIndex:0], @"name", nil];
        [databases addObject:database];
        [database release];
    }
    [dbsArrayController setContent:databases];
    [databases release];
}

- (IBAction)showTables:(id)sender
{
    NSString *dbn;
    if (sender == nil && [[dbsArrayController arrangedObjects] count] > 0) {
        dbn = [[[dbsArrayController arrangedObjects] objectAtIndex:0] objectForKey:@"name"];
    }else {
        NSPopUpButton *pb = sender;
        dbn = [[NSString alloc] initWithString:[pb titleOfSelectedItem]];
    }
    if (![dbn isPresent]) {
        [dbn release];
        return;
    }
    [db selectDB:dbn];
    [dbn release];
    MCPResult *tbs = [db listTables];
    NSArray *row;
    NSMutableArray *tables = [[NSMutableArray alloc] initWithCapacity:[tbs numOfRows]];
    while (row = [tbs fetchRowAsArray]) {
        NSDictionary *table = [[NSDictionary alloc] initWithObjectsAndKeys:[row objectAtIndex:0], @"name", nil];
        [tables addObject:table];
        [table release];
    }
    [tablesArrayController setContent:tables];
    [tables release];
}

@end
