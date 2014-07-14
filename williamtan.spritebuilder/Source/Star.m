//
//  Star.m
//  williamtan
//
//  Created by William Tan on 7/12/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//
#import "Star.h"
@implementation Star


-(void)didLoadFromCCB{
    self.physicsBody.collisionType = @"Star";
}
@end
