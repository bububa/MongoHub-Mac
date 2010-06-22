//
//  ExportWindowController.m
//  MongoHub
//
//  Created by Syd on 10-6-22.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "ExportWindowController.h"
#import "Configure.h"
#import "DatabasesArrayController.h"
#import "Database.h"
#import "Connection.h"
#import "NSString+Extras.h"
#import "MongoDB.h"
#import <MCPKit_bundled/MCPKit_bundled.h>
#import "FieldMapTableController.h"
#import "FieldMapDataObject.h"

@implementation ExportWindowController

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
@synthesize collectionTextField;
@synthesize progressIndicator;
@synthesize tablesPopUpButton;
@synthesize fieldMapTableController;

- (id)init {
    if (![super initWithWindowNibName:@"Export"]) return nil;
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
    [collectionTextField release];
    [progressIndicator release];
    [tablesPopUpButton release];
    [fieldMapTableController release];
    [super dealloc];
}

- (void)windowDidLoad {
    //NSLog(@"New Connection Window Loaded");
    [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kExportWindowWillClose object:dbname];
    dbname = nil;
    db = nil;
    [self initInterface];
}

- (IBAction)export:(id)sender {
    [progressIndicator setUsesThreadedAnimation:YES];
    [progressIndicator startAnimation: self];
    [progressIndicator setDoubleValue:0];
    NSString *collection = [[NSString alloc] initWithString:[collectionTextField stringValue]];
    if (![collection isPresent]) {
        NSRunAlertPanel(@"Error", @"Collection name could not be empty!", @"OK", nil, nil);
        return;
    }
    NSString *tablename = [[NSString alloc] initWithString:[tablesPopUpButton titleOfSelectedItem]];
    
    NSString *user=nil;
    NSString *password=nil;
    Database *mongodb = [databasesArrayController dbInfo:conn name:dbname];
    if (mongodb) {
        user = mongodb.user;
        password = mongodb.password;
    }
    [mongodb release];
    long long int total = [self exportCount:collection user:user password:password];
    if (total == 0) {
        return;
    }
    NSString *query = [[NSString alloc] initWithFormat:@"select * from %@ limit 1", tablename];
    MCPResult *theResult = [db queryString:query];
    [query release];
    NSDictionary *fieldTypes = [theResult fetchTypesAsDictionary];
    
    mongo::BSONObjBuilder fieldsBSONBuilder;
    for(FieldMapDataObject *field in fieldMapTableController.nsMutaryDataObj)
    {
        fieldsBSONBuilder.append([field.mongoKey UTF8String], 1);
    }
    mongo::BSONObj fieldsBSONObj = fieldsBSONBuilder.obj();
    std::auto_ptr<mongo::DBClientCursor> cursor = [mongoDB findAllCursorInDB:dbname collection:collection user:user password:password fields:fieldsBSONObj];
    int i = 1;
    while( cursor->more() )
    {
        mongo::BSONObj b = cursor->next();
        [self doExportToTable:tablename data:b fieldTypes:fieldTypes];
        [progressIndicator setDoubleValue:(double)i/total];
        i ++;
    }
    [progressIndicator stopAnimation: self];
    [tablename release];
    [collection release];
}

- (long long int)exportCount:(NSString *)collection user:(NSString *)user password:(NSString *)password
{
    long long int result = [mongoDB countInDB:dbname collection:collection user:user password:password critical:nil];
    return result;
}

