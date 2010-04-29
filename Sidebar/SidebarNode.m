//
//  SidebarNode.m
//  Sidebar
//
//  Created by Matteo Bertozzi on 3/8/09.
//  Copyright 2009 Matteo Bertozzi. All rights reserved.
//

#import "SidebarNode.h"

@implementation SidebarNode

@synthesize actionTarget;
@synthesize action;

@synthesize badgeValue;
@synthesize hasBadge;

@synthesize parentKey;
@synthesize nodeType;
@synthesize nodeKey;
@synthesize caption;
@synthesize icon;
@synthesize data;

- (id)init {
	if ((self = [super init])) {
		children = [[NSMutableArray alloc] init];
		hasBadge = NO;
	}

	return self;
}

- (void)dealloc {
	[children release];

	[caption release];
	[icon release];
	[data release];

	[super dealloc];
}

- (void)setAction:(SEL)aSelector target:(id)target {
	actionTarget = target;
	action = aSelector;
}

- (BOOL)hasAction {
	return(action != NULL);
}

- (void)setBadgeValue:(NSInteger)value {
	hasBadge = YES;
	badgeValue = value;
}

- (void)unsetBadgeValue {
	hasBadge = NO;
}

- (void)addChild:(SidebarNode *)node {
	[children addObject:node];
}

- (void)insertChild:(SidebarNode *)node atIndex:(NSUInteger)index {
	[children insertObject:node atIndex:index];
}

- (void)removeChild:(SidebarNode *)node {
	[children removeObject:node];
}

- (NSInteger)indexOfChild:(SidebarNode *)node {
	return [children indexOfObject:node];
}

- (SidebarNode *)childAtIndex:(int)index {
	return([children objectAtIndex:index]);
}

- (NSUInteger)numberOfChildren {
	return([children count]);
}

- (BOOL)isDraggable {
	return(nodeType != kSidebarNodeTypeSection);
}

@end
