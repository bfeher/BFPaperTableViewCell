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
static const CGFloat bfPaperTableViewCell_tapCircleDiameterMedium = 462.f;
static const CGFloat bfPaperTableViewCell_tapCircleDiameterLarge = bfPaperTableViewCell_tapCircleDiameterMedium * 1.4f;
static const CGFloat bfPaperTableViewCell_tapCircleDiameterSmall = bfPaperTableViewCell_tapCircleDiameterMedium / 2.f;
static const CGFloat bfPaperTableViewCell_tapCircleDiameterDefault = -1.f;

@interface BFPaperTableViewCell : UITableViewCell
/** A flag to set YES to use Smart Color, or NO to use a custom color scheme. While Smart Color is recommended, customization is cool too. */
@property (nonatomic) BOOL usesSmartColor;

/** The UIColor to use for the circle which appears where you tap. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended. */
@property UIColor *tapCircleColor;

/** The UIColor to fade clear backgrounds to. 
    NOTE: Alpha values are ignored as they are controlled via the property: `backgroundFadeColor`.
 */
@property (nonatomic) UIColor *backgroundFadeColor;

/**
 *  A CGFloat value between 0 and 1 to which the background will fade into upon selection.
    Default is bfPaperCell_fadeConstant which is defined in BFPaperTableViewCell.m.
 */
@property CGFloat backgroundFadeAlpha;

/** The CGFloat value representing the Diameter of the tap-circle. By default it will be the result of MAX(self.frame.width, self.frame.height). Any value less than zero will result in default being used. The constants: tapCircleDiameterLarge, tapCircleDiameterMedium, and tapCircleDiameterSmall are also available for use. */
@property CGFloat tapCircleDiameter;

/** A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the button. Default is YES. */
@property BOOL rippleFromTapLocation;

@end
