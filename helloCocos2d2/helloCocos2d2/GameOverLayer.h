//
//  GameOverLayer.h
//  helloCocos2d2
//
//  Created by yifan on 12/27/13.
//  Copyright 2013 yifan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor {
    
}

+(CCScene *) sceneWithWon:(BOOL)won;
- (id)initWithWon:(BOOL)won;

@end
