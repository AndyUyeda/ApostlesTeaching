//
//  SelectionViewController.m
//  Apostles' Teaching
//
//  Created by Andy Uyeda on 5/16/18.
//  Copyright © 2018 Andy Uyeda. All rights reserved.
//

#import "SelectionViewController.h"
#import "PlayViewController.h"

@interface SelectionViewController ()

@end

@implementation SelectionViewController

@synthesize teacherName, menuButton;

#define TEACHER_KEY @"Teachers"
#define TITLE_KEY_(teacher) [NSString stringWithFormat:@"Titles_%@",teacher]
#define URL_KEY_(teacher, title) [NSString stringWithFormat:@"URL%@%@",teacher,title]
#define IMAGE_(teacher) [NSString stringWithFormat:@"Image_%@",teacher]

NSMutableArray *downloadedTitleArray;

- (void)viewWillAppear:(BOOL)animated {
    [self.view setUserInteractionEnabled:YES];
    [self.navigationController setNavigationBarHidden:FALSE];
    self.navigationItem.title = teacherName;
    self.navigationItem.rightBarButtonItem = menuButton;
    menuButton.target = self;
    menuButton.action = @selector(selectPhoto);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    downloadedTitleArray = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:TITLE_KEY_(teacherName)]];
    
    NSLog(@"%@", TITLE_KEY_(teacherName));
    NSLog(@"%@", downloadedTitleArray);
}

-(void) selectPhoto {
    UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
    pickerLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerLibrary.delegate = self;
    pickerLibrary.allowsEditing = true;
    [self presentModalViewController:pickerLibrary animated:YES];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:UIImagePNGRepresentation(image) forKey:IMAGE_(teacherName)];
    [prefs synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [downloadedTitleArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableViews cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    int section = indexPath.section;
    
    UITableViewCell *cell = [tableViews dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [downloadedTitleArray objectAtIndex:indexPath.row];
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:20.0];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [downloadedTitleArray objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont fontWithName:@"Avenir-Heavy" size:20.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return 70;
}
- (NSString *)tableView:(UITableView *)tableViews titleForHeaderInSection:(NSInteger)section
{
    return @"Downloads";
}
- (void)tableView:(UITableView *)tableViews didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"audio" sender:self];
    [tableViews deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)tableView:(UITableView *)tableViews commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    int section = indexPath.section;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSError *error;
    if(section == 0){
        if([[downloadedTitleArray objectAtIndex:indexPath.row] containsString:@"m4a"]){
            [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@%@",@"Documents/",teacherName,[downloadedTitleArray objectAtIndex:indexPath.row],@".m4a"]] error:&error];
            NSLog(@"%@",[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@%@",@"Documents/",teacherName,[downloadedTitleArray objectAtIndex:indexPath.row],@".m4a"]]);
            
            [downloadedTitleArray removeObjectAtIndex:indexPath.row];
            
            [prefs setObject:downloadedTitleArray forKey:TITLE_KEY_(teacherName)];
            [prefs removeObjectForKey:URL_KEY_(teacherName, downloadedTitleArray)];
        }
        else{
            [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@%@",@"Documents/",teacherName,[downloadedTitleArray objectAtIndex:indexPath.row],@".mp3"]] error:&error];
            NSLog(@"%@",[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@%@",@"Documents/",teacherName,[downloadedTitleArray objectAtIndex:indexPath.row],@".mp3"]]);
            
            [downloadedTitleArray removeObjectAtIndex:indexPath.row];
            
            [prefs setObject:downloadedTitleArray forKey:TITLE_KEY_(teacherName)];
            [prefs removeObjectForKey:URL_KEY_(teacherName, downloadedTitleArray)];
        }
    }
    
    if(error){
        NSLog(@"failure");
    }
    
    [tableViews reloadData];
    [prefs synchronize];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:(@"audio")]){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        PlayViewController *play = [[PlayViewController alloc]init];
        NSIndexPath *path = [_tableView indexPathForSelectedRow];
        int section = path.section;
        play = [segue destinationViewController];
        play.teacher = teacherName;
        play.theTitle = [downloadedTitleArray objectAtIndex:path.row];
        play.websiteURL = [prefs objectForKey: URL_KEY_(teacherName, [downloadedTitleArray objectAtIndex:path.row])];
        play.type = @"mp3";
    }
}


@end
