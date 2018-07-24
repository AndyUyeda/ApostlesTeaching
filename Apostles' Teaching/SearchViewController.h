//
//  SearchViewController.h
//  Apostles' Teaching
//
//  Created by Andy Uyeda on 5/11/18.
//  Copyright © 2018 Andy Uyeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UISearchBarDelegate, UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)goBack:(id)sender;
- (IBAction)makeHome:(id)sender;
- (IBAction)addBookmark:(id)sender;
- (IBAction)toClipboard:(id)sender;

@end

