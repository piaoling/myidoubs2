//
//  ViewController.m
//  myidoubs2
//
//  Created by 赵 峰 on 13-5-15.
//  Copyright (c) 2013年 赵 峰. All rights reserved.
//

#import "ViewController.h"
#import "MainFuncTabBarController.h"

// Include all headers
#import "iOSNgnStack.h"

//#define SIP_HOST       @"192.168.1.221"
//#define SIP_PORT       5060
//#define SIP_PRIVATE_ID @"510"
//#define SIP_PUBLIC_ID  @"sip:510@192.168.1.221"
//#define SIP_PASSWORD   @"1234"
//#define SIP_REALM      @"192.168.1.221"

#define SIP_HOST       @"10.245.0.15"
#define SIP_PORT       5060
#define SIP_PRIVATE_ID @"530"
#define SIP_PUBLIC_ID  @"sip:530@10.245.0.15"
#define SIP_PASSWORD   @"1234"
#define SIP_REALM      @"10.245.0.15"

//#define SIP_HOST       @"proxy.sipthor.net"
//#define SIP_PORT       5060
//#define SIP_PRIVATE_ID @"520001"
//#define SIP_PUBLIC_ID  @"sip:520001@sip2sip.info"
//#define SIP_PASSWORD   @"123456"
//#define SIP_REALM      @"sip2sip.info"

@implementation ViewController (SipCallbackEvents)

//== Registrations events == //
-(void) onRegistrationEvent:(NSNotification*)notification
{
	NgnRegistrationEventArgs* eargs = [notification object];
	
	// Current event triggered the callback
	// to get the current registration state you should use "mSipService::getRegistrationState"
	switch (eargs.eventType) {
            // provisional responses
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_INPROGRESS:
            self.activityIndicator.alpha = 1;
			[self.activityIndicator startAnimating];
			break;
            // final responses
		case REGISTRATION_OK:
		case REGISTRATION_NOK:
		case UNREGISTRATION_OK:
		case UNREGISTRATION_NOK:
            self.activityIndicator.alpha = 0;
			[self.activityIndicator stopAnimating];
		default:
			break;
	}
	[self.connectButton setTitle: [_engine.sipService isRegistered] ? @"UnRegister" : @"Register" forState: UIControlStateNormal];
	self.connectStatusLabel.text = eargs.sipPhrase;
	
	// gets the new registration state
	ConnectionState_t registrationState = [_engine.sipService getRegistrationState];
    
	switch (registrationState)
    {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
		default:
			[self.connectButton setTitle: @"Register" forState: UIControlStateNormal];
            
			if (_bScheduleRegistration)
            {
				_bScheduleRegistration = FALSE;
				[_engine.sipService registerIdentity];
			}
            self.connectStatusLabel.backgroundColor = [UIColor redColor];
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
			[self.connectButton setTitle: @"Cancel" forState: UIControlStateNormal];
			self.connectStatusLabel.backgroundColor = [UIColor redColor];
			break;
		case CONN_STATE_CONNECTED:
			[self.connectButton setTitle: @"UnRegister" forState: UIControlStateNormal];
			self.connectStatusLabel.backgroundColor = [UIColor greenColor];
			break;
	}
}

@end

@implementation ViewController

@synthesize privateIDTextField, publicIDTextField, passwordTextField, realmTextField, connectButton, nextButton, connectStatusLabel, activityIndicator;
@synthesize mainFuncTabBarController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.activityIndicator.alpha = 0;
    self.mainFuncTabBarController = nil;
    
    _proxyHost = SIP_HOST;
    _proxyPort = SIP_PORT;
    
    _realm = SIP_REALM;
    _password = SIP_PASSWORD;
    _privateID = SIP_PRIVATE_ID;
    _publicID = SIP_PUBLIC_ID;
    
    self.privateIDTextField.text = _privateID;
    self.publicIDTextField.text = _publicID;
    self.passwordTextField.text = _password;
    self.realmTextField.text = _realm;
    
    _bEnableEarlyIMS = TRUE;
    
    // add observers
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
    
    // take an instance of the engine
	_engine = [[NgnEngine sharedInstance] retain];
	[_engine start];// start the engine
    
    // take needed services from the engine
