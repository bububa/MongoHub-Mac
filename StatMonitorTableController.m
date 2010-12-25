//
//  statMonitorArrayController.m
//  MongoHub
//
//  Created by Syd on 10-12-23.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "StatMonitorTableController.h"
#import <BWToolkitFramework/BWToolkitFramework.h>

@implementation StatMonitorTableController
@synthesize nsMutaryDataObj;
@synthesize nsTableView;


- (void)dealloc {
    [nsMutaryDataObj release];
    [nsTableView release];
    [super dealloc];
}

- (void)addObject:(NSDictionary *)item {
    if (!nsMutaryDataObj) 
        nsMutaryDataObj = [[NSMutableArray alloc] initWithObjects:item, nil];
    else 
        [nsMutaryDataObj addObject:item];
    [nsTableView reloadData];
    NSInteger numberOfRows = [nsTableView numberOfRows];
    
    if (numberOfRows > 0)
        [nsTableView scrollRowToVisible:numberOfRows - 1];
}

- (int)numberOfRowsInTableView:(NSTableView *)pTableViewObj {
    return [self.nsMutaryDataObj count];
} // end numberOfRowsInTableView


- (id) tableView:(NSTableView *)pTableViewObj 
objectValueForTableColumn:(NSTableColumn *)pTableColumn
             row:(int)pRowIndex {
    NSDictionary * zDataObject = [self.nsMutaryDataObj objectAtIndex:pRowIndex];
    if (! zDataObject) {
        NSLog(@"tableView: objectAtIndex:%d = NULL",pRowIndex);
        return NULL;
    } // end if
    return [zDataObject objectForKey:[pTableColumn identifier]];
    
} // end tableView:objectValueForTableColumn:row:


@end
