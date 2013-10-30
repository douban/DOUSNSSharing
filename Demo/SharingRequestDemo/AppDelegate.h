//
//  AppDelegate.h
//  SharingRequestDemo
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <UIKit/UIKit.h>



@class SinaweiboAuthorization;
@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SinaweiboAuthorization *authorization;

+ (AppDelegate*)appDelegate;

@end
