//
//  BFPaperTableViewCell.m
//  BFPaperKit
//
//  Created by Bence Feher on 7/11/14.
//  Copyright (c) 2014 Bence Feher. All rights reserved.
//

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
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self setup];
}


#pragma mark - Setup
- (void)setup
{
    // Defaults:
    self.usesSmartColor = YES;
    self.tapCircleColor = nil;
    self.backgroundFadeColor = nil;
    self.tapCircleDiameter = -1.f;
    self.rippleFromTapLocation = YES;
    
    self.rippleAnimationQueue = [NSMutableArray array];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;

    self.textLabel.text = @"BFPaperTableViewCell";
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.maskLayer.frame = self.frame;
    
    CGRect endRect = CGRectMake(self.contentView.bounds.origin.x, self.contentView.bounds.origin.y , self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    // Setup background fade layer:
    self.backgroundColorFadeLayer = [[CALayer alloc] init];
    self.backgroundColorFadeLayer.frame = endRect;
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
- (void)growTapCircle
{
    //NSLog(@"expanding a tap circle");
    // Spawn a growing circle that "ripples" through the button:
    
    CGRect endRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y , self.frame.size.width, self.frame.size.height);
    
    CALayer *tempAnimationLayer = [CALayer new];
    tempAnimationLayer.frame = endRect;
    
    // Set the fill color for the tap circle (self.animationLayer's fill color):
    if (!self.tapCircleColor) {
        self.tapCircleColor = self.usesSmartColor ? [self.textLabel.textColor colorWithAlphaComponent:bfPaperCell_tapFillConstant] : BFPAPERCELL__DUMB_TAP_FILL_COLOR;
    }
        
    if (!self.backgroundFadeColor) {
        self.backgroundFadeColor = self.usesSmartColor ? self.textLabel.textColor : BFPAPERCELL__DUMB_FADE_COLOR;
    }
        
        // Setup background fade layer:
    self.backgroundColorFadeLayer.frame = endRect;
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
    
    // Set animation layer's background color:
    tempAnimationLayer.backgroundColor = self.tapCircleColor.CGColor;
    tempAnimationLayer.borderColor = [UIColor clearColor].CGColor;
    tempAnimationLayer.borderWidth = 0;
    
    
    // Animation Mask Rects
    CGPoint origin = self.rippleFromTapLocation ? self.tapPoint : CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    //NSLog(@"self.center: (x%0.2f, y%0.2f)", self.center.x, self.center.y);
    UIBezierPath *startingTapCirclePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(origin.x - (bfPaperCell_tapCircleDiameterStartValue / 2.f), origin.y - (bfPaperCell_tapCircleDiameterStartValue / 2.f), bfPaperCell_tapCircleDiameterStartValue, bfPaperCell_tapCircleDiameterStartValue) cornerRadius:bfPaperCell_tapCircleDiameterStartValue / 2.f];
    
    CGFloat tapCircleDiameterEndValue = (self.tapCircleDiameter < 0) ? MAX(self.frame.size.width * bfPaperCell_tapCircleAutoSizeConstant, self.frame.size.height * bfPaperCell_tapCircleAutoSizeConstant) : self.tapCircleDiameter;
    UIBezierPath *endTapCirclePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(origin.x - (tapCircleDiameterEndValue/ 2.f), origin.y - (tapCircleDiameterEndValue/ 2.f), tapCircleDiameterEndValue, tapCircleDiameterEndValue) cornerRadius:tapCircleDiameterEndValue/ 2.f];
    
    // Animation Mask Layer:
    CAShapeLayer *animationMaskLayer = [CAShapeLayer layer];
    animationMaskLayer.path = endTapCirclePath.CGPath;
    animationMaskLayer.fillColor = [UIColor blackColor].CGColor;
    animationMaskLayer.strokeColor = [UIColor clearColor].CGColor;
    animationMaskLayer.borderColor = [UIColor clearColor].CGColor;
    animationMaskLayer.borderWidth = 0;
    
    tempAnimationLayer.mask = animationMaskLayer;
    
    // Grow tap-circle animation:
    CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    tapCircleGrowthAnimation.delegate = self;
    [tapCircleGrowthAnimation setValue:@"tapGrowth" forKey:@"id"];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    tapCircleGrowthAnimation.duration = bfPaperCell_tapCircleGrowthDurationConstant;
    tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    tapCircleGrowthAnimation.fromValue = (__bridge id)startingTapCirclePath.CGPath;
    tapCircleGrowthAnimation.toValue = (__bridge id)endTapCirclePath.CGPath;
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
    
    // Add the animation layer to our animation queue and insert it into our view:
    [self.rippleAnimationQueue addObject:tempAnimationLayer];
    [self.contentView.layer insertSublayer:tempAnimationLayer above:self.backgroundColorFadeLayer];
    
    // Apply animations:
    [animationMaskLayer addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
    [tempAnimationLayer addAnimation:fadeIn forKey:@"opacityAnimation"];
}


