//
//  MasterViewController.m
//  backgroundDownload
//
//  Created by fan lifei on 13-8-15.
//  Copyright (c) 2013年 fan lifei. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "AppDelegate.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
    __weak UITableView *table;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    table = [[self.view subviews] objectAtIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
    [self start:[self imgurl]];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    UIProgressView *prev = [[UIProgressView alloc] initWithFrame:cell.bounds];
    [cell.contentView addSubview:prev];
    prev.tag = indexPath.row;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma  mark -

- (NSString *)imgurl
{
    NSArray *ar = [NSArray arrayWithObjects:
                   @"http://i1.sinaimg.cn/dy/deco/2013/0312/logo.png",
                   @"http://i0.sinaimg.cn/dy/photo/2013/images/icon.png",
                   @"http://www.apple.com/lion.png",
                   @"http://i2.sinaimg.cn/dy/main/ewm/2/wap_photo.png",
                   @"http://i2.sinaimg.cn/photo/2/2013-06-17/U9889P1505T2D2F58DT20130815095121.jpg",
                   @"http://i2.sinaimg.cn/photo/2/2013-06-17/U9889P1505T2D2F58DT20130815095121.jpg",
                   nil];
    int i = arc4random() % ar.count;
    return [ar objectAtIndex:i];
}

- (NSMutableSet*)tasks
{
    if (nil == _tasks) {
        _tasks = [NSMutableSet set];
    }
    return _tasks;
}

- (NSMutableSet*)paused
{
    if (nil == _paused) {
        _paused = [NSMutableSet set];
    }
    return _paused;
}

- (NSURLSession*)backSession
{
    static NSURLSession *ses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfiguration:@"back.sess"];
        ses = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    });
    return ses;
}

- (void)start:(NSString*)u
{
    if ([self.paused count] > 0) {
        NSLog(@"resume paused");
        NSURLSessionDownloadTask *t = [self.paused anyObject];
        NSString *f = [self fileWithTask:t];
        NSData *data = [NSData dataWithContentsOfFile:f];
        if (data) {
            
            [self.backSession downloadTaskWithResumeData:data];
            
            return;
        }
    }
    
    NSURL *url = [NSURL URLWithString:u];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *t = [self.backSession downloadTaskWithRequest:request];
    [self.tasks addObject:t];
    
    [t resume];
}

- (void)callComplete
{
    [self.backSession getTasksWithCompletionHandler:^(NSArray *datas,NSArray *ups, NSArray *downs){
        int left = datas.count + [ups count] + [downs count];
        if (left == 0) {
            NSLog(@"callComplete");
            AppDelegate *del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            void (^blk)() = del.completHandler;
            del.completHandler = nil;
            blk();
        }
        else {
            NSLog(@"left:%d",left);
        }
    }];
}

- (NSString*)fileWithTask:(NSURLSessionDownloadTask*)task
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *fir = [paths objectAtIndex:0];
    NSString *file = [fir stringByAppendingPathComponent:task.description];
    return file;
}

#pragma mark - urlsession delegates

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"error for %@",task);
    }
    else {
        NSLog(@"complete:%@",task);
    }
    
    [self.tasks removeObject:task];
    
    if ([self.paused containsObject:task]) {
        [self.paused removeObject:task];
    }
    
    [self callComplete];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"finish task %@ at %@",downloadTask,location);
    NSString *file = [self fileWithTask:downloadTask];
    NSError *copyError = nil;
    [[NSFileManager defaultManager] copyItemAtPath:[location path] toPath:file error:&copyError];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        UIImage *img = [UIImage imageWithContentsOfFile:file];
        int x = arc4random() % 300;
        int y = arc4random() % 450;
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        iv.frame = CGRectMake(x, y, img.size.width, img.size.height);

        [table addSubview:iv];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"press:%lld/%lld",totalBytesWritten,totalBytesExpectedToWrite);
    static int i = 0;
    if (totalBytesExpectedToWrite == totalBytesWritten) {
        i ++;
    }
    if (totalBytesWritten * 2 > totalBytesExpectedToWrite) {
//        int crash = ((char*)0)[1];
        [downloadTask cancelByProducingResumeData:^(NSData* ld){
            NSLog(@"pause:%@",downloadTask);
            NSString *file = [self fileWithTask:downloadTask];
            [ld writeToFile:file atomically:YES];
            [self.paused addObject:downloadTask];
        }];
        
    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"didResumeAtOffset");
}

@end
