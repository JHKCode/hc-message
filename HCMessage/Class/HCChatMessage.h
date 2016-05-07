//
//  HCChatMessage.h
//  HC Message
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const HCContentInfoKeyMentions;
extern NSString * const HCContentInfoKeyEmoticons;
extern NSString * const HCContentInfoKeyLinks;


@interface HCChatMessage : NSObject


@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *messageID;
@property (strong, nonatomic) NSArray  *mentions;
@property (strong, nonatomic) NSArray  *emoticons;
@property (strong, nonatomic) NSArray  *links;
@property (assign, nonatomic) BOOL      parsed;

- (instancetype)initWithText:(NSString *)text;
- (NSString *)JSONContents;


@end
