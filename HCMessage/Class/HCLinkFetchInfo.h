//
//  HCLinkFetchInfo.h
//  HCMessage
//
//  Created by Jinhong Kim on 5/4/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^HCLinkFetchResultHandler)(NSString *link, NSString *title, NSError *error);


@interface HCLinkFetchInfo : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSURL *URL;
@property (strong, nonatomic) NSMutableData *data;
@property (assign, nonatomic) NSStringEncoding encoding;
@property (strong, nonatomic) NSError *error;
@property (assign, nonatomic) NSUInteger retryCount;
@property (assign, nonatomic, getter=isFinished) BOOL finished;
@property (strong, nonatomic) HCLinkFetchResultHandler completionHandler;

- (instancetype)initWithLink:(NSString *)link completionHandler:(HCLinkFetchResultHandler)handler;

@end
