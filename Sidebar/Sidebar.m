//
//  SidebarNode.m
//  Sidebar
//
//  Created by Matteo Bertozzi on 3/8/09.
//  Copyright 2009 Matteo Bertozzi. All rights reserved.
//

#import "SidebarBadgeCell.h"
#import "SidebarNode.h"
#import "Sidebar.h"

#define kSidebarPBoardType		@"SidebarNodePBoardType"

@implementation Sidebar

/* ============================================================================
 *  PUBLIC Constructors/Distructors
 */
- (void)dealloc {
	[_contents release];
	[_roots release];

	[super dealloc];
}

- (void)awakeFromNib {
	_contents = [[NSMutableDictionary alloc] init];
	_roots = [[NSMutableArray alloc] init];
	_defaultActionTarget = nil;
	_defaultAction = NULL;
		
	// Scroll to the top in case the outline contents is very long
	[[[self enclosingScrollView] verticalScroller] setFloatValue:0.0];
	[[[self enclosingScrollView] contentView] scrollToPoint:NSMakePoint(0, 0)];
	[self setBackgroundColor:[NSColor colorWithCalibratedRed:0.72 green:0.74 blue:0.79 alpha:1.0]];
	
	// Make outline view appear with gradient selection, and behave like the Finder, iTunes, etc.
	[self setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];

	// drag and drop support
	[self registerForDraggedTypes:[NSArray arrayWithObjects:kSidebarPBoardType, nil]];

	// Sup Delegates & Data Source
	[self setDataSource:self];
	[self setDelegate:self];
}

- (void)setDefaultAction:(SEL)action target:(id)target {
	_defaultAction = action;
	_defaultActionTarget = target;
}

/* ============================================================================
 *  PUBLIC Methods (Add Root Folder)
 */
- (void)addSection:(id)key
		caption:(NSString *)folderCaption
{
	if ([_contents objectForKey:key] != nil)
		[self removeItem:key];

	// Create and Setup Node
	SidebarNode *node = [[SidebarNode alloc] init];
	[node setNodeType:kSidebarNodeTypeSection];
	[node setCaption:folderCaption];
	[node setNodeKey:key];

	// Add Object to List
	[_contents setObject:node forKey:key];
	[_roots addObject:node];
	[node release];
}

/* ============================================================================
 *  PUBLIC Methods (Add Child)
 */
 - (void)addChild:(id)parentKey
			key:(id)key
			url:(NSString *)url
{
	[self addChild:parentKey key:key url:url action:NULL target:nil];
}

- (void)addChild:(id)parentKey
			key:(id)key
			url:(NSString *)url
		action:(SEL)aSelector
		target:(id)target
{
	NSString *caption = [[NSFileManager defaultManager] displayNameAtPath:url];
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:url];

	[self addChild:parentKey
				key:key
			caption:caption
				icon:icon
				data:url
			action:aSelector target:target];
}

- (void)addChild:(id)parentKey
			key:(id)key
		caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
{
	[self addChild:parentKey
				key:key
			caption:childCaption
				icon:childIcon
				data:nil
			action:NULL target:nil];
}

- (void)addChild:(id)parentKey
			key:(id)key
		caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
		action:(SEL)aSelector
		target:(id)target
{
	[self addChild:parentKey
				key:key
			caption:childCaption
				icon:childIcon
				data:nil
			action:aSelector target:target];
}

- (void)addChild:(id)parentKey
			key:(id)key
		caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
			data:(id)data
{
	[self addChild:parentKey
				key:key
			caption:childCaption
				icon:childIcon
				data:data
			action:NULL target:nil];
}

- (void)addChild:(id)parentKey
			key:(id)key
		caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
			data:(id)data
		action:(SEL)aSelector
		target:(id)target
{
	// Create and Setup Node
	SidebarNode *node = [[SidebarNode alloc] init];
	[node setAction:aSelector target:target];
	[node setNodeType:kSidebarNodeTypeItem];
	[node setCaption:childCaption];
	[node setParentKey:parentKey];
	[node setIcon:childIcon];
	[node setNodeKey:key];

	// Add Node as Child of Root Node
	SidebarNode *rootNode = [_contents objectForKey:parentKey];
	if (rootNode != nil)
		[rootNode addChild:node];
	else
		[_roots addObject:node];

	// Add Object to List
	[_contents setObject:node forKey:key];
	[node release];
}

/* ============================================================================
 *  PUBLIC Methods (Insert Child)
 */
- (void)insertChild:(id)parentKey
				key:(id)key
			atIndex:(NSUInteger)index
				url:(NSString *)url
			action:(SEL)aSelector
			target:(id)target
{
	NSString *caption = [[NSFileManager defaultManager] displayNameAtPath:url];
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:url];

	[self insertChild:parentKey
				key:key
			atIndex:index
			caption:caption
				icon:icon
				data:url
			action:aSelector target:target];
}

