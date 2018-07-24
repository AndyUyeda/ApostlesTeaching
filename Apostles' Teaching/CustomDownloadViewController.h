//
//  CustomDownloadViewController.h
//  Apostles' Teaching
//
//  Created by Andy Uyeda on 5/11/18.
//  Copyright © 2018 Andy Uyeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomDownloadViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate,UIWebViewDelegate>{
    NSMutableData *fileData;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *duplicateItem;
@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextField *linkField;
@property (strong, nonatomic) IBOutlet UITextField *teacherField;
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;
@property (strong, nonatomic) IBOutlet UIProgressView *showProgress;

- (IBAction)download:(id)sender;

@end

