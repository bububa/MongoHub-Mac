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
#import "AuthWindowController.h"
#import "ImportWindowController.h"
#import "ExportWindowController.h"
#import "ResultsOutlineViewController.h"
#import "DatabasesArrayController.h"
#import "Connection.h"
#import "Sidebar.h"
#import "SidebarNode.h"
#import "MongoDB.h"
#import "Tunnel.h"

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
@synthesize authWindowController;
@synthesize importWindowController;
@synthesize exportWindowController;


- (id)init {
    if (![super initWithWindowNibName:@"ConnectionWindow"]) return nil;
    return self;
}

- (void)sshConnected:(NSNotification*)aNotification {
    NSLog(@"connected");
}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSString *appVersion = [[NSString alloc] initWithFormat:@"version(%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey] ];
    [bundleVersion setStringValue: appVersion];
    [appVersion release];
    
    NSString *hostaddress;
    if ([conn.usessh intValue]==1) {
        NSString *portForward = [[NSString alloc] initWithFormat:@"L %d:%@:%d", conn.hostport, conn.bindaddress, conn.bindport];
        NSMutableArray *portForwardings = [NSMutableArray arrayWithObjects:portForward, nil];
        [portForward release];
        [sshTunnel setUser:conn.sshuser];
        [sshTunnel setPort:[conn.sshport intValue]];
        [sshTunnel setPortForwardings:portForwardings];
        [sshTunnel setAliveCountMax:3];
        [sshTunnel setAliveInterval:30];
        [sshTunnel setTcpKeepAlive:YES];
        [sshTunnel setCompression:YES];NSLog(@"here");
        [sshTunnel start];
        hostaddress = [NSString stringWithFormat:@"%@:%@", conn.host, conn.hostport];
    }else if ([conn.host isEqualToString:@"flame.mongohq.com"]) {
        hostaddress = [NSString stringWithFormat:@"%@:%@/%@", conn.host, conn.hostport, conn.defaultdb];
    }else {
        hostaddress = [NSString stringWithFormat:@"%@:%@", conn.host, conn.hostport];
    }
    mongoDB = [[MongoDB alloc] initWithConn:hostaddress];
    if ([conn.adminuser isPresent]) {
        [mongoDB authUser:conn.adminuser pass:conn.adminpass database:conn.defaultdb];
    }
    
    if (![conn.defaultdb isPresent]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDB:) name:kNewDBWindowWillClose object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCollection:) name:kNewCollectionWindowWillClose object:nil];
    
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
    [authWindowController release];
    [importWindowController release];
    [exportWindowController release];
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
    if ([conn.defaultdb isPresent]) {
        databases = [[NSMutableArray alloc] initWithObjects:conn.defaultdb, nil];
    }else {
        databases = [[NSMutableArray alloc ] initWithArray:[mongoDB listDatabases]];
    }
    
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
    if ([conn.defaultdb isPresent]) {
        NSRunAlertPanel(@"Error", @"Could not create database!", @"OK", nil, nil);
        return;
    }
    if (!addDBController)
    {
        addDBController = [[AddDBController alloc] init];
    }
    addDBController.managedObjectContext = self.managedObjectContext;
    addDBController.conn = self.conn;
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
    if ([conn.defaultdb isPresent]) {
        NSRunAlertPanel(@"Error", @"Could not drop database!", @"OK", nil, nil);
        return;
    }
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

- (IBAction)showAuth:(id)sender
{
    if ([conn.defaultdb isPresent]) {
        NSRunAlertPanel(@"Error", @"Could not auth for database!", @"OK", nil, nil);
        return;
    }
    
    if (!selectedDB) 
    {
        NSRunAlertPanel(@"Error", @"Please choose a database!", @"OK", nil, nil);
        return;
    }
    if (!authWindowController)
    {
        authWindowController = [[AuthWindowController alloc] init];
    }
    Database *db = [databaseArrayController dbInfo:conn name:[selectedDB caption]];
    if (db) {
        [authWindowController.userTextField setStringValue:db.user];
        [authWindowController.passwordTextField setStringValue:db.password];
    }else {
        [authWindowController.userTextField setStringValue:@""];
        [authWindowController.passwordTextField setStringValue:@""];
    }
    authWindowController.managedObjectContext = self.managedObjectContext;
    authWindowController.conn = self.conn;
    authWindowController.dbname = [selectedDB caption];
    [authWindowController showWindow:self];
}

- (IBAction)importFromMySQL:(id)sender
{
    if (selectedDB==nil) {
        NSRunAlertPanel(@"Error", @"Please specify a database!", @"OK", nil, nil);
        return;
    }
    if (!importWindowController)
    {
        importWindowController = [[ImportWindowController alloc] init];
    }
    importWindowController.managedObjectContext = self.managedObjectContext;
    importWindowController.conn = self.conn;
    importWindowController.mongoDB = mongoDB;
    importWindowController.dbname = [selectedDB caption];
    [importWindowController showWindow:self];
}

- (IBAction)exportToMySQL:(id)sender
{
    if (selectedDB==nil) {
        NSRunAlertPanel(@"Error", @"Please specify a database!", @"OK", nil, nil);
        return;
    }
    if (!exportWindowController)
    {
        exportWindowController = [[ExportWindowController alloc] init];
    }
    exportWindowController.managedObjectContext = self.managedObjectContext;
    exportWindowController.conn = self.conn;
    exportWindowController.mongoDB = mongoDB;
    exportWindowController.dbname = [selectedDB caption];
    [exportWindowController showWindow:self];
}

@end
