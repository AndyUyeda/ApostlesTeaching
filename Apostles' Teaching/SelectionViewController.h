//
//  SelectionViewController.h
//  Apostles' Teaching
//
//  Created by Andy Uyeda on 5/16/18.
//  Copyright © 2018 Andy Uyeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic)  NSString *teacherName;

@end
