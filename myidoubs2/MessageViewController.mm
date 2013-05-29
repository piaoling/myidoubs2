//
//  MessageViewController.m
//  myidoubs2
//
//  Created by 赵 峰 on 13-5-20.
//  Copyright (c) 2013年 赵 峰. All rights reserved.
//

#import "MessageViewController.h"

static const NSString *kRemoteParty = @"520";
static const NSString *kRealm = @"10.245.0.15";

@implementation  MessageViewController (SipCallbackEvents)

//== PagerMode IM (MESSAGE) events == //
-(void) onMessagingEvent:(NSNotification*)notification {
	NgnMessagingEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case MESSAGING_EVENT_CONNECTING:
		case MESSAGING_EVENT_CONNECTED:
		case MESSAGING_EVENT_TERMINATING:
		case MESSAGING_EVENT_TERMINATED:
		case MESSAGING_EVENT_FAILURE:
		case MESSAGING_EVENT_SUCCESS:
		case MESSAGING_EVENT_OUTGOING:
		default:
		{
			break;
		}
			
		case MESSAGING_EVENT_INCOMING:
		{
			if(eargs.payload){
				// The payload is a NSData object which means that it could contain binary data
				// here I consider that it's utf8 text message
				NSString* contentType = [eargs getExtraWithKey: kExtraMessagingEventArgsContentType];
				NSString* from = [eargs getExtraWithKey: kExtraMessagingEventArgsFrom];
				NSString* content = [NSString stringWithUTF8String: (const char*)[eargs.payload bytes]];
				self.receivedMsgLabel.text = [NSString stringWithFormat: @"Incoming message from:%@\n with ctype:%@\n and content:%@", from, contentType, content];
                
				// If the configuration entry "RCS_AUTO_ACCEPT_PAGER_MODE_IM" (BOOL) is equal to false then
				// you must accept() or reject() the message like this:
                
				// NgnMessagingSession* imSession = [[NgnMessagingSession getSessionWithId: eargs.sessionId] retain];
				// if(session){
				//	[imSession accept]; // or [imSession reject];
				//	[imSession release];
				//}
				
			}
			break;
		}
	}
	
	self.debugMsgLabel.text = [NSString stringWithFormat: @"onMessagingEvent: %@", eargs.sipPhrase];
}

@end

@implementation MessageViewController

@synthesize connectStatusLabel, sendButton, sendTextView, receivedMsgLabel, debugMsgLabel, activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Message";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
    _engine = [[NgnEngine sharedInstance] retain];
    _sipService = [_engine.sipService retain];
    _configurationService = [_engine.configurationService retain];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.connectStatusLabel release];
    [self.sendButton release];
    [self.sendTextView release];
    [self.receivedMsgLabel release];
    [self.debugMsgLabel release];
    [self.activityIndicator release];
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began ");
    
    [self.sendTextView resignFirstResponder];
}


- (void)clickSendButton:(id)sender
{
    NSLog(@"send");
    ActionConfig* actionConfig = new ActionConfig();
	if(actionConfig){
		actionConfig->addHeader("Organization", "Doubango Telecom");
		actionConfig->addHeader("Subject", "testMessaging for iOS");
	}
	NgnMessagingSession* imSession = [[NgnMessagingSession sendTextMessageWithSipStack: [_sipService getSipStack]
                                                                              andToUri: [NSString stringWithFormat: @"sip:%@@%@", kRemoteParty, kRealm]
                                                                            andMessage: self.sendTextView.text
                                                                        andContentType: kContentTypePlainText
                                                                       andActionConfig: actionConfig
									   ] retain]; // Do not retain the session if you don't want it
	// do whatever you want with the session
	if(actionConfig)
    {
		delete actionConfig, actionConfig = tsk_null;
	}
	[NgnMessagingSession releaseSession: &imSession];
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

}

@end
