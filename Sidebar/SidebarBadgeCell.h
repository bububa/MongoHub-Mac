//
//  TSBadgeCell.h
//  Tahsis
//
//  Created by Matteo Bertozzi on 11/29/08.
//  Copyright 2008 Matteo Bertozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SidebarBadgeCell : NSTextFieldCell {
	@private
		NSUInteger _badgeCount;
		NSImage *_icon;
		BOOL _hasBadge;
}

@property (readwrite) NSUInteger badgeCount;
@property (readwrite) BOOL hasBadge;
@property (readonly) NSImage *icon;

- (void)setIcon:(NSImage *)icon;

@end
