//
//  LunarPhaseCoreGraphicsView.h
//  Planetary Hour
//
//  Created by Xcode Developer on 12/23/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface LunarPhaseCoreGraphicsView : UIView

@property (assign, nonatomic, setter=setLunarPhase:) float moonPhase;

@end

NS_ASSUME_NONNULL_END
