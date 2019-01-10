//
//  LunarPhaseCoreGraphicsView.m
//  Planetary Hour
//
//  Created by Xcode Developer on 12/23/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "LunarPhaseCoreGraphicsView.h"
#import "LunarPhase.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0f * M_PI )

typedef enum : NSUInteger {
    LunarPhaseColorGray,
    LunarPhaseColorWhite,
} LunarPhaseColor;

@interface LunarPhaseCoreGraphicsView ()
{
    CAShapeLayer *moonLayer;
    CAShapeLayer *gibbousLayer;
    CAShapeLayer *shadowLayer;
}

@end

@implementation LunarPhaseCoreGraphicsView

@synthesize moonPhase = _moonPhase;

- (void)setLunarPhase:(float)moonPhase
{
    NSLog(@"setLunarPhase: %f", moonPhase);
    _moonPhase = moonPhase;
    [self setNeedsDisplay];
}

- (float)moonPhase
{
    return _moonPhase;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!moonLayer && !gibbousLayer && !shadowLayer)
    {
        [moonLayer    = [CAShapeLayer new] setFrame:self.layer.bounds];
        [gibbousLayer = [CAShapeLayer new] setFrame:self.layer.bounds];
        [shadowLayer  = [CAShapeLayer new] setFrame:self.layer.bounds];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (!_moonPhase)
        [self setLunarPhase:[LunarPhase.calculator phaseForDate:[NSDate date]]];
    
    // Path color
    void(^renderLunarPhasePath)(UIBezierPath *, LunarPhaseColor, CAShapeLayer *) = ^(UIBezierPath *path, LunarPhaseColor moonPhaseColor, CAShapeLayer *targetLayer) {
        [[UIColor clearColor] setStroke];
        [path stroke];
        
        UIColor *fillColor = (moonPhaseColor == LunarPhaseColorWhite) ? [UIColor whiteColor] : [UIColor grayColor];
        [fillColor setFill];
        [path fill];
        
        [targetLayer setPath:path.CGPath];
    };
    
    // Moon
    UIBezierPath *moonPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    renderLunarPhasePath(moonPath, LunarPhaseColorWhite, moonLayer);
    
    // Gibbous
    UIBezierPath *gibbousPath = [UIBezierPath bezierPath];
    [gibbousPath addArcWithCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
                           radius:CGRectGetMidY(rect)
                       startAngle:degreesToRadians(90) endAngle:degreesToRadians(270)
                        clockwise:(_moonPhase >= .5) ? FALSE : TRUE];
    renderLunarPhasePath(gibbousPath, LunarPhaseColorGray, gibbousLayer);

    // Shadow
    CGFloat width      = CGRectGetWidth(rect) - (CGRectGetWidth(rect) * fabs(_moonPhase - 0.5));
    CGFloat center_x   = CGRectGetMidX(rect) - (width / 2.0);
    CGRect shadow_rect = CGRectMake(center_x,
                                    CGRectGetMinY(rect),
                                    width,
                                    CGRectGetHeight(rect));
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithOvalInRect:shadow_rect];
    renderLunarPhasePath(shadowPath, (_moonPhase <= .5) ? LunarPhaseColorWhite : LunarPhaseColorGray, shadowLayer);
}

@end


