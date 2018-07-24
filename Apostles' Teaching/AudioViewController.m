//
//  AudioViewController.m
//  Apostles' Teaching
//
//  Created by Andy Uyeda on 5/11/18.
//  Copyright © 2018 Andy Uyeda. All rights reserved.
//

#import "AudioViewController.h"
#import "SelectionViewController.h"
#import "AppDelegate.h"

@interface AudioViewController ()

@end

@implementation AudioViewController

@synthesize menuButton;

#define TEACHER_KEY @"Teachers"
#define TITLE_KEY_(teacher) [NSString stringWithFormat:@"Titles_%@",teacher]
#define URL_KEY_(teacher, title) [NSString stringWithFormat:@"URL%@%@",teacher,title]
#define IMAGE_(teacher) [NSString stringWithFormat:@"Image_%@",teacher]

NSMutableArray *nameArray;
NSMutableArray *imageArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    menuButton.target = self.revealViewController;
    menuButton.action = @selector(revealToggle:);
    self.revealViewController.delegate = self;
    self.navigationController.navigationBar.topItem.leftBarButtonItem = menuButton;
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate *appDel = (AppDelegate*) [UIApplication sharedApplication].delegate;
    appDel.currentController = @"audio";
    
    [self.view setUserInteractionEnabled:YES];
    [self.navigationController setNavigationBarHidden:FALSE];
    self.navigationController.navigationBar.topItem.title = @"Audio";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    nameArray = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:TEACHER_KEY]];
    //    [nameArray addObject:@"Jones Ndzi"];
    //    [nameArray addObject:@"Art Azurdia"];
    //    [prefs setObject:nameArray forKey:TEACHER_KEY];
    //    [prefs synchronize];
    
    if([imageArray count] != [nameArray count])
    {
        imageArray = [NSMutableArray array];
        for(int i = 0; i < [nameArray count]; i++){
            UIImage *image = [UIImage imageWithData:[prefs objectForKey:IMAGE_([nameArray objectAtIndex:i])]];
            if(image == NULL)
            {
                [imageArray addObject:[UIImage imageNamed:@"Icon-App-60x60.png"]];
            }
            else
            {
                [imageArray addObject:image];
            }
            
            
        }
    }
    
    [_tableView reloadData];
    
    NSLog(@"%@", nameArray);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [nameArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableViews cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    NSString *name = [nameArray objectAtIndex:indexPath.row];
    int section = indexPath.section;
    UIImage *selectedImage = [imageArray objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableViews dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = name;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:20.0];
    cell.imageView.image = selectedImage;
    cell.imageView.alpha = 1.0;
    
    CGSize itemSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [nameArray objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont fontWithName:@"Avenir-Heavy" size:20.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return 70;
}
- (NSString *)tableView:(UITableView *)tableViews titleForHeaderInSection:(NSInteger)section
{
    return @"Teachers";
}

- (void)tableView:(UITableView *)tableViews didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDel = (AppDelegate*) [UIApplication sharedApplication].delegate;
    if(![appDel.teacherDownloading isEqualToString:[nameArray objectAtIndex:indexPath.row]]){
        [self performSegueWithIdentifier:@"selection" sender:self];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Downloading"
                                                        message:@"Please try again after download is finished"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [tableViews deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:(@"selection")]){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        SelectionViewController *selection = [[SelectionViewController alloc]init];
        NSIndexPath *path = [_tableView indexPathForSelectedRow];
        int section = path.section;
        selection = [segue destinationViewController];
        selection.teacherName = [nameArray objectAtIndex:path.row];
    }
}



@end
