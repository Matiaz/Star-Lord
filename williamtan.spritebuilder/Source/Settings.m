//
//  Settings.m
//  williamtan
//
//  Created by William Tan on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Settings.h"
#import "MainScene.h"

@implementation Settings


- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
}

- (void)openGameplay{
     [[CCDirector sharedDirector] popScene];
}

-(void)restart{
    [[CCDirector sharedDirector]popScene];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
@end
