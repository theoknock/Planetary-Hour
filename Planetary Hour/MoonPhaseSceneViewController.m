//
//  MoonPhaseSceneViewController.m
//  Planetary Hour
//
//  Created by Xcode Developer on 12/22/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "MoonPhaseSceneViewController.h"

@interface MoonPhaseSceneViewController ()

@end

@implementation MoonPhaseSceneViewController

SCNAction *(^orbit)(SCNNode *) = ^(SCNNode *node)
{
//    [node setEulerAngles:SCNVector3Make(node.eulerAngles.x - M_PI_4,
//                                        node.eulerAngles.y - (M_PI_4 * 3),
//                                        node.eulerAngles.z)];
    
//    return [SCNAction rotateByX:node.eulerAngles.x y:node.eulerAngles.y z:node.eulerAngles.z duration:1];
    return [SCNAction rotateByAngle:(360.0 * (M_PI / 180.0)) aroundAxis:SCNVector3Make(1, 0, 0) duration:1];
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create a new scene
    SCNScene *scene = [SCNScene new];
    
    SCNCamera *camera = [SCNCamera new];
    camera.usesOrthographicProjection = TRUE;
    camera.orthographicScale = 9;
    camera.zNear = 0;
    camera.zFar  = 100;
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.position = SCNVector3Make(0, 0, 15);
    cameraNode.camera = camera;
    SCNNode *cameraOrbit = [SCNNode node];
    [cameraOrbit addChildNode:cameraNode];
    [scene.rootNode addChildNode:cameraOrbit];
    
    [cameraOrbit runAction:[SCNAction repeatActionForever:orbit(cameraOrbit)]];
    
    // create and add a light to the scene
    SCNNode *lightNode   = [SCNNode node];
    lightNode.light      = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position   = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode    = [SCNNode node];
    ambientLightNode.light       = [SCNLight light];
    ambientLightNode.light.type  = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor blueColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    // create sphere
    SCNSphere *sphere   = [SCNSphere sphereWithRadius:5];
    SCNNode *sphereNode = [SCNNode nodeWithGeometry:sphere];
    [sphereNode setPosition:SCNVector3Make(0, 0, 0)];
    [sphereNode setRotation:SCNVector4Make(0.0, 0.0, 0.0, 0.0)];
    [scene.rootNode addChildNode:sphereNode];
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view.subviews[0];
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = NO;
    
    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

@end
