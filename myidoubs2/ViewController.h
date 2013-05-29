//
//  ViewController.h
//  myidoubs2
//
//  Created by 赵 峰 on 13-5-15.
//  Copyright (c) 2013年 赵 峰. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@class MainFuncTabBarController;

@interface ViewController : UIViewController
{
    NSString *_proxyHost;
    NSString *_realm;
    NSString *_password;
    NSString *_privateID;
    NSString *_publicID;
    
    BOOL _bEnableEarlyIMS;
    int  _proxyPort;
    
    BOOL _bScheduleRegistration;
    
    NgnEngine *_engine;
//    NgnBaseService<INgnBaseService>* _sipService;
    NgnBaseService<INgnConfigurationService>* _configurationService;
}

@property (retain, nonatomic) MainFuncTabBarController *mainFuncTabBarController;

@property (nonatomic, retain) IBOutlet UITextField *privateIDTextField;
@property (nonatomic, retain) IBOutlet UITextField *publicIDTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UITextField *realmTextField;

@property (nonatomic, retain) IBOutlet UIButton *connectButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;

@property (nonatomic, retain) IBOutlet UILabel *connectStatusLabel;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)clickConnectButton:(id)sender;
- (IBAction)clickNextButton:(id)sender;

- (void)dealWithAppWillEnterForeground;
- (void)dealWithAppWillTerminate;

@end
