//
//  PlanetaryHourDataViewController.m
//  Planetary Hour
//
//  Created by Xcode Developer on 12/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "PlanetaryHourDataViewController.h"
#import "MoonPhase.h"

@interface PlanetaryHourDataViewController ()

@end

@implementation PlanetaryHourDataViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.moonPhaseView setMoonPhase:[MoonPhase.calculator phaseForDate:[NSDate date]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