- (void)animationDidStop:(CAAnimation *)theAnimation2 finished:(BOOL)flag
{
   // NSLog(@"animation ENDED");
    self.growthFinished = YES;
}


- (void)fadeBGOutAndBringShadowBackToStart
{
    //NSLog(@"fading bg");
    
    CABasicAnimation *removeFadeBackgroundDarker = [CABasicAnimation animationWithKeyPath:@"opacity"];
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
    
    CALayer *tempAnimationLayer = [self.rippleAnimationQueue firstObject];
    
    // Animation Mask Rects
    CGFloat newTapCircleStartValue = (self.tapCircleDiameter < 0) ? MAX(self.frame.size.width * bfPaperCell_tapCircleAutoSizeConstant, self.frame.size.height * bfPaperCell_tapCircleAutoSizeConstant) : self.tapCircleDiameter;
    
    CGPoint origin = self.rippleFromTapLocation ? self.tapPoint : CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    UIBezierPath *startingTapCirclePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(origin.x - (newTapCircleStartValue / 2.f), origin.y - (newTapCircleStartValue / 2.f), newTapCircleStartValue, newTapCircleStartValue) cornerRadius:newTapCircleStartValue / 2.f];
    
    CGFloat tapCircleDiameterEndValue = (self.tapCircleDiameter < 0) ? MAX(self.frame.size.width * bfPaperCell_tapCircleAutoSizeConstant, self.frame.size.height * bfPaperCell_tapCircleAutoSizeConstant) : self.tapCircleDiameter;
    tapCircleDiameterEndValue += bfPaperCell_tapCircleGrowthBurst;
    UIBezierPath *endTapCirclePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(origin.x - (tapCircleDiameterEndValue/ 2.f), origin.y - (tapCircleDiameterEndValue/ 2.f), tapCircleDiameterEndValue, tapCircleDiameterEndValue) cornerRadius:tapCircleDiameterEndValue/ 2.f];
    
    // Animation Mask Layer:
    CAShapeLayer *animationMaskLayer = [CAShapeLayer layer];
    animationMaskLayer.path = endTapCirclePath.CGPath;
    animationMaskLayer.fillColor = [UIColor blackColor].CGColor;
    animationMaskLayer.strokeColor = [UIColor clearColor].CGColor;
    animationMaskLayer.borderColor = [UIColor clearColor].CGColor;
    animationMaskLayer.borderWidth = 0;
    
    tempAnimationLayer.mask = animationMaskLayer;
    
    // Grow tap-circle animation:
    CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    tapCircleGrowthAnimation.duration = bfPaperCell_tapCircleGrowthDurationConstant;
    tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    tapCircleGrowthAnimation.fromValue = (__bridge id)startingTapCirclePath.CGPath;
    tapCircleGrowthAnimation.toValue = (__bridge id)endTapCirclePath.CGPath;
    tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
    tapCircleGrowthAnimation.removedOnCompletion = NO;
    
    [animationMaskLayer addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
}


- (void)fadeTapCircleOut
{
    //NSLog(@"Fading away");
    
    CALayer *tempAnimationLayer = [self.rippleAnimationQueue firstObject];
    [self.rippleAnimationQueue removeObjectAtIndex:0];

    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.fromValue = [NSNumber numberWithFloat:tempAnimationLayer.opacity];
    fadeOut.toValue = [NSNumber numberWithFloat:0.f];
    fadeOut.duration = bfPaperCell_tapCircleGrowthDurationConstant;
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.removedOnCompletion = NO;
    
    [tempAnimationLayer addAnimation:fadeOut forKey:@"opacityAnimation"];
}
#pragma mark -


@end
