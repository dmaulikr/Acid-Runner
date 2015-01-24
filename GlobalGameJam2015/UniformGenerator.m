//
//  UniformGenerator.m
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 24.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

#import "UniformGenerator.h"

@implementation UniformGenerator

+ (SKUniform *)uniformForSize:(CGSize)size {
    return [SKUniform uniformWithName:@"size" floatVector3:GLKVector3Make(size.width, size.height, 0)];
}

@end
