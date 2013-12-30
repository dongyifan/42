//
//  HelloWorldLayer.h
//  helloCocos2d2
//
//  Created by yifan on 12/26/13.
//  Copyright yifan 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    NSMutableArray * monsters_;
    NSMutableArray * projectiles_;
    int monstersDestoryed;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
