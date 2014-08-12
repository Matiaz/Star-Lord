//
//  InvinciblePack.m
//  williamtan
//
//  Created by William Tan on 8/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "InvinciblePack.h"

@implementation InvinciblePack

- (void) didLoadFromCCB{
    self.physicsBody.collisionType = @"InvinciblePack";
}
@end
