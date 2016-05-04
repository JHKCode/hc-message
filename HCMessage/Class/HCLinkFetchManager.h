//
//  HCLinkFetchManager.h
//  HCMessage
//
//  Created by Jinhong Kim on 5/4/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HCLinkFetchInfo.h"


@interface HCLinkFetchManager : NSObject <NSURLSessionDataDelegate>

- (void)fetchLink:(NSString *)link completionHandler:(HCLinkFetchResultHandler)handler;
- (void)cancelAll;

@end
