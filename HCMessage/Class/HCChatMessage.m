//
//  HCChatMessage.m
//  HC Message
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import "HCChatMessage.h"


NSString * const HCContentInfoKeyMentions  = @"mentions";
NSString * const HCContentInfoKeyEmoticons = @"emoticons";
NSString * const HCContentInfoKeyLinks     = @"links";


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
        [self setParsed:NO];
    }
    
    return self;
}


- (NSString *)JSONContents
{
    NSString *JSONString = nil;
    
    
    // collect content infos
    NSMutableDictionary *contentInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if ( [[self mentions] count] > 0 ) {
        [contentInfo setObject:[self mentions] forKey:HCContentInfoKeyMentions];
    }
    
    if ( [[self emoticons] count] > 0 ) {
        [contentInfo setObject:[self emoticons] forKey:HCContentInfoKeyEmoticons];
    }
    
    if ( [[self links] count] > 0 ) {
        [contentInfo setObject:[self links] forKey:HCContentInfoKeyLinks];
    }
    
    
    // generate json
    if ( [contentInfo count] > 0 ) {
        NSError *error = nil;
        NSData  *JSONData = [NSJSONSerialization dataWithJSONObject:contentInfo
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:&error];
        
        if ( JSONData ) {
            JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
        }
    }
    
    
    return JSONString;
}


@end
