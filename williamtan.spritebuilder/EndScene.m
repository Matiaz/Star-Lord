//
//  EndScene.m
//  williamtan
//
//  Created by William Tan on 7/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "EndScene.h"

@implementation EndScene

- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
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
