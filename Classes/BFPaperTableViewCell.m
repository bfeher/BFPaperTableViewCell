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
@property UIView *backgroundColorFadeView;
@property CAShapeLayer *maskLayer;
@property BOOL beganHighlight;
@property BOOL beganSelection;
@property BOOL haveTapped;
@property BOOL letGo;
@property BOOL growthFinished;
@property NSMutableArray *rippleAnimationQueue;
@property NSMutableArray *deathRowForCircleLayers;  // This is where old circle layers go to be killed :(
@property BOOL fadedBackgroundOutAlready;
@property BOOL fadedBackgroundInAlready;
@end

@implementation BFPaperTableViewCell
// Constants used for tweaking the look/feel of:
// -animation durations:
static CGFloat const bfPaperCell_animationDurationConstant          = 0.2f;
static CGFloat const bfPaperCell_tapCircleGrowthDurationConstant    = bfPaperCell_animationDurationConstant * 2;
static CGFloat const bfPaperCell_bgFadeOutAnimationDurationConstant = 0.75f;
// -the tap-circle's size:
static CGFloat const bfPaperCell_tapCircleDiameterStartValue        = 5.f;  // for the mask
static CGFloat const bfPaperCell_tapCircleGrowthBurst               = 40.f;
// -the tap-circle's beauty:
static CGFloat const bfPaperCell_tapFillConstant                    = 0.25f;
static CGFloat const bfPaperCell_fadeConstant                       = 0.15f;

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
    self.backgroundFadeAlpha = bfPaperCell_fadeConstant;
    self.letBackgroundLinger = YES;
    
    self.rippleAnimationQueue = [NSMutableArray array];
    self.deathRowForCircleLayers = [NSMutableArray array];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;

    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.maskLayer.frame = self.frame;
    
    // Setup background fade layer:
    self.backgroundColorFadeView = [[UIView alloc] init];
    self.backgroundColorFadeView.frame = self.bounds;
    self.backgroundColorFadeView.backgroundColor = self.backgroundFadeColor;
    self.backgroundColorFadeView.alpha = 0;
    [self.contentView insertSubview:self.backgroundColorFadeView atIndex:0];

    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
}


#pragma Parent Overides
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    //NSLog(@"setSelected:\'%@\' animated:\'%@\'", selected ? @"YES" : @"NO", animated ? @"YES" : @"NO");
    
    if (!self.letBackgroundLinger) {
        return; // If we are not letting the background linger, just return as we have nothing more to do here.
    }
    
    if (!selected) {
        [self removeBackground];
    }
    else {
        [self fadeBackgroundIn];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    // Lets go ahead and "reset" our cell:
    [self setupBFPaperTableViewCell];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    self.letGo = NO;
    self.growthFinished = NO;
    self.fadedBackgroundOutAlready = NO;
    
    [self fadeBackgroundIn];
    [self growTapCircle];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self removeCircle];
    if (!self.letBackgroundLinger) {
        [self removeBackground];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];

    [self removeCircle];
    [self removeBackground];
}


#pragma mark - Setters and Getters
- (void)setUsesSmartColor:(BOOL)usesSmartColor
{
    _usesSmartColor = usesSmartColor;
    self.tapCircleColor = nil;
    self.backgroundFadeColor = nil;
}

