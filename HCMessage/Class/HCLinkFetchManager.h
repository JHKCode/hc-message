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

/**
 @method fetchLink:completionHandler:
 
 @abstract Fetch title of links
 @param link the link to fetch title
 @param completionHandler the handler is called when fetching title complete
 @discussion Fetched title is cached and there is retry logic when fetching fails.
 */
- (void)fetchLink:(NSString *)link completionHandler:(HCLinkFetchResultHandler)handler;

- (void)cancelAll;

@end
