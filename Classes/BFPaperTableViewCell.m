//
//  BFPaperTableViewCell.m
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


#import "BFPaperTableViewCell.h"

@interface BFPaperTableViewCell ()
@property CGPoint tapPoint;
@property CALayer *backgroundColorFadeLayer;
@property CAShapeLayer *maskLayer;
@property BOOL beganHighlight;
@property BOOL beganSelection;
@property BOOL haveTapped;
@property BOOL letGo;
@property BOOL growthFinished;
@property NSMutableArray *rippleAnimationQueue;
@property NSMutableArray *deathRowForCircleLayers;  // This is where old circle layers go to be killed :(
@end

@implementation BFPaperTableViewCell
// Constants used for tweaking the look/feel of:
// -animation durations:
static CGFloat const bfPaperCell_animationDurationConstant       = 0.2f;
static CGFloat const bfPaperCell_tapCircleGrowthDurationConstant = bfPaperCell_animationDurationConstant * 2;
// -the tap-circle's size:
static CGFloat const bfPaperCell_tapCircleDiameterStartValue     = 5.f; // for the mask
static CGFloat const bfPaperCell_tapCircleAutoSizeConstant       = 1.75;
static CGFloat const bfPaperCell_tapCircleGrowthBurst            = 40.f;
// -the tap-circle's beauty:
static CGFloat const bfPaperCell_tapFillConstant                 = 0.25f;
static CGFloat const bfPaperCell_fadeConstant                    = 0.15f;

#define BFPAPERCELL__DUMB_TAP_FILL_COLOR    [UIColor colorWithWhite:0.3 alpha:bfPaperCell_tapFillConstant]
#define BFPAPERCELL__DUMB_FADE_COLOR        [UIColor colorWithWhite:0.3 alpha:1]


#pragma mark - Default Initializers
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupBFPaperTableViewCell];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self setupBFPaperTableViewCell];
}


#pragma mark - Setup
- (void)setupBFPaperTableViewCell
{
    // Defaults:
    self.usesSmartColor = YES;
    self.tapCircleColor = nil;
    self.backgroundFadeColor = nil;
    self.tapCircleDiameter = -1.f;
    self.rippleFromTapLocation = YES;
    
    self.rippleAnimationQueue = [NSMutableArray array];
    self.deathRowForCircleLayers = [NSMutableArray array];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;

    self.textLabel.text = @"BFPaperTableViewCell";
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.maskLayer.frame = self.frame;
    
    // Setup background fade layer:
    self.backgroundColorFadeLayer = [[CALayer alloc] init];
    self.backgroundColorFadeLayer.frame = self.bounds;
    self.backgroundColorFadeLayer.backgroundColor = self.backgroundFadeColor.CGColor;
    [self.contentView.layer insertSublayer:self.backgroundColorFadeLayer atIndex:0];

    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
}



