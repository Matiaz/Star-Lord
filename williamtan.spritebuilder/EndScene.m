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
@implementation EndScene{
    CCLabelTTF  *_scoreLabel;
    GameData *data;
}
 

- (void)didLoadFromCCB {
    data = [GameData sharedData];
    self.userInteractionEnabled = TRUE;
     _scoreLabel.string = [NSString stringWithFormat:@"%i",data.score];
}

- (void)openGameplay{
    NSLog(@"play activated");
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

-(void)openMainScene{
    NSLog(@"Mainscene actvaed");
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}
@end
