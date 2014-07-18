//
//  BFPaperTableViewCell.h
//  BFPaperKit
//
//  Created by Bence Feher on 7/11/14.
//  Copyright (c) 2014 Bence Feher. All rights reserved.
//

#import <UIKit/UIKit.h>

// Nice circle diameter constants:
static const CGFloat bfPaperTableViewCell_tapCircleDiameterMedium = 462.f;
static const CGFloat bfPaperTableViewCell_tapCircleDiameterLarge = bfPaperTableViewCell_tapCircleDiameterMedium * 1.4f;
static const CGFloat bfPaperTableViewCell_tapCircleDiameterSmall = bfPaperTableViewCell_tapCircleDiameterMedium / 2.f;


@interface BFPaperTableViewCell : UITableViewCell
/** A flag to set YES to use Smart Color, or NO to use a custom color scheme. While Smart Color is recommended, customization is cool too. */
@property (nonatomic) BOOL usesSmartColor;

/** The UIColor to use for the circle which appears where you tap. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended. */
@property UIColor *tapCircleColor;

/** The UIColor to fade clear backgrounds to. NOTE: Setting this defeats the "Smart Color" ability of the background fade. An alpha value of 1 is recommended, as the fade is a constant (clearBGFadeConstant) defined in the BFPaperTableViewCell.m. This bothers me too. */
@property UIColor *backgroundFadeColor;

/** The CGFloat value representing the Diameter of the tap-circle. By default it will be the result of MAX(self.frame.width, self.frame.height). Any value less than zero will result in default being used. Two constants, tapCircleDiameterLarge and tapCircleDiameterSmall are also available for use.*/
@property CGFloat tapCircleDiameter;

/** A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the button. Default is YES. */
@property BOOL rippleFromTapLocation;

@end
