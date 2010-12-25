//
//  statMonitorArrayController.h
//  MongoHub
//
//  Created by Syd on 10-12-23.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BWTransparentTableView;

@interface StatMonitorTableController : NSControl {
    NSMutableArray * nsMutaryDataObj;
    IBOutlet BWTransparentTableView *nsTableView;
}

@property (nonatomic, retain) NSMutableArray * nsMutaryDataObj;
@property (nonatomic, retain) BWTransparentTableView *nsTableView;

- (void)addObject:(NSDictionary *)item;
- (int)numberOfRowsInTableView:(NSTableView *)pTableViewObj;

- (id) tableView:(NSTableView *)pTableViewObj 
objectValueForTableColumn:(NSTableColumn *)pTableColumn 
             row:(int)pRowIndex;


@end
