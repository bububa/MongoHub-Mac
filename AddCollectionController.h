//
//  AddCollectionController.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AddCollectionController : NSWindowController {
    IBOutlet NSTextField *collectionname;
    NSMutableString *dbname;
    NSMutableDictionary *dbInfo;
}

@property (nonatomic, retain) NSTextField *collectionname;
@property (nonatomic, retain) NSString *dbname;
@property (nonatomic, retain) NSMutableDictionary *dbInfo;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;

@end
