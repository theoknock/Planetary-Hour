//
//  MoonPhase.h
//  Planetary Hour
//
//  Created by Xcode Developer on 12/23/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MoonPhase : NSObject
{
@private
    NSDate *now;
}

+ (nonnull MoonPhase *)sharedMoonPhaseCalculator;

- (float) phase;

@end

NS_ASSUME_NONNULL_END

