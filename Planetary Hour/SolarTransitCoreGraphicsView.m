//
//  SolarTransitCoreGraphicsView.m
//  Planetary Hour
//
//  Created by Xcode Developer on 12/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "SolarTransitCoreGraphicsView.h"
#import "SolarTransit.h"

# define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

typedef enum : NSUInteger {
    SolarTransitColorWhite,
    SolarTransitColorGray,
} SolarTransitColor;

@interface SolarTransitCoreGraphicsView ()
{
    CAShapeLayer *sunLayer;
    CAShapeLayer *earthLayer;
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
    NSLog(@"Solar progression: %f", _solarProgression);
    [self setNeedsDisplay];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!sunLayer && !earthLayer)
    {
        [sunLayer   = [CAShapeLayer new] setFrame:self.layer.bounds];
        [earthLayer = [CAShapeLayer new] setFrame:self.layer.bounds];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (!_solarProgression)
        [SolarTransit.calculator solarProgressionForDate:[NSDate date] location:nil completionBlock:^(float solarProgression) {
            [self setSolarProgression:solarProgression];
        }];
    
    // Path color
    void(^renderSolarTransitPath)(UIBezierPath *, SolarTransitColor, CAShapeLayer *) = ^(UIBezierPath *path, SolarTransitColor solarTransitColor, CAShapeLayer *targetLayer) {
        [[UIColor clearColor] setStroke];
        [path stroke];
        
        UIColor *fillColor = (solarTransitColor == SolarTransitColorWhite) ? [UIColor whiteColor] : [UIColor grayColor];
        [fillColor setFill];
        [path fill];
        
        [targetLayer setPath:path.CGPath];
    };
    
    UIBezierPath *earthPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    renderSolarTransitPath(earthPath, (_solarProgression < 1.0) ? SolarTransitColorWhite : SolarTransitColorGray, earthLayer);
    
    float x        = CGRectGetHeight(rect) * ((_solarProgression >= 1.0) ? 1.0 - _solarProgression : _solarProgression) ;
    CGRect sunRect = CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height);
    UIBezierPath *sunPath = [UIBezierPath bezierPathWithOvalInRect:sunRect];
    renderSolarTransitPath(sunPath, (_solarProgression >= 1.0) ? SolarTransitColorWhite : SolarTransitColorGray, sunLayer);
    
    CGContextClipToRect(UIGraphicsGetCurrentContext(), rect);
}

@end
