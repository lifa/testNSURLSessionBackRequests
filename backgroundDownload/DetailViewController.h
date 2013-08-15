//
//  DetailViewController.h
//  backgroundDownload
//
//  Created by fan lifei on 13-8-15.
//  Copyright (c) 2013年 fan lifei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
