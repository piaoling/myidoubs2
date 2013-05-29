//
//  VideoNavigationController.h
//  myidoubs2
//
//  Created by 赵 峰 on 13-5-20.
//  Copyright (c) 2013年 赵 峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"

@interface VideoNavigationController : UIViewController
{
    NgnEngine *_engine;
    NgnBaseService<INgnSipService>* _sipService;
    NgnBaseService<INgnConfigurationService>* _configurationService;
    NgnAVSession *_currentAVSession;
}

@property (nonatomic, retain) IBOutlet UITextField *dailNumTextField;
@property (nonatomic, retain) IBOutlet UIButton *callButton;
@property (nonatomic, retain) IBOutlet UIImageView *remoteImgView;
@property (nonatomic, retain) IBOutlet UIView *selfView;
@property (nonatomic, retain) IBOutlet UILabel *debugInfoLabel;
@property (nonatomic, retain) IBOutlet UILabel *remoteLabel;

@property (nonatomic, retain) iOSGLView *remoteGLView;


- (IBAction)clickCallButton:(id)sender;

- (void)dealWithAppWillEnterForeground;
- (void)dealWithAppWillTerminate;

@end
