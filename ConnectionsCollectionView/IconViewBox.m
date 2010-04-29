//
//  IconViewBox.m
//  SEOBox
//
//  Created by Syd on 10-2-28.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "IconViewBox.h"


@implementation IconViewBox
@synthesize delegate;
@synthesize selectedFlag;


-(void)setSelected:(BOOL)flag {
    selectedFlag = flag;
}

-(BOOL)selected {
    return selectedFlag;
}

-(void)drawRect:(NSRect)rect {
    if([self selected]) {
        NSColor *bgColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.35];
        NSRect bgRect = rect;
        int minX = NSMinX(bgRect);
        int midX = NSMidX(bgRect);
        int maxX = NSMaxX(bgRect);
        int minY = NSMinY(bgRect);
        int midY = NSMidY(bgRect);
        int maxY = NSMaxY(bgRect);
        float radius = 25.0; // correct value to duplicate Panther's App Switcher
        NSBezierPath *bgPath = [NSBezierPath bezierPath];
        
        // Bottom edge and bottom-right curve
        [bgPath moveToPoint:NSMakePoint(midX, minY)];
        [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                         toPoint:NSMakePoint(maxX, midY) 
                                          radius:radius];
        
        // Right edge and top-right curve
        [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                         toPoint:NSMakePoint(midX, maxY) 
                                          radius:radius];
        
        // Top edge and top-left curve
        [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                         toPoint:NSMakePoint(minX, midY) 
                                          radius:radius];
        
        // Left edge and bottom-left curve
        [bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
                                         toPoint:NSMakePoint(midX, minY) 
                                          radius:radius];
        [bgPath closePath];
        
        [bgColor set];
        [bgPath fill];  
    }else {
        [self setWantsLayer:NO];
    }

    [super drawRect:rect];
}

// -------------------------------------------------------------------------------
//	hitTest:aPoint
// -------------------------------------------------------------------------------
- (NSView *)hitTest:(NSPoint)aPoint
{
    // don't allow any mouse clicks for subviews in this view
	if(NSPointInRect(aPoint,[self convertRect:[self bounds] toView:[self superview]])) {
		return self;
	} else {
		return nil;    
	}
}

-(void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];
	// check for click count above one, which we assume means it's a double click
	if([theEvent clickCount] > 1) {
		if(delegate && [delegate respondsToSelector:@selector(doubleClick:)]) {
			[delegate performSelector:@selector(doubleClick:) withObject:self];
		}
	}
}

@end
