//
//  CAppDelegate.m
//  iFind
//
//  Created by Carl on 13-9-18.
//  Copyright (c) 2013年 iFind. All rights reserved.
//

#import "CAppDelegate.h"
#import "CBLEManager.h"
#import "CRootViewController.h"
#import "CBLEPeriphral.h"

#import "ViewController.h"
#import "DeviceDetailViewController.h"
#define TestDeviceDetailViewcontroller
//#define TestCRootViewController
@implementation CAppDelegate

- (void)dealloc
{
    [_window release];
    _callCenter.callEventHandler = nil;
    [_callCenter release];
    
    _bgTimer = nil;
    [_foregroudTimer release];
    _foregroudTimer = nil;
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler = ^(CTCall * call){
        if([call.callState isEqualToString:CTCallStateIncoming])
        {
            NSLog(@"Call incoming");
            [[NSNotificationCenter defaultCenter] postNotificationName:kCallIncomingNotification object:self];
        }
        
    };
    
    //定时读取蓝牙的信号值
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _foregroudTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1.0 target:self selector:@selector(readRSSI:) userInfo:nil repeats:YES];
        [_foregroudTimer fire];
        [[NSRunLoop currentRunLoop] addTimer:_foregroudTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    CRootViewController * rootViewController = [[CRootViewController alloc] initWithNibName:nil bundle:nil];
#ifdef TestDeviceDetailViewcontroller
    DeviceDetailViewController * viewcontroller = [[[DeviceDetailViewController alloc]init]autorelease];
    [viewcontroller initializationDefaultValue:nil];
    self.window.rootViewController = viewcontroller;
#endif
    
#ifdef TestCRootViewController
    self.window.rootViewController = rootViewController;
#endif
    [rootViewController release];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if(_foregroudTimer)
    {
        [_foregroudTimer setFireDate:[NSDate distantFuture]];
        
    }
    
    
    UIApplication * app = [UIApplication sharedApplication];
    _bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [app endBackgroundTask:_bgTask];
            _bgTask = UIBackgroundTaskInvalid;
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if([app backgroundTimeRemaining] > 1.0)
        {
            _bgTimer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(readRSSI:) userInfo:nil repeats:YES];
            [_bgTimer fire];
            [[NSRunLoop currentRunLoop] addTimer:_bgTimer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
            
            [app endBackgroundTask:_bgTask];
            _bgTask = UIBackgroundTaskInvalid;
        }
    });
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    _bgTask = UIBackgroundTaskInvalid;
    if(_bgTimer)
    {
        if([_bgTimer isValid]) [_bgTimer invalidate];
    }
    
    
    if(_foregroudTimer)
    {
        [_foregroudTimer fire];
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)readRSSI:(NSTimer *)timer
{
    [[[CBLEManager sharedManager] foundPeripherals] makeObjectsPerformSelector:@selector(readRSSI:) withObject:timer];
}

@end