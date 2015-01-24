//
//  UniformGenerator.h
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 24.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface UniformGenerator : NSObject

+ (SKUniform *)uniformForSize:(CGSize)size;

@end
