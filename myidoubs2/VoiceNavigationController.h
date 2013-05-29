//
//  VoiceNavigationController.h
//  myidoubs2
//
//  Created by 赵 峰 on 13-5-20.
//  Copyright (c) 2013年 赵 峰. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface VoiceNavigationController : UIViewController
{
    NgnEngine *_engine;
    NgnBaseService<INgnSipService>* _sipService;
    NgnBaseService<INgnConfigurationService>* _configurationService;
    NgnAVSession *_currentAVSession;
    NgnAVSession *_currentAVSession2;
}

@property (nonatomic, retain) IBOutlet UITextField *dailNumTextField;
@property (nonatomic, retain) IBOutlet UIButton *callButton;
@property (nonatomic, retain) IBOutlet UILabel *debugInfoLabel;

- (IBAction)clickCallButton:(id)sender;

- (void)dealWithAppWillEnterForeground;
- (void)dealWithAppWillTerminate;

@end