//	_sipService = [[_engine getSipService] retain];
	_configurationService = [[_engine getConfigurationService] retain];
    
    // set credentials
	[_configurationService setStringWithKey: IDENTITY_IMPI andValue: _privateID];
	[_configurationService setStringWithKey: IDENTITY_IMPU andValue: _publicID];
	[_configurationService setStringWithKey: IDENTITY_PASSWORD andValue: _password];
	[_configurationService setStringWithKey: NETWORK_REALM andValue: _realm];
	[_configurationService setStringWithKey: NETWORK_PCSCF_HOST andValue:_proxyHost];
	[_configurationService setIntWithKey: NETWORK_PCSCF_PORT andValue: _proxyPort];
	[_configurationService setBoolWithKey: NETWORK_USE_EARLY_IMS andValue: _bEnableEarlyIMS];
    
//    [_sipService registerIdentity];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self.mainFuncTabBarController release];
    
    [self.privateIDTextField release];
    [self.publicIDTextField release];
    [self.passwordTextField release];
    [self.realmTextField release];
    [self.connectButton release];
    [self.nextButton release];
    [self.connectStatusLabel release];
    [self.activityIndicator release];
    
    [_proxyHost release];
    [_realm release];
    [_password release];
    [_privateID release];
    [_publicID release];
    
    _bEnableEarlyIMS = FALSE;
    _proxyPort = -1;
    
    [super dealloc];
}

- (void)dealWithAppWillEnterForeground
{
    ConnectionState_t registrationState = [_engine.sipService getRegistrationState];
	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			[_engine.sipService registerIdentity];
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
			_bScheduleRegistration = TRUE;
			[_engine.sipService unRegisterIdentity];
		case CONN_STATE_CONNECTED:
			break;
	}
}

- (void)dealWithAppWillTerminate
{
    if (self.mainFuncTabBarController != nil)
    {
        [self.mainFuncTabBarController dealWithAppWillTerminate];
    }
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_engine release];
//	[mSipService release];
	[_configurationService release];
    
    [_engine stop];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began ");
//    if ([self.titleTextField isFirstResponder])
//    {
//        [self.titleTextField resignFirstResponder];
//    }
//    else if ([self.contentTextView isFirstResponder])
//    {
//        [self textViewResign];
//    }

    [self.privateIDTextField resignFirstResponder];
    [self.publicIDTextField resignFirstResponder];
    [self.realmTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - Button Action
- (void)clickConnectButton:(id)sender
{
    ConnectionState_t registrationState = [_engine.sipService getRegistrationState];
    
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
        {
            if (self.privateIDTextField.text != _privateID)
            {
                _privateID = self.privateIDTextField.text;
            }
            if (self.publicIDTextField.text != _publicID)
            {
                _publicID = self.publicIDTextField.text;
            }
            if (self.passwordTextField.text != _password)
            {
                _password = self.passwordTextField.text;
            }
            if (self.realmTextField.text != _realm)
            {
                _realm = self.realmTextField.text;
//                _proxyHost = _realm;
            }
            
            // set credentials
            [_configurationService setStringWithKey: IDENTITY_IMPI andValue: _privateID];
            [_configurationService setStringWithKey: IDENTITY_IMPU andValue: _publicID];
            [_configurationService setStringWithKey: IDENTITY_PASSWORD andValue: _password];
            [_configurationService setStringWithKey: NETWORK_REALM andValue: _realm];
            [_configurationService setStringWithKey: NETWORK_PCSCF_HOST andValue:_proxyHost];
            [_configurationService setIntWithKey: NETWORK_PCSCF_PORT andValue: _proxyPort];
            
            [_engine.sipService registerIdentity];
        }
		
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
		case CONN_STATE_CONNECTED:
			[_engine.sipService unRegisterIdentity];
			break;
	}
    
}

- (void)clickNextButton:(id)sender
{
    ConnectionState_t registrationState = [_engine.sipService getRegistrationState];
    
    if (registrationState == CONN_STATE_CONNECTED)
    {
        if (self.mainFuncTabBarController == nil)
        {
            self.mainFuncTabBarController = [[[MainFuncTabBarController alloc] initWithNibName:@"MainFuncTabBarController" bundle:nil] autorelease];
        }
        
//        [[[UIApplication sharedApplication].delegate window] addSubview:self.mainFuncTabBarController.view];
        self.mainFuncTabBarController.selectedIndex = 0;
        [self presentViewController:self.mainFuncTabBarController animated:YES completion:nil];
    }
    //allert please regist first
}


@end
