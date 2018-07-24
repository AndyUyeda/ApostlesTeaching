//
//  CustomDownloadViewController.m
//  Apostles' Teaching
//
//  Created by Andy Uyeda on 5/11/18.
//  Copyright © 2018 Andy Uyeda. All rights reserved.
//

#import "CustomDownloadViewController.h"
#import "SWRevealViewController.h"
#import "MoreViewController.h"
#import "AppDelegate.h"

#define KEYBOARD_OFFSET 100
#define TEACHER_KEY @"Teachers"
#define TITLE_KEY_(teacher) [NSString stringWithFormat:@"Titles_%@",teacher]
#define URL_KEY_(teacher, title) [NSString stringWithFormat:@"URL%@%@",teacher,title]

@interface CustomDownloadViewController ()

@end

@implementation CustomDownloadViewController

@synthesize menuButton, teacherField, titleField, linkField, showProgress, downloadButton, duplicateItem;

long long totalFileSize;
NSURLConnection *conn;
NSString* title;
NSString* teacher;
NSString* website;
NSString* mediaType;
NSMutableArray *sermonTitleArray;
NSMutableArray *teacherArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    menuButton.target = self.revealViewController;
    menuButton.action = @selector(revealToggle:);
    
    self.revealViewController.delegate = self;
    self.navigationController.navigationBar.topItem.leftBarButtonItem = menuButton;
    self.navigationController.navigationBar.topItem.rightBarButtonItem = duplicateItem;
}

-(void)clearFields {
    teacherField.text = @"";
    titleField.text = @"";
    linkField.text = @"";
}
- (void)viewWillDisappear:(BOOL)animated {
    [duplicateItem setEnabled:NO];
    [duplicateItem setTintColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate *appDel = (AppDelegate*) [UIApplication sharedApplication].delegate;
    appDel.currentController = @"download";
    
    fileData = [NSMutableData data];
    sermonTitleArray = [NSMutableArray array];
    teacherArray = [NSMutableArray array];
    duplicateItem.target = self;
    duplicateItem.action = @selector(clearFields);
    [duplicateItem setEnabled:YES];
    [duplicateItem setTintColor:nil];
    
    [self.view setUserInteractionEnabled:YES];
    [self.navigationController setNavigationBarHidden:FALSE];
    self.navigationController.navigationBar.topItem.title = @"Download";
    
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    teacherField.delegate = self;
    titleField.delegate = self;
    linkField.delegate = self;
}

- (IBAction)download:(id)sender {
    title = titleField.text;
    teacher = teacherField.text;
    website = linkField.text;
    
    NSLog(@"%@",title);
    NSLog(@"%@",teacher);
    NSLog(@"%@",website);
    if([website containsString:@"mp3"]){
        NSLog(@"%@",@"is MP3");
        mediaType = @"mp3";
    }
    else if([website containsString:@"m4a"]){
        NSLog(@"%@",@"is M4A");
        mediaType = @"m4a";
        title = [NSString stringWithFormat:@"%@%@",@"m4a",title];
    }
    
    if(teacher != nil && title != nil && website != nil){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        sermonTitleArray = [[NSMutableArray alloc] initWithArray:[prefs objectForKey: TITLE_KEY_(teacher)]];
        teacherArray = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:TEACHER_KEY]];
        
        BOOL alreadyExists = FALSE;
        for(int i = 0; i < [sermonTitleArray count];i++){
            if([[sermonTitleArray objectAtIndex:i] isEqualToString:title]){
                alreadyExists = TRUE;
            }
        }
        if(!alreadyExists){
            
            NSURL *url = [NSURL URLWithString:website];
            NSURLRequest* req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
            conn = [NSURLConnection connectionWithRequest:req delegate:self];
            
        }
    }
}

-(void)connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse *)response{
    [showProgress setHidden: FALSE];
    [downloadButton setHidden:TRUE];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fileData setLength:0];
    totalFileSize = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    AppDelegate *appDel = (AppDelegate*) [UIApplication sharedApplication].delegate;
    appDel.teacherDownloading = teacher;
    [fileData appendData:data];
    float progressive = (float)[fileData length] / (float)totalFileSize;
    [showProgress setProgress:progressive];
    NSLog(@"%f",progressive);
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    AppDelegate *appDel = (AppDelegate*) [UIApplication sharedApplication].delegate;
    appDel.teacherDownloading = @"not downloading";
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:    (NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"G");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *path;
    if([mediaType isEqualToString:@"mp3"]){
        path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@%@",@"Documents/",teacher,title,@".mp3"]];
    }
    else if([mediaType isEqualToString:@"m4a"]){
        path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@%@",@"Documents/",teacher,title,@".m4a"]];
    }
    
    [showProgress setHidden: TRUE];
    [downloadButton setHidden:FALSE];
    
    if ([fileData writeToFile:path options:NSAtomicWrite error:nil] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"Audio Could Not Download"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [sermonTitleArray addObject:title];
        if(![teacherArray containsObject:teacher]){
            [teacherArray addObject:teacher];
        }
        
        [prefs setObject:sermonTitleArray forKey:TITLE_KEY_(teacher)];
        [prefs setObject:teacherArray forKey:TEACHER_KEY];
        [prefs setObject:website forKey:URL_KEY_(teacher, title)];
        [prefs synchronize];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:@"Audio Downloaded Successfully"
                                                       delegate:nil
                                              cancelButtonTitle:@"Great"
                                              otherButtonTitles:nil];
        [alert show];
    }
    AppDelegate *appDel = (AppDelegate*) [UIApplication sharedApplication].delegate;
    appDel.teacherDownloading = @"not downloading";
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    for (UIView *v in self.view.subviews) {
        if (v.isFirstResponder) {
            if((self.view.frame.size.height - keyboardSize.height) < v.frame.origin.y) {
                [UIView animateWithDuration:0.1 animations:^{
                    CGRect f = self.view.frame;
                    f.origin.y = -keyboardSize.height + (KEYBOARD_OFFSET);
                    self.view.frame = f;
                }];
            }
        }
    }
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.0 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [teacherField resignFirstResponder];
    [linkField resignFirstResponder];
    [titleField resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [teacherField resignFirstResponder];
    [linkField resignFirstResponder];
    [titleField resignFirstResponder];
    return YES;
}

@end
