//
//  HCLinkFetchInfo.m
//  HCMessage
//
//  Created by Jinhong Kim on 5/4/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import "HCLinkFetchInfo.h"

@implementation HCLinkFetchInfo

- (instancetype)initWithLink:(NSString *)link completionHandler:(HCLinkFetchResultHandler)handler
{
    self = [super init];
    
    if ( self ) {
        // link
        [self setLink:link];

        
        // url
        NSString *URLString = link;
        
        if ( [link hasPrefix:@"http://"] == NO || [link hasPrefix:@"https://"] ) {
            URLString = [NSString stringWithFormat:@"http://%@", link];
        }
        
        [self setURL:[NSURL URLWithString:URLString]];
        
        
        // data
        [self setData:[NSMutableData data]];
        
        
        // retry count
        [self setRetryCount:0];
        
        
        // finished
        [self setFinished:NO];
        
        
        // completion handler
        [self setCompletionHandler:handler];
    }

    return self;
}

@end
