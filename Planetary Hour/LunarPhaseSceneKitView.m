//
//  LunarPhaseSceneKitView.m
//  Planetary Hour
//
//  Created by Xcode Developer on 1/1/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "LunarPhaseSceneKitView.h"
#import "LunarPhase.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0f * M_PI )

@interface LunarPhaseSceneKitView ()
{
    BOOL shouldRotateSphere;
    SCNNode *cameraOrbit;
}


@end

@implementation LunarPhaseSceneKitView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self renderLunarPhase];
}

SCNAction *(^orbit)(SCNNode *) = ^(SCNNode *node)
{
    return [SCNAction rotateByAngle:(360.0 * (M_PI / 180.0)) aroundAxis:SCNVector3Make(1, 0, 0) duration:1];
};

float scaleBetween(float unscaledNum, float minAllowed, float maxAllowed, float min, float max) {
    return (maxAllowed - minAllowed) * (unscaledNum - min) / (max - min) + minAllowed;
}

- (void)renderLunarPhase
{
    if (!_moonPhase)
        [self setLunarPhase:[LunarPhase.calculator phaseForDate:[NSDate date]]];
    
    // Scene camera and related nodes
    SCNCamera *camera = [SCNCamera new];
    camera.usesOrthographicProjection = TRUE;
    camera.orthographicScale = 9;
    camera.zNear = 0;
    camera.zFar  = 100;
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.position = SCNVector3Make(0, 0, 10);
    cameraNode.camera = camera;
    cameraOrbit = [SCNNode node];
    [cameraOrbit addChildNode:cameraNode];
    // TO-DO: Calculate degrees based on return value of Lunar object (moonPhase)
    // if moonPhase is less than .5 = 0 - 180 degrees
    float degrees = 0;
    if (_moonPhase < .5)
        degrees = scaleBetween(_moonPhase, 0, 180, 0, .5);
    else if (_moonPhase >= .5)
        degrees = scaleBetween(_moonPhase, 180, 360, .5, 1);
    // if moonPhase is greater than .5 = 180 - 360 degrees
    
    [cameraOrbit runAction:[SCNAction rotateByX:0 y:degreesToRadians(-degrees) z:0 duration:1]];
    NSLog(@"Moon phase\t%f", _moonPhase);
    
    
    // Lighting
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 0, 45);
    //
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    
    SCNSphere *symbol = [SCNSphere sphereWithRadius:9];
    [symbol setSegmentCount:1000];
    SCNNode *symbolNode = [SCNNode nodeWithGeometry:symbol];
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self;
    
    // set the scene to the view
    scnView.scene = [SCNScene new];
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = NO;
    
    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
    
    [scnView.scene.rootNode addChildNode:cameraOrbit];
    [scnView.scene.rootNode addChildNode:lightNode];
    [scnView.scene.rootNode addChildNode:ambientLightNode];
    [scnView.scene.rootNode addChildNode:symbolNode];
    
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        shouldRotateSphere = TRUE;
        NSLog(@"UIGestureRecognizerStateBegan");
    } else if (sender.state == UIGestureRecognizerStateChanged && shouldRotateSphere
               && fabs([sender translationInView:sender.view].y) > 10.0)
    {
        shouldRotateSphere = FALSE;
        [cameraOrbit runAction:[SCNAction rotateByX:0 y:degreesToRadians([sender translationInView:sender.view].y) z:0 duration:1]];
        
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
    }
}



@end


