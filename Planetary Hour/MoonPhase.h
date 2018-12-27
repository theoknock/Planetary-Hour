//
//  MoonPhaseCalculator.h
//  Planetary Hour
//
//  Created by Xcode Developer on 12/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MoonPhase : NSObject
{
@private
    NSDate *now;
}

+ (nonnull MoonPhase *)calculator;

- (float)phaseForDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
