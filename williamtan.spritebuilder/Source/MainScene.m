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
#import <CCActionInterval.h>

@implementation MainScene{
    CMMotionManager *_motionManager;
    GameData* data;
    CCSprite *logo;
    float viewHeight, viewWidth;
    CCSprite *_closestStars1, *_closestStars2, *_furthurStars1, *_furthurStars2, *_farthestStars1, *_farthestStars2, *_overFarthestStars1, *_overFarthestStars2;
    NSMutableArray *_closestBackground, *_furthurBackground, *_farthestBackground, *_overFarthestBackground;
    CCButton *play, *calibrate, *music;
    bool calibrated;
}

-(void) didLoadFromCCB{
    data = [GameData sharedData];
    _motionManager = [[CMMotionManager alloc] init];
    
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
    
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    // play sound effect in a loop
    [audio stopEverything];
    [audio preloadBg:@"Coldnoise Awakening.mp3"];
    [audio playBg:@"Coldnoise Awakening.mp3" loop:TRUE];
    
    calibrated = false;
}

-(void)calibrated{
    calibrated = true;
    [self.animationManager runAnimationsForSequenceNamed:@"calibrateOut"];
    [calibrate setUserInteractionEnabled:false];
    [self scheduleBlock:^(CCTimer *timer) {
        [calibrate removeFromParent];
        [music removeFromParent];
        [self. animationManager runAnimationsForSequenceNamed:@"playIn"];
    } delay:0.6f];
    
}

- (void)play {
    CCColor *black = [CCColor blackColor];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithColor:black duration:0.5f];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:transition];
    
}

-(void)openMusic{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://soundcloud.com/coldnoises"]];
}
- (id)init {
    self = [super init];
    
    if (self) {
        NSString *date   = @"0";
        NSDate *lastRead    = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:date];
        if (lastRead == nil)     // App first run: set up user defaults.
        {
            NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], date, nil];
            
            // do any other initialization you want to do here - e.g. the starting default values.
            // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"should_play_sounds"];
            
            [MGWU setObject:[NSNumber numberWithInt:0] forKey:@"highScore"];
            
            // sync the defaults to disk
            [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:date];
    }
    
    return self;
}

-(void)update:(CCTime)delta{
    if(calibrated == false){
        CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
        CMAcceleration acceleration = accelerometerData.acceleration;
        
        data.calibrationAccelerationX  = acceleration.x; //taking the calibration values
        data.calibrationAccelerationY = acceleration.y;
    }
    
    [self scrollBackground];
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