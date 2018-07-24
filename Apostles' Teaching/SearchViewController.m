//
//  SearchViewController.m
//  Apostles' Teaching
//
//  Created by Andy Uyeda on 5/11/18.
//  Copyright © 2018 Andy Uyeda. All rights reserved.
//

#import "SearchViewController.h"
#import "ToastView.h"
#import "AppDelegate.h"
#import "SWRevealViewController.h"

#define BOOKMARKS @"Bookmarks"
#define BOOKMARKS_(title) [NSString stringWithFormat:@"Bookmarks_%@",title]
#define HOME @"Home"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize webView, searchBar, menuButton, activityIndicator;

NSMutableArray *bookmarks;
NSTimer *updateTimer;
NSString *currentUrl;
BOOL editing;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menuButton.target = self.revealViewController;
    menuButton.action = @selector(revealToggle:);
    self.revealViewController.delegate = self;
    self.navigationController.navigationBar.topItem.leftBarButtonItem = menuButton;
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
    
    
    self.navigationController.navigationBar.topItem.title = @"Search";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *home = [prefs objectForKey:HOME];
    if([home length] <= 0){
        home = @"https://www.google.com/";
    }
    
    NSURL *nsurl=[NSURL URLWithString:home];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    
    [webView loadRequest:nsrequest];
}

- (void)update: (NSTimer*) timer {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *url = [prefs objectForKey:@"load"];
    NSLog(@"%@", url);
    if([url length] > 0 && [url containsString: @"www"])
    {
        NSLog(@"HELLO");
        NSURL *nsurl=[NSURL URLWithString:url];
        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];

        [webView loadRequest:nsrequest];

        [prefs setObject:@"load" forKey:@"load"];
        [prefs synchronize];
    }
    
}
- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDel = (AppDelegate*) [UIApplication sharedApplication].delegate;
    appDel.currentController = @"search";
    
    updateTimer = [NSTimer timerWithTimeInterval:0.5
                                          target:self
                                        selector:@selector(update:)
                                        userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [updateTimer invalidate];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    editing = true;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    editing = false;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"%@", searchBar.text);
    NSString* typedText = [searchBar.text uppercaseString];
    
    if([typedText containsString:@"WWW."])
    {
        if(![typedText containsString:@"HTTP"])
        {
            typedText = [@"HTTP://" stringByAppendingString:typedText];
            NSLog(@"%@", typedText);
        }
        NSURL *nsurl=[NSURL URLWithString:typedText];
        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
        
        [webView loadRequest:nsrequest];
    } else {
        NSString *search = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSURL *nsurl=[NSURL URLWithString:[@"http://google.com/search?q=" stringByAppendingString:search]];
        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
        
        [webView loadRequest:nsrequest];
    }
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    currentUrl = [request.mainDocumentURL absoluteString];
    NSLog(@"URL: %@", currentUrl);
    
        if([currentUrl containsString:@"mp3"] || [currentUrl containsString:@"m4a"])
        {
            UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
            generalPasteboard.string = currentUrl;
            [ToastView showToastInParentView:self.view withText:@"Link was copied" withDuaration:4.0 withOffset:80];
        }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    NSLog(@"%@", currentUrl);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [activityIndicator setHidden:YES];
    [activityIndicator stopAnimating];
    if(!editing){
        searchBar.text = currentUrl;
        NSLog(@"%@", currentUrl);
    }
}

- (IBAction)goBack:(id)sender {
    if(webView.canGoBack)
    {
        [webView goBack];
    }
}

- (IBAction)makeHome:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *home = [prefs objectForKey:HOME];
    
    if([home length] > 0)
    {
        NSURL *nsurl=[NSURL URLWithString:home];
        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
        [webView loadRequest:nsrequest];
    }
}

- (IBAction)addBookmark:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Bookmark"
                                                    message:[NSString stringWithFormat:@"Enter Title for Bookmark:"]
                                                   delegate:self cancelButtonTitle:@"Home"
                                          otherButtonTitles:@"Add", nil];
    
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    if([currentUrl length] > 0)
    {
        [alert show];
    }
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    bookmarks = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:BOOKMARKS]];
    [bookmarks addObject:[[alert textFieldAtIndex:0] text]];
    [prefs setObject: currentUrl forKey:BOOKMARKS_([[alert textFieldAtIndex:0] text])];
    [prefs setObject: bookmarks forKey:BOOKMARKS];
    
    if(0 == buttonIndex)
    {
        [prefs setObject:currentUrl forKey:HOME];
    }
    [prefs synchronize];
}
- (IBAction)toClipboard:(id)sender {
    UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
    if([currentUrl length] > 0)
    {
        generalPasteboard.string = currentUrl;
        [ToastView showToastInParentView:self.view withText:@"Link was copied" withDuaration:4.0 withOffset:80];
    } else {
        [ToastView showToastInParentView:self.view withText:@"Failed to copy link" withDuaration:4.0 withOffset:80];
    }
}
@end
