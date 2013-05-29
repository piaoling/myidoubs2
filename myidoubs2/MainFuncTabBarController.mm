//
//  MainFuncTabBarController.m
//  myidoubs2
//
//  Created by 赵 峰 on 13-5-20.
//  Copyright (c) 2013年 赵 峰. All rights reserved.
//

#import "MainFuncTabBarController.h"

#import "MessageViewController.h"
#import "VoiceNavigationController.h"
#import "VideoNavigationController.h"
#import "LogoutViewController.h"

@interface MainFuncTabBarController ()

@end

@implementation MainFuncTabBarController
@synthesize messageViewController, voiceNavigationController, videoNavigationController, logoutViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.messageViewController = [[[MessageViewController alloc] initWithNibName:@"MessageViewController" bundle:nil] autorelease];
    self.voiceNavigationController = [[[VoiceNavigationController alloc] initWithNibName:@"VoiceNavigationController" bundle:nil] autorelease];
    self.videoNavigationController = [[[VideoNavigationController alloc] initWithNibName:@"VideoNavigationController" bundle:nil] autorelease];
    self.logoutViewController = [[[LogoutViewController alloc] initWithNibName:@"LogoutViewController" bundle:nil] autorelease];
    
    self.viewControllers = [NSArray arrayWithObjects:self.messageViewController, self.voiceNavigationController, self.videoNavigationController, self.logoutViewController, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self.messageViewController release];
    [self.voiceNavigationController release];
    [self.videoNavigationController release];
    [self.logoutViewController release];
    [super dealloc];
}

- (void)dealWithAppWillEnterForeground
{
    [self.messageViewController dealWithAppWillEnterForeground];
    [self.voiceNavigationController dealWithAppWillEnterForeground];
}

- (void)dealWithAppWillTerminate
{
    [self.messageViewController dealWithAppWillTerminate];
    [self.voiceNavigationController dealWithAppWillTerminate];
}

@end
