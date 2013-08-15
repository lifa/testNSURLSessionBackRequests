//
//  AppDelegate.h
//  backgroundDownload
//
//  Created by fan lifei on 13-8-15.
//  Copyright (c) 2013年 fan lifei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy, nonatomic) void (^completHandler)();

@end