#pragma Parent Overides
/*- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    self.letGo = NO;
    self.growthFinished = NO;

    [self growTapCircle];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    self.letGo = YES;
    
    if (self.growthFinished) {
        [self growTapCircleABit];
    }
    [self fadeTapCircleOut];
    [self fadeBGOutAndBringShadowBackToStart];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];

    self.letGo = YES;
    
    if (self.growthFinished) {
        [self growTapCircleABit];
    }
    [self fadeTapCircleOut];
    [self fadeBGOutAndBringShadowBackToStart];
}


#pragma mark - Setters and Getters
- (void)setUsesSmartColor:(BOOL)usesSmartColor
{
    _usesSmartColor = usesSmartColor;
    self.tapCircleColor = nil;
    self.backgroundFadeColor = nil;
}


#pragma mark - Gesture Recognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    CGPoint location = [touch locationInView:self];
    //NSLog(@"location: x = %0.2f, y = %0.2f", location.x, location.y);
    self.tapPoint = location;
    
    self.haveTapped = YES;
    
    return NO;  // Disallow recognition of tap gestures. We just needed this to grab that tasty tap location.
}


#pragma mark - Animation:
- (void)animationDidStop:(CAAnimation *)theAnimation2 finished:(BOOL)flag
{
    // NSLog(@"animation ENDED");
    self.growthFinished = YES;
    
    if ([[theAnimation2 valueForKey:@"id"] isEqualToString:@"fadeCircleOut"]) {
        [[self.deathRowForCircleLayers objectAtIndex:0] removeFromSuperlayer];
        [self.deathRowForCircleLayers removeObjectAtIndex:0];
    }
    else if ([[theAnimation2 valueForKey:@"id"] isEqualToString:@"removeFadeBackgroundDarker"]) {
        self.backgroundColorFadeLayer.backgroundColor = [UIColor clearColor].CGColor;
    }
}


- (void)growTapCircle
{
    //NSLog(@"expanding a tap circle");
    // Spawn a growing circle that "ripples" through the button:

    // Set the fill color for the tap circle (self.animationLayer's fill color):
    if (!self.tapCircleColor) {
        self.tapCircleColor = self.usesSmartColor ? [self.textLabel.textColor colorWithAlphaComponent:bfPaperCell_tapFillConstant] : BFPAPERCELL__DUMB_TAP_FILL_COLOR;
    }
    
    if (!self.backgroundFadeColor) {
        self.backgroundFadeColor = self.usesSmartColor ? self.textLabel.textColor : BFPAPERCELL__DUMB_FADE_COLOR;
    }
    
    // Setup background fade layer:
    self.backgroundColorFadeLayer.frame = self.bounds;
    self.backgroundColorFadeLayer.backgroundColor = self.backgroundFadeColor.CGColor;
    
    // Fade the background color a bit darker:
    CABasicAnimation *fadeBackgroundDarker = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeBackgroundDarker.duration = bfPaperCell_animationDurationConstant;
    fadeBackgroundDarker.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    fadeBackgroundDarker.fromValue = [NSNumber numberWithFloat:0.f];
    fadeBackgroundDarker.toValue = [NSNumber numberWithFloat:bfPaperCell_fadeConstant];
    fadeBackgroundDarker.fillMode = kCAFillModeForwards;
    fadeBackgroundDarker.removedOnCompletion = NO;
    [self.backgroundColorFadeLayer addAnimation:fadeBackgroundDarker forKey:@"animateOpacity"];
    
    
    // Calculate the tap circle's ending diameter:
    CGFloat tapCircleFinalDiameter = (self.tapCircleDiameter < 0) ? MAX(self.frame.size.width, self.frame.size.height) : self.tapCircleDiameter;
    
    // Create a UIView which we can modify for its frame value later (specifically, the ability to use .center):
    UIView *tapCircleLayerSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter)];
    tapCircleLayerSizerView.center = self.rippleFromTapLocation ? self.tapPoint : CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // Calculate mask starting path:
    UIView *startingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bfPaperCell_tapCircleDiameterStartValue, bfPaperCell_tapCircleDiameterStartValue)];
    startingRectSizerView.center = tapCircleLayerSizerView.center;
    
    // Create starting circle path for mask:
    UIBezierPath *startingCirclePath = [UIBezierPath bezierPathWithRoundedRect:startingRectSizerView.frame cornerRadius:bfPaperCell_tapCircleDiameterStartValue / 2.f];
    
    // Calculate mask ending path:
    UIView *endingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter)];
    endingRectSizerView.center = tapCircleLayerSizerView.center;
    
    // Create ending circle path for mask:
    UIBezierPath *endingCirclePath = [UIBezierPath bezierPathWithRoundedRect:endingRectSizerView.frame cornerRadius:tapCircleFinalDiameter / 2.f];
    
    // Create tap circle:
    CAShapeLayer *tapCircle = [CAShapeLayer layer];
    tapCircle.fillColor = self.tapCircleColor.CGColor;
    tapCircle.strokeColor = [UIColor clearColor].CGColor;
    tapCircle.borderColor = [UIColor clearColor].CGColor;
    tapCircle.borderWidth = 0;
    tapCircle.path = startingCirclePath.CGPath;
    
    // Create a mask:
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
    mask.fillColor = [UIColor blackColor].CGColor;
    mask.strokeColor = [UIColor clearColor].CGColor;
    mask.borderColor = [UIColor clearColor].CGColor;
    mask.borderWidth = 0;
    
    // Set tap circle layer's mask to the mask:
    tapCircle.mask = mask;
    
    // Add tap circle to array and view:
    [self.rippleAnimationQueue addObject:tapCircle];
    [self.contentView.layer insertSublayer:tapCircle above:self.backgroundColorFadeLayer];
    
    /*
     * Animations:
     */
    // Grow tap-circle animation (performed on mask layer):
    CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    tapCircleGrowthAnimation.delegate = self;
    [tapCircleGrowthAnimation setValue:@"tapGrowth" forKey:@"id"];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    tapCircleGrowthAnimation.duration = bfPaperCell_tapCircleGrowthDurationConstant;
    tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    tapCircleGrowthAnimation.fromValue = (__bridge id)startingCirclePath.CGPath;
    tapCircleGrowthAnimation.toValue = (__bridge id)endingCirclePath.CGPath;
    tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
    tapCircleGrowthAnimation.removedOnCompletion = NO;
    
    // Fade in self.animationLayer:
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.duration = bfPaperCell_animationDurationConstant;
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeIn.fromValue = [NSNumber numberWithFloat:0.f];
    fadeIn.toValue = [NSNumber numberWithFloat:1.f];
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = NO;
    
    // Add the animations to the layers:
    [tapCircle addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
    [tapCircle addAnimation:fadeIn forKey:@"opacityAnimation"];
}


