//
//  ConnectionWindowController.m
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "Configure.h"
#import "NSString+Extras.h"
#import "NSProgressIndicator+Extras.h"
#import <BWToolkitFramework/BWToolkitFramework.h>
#import "ConnectionWindowController.h"
#import "QueryWindowController.h"
#import "AddDBController.h";
#import "AddCollectionController.h"
#import "AuthWindowController.h"
#import "ImportWindowController.h"
#import "ExportWindowController.h"
#import "ResultsOutlineViewController.h"
#import "DatabasesArrayController.h"
#import "StatMonitorTableController.h"
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
@synthesize loaderIndicator;
@synthesize monitorButton;
@synthesize reconnectButton;
@synthesize monitorSheetController;
@synthesize statMonitorTableController;
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

- (void) tunnelStatusChanged: (Tunnel*) tunnel status: (NSString*) status {
    NSLog(@"SSH TUNNEL STATUS: %@", status);
    if( [status isEqualToString: @"CONNECTED"] ){
        exitThread = YES;
        [self connect:YES];
    }
}

- (void) connect:(BOOL)haveHostAddress {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [loaderIndicator start];
    [reconnectButton setEnabled:NO];
    [monitorButton setEnabled:NO];
    bool connected;
    NSString *hostaddress = [[[NSString alloc] init] autorelease];
    if (!haveHostAddress && [conn.usessh intValue]==1) {
        NSString *portForward = [[NSString alloc] initWithFormat:@"L:%@:%@:%@:%@", conn.hostport, conn.host, conn.sshhost, conn.bindport];
        NSMutableArray *portForwardings = [[NSMutableArray alloc] initWithObjects:portForward, nil];
        [portForward release];
        if (!sshTunnel)
            sshTunnel =[[Tunnel alloc] init];
        [sshTunnel setDelegate:self];
        [sshTunnel setUser:conn.sshuser];
        [sshTunnel setHost:conn.sshhost];
        [sshTunnel setPassword:conn.sshpassword];
        [sshTunnel setKeyfile:conn.sshkeyfile];
        [sshTunnel setPort:[conn.sshport intValue]];
        [sshTunnel setPortForwardings:portForwardings];
        [sshTunnel setAliveCountMax:3];
        [sshTunnel setAliveInterval:30];
        [sshTunnel setTcpKeepAlive:YES];
        [sshTunnel setCompression:YES];
        //[sshTunnel start];
        [portForwardings release];
        return;
    }else if (!haveHostAddress && [conn.host isEqualToString:@"flame.mongohq.com"]) {
        hostaddress = [NSString stringWithFormat:@"%@:%@/%@", conn.host, conn.hostport, conn.defaultdb];
        connected = mongoDB = [[MongoDB alloc] initWithConn:hostaddress];
    }else {
        if ([conn.userepl intValue] == 1) {
            hostaddress = conn.repl_name;
            NSArray *tmp = [conn.servers componentsSeparatedByString:@","];
            NSMutableArray *hosts = [[NSMutableArray alloc] initWithCapacity:[tmp count]];
            for (NSString *h in tmp) {
                NSString *host = [h stringByTrimmingWhitespace];
                if ([host length] == 0) {
                    continue;
                }
                [hosts addObject:host];
            }
            connected = mongoDB = [[MongoDB alloc] initWithConn:conn.repl_name hosts:hosts];
            [hosts release];
        }else{
            hostaddress = [NSString stringWithFormat:@"%@:%@", conn.host, conn.hostport];
            connected = mongoDB = [[MongoDB alloc] initWithConn:hostaddress];
        }
    }
    [loaderIndicator stop];
    if (connected) {
        if ([conn.adminuser isPresent]) {
            [mongoDB authUser:conn.adminuser pass:conn.adminpass database:conn.defaultdb];
        }
        
        if (![conn.defaultdb isPresent]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDB:) name:kNewDBWindowWillClose object:nil];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCollection:) name:kNewCollectionWindowWillClose object:nil];
        [reconnectButton setEnabled:YES];
        [monitorButton setEnabled:YES];
        [self reloadSidebar];
        [self showServerStatus:nil];
    }
    [pool release];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    exitThread = NO;
    NSString *appVersion = [[NSString alloc] initWithFormat:@"version(%@[%@])", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey] ];
    [bundleVersion setStringValue: appVersion];
    [appVersion release];
    [self connect:NO];
    if ([conn.usessh intValue]==1) {
        [NSThread detachNewThreadSelector: @selector(checkTunnel) toTarget:self withObject:nil ];
    }
}

- (IBAction)reconnect:(id)sender
{
    [self connect:NO];
    if ([conn.usessh intValue]==1) {
        [NSThread detachNewThreadSelector: @selector(checkTunnel) toTarget:self withObject:nil ];
    }
}

