//
//  HelloWorldLayer.m
//  helloCocos2d2
//
//  Created by yifan on 12/26/13.
//  Copyright yifan 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "SimpleAudioEngine.h"

#import "GameOverLayer.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)]) ) {
        [self setTouchEnabled:YES];
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite* player = [CCSprite spriteWithFile:@"player.png"];
        player.position = ccp(player.contentSize.width / 2, winSize.height / 2);
        [self addChild:player];
        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(update:)];
        monsters_ = [[NSMutableArray alloc] init];
        projectiles_ = [[NSMutableArray alloc] init];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
	}
	return self;
}

-(void)gameLogic:(ccTime)dt {
    [self addMonster];
}

- (void) addMonster {
    CCSprite * monster = [CCSprite spriteWithFile:@"monster.png"];
    
    // Determing where to spawn the monster along the Y axis
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = monster.contentSize.height / 2;
    int maxY = winSize.height - monster.contentSize.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = ccp(winSize.width + monster.contentSize.width / 2, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int acturalDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    CCMoveTo * actionMove = [CCMoveTo actionWithDuration:acturalDuration position:ccp(-monster.contentSize.width / 2, actualY)];
    CCCallBlockN * actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
        [monsters_ removeObject:node];
        CCScene * gameOverScene = [GameOverLayer sceneWithWon:NO];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }];

    [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    monster.tag = 1;
    [monsters_ addObject:monster];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite * projectile = [CCSprite spriteWithFile:@"projectile.png"];
    projectile.position = ccp(20, winSize.height / 2);
    
    // Determine offset of location to projectile
    CGPoint offset = ccpSub(location, projectile.position);
    
    // Bail out if you are shooting down or backwards
    if (offset.x <= 0) {
        return;
    }
    
    // Ok to add now - we've double checked position
    [self addChild:projectile];
    
    int realX = winSize.width + projectile.contentSize.width / 2;
    float ratio = (float) offset.y / (float) offset.x;
    int realY = realX * ratio + projectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far you're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf(offRealX * offRealX + offRealY * offRealY);
    float velocity = 480 / 1; // 480 px/s
    float realMoveDuration = length / velocity;
    
    // Move projectile to actual endpoint
    [projectile runAction:[CCSequence actions:[CCMoveTo actionWithDuration:realMoveDuration position:realDest], [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
        [projectiles_ removeObject:node];
    }], nil]];
    
    projectile.tag = 2;
    [projectiles_ addObject:projectile];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
}

- (void)update:(ccTime)delta {
    NSMutableArray * projectilesToDelete = [[NSMutableArray alloc] init];
    for (CCSprite * projectile in projectiles_) {
        
        NSMutableArray * monstersToDelete = [[NSMutableArray alloc] init];
        for (CCSprite * monster in monsters_) {
            if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)) {
                [monstersToDelete addObject:monster];
            }
        }
        
        for (CCSprite * monster in monstersToDelete) {
            [monsters_ removeObject:monster];
            [self removeChild:monster cleanup:YES];
            monstersDestoryed++;
            if (monstersDestoryed > 30) {
                CCScene * gameOverScene = [GameOverLayer sceneWithWon:YES];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }
        }
        
        if (monstersToDelete.count > 0) {
            [projectilesToDelete addObject:projectile];
        }
        [monstersToDelete release];
    }
    
    for (CCSprite * projectile in projectilesToDelete) {
        [projectiles_ removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    [projectilesToDelete release];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
    [monsters_ release];
    monsters_ = nil;
    [projectiles_ release];
    projectiles_ = nil;
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
