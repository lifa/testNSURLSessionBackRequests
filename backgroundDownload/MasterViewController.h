//
//  MasterViewController.h
//  backgroundDownload
//
//  Created by fan lifei on 13-8-15.
//  Copyright (c) 2013年 fan lifei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <NSURLSessionDelegate,NSURLSessionDownloadDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSURLSession  *backSession;
@property (strong, nonatomic) NSMutableSet  *tasks;
@property (strong, nonatomic) NSMutableSet  *paused;

@end
