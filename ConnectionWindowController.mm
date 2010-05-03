//
//  ConnectionWindowController.m
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "Configure.h"
#import "NSString+Extras.h"
#import "ConnectionWindowController.h"
#import "QueryWindowController.h"
#import "AddDBController.h";
#import "AddCollectionController.h"
#import "ResultsOutlineViewController.h"
#import "DatabasesArrayController.h"
#import "Connection.h"
#import "Sidebar.h"
#import "SidebarNode.h"
#import "MongoDB.h"
#import <SSHTunnel/SSHTunnel.h>

@implementation ConnectionWindowController

@synthesize managedObjectContext;
@synthesize databaseArrayController;
@synthesize resultsOutlineViewController;
@synthesize conn;
@synthesize mongoDB;
@synthesize sidebar;
@synthesize databases;
@synthesize collections;
@synthesize selectedDB;
@synthesize selectedCollection;
@synthesize sshTunnel;
@synthesize addDBController;
@synthesize addCollectionController;
@synthesize resultsTitle;
@synthesize bundleVersion;

- (id)init {
    if (![super initWithWindowNibName:@"ConnectionWindow"]) return nil;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSString *appVersion = [[NSString alloc] initWithFormat:@"version(%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey] ];
    [bundleVersion setStringValue: appVersion];
    [appVersion release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDB:) name:kNewDBWindowWillClose object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCollection:) name:kNewCollectionWindowWillClose object:nil];
    NSString *hostaddress;
    if ([conn.usessh intValue]==1) {
        sshTunnel = [SSHTunnel sshTunnelWithHostname:conn.sshhost 
                                                port:[conn.sshport intValue] 
                                            username:conn.sshpassword 
                                            password:conn.sshpassword];
        [sshTunnel addLocalForwardWithBindAddress:conn.bindaddress 
                                         bindPort:[conn.bindport intValue] 
                                             host:conn.host 
                                         hostPort:[conn.hostport intValue]];
        [sshTunnel launch];
        hostaddress = [NSString stringWithFormat:@"%@:%@", conn.bindaddress, conn.bindport];
    }else {
        hostaddress = [NSString stringWithFormat:@"%@:%@", conn.host, conn.hostport];
    }
    mongoDB = [[MongoDB alloc] initWithConn:hostaddress];
    [self reloadSidebar];
    [self showServerStatus:nil];
}

- (void)dealloc {
    [managedObjectContext release];
    [databaseArrayController release];
    [resultsOutlineViewController release];
    [conn release];
    [mongoDB release];
    [sidebar release];
    [databases release];
    [collections release];
    [selectedDB release];
    [selectedCollection release];
    [sshTunnel release];
    [addDBController release];
    [addCollectionController release];
    [resultsTitle release];
    [bundleVersion release];
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification {
    [sshTunnel terminate];
    [sshTunnel waitUntilExit];
    selectedDB = nil;
    selectedCollection = nil;
    [self release];
}

- (void)reloadSidebar {
    [sidebar addSection:@"1" caption:@"DATABASES"];
    [self reloadDBList];
    [sidebar reloadData];
}

- (void)reloadDBList {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //[selectedDB release];
    selectedDB = nil;
    //[selectedCollection release];
    selectedCollection = nil;
    [collections release];
    collections = [[NSMutableArray alloc] init];
    [databases release];
    databases = [[NSMutableArray alloc ] initWithArray:[mongoDB listDatabases]];
    [databaseArrayController clean:conn databases:databases];
    [sidebar removeItem:@"2"];
    unsigned int i=1;
    for (NSString *db in databases) {
        [sidebar addChild:@"1" key:[NSString stringWithFormat:@"1.%d", i] caption:db icon:[NSImage imageNamed:@"dbicon.png"] action:@selector(useDB:) target:self];
        i ++ ;
    }
    [sidebar reloadData];
    [sidebar expandItem:@"1"];
    [pool release];
}

- (void)useDB:(id)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *dbname = [[NSString alloc] initWithFormat:@"%@", [sender caption]];
    if (![[selectedDB caption] isEqualToString:dbname]) {
        //[selectedDB release];
        selectedDB = (SidebarNode *)sender;
    }
    //[selectedCollection release];
    selectedCollection = nil;
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databaseArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    [collections release];
    collections = [[NSMutableArray alloc] initWithArray:[mongoDB listCollections:dbname user:user password:password]];
    [dbname release];
    
    [sidebar removeItem:@"2"];
    [sidebar addSection:@"2" caption:[[selectedDB caption] uppercaseString]];
    unsigned int i = 1;
    for (NSString *collection in collections) {
        [sidebar addChild:@"2" key:[NSString stringWithFormat:@"2.%d", i] caption:collection icon:[NSImage imageNamed:@"collectionicon.png"] action:@selector(useCollection:) target:self];
        i ++ ;
    }
    [sidebar reloadData];
    [sidebar setBadge:[selectedDB nodeKey] count:[collections count]];
    [sidebar expandItem:@"2"];
    [self showDBStats:nil];
    [pool release];
}

- (void)useCollection:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *collectionname = [[NSString alloc] initWithFormat:@"%@", [sender caption] ];
    if ([collectionname isPresent]) {
        //[selectedCollection release];
        selectedCollection = (SidebarNode *)sender;
        [self showCollStats:nil];
    }
    [collectionname release];
    [pool release];
}