- (void)doExportToTable:(NSString *)tableName data:(mongo::BSONObj) bsonObj fieldTypes:(NSDictionary *)fieldTypes
{
    int fieldsCount = [fieldMapTableController.nsMutaryDataObj count];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:fieldsCount];
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:fieldsCount];
    for(FieldMapDataObject *field in fieldMapTableController.nsMutaryDataObj)
    {
        id value;
        mongo::BSONElement e = bsonObj.getFieldDotted([field.mongoKey UTF8String]);
        if (e.eoo() == true) {
            continue;
        }
        if (e.type() == mongo::jstNULL) {
            continue;
        }else if (e.type() == mongo::Array) {
            continue;
        }else if (e.type() == mongo::Object) {
            continue;
        }else if (e.type() == mongo::Bool)  {
            if (e.boolean()) {
                value = [[NSString alloc] initWithString:@"1" ];
            }else {
                value = [[NSString alloc] initWithString:@"0"];
            }
        }else if (e.type() == mongo::NumberDouble) {
            value = [[NSNumber alloc] initWithDouble: e.numberDouble()];
        }else if (e.type() == mongo::NumberInt) {
            NSString *ft = [fieldTypes objectForKey:field.sqlKey];
            if ([ft isEqualToString:@"date"] || [ft isEqualToString:@"datetime"]) {
                value = [[NSDate alloc] initWithTimeIntervalSince1970:e.numberInt()];
            }else {
                value = [[NSNumber alloc] initWithInt: e.numberInt()];
            }
        }else if (e.type() == mongo::Date) {
            mongo::Date_t dt = (time_t)e.date();
            time_t timestamp = dt / 1000;
            value = [[NSDate alloc] initWithTimeIntervalSince1970:timestamp];
        }else if (e.type() == mongo::Timestamp) {
            time_t timestamp = (time_t)e.timestampTime();
            value = [[NSDate alloc] initWithTimeIntervalSince1970:timestamp];
        }else if (e.type() == mongo::BinData) {
            int binlen;
            const char* data = e.binData(binlen);
            value = [[NSData alloc] initWithBytes:data length:binlen];
        }else if (e.type() == mongo::NumberLong) {
            NSString *ft = [fieldTypes objectForKey:field.sqlKey];
            if ([ft isEqualToString:@"date"] || [ft isEqualToString:@"datetime"]) {
                value = [[NSDate alloc] initWithTimeIntervalSince1970:e.numberLong()];
            }else {
                value = [[NSNumber alloc] initWithLong: e.numberLong()];
            }
        }else if ([field.mongoKey isEqualToString:@"_id" ]) {
            if (e.type() == mongo::jstOID)
            {
                value = [[NSString alloc] initWithUTF8String: e.__oid().str().c_str()];
            }else {
                value = [[NSString alloc] initWithUTF8String: e.str().c_str()];
            }
        }else {
            value = [[NSString alloc] initWithUTF8String:e.str().c_str()];
        }
        NSString *sqlKey = [[NSString alloc] initWithString:field.sqlKey];
        NSString *quotedValue = [[NSString alloc] initWithString:[db quoteObject:value]];
        [value release];
        [fields addObject:sqlKey];
        [values addObject:quotedValue];
        [quotedValue release];
        [sqlKey release];
    }
    if ([fields count] > 0) {
        NSString *query = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (%@) values (%@)", tableName, [fields componentsJoinedByString:@","], [values componentsJoinedByString:@","]];
        //NSLog(@"query: %@", query);
        [db queryString:query];
        [query release];
    }
    [fields release];
    [values release];
}

- (IBAction)connect:(id)sender {
    if (db) {
        [self initInterface];
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
    //[self showTables:nil];
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
    [self showFields:nil];
}

- (IBAction)showFields:(id)sender
{
    NSString *tablename = [[NSString alloc] initWithString:[tablesPopUpButton titleOfSelectedItem]];
    MCPResult *theResult = [db queryString:[NSString stringWithFormat:@"select * from %@ limit 1", tablename]];
    [tablename release];
    NSArray *theFields = [theResult fetchFieldNames];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:[theFields count] ];
    for (int i=0; i<[theFields count]; i++) {
        NSString *fieldName = [theFields objectAtIndex:i];
        FieldMapDataObject *fd = [[FieldMapDataObject alloc] initWithSqlKey:fieldName andMongoKey:fieldName];
        [fields addObject:fd];
        [fd release];
    }
    [fieldMapTableController setNsMutaryDataObj:fields];
    [fieldMapTableController.idTableView reloadData];
    [fields release];
}

- (void)initInterface
{
    [dbsArrayController setContent:nil];
    [tablesArrayController setContent:nil];
    [progressIndicator setDoubleValue:0.0];
    [fieldMapTableController.nsMutaryDataObj removeAllObjects];
    [fieldMapTableController.idTableView reloadData];
}

@end
