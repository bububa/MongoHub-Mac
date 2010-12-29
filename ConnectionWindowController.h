//
//  ConnectionWindowController.h
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Tunnel.h"
@class BWSheetController;
@class DatabasesArrayController;
@class StatMonitorTableController;
@class AddDBController;
@class AddCollectionController;
@class AuthWindowController;
@class ImportWindowController;
@class ExportWindowController;
@class ResultsOutlineViewController;
@class Connection;
@class Sidebar;
@class SidebarNode;
@class MongoDB;

@interface ConnectionWindowController : NSWindowController {
    NSManagedObjectContext *managedObjectContext;
    IBOutlet DatabasesArrayController *databaseArrayController;
    IBOutlet ResultsOutlineViewController *resultsOutlineViewController;
    Connection *conn;
    MongoDB *mongoDB;
    IBOutlet Sidebar *sidebar;
    IBOutlet NSTextField *resultsTitle;
    IBOutlet NSProgressIndicator *loaderIndicator;
    IBOutlet NSButton *reconnectButton;
    IBOutlet NSButton *monitorButton;
    IBOutlet BWSheetController *monitorSheetController;
    IBOutlet StatMonitorTableController *statMonitorTableController;
    NSMutableArray *databases;
    NSMutableArray *collections;
    SidebarNode *selectedDB;
    SidebarNode *selectedCollection;
    Tunnel *sshTunnel;
    AddDBController *addDBController;
    AddCollectionController *addCollectionController;
    AuthWindowController *authWindowController;
    ImportWindowController *importWindowController;
    ExportWindowController *exportWindowController;
    IBOutlet NSTextField *bundleVersion;
    BOOL exitThread;
    BOOL monitorStopped;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) DatabasesArrayController *databaseArrayController;
@property (nonatomic, retain) ResultsOutlineViewController *resultsOutlineViewController;
@property (nonatomic, retain) Connection *conn;
@property (nonatomic, retain) MongoDB *mongoDB;
@property (nonatomic, retain) Sidebar *sidebar;
@property (nonatomic, retain) NSMutableArray *databases;
@property (nonatomic, retain) NSMutableArray *collections;
@property (nonatomic, retain) SidebarNode *selectedDB;
@property (nonatomic, retain) SidebarNode *selectedCollection;
@property (nonatomic, retain) Tunnel *sshTunnel;
@property (nonatomic, retain) NSTextField *resultsTitle;
@property (nonatomic, retain) NSProgressIndicator *loaderIndicator;
@property (nonatomic, retain) NSButton *monitorButton;
@property (nonatomic, retain) NSButton *reconnectButton;
@property (nonatomic, retain) BWSheetController *monitorSheetController;
@property (nonatomic, retain) StatMonitorTableController *statMonitorTableController;
@property (nonatomic, retain) AddDBController *addDBController;
@property (nonatomic, retain) AddCollectionController *addCollectionController;
@property (nonatomic, retain) NSTextField *bundleVersion;
@property (nonatomic, retain) AuthWindowController *authWindowController;
@property (nonatomic, retain) ImportWindowController *importWindowController;
@property (nonatomic, retain) ExportWindowController *exportWindowController;

- (void)reloadSidebar;
- (void)reloadDBList;
- (void)useDB:(id)sender;
- (void)useCollection:(id)sender;
- (IBAction)reconnect:(id)sender;
- (IBAction)showServerStatus:(id)sender;
- (IBAction)showDBStats:(id)sender;
- (IBAction)showCollStats:(id)sender;
- (IBAction)createDBorCollection:(id)sender;
- (IBAction)importFromMySQL:(id)sender;
- (IBAction)exportToMySQL:(id)sender;
- (void)dropCollection:(NSString *)collectionname 
                 ForDB:(NSString *)dbname;
- (void)createDB;
- (void)createCollectionForDB:(NSString *)dbname;
- (IBAction)dropDBorCollection:(id)sender;
- (void)dropDB;
- (IBAction)query:(id)sender;
- (IBAction)showAuth:(id)sender;
-(void) checkTunnel;
- (void) connect:(BOOL)haveHostAddress;
- (void) tunnelStatusChanged: (Tunnel*) tunnel status: (NSString*) status;
- (void)dropWarning:(NSString *)msg;

- (IBAction)startMonitor:(id)sender;
- (IBAction)stopMonitor:(id)sender;
- (void)updateMonitor;
@end
