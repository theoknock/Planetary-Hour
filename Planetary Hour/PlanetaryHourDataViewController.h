//
//  PlanetaryHourDataViewController.h
//  Planetary Hour
//
//  Created by Xcode Developer on 12/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoonPhaseCoreGraphicsView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlanetaryHourDataViewController : UIViewController

@property (weak, nonatomic) IBOutlet MoonPhaseCoreGraphicsView *moonPhaseView;

@end

NS_ASSUME_NONNULL_END
