//
//  SubclassOfPaperTableViewCell.m
//  BFPaperTableViewCell
//
//  This is an example of how to subclass BFPaperTableViewCell.
//  Note that you MUST call [super awakeFromNib] from within awakeFromNib!
//
//  Created by Bence Feher on 11/14/14.
//  Copyright (c) 2014 Bence Feher. All rights reserved.
//

#import "SubclassOfPaperTableViewCell.h"


@implementation SubclassOfPaperTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customSetup];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];   // THIS IS NECESSARY!
    [self customSetup];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // This is a good place to call your custom setup function.
    [self customSetup];
}

- (void)customSetup
{
    // Even though defaults values are cool, I'm setting all of the customizable options here as an example:
    self.usesSmartColor = NO;
    self.tapCircleColor = [[UIColor colorWithRed:198.f/255.f green:255.f/255.f blue:0/255.f alpha:1] colorWithAlphaComponent:0.6f];
    self.tapCircleDiameter = bfPaperTableViewCell_tapCircleDiameterSmall;
    self.rippleFromTapLocation = YES;
    self.backgroundFadeColor = [UIColor colorWithWhite:1 alpha:0.2f];
    self.letBackgroundLinger = YES;
    self.tapDelay = 0.f;
    
//    CGRect maskRect = CGRectMake(0, 0, 100, 100);
//    self.maskPath = [UIBezierPath bezierPathWithRoundedRect:maskRect cornerRadius:25.f];    // Just to show this property exists.
    // Other setup (eg. text labels, image views, etc.):
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated]; // Be sure to call super!
}

@end
