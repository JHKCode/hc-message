//
//  HCEmoticons.h
//  HCMessage
//
//  Created by Jinhong Kim on 5/6/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    @class HCEmoticon
 
    @discussion   HCEmoticon contains all possible custom emoticons' string.
    HCEmoticon might download list of emoticons from sever
    becaus the service can add, remove, or update emoticons at any time.
 */

@interface HCEmoticon : NSObject

/**
 @method isCustomEmoticon
 
 @param emoticon string represents emoticon without parenthesis
 @result YES if emoticon is a custom emoticon, NO if not.
 */
+ (BOOL)isCustomEmoticon:(NSString *)emoticon;

@end
