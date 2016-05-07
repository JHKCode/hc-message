//
//  HCMessageTableViewCell.h
//  HCMessage
//
//  Created by Jinhong Kim on 5/7/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHCMessageLabelTopMargin        10
#define kHCMessageLabelLeftMargin       10
#define kHCMessageLabelBottomMargin     10
#define kHCMessageLabelRightMargin      10


extern NSString * const HCMessageCellID;


@interface HCMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) NSString *messageID;

+ (NSDictionary *)messageAttribute;
+ (NSDictionary *)contentsAttribute;

@end
