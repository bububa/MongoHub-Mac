//
//  QueryWindowController.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>
@class DatabasesArrayController;
@class ResultsOutlineViewController;
@class Connection;
@class MongoDB;

@interface QueryWindowController : NSWindowController {
    NSManagedObjectContext *managedObjectContext;
    DatabasesArrayController *databasesArrayController;
    IBOutlet ResultsOutlineViewController *findResultsViewController;
    IBOutlet NSOutlineView *findResultsOutlineView;
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
    IBOutlet NSTextField *findQueryTextField;
    IBOutlet NSProgressIndicator *findQueryLoaderIndicator;
    
    IBOutlet NSTextField *updateCriticalTextField;
    IBOutlet NSTextField *updateSetTextField;
    IBOutlet NSButton *upsetCheckBox;
    IBOutlet BWInsetTextField *updateResultsTextField;
    IBOutlet NSTextField *updateQueryTextField;
    IBOutlet NSProgressIndicator *updateQueryLoaderIndicator;
    
    IBOutlet NSTextField *removeCriticalTextField;
    IBOutlet BWInsetTextField *removeResultsTextField;
    IBOutlet NSTextField *removeQueryTextField;
    IBOutlet NSProgressIndicator *removeQueryLoaderIndicator;
    
    IBOutlet NSTextView *insertDataTextView;
    IBOutlet BWInsetTextField *insertResultsTextField;
    IBOutlet NSProgressIndicator *insertLoaderIndicator;
    
    IBOutlet NSTextField *indexTextField;
    IBOutlet ResultsOutlineViewController *indexesOutlineViewController;
    IBOutlet NSProgressIndicator *indexLoaderIndicator;
    
    IBOutlet NSTextView *mapFunctionTextView;
    IBOutlet NSTextView *reduceFunctionTextView;
    IBOutlet NSTextField *mrcriticalTextField;
    IBOutlet NSTextField *mroutputTextField;
    IBOutlet NSProgressIndicator *mrLoaderIndicator;
    IBOutlet ResultsOutlineViewController *mrOutlineViewController;
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
@property (nonatomic, retain) NSTextField *findQueryTextField;
@property (nonatomic, retain) NSOutlineView *findResultsOutlineView;
@property (nonatomic, retain) NSProgressIndicator *findQueryLoaderIndicator;

@property (nonatomic, retain) NSTextField *updateCriticalTextField;
@property (nonatomic, retain) NSTextField *updateSetTextField;
@property (nonatomic, retain) NSButton *upsetCheckBox;
@property (nonatomic, retain) BWInsetTextField *updateResultsTextField;
@property (nonatomic, retain) NSTextField *updateQueryTextField;
@property (nonatomic, retain) NSProgressIndicator *updateQueryLoaderIndicator;

@property (nonatomic, retain) NSTextField *removeCriticalTextField;
@property (nonatomic, retain) BWInsetTextField *removeResultsTextField;
@property (nonatomic, retain) NSTextField *removeQueryTextField;
@property (nonatomic, retain) NSProgressIndicator *removeQueryLoaderIndicator;

@property (nonatomic, retain) NSTextView *insertDataTextView;
@property (nonatomic, retain) BWInsetTextField *insertResultsTextField;
@property (nonatomic, retain) NSProgressIndicator *insertLoaderIndicator;

@property (nonatomic, retain) NSTextField *indexTextField;
@property (nonatomic, retain) ResultsOutlineViewController *indexesOutlineViewController;
@property (nonatomic, retain) NSProgressIndicator *indexLoaderIndicator;

@property (nonatomic, retain) NSTextView *mapFunctionTextView;
@property (nonatomic, retain) NSTextView *reduceFunctionTextView;
@property (nonatomic, retain) NSTextField *mrcriticalTextField;
@property (nonatomic, retain) NSTextField *mroutputTextField;
@property (nonatomic, retain) ResultsOutlineViewController *mrOutlineViewController;
@property (nonatomic, retain) NSProgressIndicator *mrLoaderIndicator;

- (IBAction)findQuery:(id)sender;
- (void)doFindQuery;
- (IBAction)expandFindResults:(id)sender;
- (IBAction)collapseFindResults:(id)sender;
- (IBAction)updateQuery:(id)sender;
- (void)doUpdateQuery;
- (IBAction)removeQuery:(id)sender;
- (void)doRemoveQuery;
- (IBAction)insertQuery:(id)sender;
- (void)doInsertQuery;
- (IBAction)indexQuery:(id)sender;
- (void)doIndexQuery;
- (IBAction)ensureIndex:(id)sender;
- (void)doEnsureIndex;
- (IBAction)reIndex:(id)sender;
- (void)doReIndex;
- (IBAction)dropIndex:(id)sender;
- (void)doDropIndex;
- (IBAction) mapReduce:(id)sender;
- (void)doMapReduce;

- (IBAction)findQueryComposer:(id)sender;
- (IBAction)updateQueryComposer:(id)sender;
- (IBAction)removeQueryComposer:(id)sender;

- (void)showEditWindow:(id)sender;
- (void)jsonWindowWillClose:(id)sender;

@end
