//
//  QueryWindowController.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DatabasesArrayController;
@class ResultsOutlineViewController;
@class IndexesOutlineViewController;
@class Connection;
@class MongoDB;
@class BWInsetTextField;

@interface QueryWindowController : NSWindowController {
    NSManagedObjectContext *managedObjectContext;
    IBOutlet DatabasesArrayController *databasesArrayController;
    IBOutlet ResultsOutlineViewController *findResultsViewController;
    MongoDB *mongoDB;
    NSString *dbname;
    NSString *collectionname;
    Connection *conn;
    
    IBOutlet NSTextField *criticalTextField;
    IBOutlet NSTokenField *fieldsTextField;
    IBOutlet NSTextField *skipTextField;
    IBOutlet NSTextField *limitTextField;
    IBOutlet NSTextField *sortTextField;
    IBOutlet BWInsetTextField *totalResultsTextField;
    
    IBOutlet NSTextField *updateCriticalTextField;
    IBOutlet NSTextField *updateSetTextField;
    IBOutlet NSButton *upsetCheckBox;
    IBOutlet BWInsetTextField *updateResultsTextField;
    
    IBOutlet NSTextField *removeCriticalTextField;
    IBOutlet BWInsetTextField *removeResultsTextField;
    
    IBOutlet NSTextView *insertDataTextView;
    IBOutlet BWInsetTextField *insertResultsTextField;
    
    IBOutlet NSTextField *indexTextField;
    IBOutlet ResultsOutlineViewController *indexesOutlineViewController;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) DatabasesArrayController *databasesArrayController;
@property (nonatomic, retain) ResultsOutlineViewController *findResultsViewController;
@property (nonatomic, retain) MongoDB *mongoDB;
@property (nonatomic, retain) NSString *dbname;
@property (nonatomic, retain) NSString *collectionname;
@property (nonatomic, retain) Connection *conn;

@property (nonatomic, retain) NSTextField *criticalTextField;
@property (nonatomic, retain) NSTokenField *fieldsTextField;
@property (nonatomic, retain) NSTextField *skipTextField;
@property (nonatomic, retain) NSTextField *limitTextField;
@property (nonatomic, retain) NSTextField *sortTextField;
@property (nonatomic, retain) BWInsetTextField *totalResultsTextField;

@property (nonatomic, retain) NSTextField *updateCriticalTextField;
@property (nonatomic, retain) NSTextField *updateSetTextField;
@property (nonatomic, retain) NSButton *upsetCheckBox;
@property (nonatomic, retain) BWInsetTextField *updateResultsTextField;

@property (nonatomic, retain) NSTextField *removeCriticalTextField;
@property (nonatomic, retain) BWInsetTextField *removeResultsTextField;

@property (nonatomic, retain) NSTextView *insertDataTextView;
@property (nonatomic, retain) BWInsetTextField *insertResultsTextField;

@property (nonatomic, retain) NSTextField *indexTextField;
@property (nonatomic, retain) ResultsOutlineViewController *indexesOutlineViewController;

- (IBAction)findQuery:(id)sender;
- (IBAction)updateQuery:(id)sender;
- (IBAction)removeQuery:(id)sender;
- (IBAction)insertQuery:(id)sender;
- (IBAction)indexQuery:(id)sender;
- (IBAction)ensureIndex:(id)sender;
- (IBAction)reIndex:(id)sender;
- (IBAction)dropIndex:(id)sender;
@end