- (void)insertChild:(id)parentKey
				key:(id)key
			atIndex:(NSUInteger)index
			caption:(NSString *)childCaption
				icon:(NSImage *)childIcon
			action:(SEL)aSelector
			target:(id)target
{
	[self insertChild:parentKey
				key:key
			atIndex:index
			caption:childCaption
				icon:childIcon
				data:nil
			action:aSelector target:target];
}

- (void)insertChild:(id)parentKey
				key:(id)key
			atIndex:(NSUInteger)index
			caption:(NSString *)childCaption
				icon:(NSImage *)childIcon
				data:(id)data
			action:(SEL)aSelector
			target:(id)target
{
	// Create and Setup Node
	SidebarNode *node = [[SidebarNode alloc] init];
	[node setAction:aSelector target:target];
	[node setNodeType:kSidebarNodeTypeItem];
	[node setCaption:childCaption];
	[node setParentKey:parentKey];
	[node setIcon:childIcon];
	[node setNodeKey:key];

	// Add Node as Child of Root Node
	SidebarNode *rootNode = [_contents objectForKey:parentKey];
	if (rootNode != nil)
		[rootNode insertChild:node atIndex:index];
	else
		[_roots addObject:node];

	// Add Object to List
	[_contents setObject:node forKey:key];
	[node release];
}

/* ============================================================================
 *  PUBLIC Methods (Remove Items)
 */
- (void)removeItem:(id)key {
	SidebarNode *node = [_contents objectForKey:key];
	if (node == nil) return;
	
	id parentKey = [node parentKey];
	if (parentKey != nil) {
		SidebarNode *parentNode = [_contents objectForKey:parentKey];
		[parentNode removeChild:node];
	} else {
		[_roots removeObject:node];
	}
	
	[_contents removeObjectForKey:key];
}

- (void)removeChild:(id)key {
	[self removeItem:key];
}

- (void)removeFolder:(id)key {
	[self removeItem:key];
}

- (void)removeSection:(id)key {
	[self removeItem:key];
}

/* ============================================================================
 *  PUBLIC Methods (Selection)
 */
- (SidebarNode *)selectedNode {
	return([self itemAtRow:[self selectedRow]]);
}
 
- (void)selectItem:(id)key {
	SidebarNode *node = [_contents objectForKey:key];
	if (node != nil && [node nodeType] != kSidebarNodeTypeSection) {
		NSInteger rowIndex = [self rowForItem:node];
		if (rowIndex >= 0) [self selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:NO];
	}
}

- (void)unselectItem {
}

/* ============================================================================
 *  PUBLIC Methods (Expand/Collapse)
 */
- (void)expandAll {
	[super expandItem:nil expandChildren:YES];
}

- (void)expandItem:(id)key {
	if (key == nil || [key isKindOfClass:[SidebarNode class]]) {
		[super expandItem:key];
	} else {
		SidebarNode *node = [_contents objectForKey:key];
		if (node != nil && [node nodeType] != kSidebarNodeTypeItem)
			[super expandItem:node expandChildren:NO];
	}
}

- (void)expandItem:(id)key expandChildren:(BOOL)expandChildren {
	if (key == nil || [key isKindOfClass:[SidebarNode class]]) {
		[super expandItem:key expandChildren:expandChildren];
	} else {
		SidebarNode *node = [_contents objectForKey:key];
		if (node != nil && [node nodeType] != kSidebarNodeTypeItem)
			[super expandItem:node expandChildren:expandChildren];
	}
}

- (void)collapseAll {
	[super collapseItem:nil collapseChildren:YES];
}

- (void)collapseItem:(id)key {
	if (key == nil || [key isKindOfClass:[SidebarNode class]]) {
		[super collapseItem:key];
	} else {
		SidebarNode *node = [_contents objectForKey:key];
		if (node != nil && [node nodeType] != kSidebarNodeTypeItem)
			[super collapseItem:node collapseChildren:NO];
	}
}

- (void)collapseItem:(id)key expandChildren:(BOOL)collapseChildren {
	if (key == nil || [key isKindOfClass:[SidebarNode class]]) {
		[super collapseItem:key collapseChildren:collapseChildren];
	} else {
		SidebarNode *node = [_contents objectForKey:key];
		if (node != nil && [node nodeType] != kSidebarNodeTypeItem)
			[super collapseItem:node collapseChildren:collapseChildren];
	}
}

/* ============================================================================
 *  PUBLIC Methods (Badges)
 */
- (void)setBadge:(id)key count:(NSInteger)badgeValue {
	SidebarNode *node = [_contents objectForKey:key];
	[node setBadgeValue:badgeValue];
}

- (void)unsetBadge:(id)key {
	SidebarNode *node = [_contents objectForKey:key];
	[node unsetBadgeValue];
}

/* ============================================================================
 *  PRIVATE Data Source Delegates
 */

// The child item at index of a item. 
// If item is nil, returns the appropriate child item of the root object.
- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index
			ofItem:(id)item
{
	if (item == nil)
		return [_roots objectAtIndex:index];
	return [(SidebarNode *)item childAtIndex:index];
}