- (void)checkTunnel {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    while(!exitThread){
		@synchronized(self){
            if ([sshTunnel running] == NO){
                [sshTunnel start];
            }else if( [sshTunnel running] == YES && [sshTunnel checkProcess] == NO ){
                [sshTunnel stop];
                [NSThread sleepForTimeInterval:2];
                [sshTunnel start];
            }
            [sshTunnel readStatus];
		}
		[NSThread sleepForTimeInterval:3];
	}
    [NSThread exit];
    [pool release];
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
    [loaderIndicator release];
    [reconnectButton release];
    [monitorButton release];
    [monitorSheetController release];
    [statMonitorTableController release];
    [bundleVersion release];
    [authWindowController release];
    [importWindowController release];
    [exportWindowController release];
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification {
    if ([sshTunnel running]) {
        [sshTunnel stop];
    }
    //exitThread = YES;
    resultsOutlineViewController = nil;
    selectedDB = nil;
    selectedCollection = nil;
    [super release];
}

- (void)reloadSidebar {
    [loaderIndicator start];
    [sidebar addSection:@"1" caption:@"DATABASES"];
    [self reloadDBList];
    [sidebar reloadData];
    [loaderIndicator stop];
}

- (void)reloadDBList {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [loaderIndicator start];
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
    [loaderIndicator stop];
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
    [loaderIndicator start];
    collections = [[NSMutableArray alloc] initWithArray:[mongoDB listCollections:dbname user:user password:password]];
    if ([collections count] == 0) {
        [collections addObject:@"test"];
    }
    [loaderIndicator stop];
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
    [loaderIndicator start];
    [resultsTitle setStringValue:[NSString stringWithFormat:@"Server %@:%@ stats", conn.host, conn.hostport]];
    NSArray *serverStats = [[NSArray alloc] initWithArray:[mongoDB serverStatus]];
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:serverStats];
    [serverStats release];
    resultsOutlineViewController.results = results;
    [resultsOutlineViewController.myOutlineView reloadData];
    [results release];
    [loaderIndicator stop];
    
}

- (IBAction)showDBStats:(id)sender 
{
    if (selectedDB==nil) {
        NSRunAlertPanel(@"Error", @"Please specify a database!", @"OK", nil, nil);
        return;
    }
    [loaderIndicator start];
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
    [loaderIndicator stop];
    //NSLog(@"STATUS: %@", results);
}

- (IBAction)showCollStats:(id)sender 
{NSLog(@"showCollStats");
    if (selectedDB==nil || selectedCollection==nil) {
        NSRunAlertPanel(@"Error", @"Please specify a collection!", @"OK", nil, nil);
        return;
    }
    [loaderIndicator start];
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
    [loaderIndicator stop];
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
        [self dropWarning:[NSString stringWithFormat:@"COLLECTION:%@", [selectedCollection caption]]];
    }else {
        [self dropWarning:[NSString stringWithFormat:@"DB:%@", [selectedDB caption]]];
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
    [loaderIndicator start];
    [mongoDB dropCollection:collectionname 
                      forDB:dbname 
                       user:user 
                   password:password];
    [loaderIndicator stop];
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
    [loaderIndicator start];
    [mongoDB dropDB:[selectedDB caption] 
                user:user 
            password:password];
    [loaderIndicator stop];
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

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertFirstButtonReturn)
    {
        if (selectedCollection) {
            [self dropCollection:[selectedCollection caption] ForDB:[selectedDB caption]];
        }else {
            [self dropDB];
        }
    }
}

- (void)dropWarning:(NSString *)msg
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:[NSString stringWithFormat:@"Drop this %@?", msg]];
    [alert setInformativeText:[NSString stringWithFormat:@"Dropped %@ cannot be restored.", msg]];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self window] modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

- (IBAction)startMonitor:(id)sender {
    monitorStopped = NO;
    [NSThread detachNewThreadSelector: @selector(updateMonitor) toTarget:self withObject:nil ];
    [monitorSheetController openSheet:sender];
    NSLog(@"startMonitor");
}

- (IBAction)stopMonitor:(id)sender {
    [monitorSheetController closeSheet:sender];
    monitorStopped = YES;
    NSLog(@"stopMonitor");
}

- (void)updateMonitor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDate *prev = [NSDate date];
    mongo::BSONObj a = [mongoDB serverStat];
    while (!monitorStopped) {
        [NSThread sleepForTimeInterval:1];
        NSDate *now = [NSDate date];
        mongo::BSONObj b = [mongoDB serverStat];
        NSDictionary *item = [mongoDB serverMonitor:a second:b currentDate:now previousDate:prev];
        a = b;
        prev = now;
        [statMonitorTableController addObject:item];
        
    }
    [NSThread exit];
    [pool release];
}

@end
