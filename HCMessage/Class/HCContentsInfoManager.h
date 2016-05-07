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

- (void)parseMessage:(HCChatMessage *)message completionHandler:(void (^)(void))handler;

@end
