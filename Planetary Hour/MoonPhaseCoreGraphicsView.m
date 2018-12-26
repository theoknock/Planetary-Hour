//
//  MoonPhaseCoreGraphicsView.m
//  Planetary Hour
//
//  Created by Xcode Developer on 12/23/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "MoonPhaseCoreGraphicsView.h"
#import "MoonPhase.h"

# define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

typedef enum : NSUInteger {
    MoonPhaseColorYellow,
    MoonPhaseColorBlue,
} MoonPhaseColor;

@interface MoonPhaseCoreGraphicsView ()
{
    CAShapeLayer *moonLayer;
    CAShapeLayer *gibbousLayer;
    CAShapeLayer *shadowLayer;
}

@end

@implementation MoonPhaseCoreGraphicsView

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
    [self renderMoonPhase:MoonPhase.sharedMoonPhaseCalculator.phase inRect:rect];
}

- (void)renderMoonPhase:(CGFloat)phase inRect:(CGRect)rect
{
    // Path color
    void(^renderMoonPhasePath)(UIBezierPath *, MoonPhaseColor, CAShapeLayer *) = ^(UIBezierPath *path, MoonPhaseColor moonPhaseColor, CAShapeLayer *targetLayer) {
        UIColor *color = (moonPhaseColor == MoonPhaseColorYellow) ? [UIColor yellowColor] : [UIColor blueColor];
        [color setStroke];
        [color setFill];
        [path fill];
        [path stroke];
        [targetLayer setPath:path.CGPath];
    };
    
    // Moon
    UIBezierPath *moonPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    renderMoonPhasePath(moonPath, (phase <= .5) ? MoonPhaseColorBlue : MoonPhaseColorYellow, moonLayer);
    
    // Gibbous
    UIBezierPath *gibbous = [UIBezierPath bezierPath];
    [gibbous addArcWithCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
                           radius:CGRectGetMidY(rect)
                       startAngle:degreesToRadians(90) endAngle:degreesToRadians(270)
                        clockwise:(phase >= .5) ? FALSE : TRUE];
    renderMoonPhasePath(gibbous, (phase >= .5) ? MoonPhaseColorBlue : MoonPhaseColorYellow, gibbousLayer);
    
    // Shadow
    CGFloat width      = CGRectGetWidth(rect) - (CGRectGetWidth(rect) * fabs(phase - 0.5));
    CGFloat center_x   = CGRectGetMidX(rect) - (width / 2.0);
    CGRect shadow_rect = CGRectMake(center_x,
                                    CGRectGetMinY(rect),
                                    width,
                                    CGRectGetHeight(rect));
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithOvalInRect:shadow_rect];
    renderMoonPhasePath(shadowPath, (phase >= .5) ? MoonPhaseColorYellow : MoonPhaseColorBlue, shadowLayer);
}

@end

