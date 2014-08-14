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
    CCNode *_closestStars1, *_closestStars2, *_furthurStars1, *_furthurStars2, *_farthestStars1, *_farthestStars2, *_overFarthestStars1, *_overFarthestStars2;
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
    for(CCNode *background in _closestBackground){
        background.position = ccp(background.position.x, background.position.y - 8);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCNode *background in _furthurBackground){
        background.position = ccp(background.position.x, background.position.y - 6);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCNode *background in _farthestBackground){
        background.position = ccp(background.position.x, background.position.y - 4);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCNode *background in _overFarthestBackground){
        background.position = ccp(background.position.x, background.position.y - 2);
        
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