- (void)fadeBGOutAndBringShadowBackToStart
{
    //NSLog(@"fading bg");
    
    CABasicAnimation *removeFadeBackgroundDarker = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [removeFadeBackgroundDarker setValue:@"removeFadeBackgroundDarker" forKey:@"id"];
    removeFadeBackgroundDarker.delegate = self;
    removeFadeBackgroundDarker.duration = bfPaperCell_animationDurationConstant;
    removeFadeBackgroundDarker.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    removeFadeBackgroundDarker.fromValue = [NSNumber numberWithFloat:bfPaperCell_fadeConstant];
    removeFadeBackgroundDarker.toValue = [NSNumber numberWithFloat:0.f];
    removeFadeBackgroundDarker.fillMode = kCAFillModeForwards;
    removeFadeBackgroundDarker.removedOnCompletion = NO;
        
    [self.backgroundColorFadeLayer addAnimation:removeFadeBackgroundDarker forKey:@"removeBGShade"];
}


- (void)growTapCircleABit
{
    //NSLog(@"expanding a bit more");
    
    // Create a UIView which we can modify for its frame value later (specifically, the ability to use .center):
    CGFloat tapCircleDiameterStartValue = (self.tapCircleDiameter < 0) ? MAX(self.frame.size.width * bfPaperCell_tapCircleAutoSizeConstant, self.frame.size.height * bfPaperCell_tapCircleAutoSizeConstant) : self.tapCircleDiameter;
    
    UIView *tapCircleLayerSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleDiameterStartValue, tapCircleDiameterStartValue)];
    tapCircleLayerSizerView.center = self.rippleFromTapLocation ? self.tapPoint : CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // Calculate mask starting path:
    UIView *startingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleDiameterStartValue, tapCircleDiameterStartValue)];
    startingRectSizerView.center = tapCircleLayerSizerView.center;
    
    // Create starting circle path for mask:
    UIBezierPath *startingCirclePath = [UIBezierPath bezierPathWithRoundedRect:startingRectSizerView.frame cornerRadius:tapCircleDiameterStartValue / 2.f];
    
    // Calculate mask ending path:
    CGFloat tapCircleDiameterEndValue = (self.tapCircleDiameter < 0) ? MAX(self.frame.size.width, self.frame.size.height) : self.tapCircleDiameter;
    tapCircleDiameterEndValue += bfPaperCell_tapCircleGrowthBurst;
    
    UIView *endingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleDiameterEndValue, tapCircleDiameterEndValue)];
    endingRectSizerView.center = tapCircleLayerSizerView.center;
    
    // Create ending circle path for mask:
    UIBezierPath *endingCirclePath = [UIBezierPath bezierPathWithRoundedRect:endingRectSizerView.frame cornerRadius:tapCircleDiameterEndValue / 2.f];
    
    // Get the next tap circle to expand:
    CAShapeLayer *tapCircle = [self.rippleAnimationQueue firstObject];
    
    // Expand tap-circle animation:
    CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    tapCircleGrowthAnimation.duration = bfPaperCell_tapCircleGrowthDurationConstant;
    tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    tapCircleGrowthAnimation.toValue = (__bridge id)startingCirclePath.CGPath;  // LOOK: using starting for toValue!
    tapCircleGrowthAnimation.fromValue = (__bridge id)endingCirclePath.CGPath;  // LOOK: using ending for fromValue! (I shouild fix this...)
    tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
    tapCircleGrowthAnimation.removedOnCompletion = NO;
    
    [tapCircle addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
}


- (void)fadeTapCircleOut
{
    //NSLog(@"Fading away");
    
    CALayer *tempAnimationLayer = [self.rippleAnimationQueue firstObject];
    [self.rippleAnimationQueue removeObjectAtIndex:0];
    [self.deathRowForCircleLayers addObject:tempAnimationLayer];
    
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeOut setValue:@"fadeCircleOut" forKey:@"id"];
    fadeOut.delegate = self;
    fadeOut.fromValue = [NSNumber numberWithFloat:tempAnimationLayer.opacity];
    fadeOut.toValue = [NSNumber numberWithFloat:0.f];
    fadeOut.duration = bfPaperCell_tapCircleGrowthDurationConstant;
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.removedOnCompletion = NO;
    
    [tempAnimationLayer addAnimation:fadeOut forKey:@"opacityAnimation"];
}
#pragma mark -


@end
