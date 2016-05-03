//
//  HCContentsInfoManager.m
//  HC Message
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import "HCContentsInfoManager.h"

#import "HCChatMessage.h"


static NSString * const HCContentInfoKeyMentions  = @"mentions";
static NSString * const HCContentInfoKeyEmoticons = @"emoticons";
static NSString * const HCContentInfoKeyLinks     = @"links";
static NSString * const HCContentInfoLinkKeyURL   = @"url";
static NSString * const HCContentInfoLinkKeyTitle = @"title";


@implementation HCContentsInfoManager


- (instancetype)init
{
    self = [super init];
    
    if ( self ) {
        
    }
    
    return self;
}


- (void)parseMessage:(HCChatMessage *)message completionHandler:(void (^)(HCChatMessage *message, NSError *error))handler
{
    // check handler
    if ( handler == nil ) {
        return;
    }
    
    
    // check text
    if ( [[message text] length] == 0 ) {
        handler(message, nil);
        return;
    }
    

    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *mentions  = [self findMentions:[message text]];
        NSArray *emoticons = [self findEmoticons:[message text]];
        NSArray *links     = [self findLinks:[message text]];
        
        
        NSMutableDictionary *contentInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        
        if ( [mentions count] > 0 ) {
            [contentInfo setObject:mentions forKey:HCContentInfoKeyMentions];
        }
        
        if ( [emoticons count] > 0 ) {
            [contentInfo setObject:emoticons forKey:HCContentInfoKeyEmoticons];
        }
        
        if ( [links count] > 0 ) {
            [contentInfo setObject:links forKey:HCContentInfoKeyLinks];
        }
        
        
        if ( [contentInfo count] > 0 ) {
            NSError *error = nil;
            NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:contentInfo options:NSJSONWritingPrettyPrinted error:&error];
            
            if ( jsonData ) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                if ( jsonString ) {
                    [message setContentInfo:jsonString];
                }
            }
        }
        
        
        if ( handler ) {
            handler( message, nil );
        }
    });
}


#pragma mark - Find Mentions & Emoticons

/*
 
 You can use this method if you concern about performance since it walks through text only once.
 However, some post processing needs to remove '@' or parenthesis.
 output : @["@hello", "(emoticon1)", "(emoticon2)", "@world", ...]
 
 */
- (NSArray *)findMentionsAndEmoticons:(NSString *)text
{
    // check text
    if ( [text length] == 0 ) {
        return nil;
    }
    
    
    // create regular expression
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(@\\w+)|(\\((\\w{1,15})\\))"
                                                                           options:0
                                                                             error:&error];
    
    if ( error ) {
        NSLog(@"[ERROR] creating regular expression error, %@", error);
        
        return nil;
    }
    
    
    // find matches
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if ( [matches count] == 0 ) {
        return nil;
    }
    
    
    // create items
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[matches count]];
    
    for ( NSTextCheckingResult *match in matches ) {
        NSRange   matchRange  = [match range];
        NSString *matchString = [text substringWithRange:matchRange];
        
        if ( [matchString length] > 0 ) {
            [items addObject:matchString];
        }
    }
    
    
    if ( [items count] == 0 ) {
        return nil;
    }
    
    
    return items;
}


- (NSArray *)findMentions:(NSString *)text
{
    // check text
    if ( [text length] == 0 ) {
        return nil;
    }
    
    
    // create regular expression
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)"
                                                                           options:0
                                                                             error:&error];
    
    if ( error ) {
        NSLog(@"[ERROR] creating regular expression error, %@", error);
        
        return nil;
    }
    
    
    // find matches
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if ( [matches count] == 0 ) {
        return nil;
    }
    
    
    // create items
    NSMutableArray *mentions = [NSMutableArray arrayWithCapacity:[matches count]];
    
    for ( NSTextCheckingResult *match in matches ) {
        // check range count
        if ( [match numberOfRanges] < 2 ) {
            continue;
        }
        
        
        // find range without '@'
        NSRange matchRange = [match rangeAtIndex:1];
        
        if ( matchRange.location == NSNotFound || matchRange.length == 0 ) {
            continue;
        }
        
        
        // find string
        NSString *matchString = [text substringWithRange:matchRange];
        
        if ( [matchString length] > 0 ) {
            [mentions addObject:matchString];
        }
    }
    
    
    if ( [mentions count] == 0 ) {
        return nil;
    }
    
    
    return mentions;
}


- (NSArray *)findEmoticons:(NSString *)text
{
    // check text
    if ( [text length] == 0 ) {
        return nil;
    }
    
    
    // create regular expression
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\((\\w{1,15})\\)"
                                                                           options:0
                                                                             error:&error];
    
    if ( error ) {
        NSLog(@"[ERROR] creating regular expression error, %@", error);
        
        return nil;
    }
    
    
    // find matches
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if ( [matches count] == 0 ) {
        return nil;
    }
    
    
    // create items
    NSMutableArray *emoticons = [NSMutableArray arrayWithCapacity:[matches count]];
    
    for ( NSTextCheckingResult *match in matches ) {
        // check range count
        if ( [match numberOfRanges] < 2 ) {
            continue;
        }
        
        
        // find range without parenthesis
        NSRange matchRange  = [match rangeAtIndex:1];
        
        if ( matchRange.location == NSNotFound || matchRange.length == 0 ) {
            continue;
        }
        
        
        // find string
        NSString *matchString = [text substringWithRange:matchRange];
        
        if ( [matchString length] > 0 ) {
            [emoticons addObject:matchString];
        }
    }
    
    
    if ( [emoticons count] == 0 ) {
        return nil;
    }
    
    
    return emoticons;
}


- (NSArray *)findLinks:(NSString *)text
{
    // check text
    if ( [text length] == 0 ) {
        return nil;
    }
    
    
    // create data detector
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    if ( error ) {
        NSLog(@"[ERROR] creating link detector error, %@", error);

        return nil;
    }
    
    
    // find matches
    NSArray *matches = [detector matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if ( [matches count] == 0 ) {
        return nil;
    }

    
    // create items
    NSMutableArray *links = [NSMutableArray arrayWithCapacity:[matches count]];
    
    for ( NSTextCheckingResult *match in matches ) {
        NSRange   matchRange  = [match range];
        NSString *matchString = [text substringWithRange:matchRange];
        
        // skip if matchString is an email address.
        if ( [self isEmailAdress:matchString] ) {
            continue;
        }
        
        if ( [matchString length] > 0 ) {
            [links addObject:matchString];
        }
    }

    
    if ( [links count] == 0 ) {
        return nil;
    }
    
    
    return links;
}


- (BOOL)isEmailAdress:(NSString *)link
{
    if ( [link length] == 0 ) {
        return NO;
    }
    
    
    NSString    *regExp    = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExp];
    
    return [predicate evaluateWithObject:link];
}


@end
