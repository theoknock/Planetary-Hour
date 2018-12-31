//
//  SolarTransit.m
//  Planetary Hour
//
//  Created by Xcode Developer on 12/28/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "SolarTransit.h"

double const FESSolarCalculationZenithOfficial = 90.83;

double const toRadians = M_PI / 180;
double const toDegrees = 180 / M_PI;

@implementation SolarTransit

static SolarTransit *calculator = NULL;
+ (nonnull SolarTransit *)calculator
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      if (!calculator)
                          calculator = [[self alloc] init];
                  });
    
    return calculator;
}

- (instancetype)init
{
    if (self == [super init])
    {
        self.locationManager = [[CLLocationManager alloc] init];
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager setDelegate:(id<CLLocationManagerDelegate> _Nullable)self];
    }
    
    return self;
}

#pragma mark <CLLocationManagerDelegate methods>

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s\n%@", __PRETTY_FUNCTION__, error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //    NSLog(@"%s\t\t\nLocation services authorization status code:\t%d", __PRETTY_FUNCTION__, status);
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        NSLog(@"%s\nFailure to authorize location services", __PRETTY_FUNCTION__);
    }
    else
    {
        CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
        if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse ||
            authStatus == kCLAuthorizationStatusAuthorizedAlways)
        {
            //[manager requestLocation];
            [manager startMonitoringSignificantLocationChanges];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    //    NSLog(@"User location\t%f", locations.lastObject.coordinate.longitude);
    //    CLLocation *currentLocation = [locations lastObject];
    //    if ((self.lastLocation == nil) || (((self.lastLocation.coordinate.latitude != currentLocation.coordinate.latitude) || (self.lastLocation.coordinate.longitude != currentLocation.coordinate.longitude)) && ((currentLocation.coordinate.latitude != 0.0) || (currentLocation.coordinate.longitude != 0.0)))) {
    //        self.lastLocation = [[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    //        NSLog(@"%s", __PRETTY_FUNCTION__);
    //        //    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlanetaryHoursDataSourceUpdatedNotification"
    //        //                                                        object:nil
    //        //                                                      userInfo:nil];
    //    }
}

- (void)dealloc
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
    calculator = nil;
}

#pragma mark - SolarData Calculations

NSDate *(^dateFromJulianDayNumber)(double) = ^(double julianDayValue)
{
    // calculation of Gregorian date from Julian Day Number ( http://en.wikipedia.org/wiki/Julian_day )
    int JulianDayNumber = (int)floor(julianDayValue);
    int J = floor(JulianDayNumber + 0.5);
    int j = J + 32044;
    int g = j / 146097;
    int dg = j - (j/146097) * 146097; // mod
    int c = (dg / 36524 + 1) * 3 / 4;
    int dc = dg - c * 36524;
    int b = dc / 1461;
    int db = dc - (dc/1461) * 1461; // mod
    int a = (db / 365 + 1) * 3 / 4;
    int da = db - a * 365;
    int y = g * 400 + c * 100 + b * 4 + a;
    int m = (da * 5 + 308) / 153 - 2;
    int d = da - (m + 4) * 153 / 5 + 122;
    NSDateComponents *components = [NSDateComponents new];
    components.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    components.year = y - 4800 + (m + 2) / 12;
    components.month = ((m+2) - ((m+2)/12) * 12) + 1;
    components.day = d + 1;
    double timeValue = ((julianDayValue - floor(julianDayValue)) + 0.5) * 24;
    components.hour = (int)floor(timeValue);
    double minutes = (timeValue - floor(timeValue)) * 60;
    components.minute = (int)floor(minutes);
    components.second = (int)((minutes - floor(minutes)) * 60);
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *returnDate = [calendar dateFromComponents:components];
    
    return returnDate;
};

int (^julianDayNumberFromDate)(NSDate *) = ^(NSDate *inDate)
{
    // calculation of Julian Day Number (http://en.wikipedia.org/wiki/Julian_day ) from Gregorian Date
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:inDate];
    int a = (14 - (int)[components month]) / 12;
    int y = (int)[components year] +  4800 - a;
    int m = (int)[components month] + (12 * a) - 3;
    int JulianDayNumber = (int)[components day] + (((153 * m) + 2) / 5) + (365 * y) + (y/4) - (y/100) + (y/400) - 32045;
    
    return JulianDayNumber;
};

