//
//  VideoNavigationController.m
//  myidoubs2
//
//  Created by 赵 峰 on 13-5-20.
//  Copyright (c) 2013年 赵 峰. All rights reserved.
//

#import "VideoNavigationController.h"

//static const NSString *kRealm = @"10.245.0.15";
static const NSString *kRealm = @"sip2sip.info";

@implementation VideoNavigationController(SipCallbackEvents)

//== INVITE (audio/video, file transfer, chat, ...) events == //
-(void) onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INCOMING:
		{
			if(_currentAVSession){
				TSK_DEBUG_ERROR("This is a test application and we only support ONE audio/video call at time!");
				[_currentAVSession hangUpCall];
				return;
			}
			
			_currentAVSession = [[NgnAVSession getSessionWithId: eargs.sessionId] retain];
			if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
				UILocalNotification* localNotif = [[[UILocalNotification alloc] init] autorelease];
				if (localNotif){
					localNotif.alertBody =[NSString  stringWithFormat:@"Call from %@", [_currentAVSession getRemotePartyUri]];
					localNotif.soundName = UILocalNotificationDefaultSoundName;
					localNotif.applicationIconBadgeNumber = 1;
					localNotif.repeatInterval = 0;
					
					[[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
				}
			}
			else {
				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle: @"Incoming Call"
									  message: [NSString  stringWithFormat:@"Call from %@", [_currentAVSession getRemotePartyUri]]
									  delegate: self
									  cancelButtonTitle: @"No"
									  otherButtonTitles:@"Yes", nil];
				[alert show];
				[alert release];
			}
            [NgnCamera setPreview:self.remoteGLView];
			break;
		}
			
		case INVITE_EVENT_INPROGRESS:
		{
			break;
		}
			
		case INVITE_EVENT_EARLY_MEDIA:
		case INVITE_EVENT_CONNECTED:
		{
			if(_currentAVSession && (_currentAVSession.id == eargs.sessionId)){
                [NgnCamera setPreview:nil];
				[_currentAVSession setRemoteVideoDisplay: self.remoteGLView];
				[_currentAVSession setLocalVideoDisplay: self.selfView];
                [self.remoteGLView startAnimation];
			}
			break;
		}
			
		case INVITE_EVENT_TERMINATED:
		case INVITE_EVENT_TERMWAIT:
		{
			if(_currentAVSession && (_currentAVSession.id == eargs.sessionId)){
				[_currentAVSession setRemoteVideoDisplay: nil];
				[_currentAVSession setLocalVideoDisplay: nil];
                [self.remoteGLView stopAnimation];
                [NgnCamera setPreview:self.remoteGLView];
				[NgnAVSession releaseSession: &_currentAVSession];
			}
			break;
		}
			
		default:
			break;
	}
	
	self.debugInfoLabel.text = [NSString stringWithFormat: @"onInviteEvent: %@", eargs.sipPhrase];
	[self.callButton setTitle: _currentAVSession ? @"End Call" : @"Video Call" forState: UIControlStateNormal];
}

@end

@interface VideoNavigationController ()

@end

@implementation VideoNavigationController

@synthesize dailNumTextField, callButton, selfView, debugInfoLabel, remoteGLView, remoteLabel;

- (void)dealloc
{
    [self.dailNumTextField release];
    [self.callButton release];
//    [self.remoteImgView release];
    [self.selfView release];
    [self.debugInfoLabel release];
    [self.remoteGLView release];
    [self.remoteLabel release];
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began ");
    
    [self.dailNumTextField resignFirstResponder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"video";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onInviteEvent:)
                                                 name:kNgnInviteEventArgs_Name
                                               object:nil];
    
    _engine = [[NgnEngine sharedInstance] retain];
    _sipService = [_engine.sipService retain];
    _configurationService = [_engine.configurationService retain];
    
    self.remoteGLView = [[[iOSGLView alloc] initWithFrame:[self.remoteLabel bounds]] autorelease];
    self.remoteGLView.frame.origin = self.remoteLabel.frame.origin;
    
//    [self.view insertSubview:self.remoteGLView aboveSubview:self.remoteImgView];
    [self.view insertSubview:self.remoteGLView atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickCallButton:(id)sender
{
    if(_currentAVSession)
    {
		[_currentAVSession hangUpCall];
	}
	else
    {
		_currentAVSession = [[NgnAVSession makeAudioVideoCallWithRemoteParty:[NSString stringWithFormat:@"sip:%@@%@", self.dailNumTextField.text, kRealm]
                                                                 andSipStack:[_sipService getSipStack]] retain];
	}
}

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    
	if(_currentAVSession)
    {
		if (buttonIndex == 1)
        {
			[_currentAVSession acceptCall];
		}
		else
        {
			[_currentAVSession hangUpCall];
		}
	}
}

- (void)dealWithAppWillEnterForeground
{
    
}

- (void)dealWithAppWillTerminate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_engine release];
    [_sipService release];
	[_configurationService release];
    [_currentAVSession release];
    
    _engine = nil;
    _sipService = nil;
    _configurationService = nil;
    _currentAVSession = nil;
    
}

@end
