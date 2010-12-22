//
//  NSProgressIndicator+Extras.m
//  MongoHub
//
//  Created by Syd on 10-12-22.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "NSProgressIndicator+Extras.h"


@implementation NSProgressIndicator (Extras)

- (void)start {
    [self startAnimation:self];
    [self setHidden:NO];
}

- (void)stop {
    [self setHidden:YES];
    [self stopAnimation:self];
}

@end
