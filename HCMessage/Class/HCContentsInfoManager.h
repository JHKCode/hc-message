//
//  HCContentsInfoManager.h
//  HC Message
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import <Foundation/Foundation.h>


@class HCChatMessage;


@interface HCContentsInfoManager : NSObject

/**
 @method parseMessage:completionHandler:
 
 @abstract Parse message and fetch title of links if message contains link
 @param message the message to parse
 @param completionHandler the handler is called when parsing and fetching title complete
 @discussion The result of parsing is saved in message instance
 */
- (void)parseMessage:(HCChatMessage *)message completionHandler:(void (^)(void))handler;

@end
