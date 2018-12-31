//
//  PlanetaryHourDataViewController.m
//  Planetary Hour
//
//  Created by Xcode Developer on 12/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "PlanetaryHourDataViewController.h"
#import "LunarPhase.h"
#import "SolarTransit.h"

@interface PlanetaryHourDataViewController ()

@end

@implementation PlanetaryHourDataViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.moonPhaseView setLunarPhase:[LunarPhase.calculator phaseForDate:[NSDate date]]];
    [SolarTransit.calculator solarProgressionForDate:[NSDate date]
                                            location:nil
                                     completionBlock:^(float solarProgression) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.solarTransitView setSolarProgression:solarProgression];
                                         });
                                     }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

