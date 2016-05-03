//
//  HCChatMessage.m
//  HC Message
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import "HCChatMessage.h"


@implementation HCChatMessage


#pragma mark - Class Method


+ (NSString *)uniqueMessageID
{
    CFUUIDRef    UUIDObject = CFUUIDCreate( kCFAllocatorDefault );
    CFStringRef  UUIDString = CFUUIDCreateString(kCFAllocatorDefault, UUIDObject);
    NSString    *UUID       = (__bridge NSString *)UUIDString;
    
    CFRelease(UUIDObject);
    CFRelease(UUIDString);
    
    return UUID;
}


#pragma mark - Init


- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    
    if ( self ) {
        [self setMessageID:[[self class] uniqueMessageID]];
        [self setText:text];
    }
    
    return self;
}


@end
