//
//  VoiceNavigationController.m
//  myidoubs2
//
//  Created by 赵 峰 on 13-5-20.
//  Copyright (c) 2013年 赵 峰. All rights reserved.
//

#import "VoiceNavigationController.h"

static const NSString *kRealm = @"10.245.0.15";

#define AV_SESSION  101
#define AV_SESSION2 102

//#undef TAG
//#define kTAG @"TestAudioCall///:"
//#define TAG kTAG

@interface VoiceNavigationController ()

@end

@implementation VoiceNavigationController(SipCallbackEvents)

//== INVITE (audio/video, file transfer, chat, ...) events == //
-(void) onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INCOMING:
		{
			if(_currentAVSession && _currentAVSession2){
				TSK_DEBUG_ERROR("This is a test application and we only support ONE audio/video call at time!");
				[_currentAVSession hangUpCall];
                [_currentAVSession2 hangUpCall];
				return;
			}
			
            if (!_currentAVSession)
            {
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
                    alert.tag = AV_SESSION;
                    [alert show];
                    [alert release];
                }
            }
            else if(_currentAVSession && !_currentAVSession2)
            {
                _currentAVSession2 = [[NgnAVSession getSessionWithId: eargs.sessionId] retain];
                if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
                    UILocalNotification* localNotif = [[[UILocalNotification alloc] init] autorelease];
                    if (localNotif){
                        localNotif.alertBody =[NSString  stringWithFormat:@"Call from %@", [_currentAVSession2 getRemotePartyUri]];
                        localNotif.soundName = UILocalNotificationDefaultSoundName;
                        localNotif.applicationIconBadgeNumber = 1;
                        localNotif.repeatInterval = 0;
                        
                        [[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
                    }
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle: @"Incoming Call"
                                          message: [NSString  stringWithFormat:@"Call from %@", [_currentAVSession2 getRemotePartyUri]]
                                          delegate: self
                                          cancelButtonTitle: @"No"
                                          otherButtonTitles:@"Yes", nil];
                    alert.tag = AV_SESSION2;
                    [alert show];
                    [alert release];
                }
            }
			
			break;
		}
            
		case INVITE_EVENT_INPROGRESS:
		{
			break;
		}
			
		case INVITE_EVENT_TERMINATED:
		case INVITE_EVENT_TERMWAIT:
		{
			if(_currentAVSession && (_currentAVSession.id == eargs.sessionId))
            {
				[NgnAVSession releaseSession: &_currentAVSession];
			}
            if(_currentAVSession2 && (_currentAVSession2.id == eargs.sessionId))
            {
				[NgnAVSession releaseSession: &_currentAVSession2];
			}
			break;
		}
			
		default:
			break;
	}
	
	self.debugInfoLabel.text = [NSString stringWithFormat: @"onInviteEvent: %@", eargs.sipPhrase];
	[self.callButton setTitle: _currentAVSession ? @"End Call" : @"Audio Call" forState: UIControlStateNormal];
}

@end

@implementation VoiceNavigationController

@synthesize dailNumTextField, callButton, debugInfoLabel;

-(void)dealloc
{
    [self.dailNumTextField release];
    [self.callButton release];
    [self.debugInfoLabel release];
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
        self.title = @"Voice";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
    
    _engine = [[NgnEngine sharedInstance] retain];
    _sipService = [_engine.sipService retain];
    _configurationService = [_engine.configurationService retain];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickCallButton:(id)sender
{
    if (_currentAVSession)
    {
        [_currentAVSession hangUpCall];
        
    }
    else
    {
        _currentAVSession = [[NgnAVSession makeAudioCallWithRemoteParty:
                              [NSString stringWithFormat: @"sip:%@@%@", self.dailNumTextField.text, kRealm]
                                                            andSipStack: [_sipService getSipStack]] retain];
    }
    
    if (_currentAVSession2)
    {
        [_currentAVSession2 hangUpCall];
    }
}

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex{
    
    if (alertView.tag == AV_SESSION)
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
    else if (alertView.tag == AV_SESSION2)
    {
        if(_currentAVSession2)
        {
            if (buttonIndex == 1)
            {
                [_currentAVSession2 acceptCall];
            }
            else
            {
                [_currentAVSession2 hangUpCall];
            }
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
    [_currentAVSession2 release];
    
    _engine = nil;
    _sipService = nil;
    _configurationService = nil;
    _currentAVSession = nil;
    _currentAVSession2 = nil;
    
}

@end
