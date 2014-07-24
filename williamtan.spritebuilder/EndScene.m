//
//  EndScene.m
//  williamtan
//
//  Created by William Tan on 7/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "EndScene.h"
#import "Gameplay.h"
@implementation EndScene{
    CCLabelTTF *_scoreLabel;
}

- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
     _scoreLabel.string = [NSString stringWithFormat:@"%d",self.gameplay.score];
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


- (void)update:(CCTime)delta{
}
@end