// Returns a Boolean value that indicates whether in a given item is expandable.
- (BOOL)outlineView:(NSOutlineView *)outlineView
		isItemExpandable:(id)item
{
	return((item == nil) ? NO : [item nodeType] != kSidebarNodeTypeItem);
}

// Returns the number of child items encompassed by a given item.
- (NSInteger)outlineView:(NSOutlineView *)outlineView
		numberOfChildrenOfItem:(id)item
{
	return((item == nil) ? [_roots count] : [item numberOfChildren]);
}

// Invoked by outlineView to return the data object 
// associated with the specified item.
- (id)outlineView:(NSOutlineView *)outlineView
		objectValueForTableColumn:(NSTableColumn *)tableColumn
		byItem:(id)item
{
	return [item caption];
}

/* ============================================================================
 *  PRIVATE Delegates
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView
	shouldSelectItem:(id)item
{
	return([item nodeType] != kSidebarNodeTypeSection);
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView
	dataCellForTableColumn:(NSTableColumn *)tableColumn
                      item:(id)item
{
	return [tableColumn dataCell];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
	shouldEditTableColumn:(NSTableColumn *)tableColumn
                     item:(id)item
{
	return NO;
}

-(BOOL)outlineView:(NSOutlineView*)outlineView
		isGroupItem:(id)item
{
	return([item nodeType] != kSidebarNodeTypeItem);
}

- (void)outlineView:(NSOutlineView *)outlineView
    willDisplayCell:(NSCell*)cell
     forTableColumn:(NSTableColumn *)tableColumn
               item:(id)item
{
	if ([cell isKindOfClass:[SidebarBadgeCell class]]) {
		SidebarBadgeCell *badgeCell = (SidebarBadgeCell *) cell;
		[badgeCell setBadgeCount:[item badgeValue]];
		[badgeCell setHasBadge:[item hasBadge]];
		[badgeCell setIcon:[item icon]];
	}
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	SidebarNode *selectedNode = [self selectedNode];
	if (selectedNode == nil) return;
	
	SEL action = NULL;
	id target = nil;
	
	if ([selectedNode hasAction]) {
		action = [selectedNode action];
		target = [selectedNode actionTarget];
	} else {
		action = _defaultAction;
		target = _defaultActionTarget;
	}

	// Run Thread with selected Action
	if (action != NULL)
		[NSThread detachNewThreadSelector:action toTarget:target withObject:selectedNode];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
	return([[fieldEditor string] length] > 0);
}

/* ============================================================================
 *  PRIVATE Delegates (Drag & Drop)
 */
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
	return NSDragOperationMove;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         writeItems:(NSArray *)items
       toPasteboard:(NSPasteboard *)pboard
{
	[pboard declareTypes:[NSArray arrayWithObjects:kSidebarPBoardType, nil] owner:self];

	// keep track of this nodes for drag feedback in "validateDrop"
	dragNodesArray = items;

	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
                  validateDrop:(id<NSDraggingInfo>)info
                  proposedItem:(id)item
            proposedChildIndex:(NSInteger)index
{
	if (item == nil)
		return NSDragOperationGeneric;

	if (![item isDraggable] && index >= 0)
		return NSDragOperationMove;

	return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView
		acceptDrop:(id<NSDraggingInfo>)info
			item:(id)targetItem
		childIndex:(NSInteger)index
{
	NSPasteboard *pboard = [info draggingPasteboard];	// get the pasteboard

	// user is doing an intra-app drag within the outline view
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject:kSidebarPBoardType]]) {
		id targetKey = (targetItem != nil) ? [targetItem nodeKey] : nil;
		
		for (NSInteger i = 0; i < [dragNodesArray count]; ++i) {
			SidebarNode *node = [dragNodesArray objectAtIndex:i];
			
			// Get Adjust Index Value
			NSInteger adjIdx = 0;
			if (targetKey != nil && [node parentKey] == targetKey && [targetItem indexOfChild:node] < index)
				adjIdx = -1;
			
			// Remove From Current Position
			if ([node parentKey] != nil) {
				SidebarNode *parentNode = [_contents objectForKey:[node parentKey]];
				[parentNode removeChild:node];
			} else {
				[_roots removeObject:node];
			}
			
			// Update Parent Key && Insert Item at New Location
			[node setParentKey:targetKey];
			if (targetKey != nil) {
				[((SidebarNode *)targetItem) insertChild:node atIndex:(index + i + adjIdx)];
			} else if (index < 0) {
				[_roots addObject:node];
			} else {
				[_roots insertObject:node atIndex:index];
			}
		}

		[self reloadData];
		return YES;
	}
	
	return NO;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event
                      inRect:(NSRect)cellFrame
                      ofView:(NSView *)controlView
{
	if ([controlView isKindOfClass:[Sidebar class]]) {
		Sidebar *sidebar = (Sidebar *) controlView;
		SidebarNode *node = [sidebar selectedNode];
		if (![node isDraggable])
			return NSCellHitTrackableArea;
	}

	return NSCellHitContentArea;
}

@end

