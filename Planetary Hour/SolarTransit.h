//
//  SolarTransit.h
//  Planetary Hour
//
//  Created by Xcode Developer on 12/28/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SolarEvent) {
    Sunrise,
    Sunset
};

typedef void (^SolarProgressionDataCompletionBlock)(float solarProgression);

@interface SolarTransit : NSObject <CLLocationManagerDelegate>

+ (nonnull SolarTransit *)calculator;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (float)solarProgressionForDate:(NSDate *)date location:(nullable CLLocation *)location completionBlock:(SolarProgressionDataCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
