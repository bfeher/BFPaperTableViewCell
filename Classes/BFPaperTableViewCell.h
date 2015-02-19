//
//  BFPaperTableViewCell.h
//  BFPaperKit
//
//  Created by Bence Feher on 7/11/14.
//  Copyright (c) 2014 Bence Feher. All rights reserved.
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Bence Feher
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


#import <UIKit/UIKit.h>

// Nice circle diameter constants:
extern const CGFloat bfPaperTableViewCell_tapCircleDiameterMedium;
extern const CGFloat bfPaperTableViewCell_tapCircleDiameterLarge;
extern const CGFloat bfPaperTableViewCell_tapCircleDiameterSmall;
extern const CGFloat bfPaperTableViewCell_tapCircleDiameterFull;
extern const CGFloat bfPaperTableViewCell_tapCircleDiameterDefault;

@interface BFPaperTableViewCell : UITableViewCell

#pragma mark - Properties
#pragma mark Animation
/** A CGFLoat representing the duration of the animations which take place on touch DOWN! Default is 0.25f seconds. (Go Steelers) */
@property CGFloat touchDownAnimationDuration;
/** A CGFLoat representing the duration of the animations which take place on touch UP! Default is 2 * touchDownAnimationDuration seconds. */
@property CGFloat touchUpAnimationDuration;


#pragma mark Prettyness and Behaviour
/** A flag to set YES to use Smart Color, or NO to use a custom color scheme. While Smart Color is recommended, customization is cool too. */
@property (nonatomic) BOOL usesSmartColor;

/** A CGFLoat representing the diameter of the tap-circle as soon as it spawns, before it grows. Default is 5.f. */
@property CGFloat tapCircleDiameterStartValue;

/** The CGFloat value representing the Diameter of the tap-circle. By default it will be the result of MAX(self.frame.width, self.frame.height). tapCircleDiameterFull will calculate a circle that always fills the entire view. Any value less than or equal to tapCircleDiameterFull will result in default being used. The constants: tapCircleDiameterLarge, tapCircleDiameterMedium, and tapCircleDiameterSmall are also available for use. */
@property CGFloat tapCircleDiameter;

/** The CGFloat value representing how much we should increase the diameter of the tap-circle by when we burst it. Default is 100.f. */
@property CGFloat tapCircleBurstAmount;

/** The UIColor to use for the circle which appears where you tap. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended. */
@property UIColor *tapCircleColor;

/** The UIColor to fade clear backgrounds to. NOTE: Setting this defeats the "Smart Color" ability of the background fade. Alpha values less than 1 are recommended. */
@property UIColor *backgroundFadeColor;

/** A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the tab. Default is YES. */
@property (nonatomic) BOOL rippleFromTapLocation;

/** A BOOL flag that determines whether or not to keep the background around after a tap, essentially "highlighting/selecting" the cell. Note that this does not trigger setSelected:! It is purely aesthetic. Also this kinda clashes with cell.selectionStyle, so by defualt the constructor sets that to UITableViewCellSelectionStyleNone.
    Default is YES. */
@property BOOL letBackgroundLinger;

/** A BOOL flag indicating whether or not to always complete a full animation cycle (bg fade in, tap-circle grow and burst, bg fade out) before starting another one. NO will behave just like the other BFPaper controls, tapping rapidly spawns many circles which all fade out in turn. Default is YES. */
@property BOOL alwaysCompleteFullAnimation;

/**
 *  A CGFLoat to set the amount of time in seconds to delay the tap event / trigger to spawn circles. For example, if the tapDelay is set to 1.f, you need to press and hold the cell for 1.f seconds to trigger spawning a circle. Default is 0.1f.
 */
@property CGFloat tapDelay;
@end