- (void)setBackgroundFadeColor:(UIColor *)backgroundFadeColor
{
    _backgroundFadeColor = [backgroundFadeColor colorWithAlphaComponent:1];
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
- (void)removeCircle
{
    self.letGo = YES;
    
    if (self.growthFinished) {
        [self growTapCircleABit];
    }
    [self fadeTapCircleOut];
}

- (void)removeBackground
{
    if (self.fadedBackgroundOutAlready) {
        return;
    }
    self.fadedBackgroundOutAlready = YES;
    self.fadedBackgroundInAlready = NO;
    
    [self fadeBGOutAndBringShadowBackToStart];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    // NSLog(@"animation ENDED");
    self.growthFinished = YES;
    
    if ([[animation valueForKey:@"id"] isEqualToString:@"fadeCircleOut"]) {
        [[self.deathRowForCircleLayers objectAtIndex:0] removeFromSuperlayer];
        if (self.deathRowForCircleLayers.count > 0) {
            [self.deathRowForCircleLayers removeObjectAtIndex:0];
        }
    }
    else if ([[animation valueForKey:@"id"] isEqualToString:@"removeFadeBackgroundDarker"]) {
        self.backgroundColorFadeView.backgroundColor = [UIColor clearColor];
        //        self.backgroundColorFadeLayer.backgroundColor = [UIColor clearColor].CGColor;
    }
}

- (void)fadeBackgroundIn
{
    if (self.fadedBackgroundInAlready) {
        return;
    }
    self.fadedBackgroundInAlready = YES;
    self.fadedBackgroundOutAlready = NO;
    
    if (!self.backgroundFadeColor) {
        self.backgroundFadeColor = self.usesSmartColor ? self.textLabel.textColor : BFPAPERCELL__DUMB_FADE_COLOR;
    }
    
    self.backgroundColorFadeView.frame = self.bounds;
    self.backgroundColorFadeView.backgroundColor = self.backgroundFadeColor;
    
    [UIView animateWithDuration:bfPaperCell_animationDurationConstant
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColorFadeView.alpha = self.backgroundFadeAlpha;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)growTapCircle
{
    //NSLog(@"expanding a tap circle");
    // Spawn a growing circle that "ripples" through the button:
    
    // Set the fill color for the tap circle (self.animationLayer's fill color):
    if (!self.tapCircleColor) {
        self.tapCircleColor = self.usesSmartColor ? [self.textLabel.textColor colorWithAlphaComponent:bfPaperCell_tapFillConstant] : BFPAPERCELL__DUMB_TAP_FILL_COLOR;
    }
    
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
    [self.contentView.layer insertSublayer:tapCircle above:self.backgroundColorFadeView.layer];
    
    
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
    
    [UIView animateWithDuration:bfPaperCell_bgFadeOutAnimationDurationConstant
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColorFadeView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)growTapCircleABit
{
    //NSLog(@"expanding a bit more");
    CGFloat tapCircleDiameterStartValue = (self.tapCircleDiameter < 0) ? MAX(self.frame.size.width, self.frame.size.height) : self.tapCircleDiameter;
    NSLog(@"tapCircleDiameterStartValue = \'%0.2f\'", tapCircleDiameterStartValue);
    
    // Create a UIView which we can modify for its frame value later (specifically, the ability to use .center):
    UIView *tapCircleLayerSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleDiameterStartValue, tapCircleDiameterStartValue)];
    tapCircleLayerSizerView.center = self.rippleFromTapLocation ? self.tapPoint : CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // Calculate mask starting path:
    UIView *startingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleDiameterStartValue, tapCircleDiameterStartValue)];
    startingRectSizerView.center = tapCircleLayerSizerView.center;
    
    // Create starting circle path for mask:
    UIBezierPath *startingCirclePath = [UIBezierPath bezierPathWithRoundedRect:startingRectSizerView.frame cornerRadius:tapCircleDiameterStartValue / 2.f];
    
    // Calculate mask ending path:
    CGFloat tapCircleDiameterEndValue = tapCircleDiameterStartValue + bfPaperCell_tapCircleGrowthBurst;
    
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
    tapCircleGrowthAnimation.fromValue = (__bridge id)startingCirclePath.CGPath;
    tapCircleGrowthAnimation.toValue = (__bridge id)endingCirclePath.CGPath;

    tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
    tapCircleGrowthAnimation.removedOnCompletion = NO;
    
    [tapCircle addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
}

- (void)fadeTapCircleOut
{
    //NSLog(@"Fading away");
    
    if (self.rippleAnimationQueue.count > 0) {
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
}
#pragma mark -


@end
