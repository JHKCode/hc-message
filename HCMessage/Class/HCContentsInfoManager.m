//
//  HCContentsInfoManager.m
//  HC Message
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import "HCContentsInfoManager.h"

#import "HCEmoticon.h"
#import "HCChatMessage.h"
#import "HCLinkFetchManager.h"


@interface HCContentsInfoManager ()
{
    HCLinkFetchManager *_linkFetchManager;
}
@end


@implementation HCContentsInfoManager


- (instancetype)init
{
    self = [super init];
    
    if ( self ) {
        _linkFetchManager = [[HCLinkFetchManager alloc] init];
    }
    
    return self;
}


- (void)dealloc
{
    [_linkFetchManager cancelAll];
}


- (void)parseMessage:(HCChatMessage *)message completionHandler:(void (^)(void))handler
{
    // check handler
    if ( handler == nil ) {
        return;
    }
    
    
    // check text
    if ( [[message text] length] == 0 ) {
        handler();
        return;
    }
    
    
    // parse message in background thread
    __weak HCContentsInfoManager *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ( weakSelf == nil ) {
            return;
        }
        
        
        // find mentions
        NSArray *mentions = [weakSelf findMentions:[message text]];
        
        if ( [mentions count] > 0 ) {
            [message setMentions:mentions];
        }

        
        // find emoticons
        NSArray *emoticons = [weakSelf findEmoticons:[message text]];

        if ( [emoticons count] > 0 ) {
            [message setEmoticons:emoticons];
        }
        
        
        // find links
        NSArray *links = [weakSelf findLinks:[message text]];
        
        // fetch link title
        if ( [links count] > 0 ) {
            [weakSelf fetchLinks:links message:message completionHandler:handler];
            
            return;
        }

        
        // call handler if there is no links
        if ( handler ) {
            handler();
        }
    });
}


#pragma mark - Fetch Links


- (void)fetchLinks:(NSArray *)links message:(HCChatMessage *)message completionHandler:(void (^)(void))handler
{
    NSMutableArray      *linkInfos      = [NSMutableArray arrayWithCapacity:[links count]];
    NSMutableDictionary *linkErrors     = [NSMutableDictionary dictionaryWithCapacity:[links count]];
    __block NSUInteger   linkFetchCount = 0;
    
    for ( NSString *link in links ) {
        NSMutableDictionary *linkInfo = [NSMutableDictionary dictionaryWithObject:link forKey:HCContentInfoLinkKeyURL];
        
        [linkInfos addObject:linkInfo];
        
        // fetch a title of one link
        [_linkFetchManager fetchLink:link completionHandler:^(NSString *link, NSString *title, NSError *error) {
            linkFetchCount++;
            
            for ( NSMutableDictionary *linkInfo in linkInfos ) {
                if ( [link isEqualToString:[linkInfo objectForKey:HCContentInfoLinkKeyURL]] ) {
                    NSString *prevTitle = [linkInfo objectForKey:HCContentInfoLinkKeyTitle];
                    
                    if ( [prevTitle length] > 0 ) {
                        continue;
                    }
                    
                    if ( [title length] > 0 ) {
                        [linkInfo setObject:title forKey:HCContentInfoLinkKeyTitle];
                    }
                    else if ( error ) {
                        [linkErrors setObject:error forKey:link];
                    }
                }
            }

            
            // check if all links were fetched.
            if ( linkFetchCount == [links count] ) {
                [message setLinks:linkInfos];
                
                if ( [linkErrors count] > 0 ) {
                    [message setLinkFetchErrors:[NSDictionary dictionaryWithDictionary:linkErrors]];
                }
                
                if ( handler ) {
                    handler();
                }
            }
        }];
    }
}


#pragma mark - Find Mentions & Emoticons


/**
 @method findMentionsAndEmoticons:
 
 @param text
 @result array of mentions and emoticons (@["@hello", "(emoticon1)", "(emoticon2)", "@world", ...])
 @discussion You can use this method if you concern about performance since it walks through text only once.
 However, some post processing needs to remove '@' or parenthesis.
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


/**
 @method findMentions:
 
 @param text
 @result array of mentions without '@' (@["John", "Bob", "Foo", "Bar", ...])
 */
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


/**
 @method findEmoticons:
 
 @param text
 @result array of emoticons without parenthesis (@["heart", "sydney", "success", ...])
 */
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
        
        if ( [matchString length] > 0 && [HCEmoticon isCustomEmoticon:matchString] ) {
            [emoticons addObject:matchString];
        }
    }
    
    
    if ( [emoticons count] == 0 ) {
        return nil;
    }
    
    
    return emoticons;
}


/**
 @method findLinks:
 
 @param text
 @result array of link (@["www.google.com", "www.apple.com", ...])
 @discussion email address is not considered as link.
 */
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
