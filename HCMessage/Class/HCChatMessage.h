//
//  HCChatMessage.h
//  HC Message
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HCChatMessage : NSObject


@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *contentInfo;
@property (strong, nonatomic) NSString *messageID;


- (instancetype)initWithText:(NSString *)text;


@end
