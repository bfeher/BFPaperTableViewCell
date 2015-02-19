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
#import "UIColor+BFPaperColors.h"

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
    self.tapCircleColor = [[UIColor paperColorLimeA400] colorWithAlphaComponent:0.6f];
    self.tapCircleDiameter = bfPaperTableViewCell_tapCircleDiameterSmall;
    self.rippleFromTapLocation = YES;
    self.backgroundFadeColor = [UIColor colorWithWhite:1 alpha:0.2f];
    self.letBackgroundLinger = YES;

    // Other setup (eg. text labels, image views, etc.):
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated]; // Be sure to call super!
}

@end
