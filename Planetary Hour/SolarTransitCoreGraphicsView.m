//
//  SolarTransitCoreGraphicsView.m
//  Planetary Hour
//
//  Created by Xcode Developer on 12/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "SolarTransitCoreGraphicsView.h"

# define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

typedef enum : NSUInteger {
    SolarTransitColorYellow,
    SolarTransitColorBlue,
} SolarTransitColor;

@interface SolarTransitCoreGraphicsView ()
{
    CAShapeLayer *sunLayer;
    CAShapeLayer *horizonLayer;
}

@end

@implementation SolarTransitCoreGraphicsView

@synthesize solarProgression = _solarProgression;

- (float)solarProgression
{
    return _solarProgression;
}

- (void)setSolarProgression:(float)solarProgression
{
    _solarProgression = solarProgression;
    [self setNeedsDisplay];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!sunLayer && !horizonLayer)
    {
        [sunLayer     = [CAShapeLayer new] setFrame:self.layer.bounds];
        [horizonLayer = [CAShapeLayer new] setFrame:self.layer.bounds];
    }
}

- (void)drawRect:(CGRect)rect
{
    // Path color
    void(^renderLunarPhasePath)(UIBezierPath *, SolarTransitColor, CAShapeLayer *) = ^(UIBezierPath *path, SolarTransitColor moonPhaseColor, CAShapeLayer *targetLayer) {
        [[UIColor whiteColor] setStroke];
        [path stroke];
        
        UIColor *fillColor = (moonPhaseColor == SolarTransitColorYellow) ? [UIColor whiteColor] : [UIColor clearColor];
        [fillColor setFill];
        [path fill];
        
        [targetLayer setPath:path.CGPath];
    };
    
    UIBezierPath *sunPath = [UIBezierPath bezierPath];
    float dawn  = CGRectGetMaxY(rect);
    float dusk  = CGRectGetMinY(rect);
    float noon  = (dawn - dusk) / 2.0;
    NSLog(@"1.\tdawn: %f\tdusk: %f\tnoon: %f", dawn, dusk, noon);
    float progress = noon + (dawn * fabs(_solarProgression - 0.5));
    [sunPath addArcWithCenter:CGPointMake(CGRectGetMidX(rect), progress)
                       radius:CGRectGetMidY(rect)
                   startAngle:degreesToRadians(0) endAngle:degreesToRadians(360)
                    clockwise:(_solarProgression >= .5) ? FALSE : TRUE];
    renderLunarPhasePath(sunPath, (_solarProgression >= .5) ? SolarTransitColorBlue : SolarTransitColorYellow, sunLayer);
    
    CGContextClipToRect(UIGraphicsGetCurrentContext(), rect);
}

@end
