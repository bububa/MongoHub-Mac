//
//  JsonWindowController.h
//  MongoHub
//
//  Created by Syd on 10-12-27.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UKSyntaxColoredTextViewController.h"
@class DatabasesArrayController;
@class Connection;
@class MongoDB;

#ifndef UKSCTD_DEFAULT_TEXTENCODING
#define UKSCTD_DEFAULT_TEXTENCODING		NSUTF8StringEncoding
#endif

@interface JsonWindowController : NSWindowController <UKSyntaxColoredTextViewDelegate>{
    NSManagedObjectContext *managedObjectContext;
    DatabasesArrayController *databaseArrayController;
    Connection *conn;
    MongoDB *mongoDB;
    NSString *dbname;
    NSString *collectionname;
    NSDictionary *jsonDict;
    IBOutlet NSTextView *myTextView;
    IBOutlet NSProgressIndicator *progress;
    IBOutlet NSTextField *status;
    UKSyntaxColoredTextViewController *syntaxColoringController;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) DatabasesArrayController *databasesArrayController;
@property (nonatomic, retain) MongoDB *mongoDB;
@property (nonatomic, retain) NSString *dbname;
@property (nonatomic, retain) NSString *collectionname;
@property (nonatomic, retain) Connection *conn;
@property (nonatomic, retain) NSDictionary *jsonDict;
@property (nonatomic, retain) NSTextView *myTextView;

-(IBAction) save:(id)sender;
-(void) doSave;
-(IBAction)	recolorCompleteFile: (id)sender;

@end
