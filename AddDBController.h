//
//  AddDBController.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddDBController : NSWindowController {
    IBOutlet NSTextField *dbname;
    IBOutlet NSTextField *user;
    IBOutlet NSSecureTextField *password;
    NSMutableDictionary *dbInfo;
}

@property (nonatomic, retain) NSTextField *dbname;
@property (nonatomic, retain) NSTextField *user;
@property (nonatomic, retain) NSSecureTextField *password;
@property (nonatomic, retain) NSMutableDictionary *dbInfo;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;
@end
