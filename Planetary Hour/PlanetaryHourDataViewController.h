//
//  PlanetaryHourDataViewController.h
//  Planetary Hour
//
//  Created by Xcode Developer on 12/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "LunarPhaseCoreGraphicsView.h"
#import "SolarTransitCoreGraphicsView.h"
#import "LunarPhaseSceneKitView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlanetaryHourDataViewController : UIViewController

@property (weak, nonatomic) IBOutlet LunarPhaseCoreGraphicsView *moonPhaseView;
@property (weak, nonatomic) IBOutlet SolarTransitCoreGraphicsView *solarTransitView;
@property (weak, nonatomic) IBOutlet LunarPhaseSceneKitView *lunarPhaseSceneKitView;

@end

NS_ASSUME_NONNULL_END
