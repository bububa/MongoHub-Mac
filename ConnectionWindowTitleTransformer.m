//
//  ConnectionWindowTitleTransformer.m
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "ConnectionWindowTitleTransformer.h"
#import "Connection.h"

@implementation ConnectionWindowTitleTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}
+ (BOOL)allowsReverseTransformation {
    return NO;
}
- (id)transformedValue:(id)value 
{
    if (value)
    {
        if ([[value userepl] intValue] == 1) {
            return [NSString stringWithFormat:@"%@ [%@]", [value alias], [value repl_name] ];
        }else {
            return [NSString stringWithFormat:@"%@ [%@:%@]", [value alias], [value host], [value hostport] ];
        }

    }
	return nil;
}

@end
