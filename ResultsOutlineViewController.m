//
//  ResultsOutlineViewController.m
//  MongoHub
//
//  Created by Syd on 10-4-26.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "ResultsOutlineViewController.h"

@implementation ResultsOutlineViewController

@synthesize myOutlineView;
@synthesize results;

- (id)init
{
	if (self = [super init]) {
		results = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc {
    [myOutlineView deselectAll:nil];
    [myOutlineView release];
    [results release];
    [super dealloc];
}

- (void)awakeFromNib
{
	[myOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

#pragma mark -
#pragma mark NSOutlineView dataSource methods

// Returns the child item at the specified index of a given item.
- (id)outlineView:(NSOutlineView *)outlineView
			child:(int)index
		   ofItem:(id)item
{
	// If the item is the root item, return the corresponding mailbox object
	if([outlineView levelForItem:item] == -1)
	{
		return [results objectAtIndex:index];
	}
	
	// If the item is a root-level item (ie mailbox)
	return [[item objectForKey:@"child" ] objectAtIndex:index];
}

// Returns a Boolean value that indicates wheter a given item is expandable.
- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
	// If the item is a root-level item (ie mailbox) and it has emails in it, return true
	if(([[item objectForKey:@"child"] count] != 0))
		return true;
	
	else
		return false;
}

// Returns the number of child items encompassed by a given item.
- (int)outlineView:(NSOutlineView *)outlineView
numberOfChildrenOfItem:(id)item
{
	// If the item is the root item, return the number of mailboxes
	if([outlineView levelForItem:item] == -1)
	{
		return [results count];
	}
	// If the item is a root-level item (ie mailbox)
	return [[item objectForKey:@"child" ] count];
}

// Return the data object associated with the specified item.
- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item
{
    if([[tableColumn identifier] isEqualToString:@"name"])
    {
        return [item objectForKey:@"name"];
    }
    
    else if([[tableColumn identifier] isEqualToString:@"value"])
        return [item objectForKey:@"value"];
    else if([[tableColumn identifier] isEqualToString:@"type"])
        return [item objectForKey:@"type"];
	/*switch([outlineView levelForItem:item])
	{
            // If the item is a root-level item 
		case 0:
			if([[tableColumn identifier] isEqualToString:@"name"])
				return [item objectForKey:@"name" ];
			break;
            
		case 1:
			if([[tableColumn identifier] isEqualToString:@"name"])
			{
				return [item objectForKey:@"name"];
			}
			
			else if([[tableColumn identifier] isEqualToString:@"value"])
				return [item objectForKey:@"value"];
			else if([[tableColumn identifier] isEqualToString:@"type"])
				return [item objectForKey:@"type"];
			break;
	}*/
	
	return nil;
}

#pragma mark -
#pragma mark NSOutlineView delegate methods
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	switch([myOutlineView selectedRow])
	{
		case -1:
			break;
		default:{
            id currentItem = [myOutlineView itemAtRow:[myOutlineView selectedRow]];
            if ([myOutlineView isItemExpanded:currentItem]) {
                [myOutlineView collapseItem:currentItem collapseChildren:YES];
            }else {
                [myOutlineView expandItem:currentItem expandChildren:YES];
            }
			break;
        }
	}
}


#pragma mark helper methods
- (id)rootForItem:(id)item
{
    id parentItem = [myOutlineView parentForItem:item];
    if (parentItem) {
        return [self rootForItem:parentItem];
    }else {
        return item;
    }

}

@end
