//
//  EndScene.m
//  williamtan
//
//  Created by William Tan on 7/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "EndScene.h"
#import "Gameplay.h"
#import "GameData.h"
#import <CoreMotion/CoreMotion.h>
@implementation EndScene{
    CMMotionManager *_motionManager;
    CCLabelTTF  *_scoreLabel;
    CCLabelTTF *_highScoreLabel;
    GameData *data;
    float viewHeight, viewWidth;
    CCSprite *_closestStars1, *_closestStars2, *_furthurStars1, *_furthurStars2, *_farthestStars1, *_farthestStars2, *_overFarthestStars1, *_overFarthestStars2;
    NSMutableArray *_closestBackground, *_furthurBackground, *_farthestBackground, *_overFarthestBackground;
}
 

- (void)didLoadFromCCB {
    data = [GameData sharedData];
    _motionManager = [[CMMotionManager alloc] init];
    self.userInteractionEnabled = TRUE;
    
    
    viewHeight = [[CCDirector sharedDirector] viewSize].height; //568
    viewWidth = [[CCDirector sharedDirector] viewSize].width;   //320
    
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
    
    _closestStars1.positionType = CCPositionTypePoints;
    _closestStars2.positionType = CCPositionTypePoints;
    _furthurStars1.positionType = CCPositionTypePoints;
    _furthurStars2.positionType = CCPositionTypePoints;
    _farthestStars2.positionType = CCPositionTypePoints;
    _farthestStars1.positionType = CCPositionTypePoints;
    _overFarthestStars1.positionType = CCPositionTypePoints;
    _overFarthestStars2.positionType = CCPositionTypePoints;
    
    _closestStars1.position = ccp(0, 0);
    _closestStars2.position = ccp(0, viewHeight);
    _furthurStars1.position = ccp(0, 0);
    _furthurStars2.position = ccp(0, viewHeight);
    _farthestStars1.position = ccp(0, 0);
    _farthestStars2.position = ccp(0, viewHeight);
    _overFarthestStars1.position = ccp(0, 0);
    _overFarthestStars2.position = ccp(0, viewHeight);
    
     _scoreLabel.string = [NSString stringWithFormat:@"%i",data.score];
    _highScoreLabel.string = [NSString stringWithFormat:@"%ld", (long)[[MGWU objectForKey:@"highScore"] integerValue]];
}

-(void)update:(CCTime)delta{
    [self scrollBackground];
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    data.calibrationAccelerationX  = acceleration.x; //taking the calibration values
    data.calibrationAccelerationY = acceleration.y;
    
    NSLog(@"Singleton accel X: %f, accel y: %f", data.calibrationAccelerationX, data.calibrationAccelerationY);
}

- (void)replay{
    NSLog(@"play activated");
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}


-(void)scrollBackground{
    for(CCSprite *background in _closestBackground){
        background.position = ccp(background.position.x, background.position.y - 8);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCSprite *background in _furthurBackground){
        background.position = ccp(background.position.x, background.position.y - 6);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCSprite *background in _farthestBackground){
        background.position = ccp(background.position.x, background.position.y - 4);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCSprite *background in _overFarthestBackground){
        background.position = ccp(background.position.x, background.position.y - 2);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
}

-(void)openMainMenu{
    CCColor *black = [CCColor blackColor];
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    CCTransition *transition = [CCTransition transitionFadeWithColor: black duration:0.5f];
    [[CCDirector sharedDirector] presentScene:mainScene  withTransition:transition];
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
