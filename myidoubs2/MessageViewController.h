//
//  MessageViewController.h
//  myidoubs2
//
//  Created by 赵 峰 on 13-5-20.
//  Copyright (c) 2013年 赵 峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"

@interface MessageViewController : UIViewController
{
    
    NgnEngine *_engine;
    NgnBaseService<INgnSipService>* _sipService;
    NgnBaseService<INgnConfigurationService>* _configurationService;
}

@property (nonatomic, retain) IBOutlet UILabel *connectStatusLabel;
@property (nonatomic, retain) IBOutlet UITextView *sendTextView;
@property (nonatomic, retain) IBOutlet UILabel *receivedMsgLabel;
@property (nonatomic, retain) IBOutlet UILabel *debugMsgLabel;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)clickSendButton:(id)sender;

- (void)dealWithAppWillEnterForeground;
- (void)dealWithAppWillTerminate;

@end
