//
//  VisionPack.m
//  williamtan
//
//  Created by William Tan on 7/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "VisionPack.h"

@implementation VisionPack
- (void) didLoadFromCCB{
    self.physicsBody.collisionType = @"VisionPack";
}
@end
