//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "GameData.h"
#import <CoreMotion/CoreMotion.h>
#import <CCColor.h>
#import <ccTypes.h>
#import <CCTransition.h>
#import "Ship.h"
#import <CCAction.h>

@implementation MainScene{
    CMMotionManager *_motionManager;
    GameData* data;
    
    Ship *_currentShip;
    CCSprite *_vision;
    
    float viewHeight, viewWidth;
    int ACCEL;
    CCSprite *logo;
    CCNode *_closestStars1, *_closestStars2, *_furthurStars1, *_furthurStars2, *_farthestStars1, *_farthestStars2, *_overFarthestStars1, *_overFarthestStars2;
    NSMutableArray *_closestBackground, *_furthurBackground, *_farthestBackground, *_overFarthestBackground;

}

-(void) didLoadFromCCB{
    ACCEL = 1000;
    
    data = [GameData sharedData];
    _motionManager = [[CMMotionManager alloc] init];
    
    viewHeight = [[CCDirector sharedDirector] viewSize].height; //568
    viewWidth = [[CCDirector sharedDirector] viewSize].width;   //320

    data.MINVISION = 5;
    [_vision setScale:data.MINVISION];
    
    _currentShip.positionType = CCPositionTypePoints;
    _vision.positionType = CCPositionTypePoints;
    _currentShip.position = ccp(viewWidth/2, viewHeight/2);
    _vision.position = ccp(viewWidth/2, viewHeight/2);
    
    _closestBackground = [NSMutableArray array];
    [_closestBackground  addObject:_closestStars1];
    [_closestBackground  addObject:_closestStars2];
    _furthurBackground = [NSMutableArray array];
    [_furthurBackground addObject:_furthurStars1];
    [_furthurBackground addObject:_furthurStars2];
    _farthestBackground = [NSMutableArray array];
    [_farthestBackground addObject:_farthestStars1];
    [_farthestBackground addObject:_farthestStars2];
    _overFarthestBackground = [NSMutableArray array];
    [_overFarthestBackground addObject:_overFarthestStars1];
    [_overFarthestBackground addObject:_overFarthestStars2];
}
- (void)play {
    NSLog(@"play activated and calibrated");
    
    id move = [CCActionMoveTo actionWithDuration:0.4f position:ccp(100, 800)];
    [logo runAction:move];
    
    CCColor *myColor = [CCColor blackColor];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithColor: myColor duration:0.5f];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:transition];
}
-(void)update:(CCTime)delta{
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    CGFloat newXPosition = _currentShip.position.x + (acceleration.x) * ACCEL * delta;
    newXPosition = clampf(newXPosition, 30, viewWidth-28);
    
    CGFloat newYPosition = _currentShip.position.y + (acceleration.y) * ACCEL * delta;
    newYPosition = clampf(newYPosition, 20, viewHeight-21);
    
    _currentShip.position = CGPointMake(newXPosition, newYPosition);
    
    data.calibrationAccelerationX  = acceleration.x; //taking the calibration values
    data.calibrationAccelerationY = acceleration.y;
    
    NSLog(@"Singleton accel X: %f, accel y: %f", data.calibrationAccelerationX, data.calibrationAccelerationY);

      _vision.position = _currentShip.position;
    [self scrollBackground];
}
-(void)scrollBackground{
    for(CCNode *background in _closestBackground){
        background.position = ccp(background.position.x, background.position.y - 4);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCNode *background in _furthurBackground){
        background.position = ccp(background.position.x, background.position.y - 3);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCNode *background in _farthestBackground){
        background.position = ccp(background.position.x, background.position.y - 2);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCNode *background in _overFarthestBackground){
        background.position = ccp(background.position.x, background.position.y - 1);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
}

#pragma Mark accelerometer
- (void)onEnter
{
    [super onEnter];
    [_motionManager startAccelerometerUpdates];
    self.paused = NO;
}

- (void)onExit
{
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
    self.paused = YES;
}
@end