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
        
        if ( [URLString hasPrefix:@"http://"] == NO && [URLString hasPrefix:@"https://"] == NO ) {
            URLString = [NSString stringWithFormat:@"http://%@", URLString];
        }
        
        [self setURL:[NSURL URLWithString:URLString]];
        
        
        // data
        [self setData:[NSMutableData data]];
        
        
        // string encoding
        [self setEncoding:NSASCIIStringEncoding];
        
        
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
