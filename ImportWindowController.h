//
//  ImportWindowController.h
//  MongoHub
//
//  Created by Syd on 10-6-16.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Connection;
@class DatabasesArrayController;
@class MCPConnection;
@class MongoDB;

@interface ImportWindowController : NSWindowController {
    NSManagedObjectContext *managedObjectContext;
    DatabasesArrayController *databasesArrayController;
    NSString *dbname;
    Connection *conn;
    MongoDB *mongoDB;
    MCPConnection *db;
    IBOutlet NSArrayController *dbsArrayController;
    IBOutlet NSArrayController *tablesArrayController;
    IBOutlet NSTextField *hostTextField;
    IBOutlet NSTextField *portTextField;
    IBOutlet NSTextField *userTextField;
    IBOutlet NSSecureTextField *passwdTextField;
    IBOutlet NSTextField *chunkSizeTextField;
    IBOutlet NSTextField *collectionTextField;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSPopUpButton *tablesPopUpButton;
}

@property (nonatomic, retain) Connection *conn;
@property (nonatomic, retain) MCPConnection *db;
@property (nonatomic, retain) MongoDB *mongoDB;
@property (nonatomic, retain) DatabasesArrayController *databasesArrayController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString *dbname;
@property (nonatomic, retain) NSArrayController *dbsArrayController;
@property (nonatomic, retain) NSArrayController *tablesArrayController;
@property (nonatomic, retain) NSTextField *hostTextField;
@property (nonatomic, retain) NSTextField *portTextField;
@property (nonatomic, retain) NSTextField *userTextField;
@property (nonatomic, retain) NSSecureTextField *passwdTextField;
@property (nonatomic, retain) NSTextField *chunkSizeTextField;
@property (nonatomic, retain) NSTextField *collectionTextField;
@property (nonatomic, retain) NSProgressIndicator *progressIndicator;
@property (nonatomic, retain) NSPopUpButton *tablesPopUpButton;

- (IBAction)connect:(id)sender;
- (IBAction)import:(id)sender;
- (IBAction)showTables:(id)sender;
- (long long int)importCount:(NSString *)tableName;
- (void)doImportFromTable:(NSString *)tableName toCollection:(NSString *)collection withChunkSize:(int)chunkSize fromId:(int)fromId totalResults:(int)total user:(NSString *)user password:(NSString *)password;


@end
