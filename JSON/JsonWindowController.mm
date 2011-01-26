//
//  JsonWindowController.m
//  MongoHub
//
//  Created by Syd on 10-12-27.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "JsonWindowController.h"
#import "Configure.h"
#import "NSProgressIndicator+Extras.h"
#import "DatabasesArrayController.h"
#import "Connection.h"
#import "MongoDB.h"
#import "NSString+Extras.h"

@implementation JsonWindowController
@synthesize managedObjectContext;
@synthesize databasesArrayController;
@synthesize mongoDB;
@synthesize conn;
@synthesize dbname;
@synthesize collectionname;
@synthesize jsonDict;
@synthesize myTextView;

- (id)init {
    if (![super initWithWindowNibName:@"JsonWindow"]) return nil;
    return self;
}

- (void)dealloc {
    [managedObjectContext release];
    [databasesArrayController release];
    [conn release];
    [mongoDB release];
    [dbname release];
    [collectionname release];
    [jsonDict release];
    [myTextView release];
    [syntaxColoringController setDelegate: nil];
	[syntaxColoringController release];
	syntaxColoringController = nil;
    [progress release];
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kJsonWindowWillClose object:nil];
    [super release];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSString *title = [[NSString alloc] initWithFormat:@"%@.%@ _id:%@", dbname, collectionname, [jsonDict objectForKey:@"value"]];
    [self.window setTitle:title];
    [title release];
    [myTextView setString:[jsonDict objectForKey:@"beautified"]];
    syntaxColoringController = [[UKSyntaxColoredTextViewController alloc] init];
	[syntaxColoringController setDelegate: self];
	[syntaxColoringController setView: myTextView];
}


-(void)	textViewControllerWillStartSyntaxRecoloring: (UKSyntaxColoredTextViewController*)sender
{
    // Show your progress indicator.
	[progress startAnimation: self];
	[progress display];
}


-(void)	textViewControllerDidFinishSyntaxRecoloring: (UKSyntaxColoredTextViewController*)sender
{
    // Hide your progress indicator.
	[progress stopAnimation: self];
	[progress display];
}

-(NSString *)syntaxDefinitionFilenameForTextViewController: (UKSyntaxColoredTextViewController*)sender
{
    return @"JSON";
}

-(void)	selectionInTextViewController: (UKSyntaxColoredTextViewController*)sender						// Update any selection status display.
              changedToStartCharacter: (NSUInteger)startCharInLine endCharacter: (NSUInteger)endCharInLine
                               inLine: (NSUInteger)lineInDoc startCharacterInDocument: (NSUInteger)startCharInDoc
               endCharacterInDocument: (NSUInteger)endCharInDoc;
{
	NSString*	statusMsg = nil;
	
	if( startCharInDoc < endCharInDoc )
	{
		statusMsg = NSLocalizedString(@"character %lu to %lu of line %lu (%lu to %lu in document).",@"selection description in syntax colored text documents.");
		statusMsg = [NSString stringWithFormat: statusMsg, startCharInLine +1, endCharInLine +1, lineInDoc +1, startCharInDoc +1, endCharInDoc +1];
	}
	else
	{
		statusMsg = NSLocalizedString(@"character %lu of line %lu (%lu in document).",@"insertion mark description in syntax colored text documents.");
		statusMsg = [NSString stringWithFormat: statusMsg, startCharInLine +1, lineInDoc +1, startCharInDoc +1];
	}
    
	[status setStringValue: statusMsg];
	[status display];
}

/* -----------------------------------------------------------------------------
 recolorCompleteFile:
 IBAction to do a complete recolor of the whole friggin' document.
 -------------------------------------------------------------------------- */

-(IBAction)	recolorCompleteFile: (id)sender
{
	[syntaxColoringController recolorCompleteFile: sender];
}

-(IBAction) save:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doSave) toTarget:self withObject:nil];
}

-(void) doSave
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [status setStringValue: @"Saving..."];
    [status display];
    [progress startAnimation: self];
	[progress display];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *_id = nil;
    if ([[jsonDict objectForKey:@"type"] isEqualToString:@"ObjectId"]) {
        _id = [NSString stringWithFormat:@"ObjectId(\"%@\")", [jsonDict objectForKey:@"value"]];
    }else {
        _id = [NSString stringWithFormat:@"\"%@\"", [jsonDict objectForKey:@"value"]];
    }
    NSMutableString *json = [[NSMutableString alloc] initWithString:[myTextView string]];
    [mongoDB saveInDB:dbname collection:collectionname user:user password:password jsonString:json _id:_id];
    [json release];
    [progress stopAnimation: self];
	[progress display];
    [status setStringValue: @"Saved"];
    [status display];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJsonWindowSaved object:nil];
    [pool release];
}
@end
