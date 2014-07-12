//
//  Gameplay.m
//  williamtan
//
//  Created by William Tan on 7/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Ship.h"
#import <CoreMotion/CoreMotion.h>
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Gameplay{
    Ship *_currentShip;
    CGPoint shipPosition;
    CMMotionManager *_motionManager;
    float viewHeight;
    float viewWidth;
}

- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    //  _currentBeam = (Beam*)[CCBReader load:@"Beam"];
    //  beamPosition = CGPointZero;
    // _currentBeam.position = beamPosition;
    // [_ccNode addChild:_currentBeam];
    // CCLabelTTF score = 500;
    _currentShip.physicsBody.allowsRotation = FALSE;
    _motionManager = [[CMMotionManager alloc] init];
    
    viewHeight = [[CCDirector sharedDirector] viewSize].height;
    viewWidth = [[CCDirector sharedDirector] viewSize].width;
}
- (void)onEnter
{
    [super onEnter];
    [_motionManager startAccelerometerUpdates];
}

- (void)onExit
{
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
}

- (void)update:(CCTime)delta {
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    CGFloat newXPosition = _currentShip.position.x + acceleration.x * 1000 * delta;
    newXPosition = clampf(newXPosition, 0, viewWidth);
    
    CGFloat newYPosition = _currentShip.position.y + acceleration.y * 1000 * delta;
    newYPosition = clampf(newYPosition, 0, viewHeight);
    _currentShip.position = CGPointMake(newXPosition, newYPosition);
}
@end