NSArray<NSDate *> *(^calculateSolarData)(NSDate *, CLLocationCoordinate2D) = ^(NSDate *startDate, CLLocationCoordinate2D coordinate)
{
    // math in this method comes directly from http://users.electromagnetic.net/bu/astro/sunrise-set.php
    // with a change to calculate twilight times as well (that information comes from
    // http://williams.best.vwh.net/sunrise_sunset_algorithm.htm ). The math in the first url
    // is sourced from http://www.astro.uu.nl/~strous/AA/en/reken/zonpositie.html which no longer exists
    // but a copy was found on the Wayback Machine at
    // http://web.archive.org/web/20110723172451/http://www.astro.uu.nl/~strous/AA/en/reken/zonpositie.html
    // All constants can be referenced and are explained on the archive.org page
    
    // run the calculations based on the users criteria at initalization time
    //    int JulianDayNumber = [FESSolarCalculator julianDayNumberFromDate:self.startDate];
    int JulianDayNumber = julianDayNumberFromDate(startDate);
    double JanuaryFirst2000JDN = 2451545.0;
    
    // this formula requires west longitude, thus 75W = 75, 45E = -45
    // convert to get it there
    double westLongitude = coordinate.longitude * -1.0;
    
    // define some of our mathmatical values;
    double Nearest = 0.0;
    double ElipticalLongitudeOfSun = 0.0;
    double ElipticalLongitudeRadians = ElipticalLongitudeOfSun * toRadians;
    double MeanAnomoly = 0.0;
    double MeanAnomolyRadians = MeanAnomoly * toRadians;
    double MAprev = -1.0;
    double Jtransit = 0.0;
    
    // we loop through our calculations for Jtransit
    // Running the loop the first time we then re-run it with Jtransit
    // as the input to refine MeanAnomoly. Once MeanAnomoly is equal
    // to the previous run's MeanAnomoly calculation we can continue
    while (MeanAnomoly != MAprev) {
        MAprev = MeanAnomoly;
        Nearest = round(((double)JulianDayNumber - JanuaryFirst2000JDN - 0.0009) - (westLongitude/360.0));
        double Japprox = JanuaryFirst2000JDN + 0.0009 + (westLongitude/360.0) + Nearest;
        if (Jtransit != 0.0) {
            Japprox = Jtransit;
        }
        double Ms = (357.5291 + 0.98560028 * (Japprox - JanuaryFirst2000JDN));
        MeanAnomoly = fmod(Ms, 360.0);
        MeanAnomolyRadians = MeanAnomoly * toRadians;
        double EquationOfCenter = (1.9148 * sin(MeanAnomolyRadians)) + (0.0200 * sin(2.0 * (MeanAnomolyRadians))) + (0.0003 * sin(3.0 * (MeanAnomolyRadians)));
        double eLs = (MeanAnomoly + 102.9372 + EquationOfCenter + 180.0);
        ElipticalLongitudeOfSun = fmod(eLs, 360.0);
        ElipticalLongitudeRadians = ElipticalLongitudeOfSun * toRadians;
        if (Jtransit == 0.0) {
            Jtransit = Japprox + (0.0053 * sin(MeanAnomolyRadians)) - (0.0069 * sin(2.0 * ElipticalLongitudeRadians));
        }
    }
    
    double DeclinationOfSun = asin( sin(ElipticalLongitudeRadians) * sin(23.45 * toRadians) ) * toDegrees;
    double DeclinationOfSunRadians = DeclinationOfSun * toRadians;
    
    // We now have solar noon for our day
    //    NSDate *solarNoon = dateFromJulianDayNumber(Jtransit);
    
    // create a block to run our per-zenith calculations based on solar noon
    double H1 = (cos(FESSolarCalculationZenithOfficial * toRadians) - sin(coordinate.latitude * toRadians) * sin(DeclinationOfSunRadians));
    double H2 = (cos(coordinate.latitude * toRadians) * cos(DeclinationOfSunRadians));
    double HourAngle = acos( (H1  * toRadians) / (H2  * toRadians) ) * toDegrees;
    
    double Jss = JanuaryFirst2000JDN + 0.0009 + ((HourAngle + westLongitude)/360.0) + Nearest;
    
    // compute the setting time from Jss approximation
    double Jset = Jss + (0.0053 * sin(MeanAnomolyRadians)) - (0.0069 * sin(2.0 * ElipticalLongitudeRadians));
    // calculate the rise time based on solar noon and the set time
    double Jrise = Jtransit - (Jset - Jtransit);
    
    // assign the rise and set dates to the correct properties
    NSDate *riseDate = dateFromJulianDayNumber(Jrise);
    NSDate *setDate = dateFromJulianDayNumber(Jset);
    
    return @[riseDate, setDate];
};

- (float)solarProgressionForDate:(NSDate *)date location:(nullable CLLocation *)location completionBlock:(SolarProgressionDataCompletionBlock)completionBlock
{
    float dayperc = 0;
    if (!location) location = _locationManager.location;
    if (CLLocationCoordinate2DIsValid(location.coordinate))
    {
        NSArray<NSDate *> *solarCalculator = calculateSolarData(date, location.coordinate);
            
            NSDate *firstDate = date;
            NSDate *earlierDate = [solarCalculator[Sunrise] earlierDate:date];
            if ([earlierDate isEqualToDate:date])
            {
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [[NSDateComponents alloc] init];
                components.day = -1;
                firstDate = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
                solarCalculator = calculateSolarData(firstDate, location.coordinate);
            }
        
        NSTimeInterval dayspan = [[solarCalculator objectAtIndex:Sunset] timeIntervalSinceDate:[solarCalculator objectAtIndex:Sunrise]];
        NSTimeInterval dayprog = [date timeIntervalSinceDate:[solarCalculator objectAtIndex:Sunrise]];
              dayperc          = (float)(dayprog / dayspan);
        NSLog(@"Current time interval: %f\t\tDay span: %f", dayprog, dayspan);
        completionBlock(dayperc);
    }
    
    return dayperc;
}

@end






