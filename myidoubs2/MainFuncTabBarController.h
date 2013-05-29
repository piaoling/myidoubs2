//
//  MainFuncTabBarController.h
//  myidoubs2
//
//  Created by 赵 峰 on 13-5-20.
//  Copyright (c) 2013年 赵 峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageViewController;
@class VoiceNavigationController;
@class VideoNavigationController;
@class LogoutViewController;

@interface MainFuncTabBarController : UITabBarController

@property (retain, nonatomic) MessageViewController *messageViewController;
@property (retain, nonatomic) VoiceNavigationController *voiceNavigationController;
@property (retain, nonatomic) VideoNavigationController *videoNavigationController;
@property (retain, nonatomic) LogoutViewController *logoutViewController;

- (void)dealWithAppWillEnterForeground;
- (void)dealWithAppWillTerminate;

@end
