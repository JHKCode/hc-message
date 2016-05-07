//
//  HCMessageTableViewCell.m
//  HCMessage
//
//  Created by Jinhong Kim on 5/7/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import "HCMessageTableViewCell.h"


NSString * const HCMessageCellID = @"HCMessageTableViewCell";


@implementation HCMessageTableViewCell


+ (NSDictionary *)messageAttribute
{
    NSDictionary *attributes;
    
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragrahStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragrahStyle setAlignment:NSTextAlignmentLeft];
    
    
    attributes = @{ NSParagraphStyleAttributeName  : paragrahStyle,
                    NSFontAttributeName            : [UIFont systemFontOfSize:17],
                    NSForegroundColorAttributeName : [UIColor blackColor] };
    
    return attributes;
}


+ (NSDictionary *)contentsAttribute
{
    NSDictionary *attributes;
    
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragrahStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragrahStyle setAlignment:NSTextAlignmentLeft];
    
    
    attributes = @{ NSParagraphStyleAttributeName  : paragrahStyle,
                    NSFontAttributeName            : [UIFont systemFontOfSize:14],
                    NSForegroundColorAttributeName : [UIColor darkGrayColor] };
    
    return attributes;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self setMessageID:nil];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