- (IBAction)showServerStatus:(id)sender 
{
    [resultsTitle setStringValue:[NSString stringWithFormat:@"Server %@:%@ stats", conn.host, conn.hostport]];
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:[mongoDB serverStatus]];
    resultsOutlineViewController.results = results;
    [resultsOutlineViewController.myOutlineView reloadData];
    [results release];
    //NSLog(@"STATUS: %@", results);
}

- (IBAction)showDBStats:(id)sender 
{
    if (selectedDB==nil) {
        NSRunAlertPanel(@"Error", @"Please specify a database!", @"OK", nil, nil);
        return;
    }
    [resultsTitle setStringValue:[NSString stringWithFormat:@"Database %@ stats", [selectedDB caption]]];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databaseArrayController dbInfo:conn name:[selectedDB caption]];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:[mongoDB dbStats:[selectedDB caption] 
                                                                                user:user 
                                                                            password:password]];
    resultsOutlineViewController.results = results;
    [resultsOutlineViewController.myOutlineView reloadData];
    [results release];
    //NSLog(@"STATUS: %@", results);
}

- (IBAction)showCollStats:(id)sender 
{
    if (selectedDB==nil || selectedCollection==nil) {
        NSRunAlertPanel(@"Error", @"Please specify a collection!", @"OK", nil, nil);
        return;
    }
    [resultsTitle setStringValue:[NSString stringWithFormat:@"Collection %@.%@ stats", [selectedDB caption], [selectedCollection caption]]];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databaseArrayController dbInfo:conn name:[selectedDB caption] ];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:[mongoDB collStats:[selectedCollection caption] 
                                                                                 forDB:[selectedDB caption] 
                                                                                  user:user 
                                                                              password:password] ];
    //NSLog(@"STATUS: %@", results);
    resultsOutlineViewController.results = results;
    [resultsOutlineViewController.myOutlineView reloadData];
    [results release];
}

- (IBAction)createDBorCollection:(id)sender
{
    if (selectedCollection) {
        [self createCollectionForDB:[selectedDB caption]];
    }else {
        [self createDB];
    }
}

- (void)createCollectionForDB:(NSString *)dbname
{
    if (!addCollectionController)
    {
        addCollectionController = [[AddCollectionController alloc] init];
    }
    addCollectionController.dbname = dbname;
    [addCollectionController showWindow:self];
}

- (void)createDB
{
    if (!addDBController)
    {
        addDBController = [[AddDBController alloc] init];
    }
    [addDBController showWindow:self];
}

- (void)addDB:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (![sender object]) {
        return;
    }
    NSString *dbname = [[NSString alloc] initWithString:[[sender object] objectForKey:@"dbname"]];
    NSString *user = [[NSString alloc] initWithString:[[sender object] objectForKey:@"user"]];
    NSString *password = [[NSString alloc] initWithString:[[sender object] objectForKey:@"password"]];
    [mongoDB dbStats:dbname 
                user:user 
            password:password];
    [dbname release];
    [user release];
    [password release];
    [self reloadSidebar];
    [pool release];
}

- (void)addCollection:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (![sender object]) {
        return;
    }
    NSString *dbname = [[NSString alloc] initWithString:[[sender object] objectForKey:@"dbname"]];
    NSString *collectionname = [[NSString alloc] initWithString:[[sender object] objectForKey:@"collectionname"]];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databaseArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    [mongoDB createCollection:collectionname 
                        forDB:dbname 
                         user:user 
                     password:password];
    if ([[selectedDB caption] isEqualToString:dbname]) {
        [sidebar selectItem:[selectedDB nodeKey]];
    }
    [dbname release];
    [collectionname release];
    [pool release];
}

- (IBAction)dropDBorCollection:(id)sender
{
    if (selectedCollection) {
        [self dropCollection:[selectedCollection caption] ForDB:[selectedDB caption]];
    }else {
        [self dropDB];
    }
}

- (void)dropCollection:(NSString *)collectionname ForDB:(NSString *)dbname
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databaseArrayController dbInfo:conn name:[selectedDB caption]];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    [mongoDB dropCollection:collectionname 
                      forDB:dbname 
                       user:user 
                   password:password];
    if ([[selectedDB caption] isEqualToString:dbname]) {
        [sidebar selectItem:[selectedDB nodeKey]];
    }
    [pool release];
}

- (void)dropDB
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databaseArrayController dbInfo:conn name:[selectedDB caption]];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    [mongoDB dropDB:[selectedDB caption] 
                user:user 
            password:password];
    [self reloadSidebar];
    [pool release];
}

- (IBAction)query:(id)sender
{
    if (!selectedCollection) {
        NSRunAlertPanel(@"Error", @"Please choose a collection!", @"OK", nil, nil);
        return;
    }
    
    QueryWindowController *queryWindowController = [[QueryWindowController alloc] init];
    queryWindowController.managedObjectContext = self.managedObjectContext;
    queryWindowController.conn = conn;
    queryWindowController.dbname = [selectedDB caption];
    queryWindowController.collectionname = [selectedCollection caption];
    queryWindowController.mongoDB = mongoDB;
    [queryWindowController showWindow:sender];
}
@end
