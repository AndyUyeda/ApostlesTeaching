//
//  PlayViewController.m
//  Apostles' Teaching
//
//  Created by Andy Uyeda on 5/18/18.
//  Copyright © 2018 Andy Uyeda. All rights reserved.
//https://stackoverflow.com/questions/18800742/is-mpnowplayinginfocenter-compatible-with-avaudioplayer

#import "PlayViewController.h"
#import "ToastView.h"
#import <MessageUI/MessageUI.h>

@interface PlayViewController () <MFMessageComposeViewControllerDelegate>

@end

@implementation PlayViewController{
    
}

NSString *mp3URL;
float totalSeconds;
float currentSeconds;
NSString* seconds;
NSString* rseconds;
NSString* hourMinute;
NSString* rhourMinute;
BOOL isPaused;
NSMutableArray *titles;
NSMutableArray *teacherNames,*croppedTitles,*croppedTeachers;
NSTimer* timer;
BOOL favorited;
int seekAction = 0;
int startSeconds, endSeconds;
NSString *croppedTitle;
BOOL note;
int cropSuccess = 0;


@synthesize websiteURL,theTitle,teacher,type,currentSermonLabel,currentTimeLabel,timeRemainingLabel,pauseButton,minuteLabel,minuteText,secondLabel,secondText,hourLabel,hourText,undoButton,goButton,favoriteStarButton,startTimeButton,cropButton,shareButton,clipboardButton;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initPlayer
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    
    NSError *err;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:true error:nil];
    
    audioSession.delegate = self;
    
    [audioSession setActive:YES error:&err];
    
    NSURL *path;
    if([type isEqualToString:@"mp3"]){
        if([theTitle containsString:@"m4a"]){
            path = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@%@",@"Documents/",teacher,theTitle,@".m4a"]]];
            
            NSLog(@"%@",[NSString stringWithFormat:@"%@%@%@%@",@"Documents/",teacher,theTitle,@".m4a"]);
        }
        else{
            path = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@%@",@"Documents/",teacher,theTitle,@".mp3"]]];
            
            NSLog(@"%@",[NSString stringWithFormat:@"%@%@%@%@",@"Documents/",teacher,theTitle,@".mp3"]);
        }
    }
    else{
        [cropButton setHidden:TRUE];
        [clipboardButton setHidden:TRUE];
        [favoriteStarButton setHidden:TRUE];
        [shareButton setHidden:FALSE];
        
        path = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@",@"Documents/",theTitle,@".m4a"]]];
        
        NSLog(@"%@",[NSString stringWithFormat:@"%@%@%@",@"Documents/",theTitle,@".m4a"]);
    }
    
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:path error:nil];
    
    AVURLAsset *asst = [AVURLAsset URLAssetWithURL: path options:nil];
    
    //[self exportAsset:asst toFilePath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@",@"Documents/",theTitle,@"trim.m4a"]]];
}
-(void)viewWillAppear:(BOOL)animated{
    note = false;
    NSLog(@"%@", NSHomeDirectory());
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    mp3URL = websiteURL;
    note = false;
    // Do any additional setup after loading the view, typically from a nib.
    UIImage *img = [UIImage imageNamed:@"slider.png"];
    
    [_slider setThumbImage:img forState:UIControlStateNormal];
    
    if([theTitle containsString:@"m4a"]){
        currentSermonLabel.text = [theTitle substringFromIndex:3];
    }
    else{
        currentSermonLabel.text = theTitle;
    }
    currentSermonLabel.numberOfLines = 0;
    currentSermonLabel.textAlignment = NSTextAlignmentCenter;
    [currentSermonLabel sizeToFit];
    currentSermonLabel.center = CGPointMake([self view].center.x, 134);
    
    [self initPlayer];
    [player play];
    
    NSTimeInterval duration = player.duration;
    totalSeconds = duration;
    
    NSTimeInterval currentTime = player.currentTime;
    currentSeconds = currentTime;
    NSLog(@"duration: %.2f", totalSeconds);
    
    isPaused = false;
    
    timer = [NSTimer timerWithTimeInterval:0.2
                                    target:self
                                  selector:@selector(update:)
                                  userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self see];
}
-(void) see{
    NSString* fff = [NSString stringWithFormat:@"%@%@%@",teacher,theTitle,@"favorite"];
    NSString* ttt = [NSString stringWithFormat:@"%@%@%@",teacher,theTitle,@"time"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    favorited = [prefs boolForKey:fff];
    float fl = [prefs floatForKey:ttt];
    //NSLog(@"%f",fl);
    int16_t intt = 600;
    [player setCurrentTime:fl];
    
    
    UIImage *img;
    if(favorited){
        img = [UIImage imageNamed:@"star.png"];
    }
    else{
        img = [UIImage imageNamed:@"starGray.png"];
    }
    [favoriteStarButton setImage:img forState:UIControlStateNormal];
    
}

- (void)update: (NSTimer*) timer {
    //NSLog(@"%d",cropSuccess);
    if(cropSuccess == 1){
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        NSMutableArray *noteTitles = [[prefs objectForKey:@"noteTitles"] mutableCopy];
//        NSMutableArray *notesArray = [[prefs objectForKey:@"notesArray"] mutableCopy];
//
//        if(noteTitles == nil){
//            NSLog(@"nillllll");
//
//            notesArray = [NSMutableArray array];
//            noteTitles = [NSMutableArray array];
//        }
//        NSString *last = [[teacher componentsSeparatedByString:@" "] objectAtIndex:1];
//        NSString *tt = [NSString stringWithFormat:@"%@%@%@", last, @" - ", croppedTitle];
//
//        [noteTitles insertObject:tt atIndex:0];
//        [notesArray insertObject:[NSString stringWithFormat:@"%@ - %@", teacher,theTitle] atIndex:0];
//
//        [prefs setObject:noteTitles forKey:@"noteTitles"];
//        [prefs setObject:notesArray forKey:@"notesArray"];
//        [prefs synchronize];
        
        
        
        [ToastView showToastInParentView:self.view withText:@"Trim Successful" withDuaration:4.0];
        cropSuccess = 0;
    }
    else if(cropSuccess == 2){
        [ToastView showToastInParentView:self.view withText:@"Trim Failed" withDuaration:4.0];
        cropSuccess = 0;
    }
    NSTimeInterval currentTime = player.currentTime;
    currentSeconds = currentTime;
    
    float percent = currentSeconds / totalSeconds;
    [_slider setValue:percent];
    
    float remainingSeconds = totalSeconds - currentSeconds;
    if(totalSeconds < 3600){
        int currentMinute = currentSeconds / 60;
        int currentSec = (int)currentSeconds % 60;
        
        if(currentSec < 10){
            seconds = [NSString stringWithFormat:@"%@%d",@"0",currentSec];
        }
        else{
            seconds = [NSString stringWithFormat:@"%d", currentSec];
        }
        currentTimeLabel.text = [NSString stringWithFormat:@"%d%@%@", currentMinute,@":",seconds];
        
        int remainingMinute = remainingSeconds / 60;
        int remainingSec = (int)remainingSeconds % 60;
        
        if(remainingSec < 10){
            rseconds = [NSString stringWithFormat:@"%@%d",@"0",remainingSec];
        }
        else{
            rseconds = [NSString stringWithFormat:@"%d", remainingSec];
        }
        timeRemainingLabel.text = [NSString stringWithFormat:@"%d%@%@", remainingMinute,@":",rseconds];
    }
    else{
        int currentHour = currentSeconds / 3600;
        int currentMinute = (currentSeconds - (currentHour * 3600))/ 60;
        int currentSec = (int)(currentSeconds - (currentHour * 3600)) % 60;
        
        if(currentSec < 10){
            seconds = [NSString stringWithFormat:@"%@%d",@"0",currentSec];
        }
        else{
            seconds = [NSString stringWithFormat:@"%d", currentSec];
        }
        if(currentMinute < 10){
            hourMinute = [NSString stringWithFormat:@"%@%d",@"0",currentMinute];
        }
        else{
            hourMinute = [NSString stringWithFormat:@"%d",currentMinute];
        }
        currentTimeLabel.text = [NSString stringWithFormat:@"%d%@%@%@%@",currentHour,@":", hourMinute,@":",seconds];
        
        int remainingHour = remainingSeconds / 3600;
        int remainingMinute = (remainingSeconds - (remainingHour * 3600))/ 60;
        int remainingSec = (int)(remainingSeconds - (remainingHour * 3600)) % 60;
        
        if(remainingSec < 10){
            rseconds = [NSString stringWithFormat:@"%@%d",@"0",remainingSec];
        }
        else{
            rseconds = [NSString stringWithFormat:@"%d", remainingSec];
        }
        if(remainingMinute < 10){
            rhourMinute = [NSString stringWithFormat:@"%@%d",@"0", remainingMinute];
        }
        else{
            rhourMinute = [NSString stringWithFormat:@"%d",remainingMinute];
        }
        timeRemainingLabel.text = [NSString stringWithFormat:@"%d%@%@%@%@",remainingHour,@":", rhourMinute,@":",rseconds];
        
        //NSLog(@"%@",[NSString stringWithFormat:@"%d%@%d%@%@",remainingHour,@":", remainingMinute,@":",rseconds]);
        //NSLog(@"%f",totalSeconds);
        
    }
    
    //NSLog(@"%f", currentSeconds);
    NSString* ttt = [NSString stringWithFormat:@"%@%@%@",teacher,theTitle,@"time"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setFloat:currentSeconds - 2 forKey:ttt];
    [prefs synchronize];
    
    
}

- (IBAction)sliderChanged:(id)sender {
    Float64 sec = (_slider.value) * totalSeconds;
    //int16_t intt = 600;
    //CMTime theTime = CMTimeMakeWithSeconds(sec, intt);
    [player setCurrentTime:sec];
    
}

- (IBAction)paused:(id)sender {
    if(!isPaused){
        isPaused = true;
        [player pause];
        UIImage *img = [UIImage imageNamed:@"play-disabled-1.png"];
        [pauseButton setImage:img forState:UIControlStateNormal];
        
    }
    else{
        UIImage *img = [UIImage imageNamed:@"pause-disabled.png"];
        [pauseButton setImage:img forState:UIControlStateNormal];
        isPaused = false;
        [player play];
    }
}
- (IBAction)crop:(id)sender {
    hourText.text = @"";
    minuteText.text = @"";
    secondText.text = @"";
    
    
    [undoButton setHidden:FALSE];
    [startTimeButton setHidden:TRUE];
    seekAction = 1;
    [goButton setTitle:@"Start" forState:UIControlStateNormal];
    [goButton setHidden:FALSE];
    [secondText setHidden:FALSE];
    [secondLabel setHidden:FALSE];
    [minuteText setHidden:FALSE];
    [minuteLabel setHidden:FALSE];
    [hourText setHidden:FALSE];
    [hourLabel setHidden:FALSE];
    [hourText becomeFirstResponder];
    
}

- (IBAction)backToStart:(id)sender {
    hourText.text = @"";
    minuteText.text = @"";
    secondText.text = @"";
    
    
    [undoButton setHidden:FALSE];
    [startTimeButton setHidden:TRUE];
    seekAction = 1;
    [goButton setTitle:@"Start" forState:UIControlStateNormal];
    [goButton setHidden:FALSE];
    [secondText setHidden:FALSE];
    [secondLabel setHidden:FALSE];
    [minuteText setHidden:FALSE];
    [minuteLabel setHidden:FALSE];
    [hourText setHidden:FALSE];
    [hourLabel setHidden:FALSE];
    [hourText becomeFirstResponder];
}

- (IBAction)shareClip:(id)sender {
    
    [self showSMS:@"HEY"];
}

- (IBAction)copied:(id)sender {
    UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
    generalPasteboard.string = mp3URL;
    [ToastView showToastInParentView:self.view withText:@"Link was copied" withDuaration:4.0];
}

- (IBAction)editCroppedTitle:(id)sender {
    if(![type isEqualToString:@"mp3"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename Clip"
                                                        message:[NSString stringWithFormat:@"Enter Title for Clip:"]
                                                       delegate:self cancelButtonTitle:@"Rename"
                                              otherButtonTitles:nil];
        
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
    }
}
- (void)showSMS:(NSString*)file {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    //NSArray *recipents = @[@"12345678", @"72345524"];
    //NSString *message = [NSString stringWithFormat:@"Just sent the %@ file to your email. Please check!", file];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    //[messageController setRecipients:recipents];
    //[messageController setBody:message];
    NSURL *path = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@",@"Documents/",theTitle,@".m4a"]]];
    NSData * data = [NSData dataWithContentsOfURL:path];
    [messageController addAttachmentData:data typeIdentifier:@"public.data" filename:[NSString stringWithFormat: @"%@ (%@).m4a",theTitle,teacher]];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)seekPosition:(id)sender {
    
    hourText.text = @"";
    minuteText.text = @"";
    secondText.text = @"";
    
    
    [undoButton setHidden:FALSE];
    seekAction = 0;
    [goButton setTitle:@"Seek" forState:UIControlStateNormal];
    [startTimeButton setHidden:TRUE];
    [goButton setHidden:FALSE];
    [secondText setHidden:FALSE];
    [secondLabel setHidden:FALSE];
    [minuteText setHidden:FALSE];
    [minuteLabel setHidden:FALSE];
    [hourText setHidden:FALSE];
    [hourLabel setHidden:FALSE];
    [hourText becomeFirstResponder];
    
}

- (IBAction)undid:(id)sender {
    [hourText resignFirstResponder];
    [minuteText resignFirstResponder];
    [secondText resignFirstResponder];
    
    [startTimeButton setHidden:TRUE];
    [undoButton setHidden:TRUE];
    [goButton setHidden:TRUE];
    [secondText setHidden:TRUE];
    [secondLabel setHidden:TRUE];
    [minuteText setHidden:TRUE];
    [minuteLabel setHidden:TRUE];
    [hourText setHidden:TRUE];
    [hourLabel setHidden:TRUE];
}

- (IBAction)sought:(id)sender {
    if(seekAction == 0){
        [hourText resignFirstResponder];
        [minuteText resignFirstResponder];
        [secondText resignFirstResponder];
        
        [undoButton setHidden:TRUE];
        [goButton setHidden:TRUE];
        [secondText setHidden:TRUE];
        [secondLabel setHidden:TRUE];
        [minuteText setHidden:TRUE];
        [minuteLabel setHidden:TRUE];
        [startTimeButton setHidden:TRUE];
        [hourText setHidden:TRUE];
        [hourLabel setHidden:TRUE];
        
        NSString *ht = hourText.text;
        NSString *mt = minuteText.text;
        NSString *st = secondText.text;
        int hour;
        int minute;
        int second;
        
        if(ht.length < 1){
            hour = 0;
        }
        else{
            hour = [ht intValue];
        }
        if(mt.length < 1){
            minute = 0;
        }
        else{
            minute = [mt intValue];
        }
        if(st.length < 1){
            second = 0;
        }
        else{
            second = [st intValue];
        }
        //NSLog(@"%d%d",hour,minute);
        Float64 totSec = (hour*3600) + (minute * 60) + second;
        
        if(totSec > totalSeconds){
            totSec = totalSeconds;
        }
        if(totSec <= 0){
            totSec = 0;
        }
        
        [player setCurrentTime:totSec];
    }
    else if(seekAction == 1){
        
        NSString *ht = hourText.text;
        NSString *mt = minuteText.text;
        NSString *st = secondText.text;
        if(ht.length == 0){
            ht = @"00";
        }
        else if(ht.length == 1){
            ht = [@"0" stringByAppendingString:ht];
        }
        else if(ht.length > 2){
            ht = [ht substringToIndex:2];
        }
        
        if(mt.length == 0){
            mt = @"00";
        }
        else if(mt.length == 1){
            mt = [@"0" stringByAppendingString:mt];
        }
        else if(mt.length > 2){
            mt = [mt substringToIndex:2];
        }
        
        if(st.length == 0){
            st = @"00";
        }
        else if(st.length == 1){
            st = [@"0" stringByAppendingString:st];
        }
        else if(st.length > 2){
            st = [st substringToIndex:2];
        }
        NSString *ss = [NSString stringWithFormat:@"%@%@%@%@%@",ht,@":",mt,@":",st];
        int hour;
        int minute;
        int second;
        
        if(ht.length < 1){
            hour = 0;
        }
        else{
            hour = [ht intValue];
        }
        if(mt.length < 1){
            minute = 0;
        }
        else{
            minute = [mt intValue];
        }
        if(st.length < 1){
            second = 0;
        }
        else{
            second = [st intValue];
        }
        //NSLog(@"%d%d",hour,minute);
        Float64 totSec = (hour*3600) + (minute * 60) + second;
        
        if(totSec > totalSeconds){
            totSec = totalSeconds - 1;
        }
        if(totSec <= 0){
            totSec = 0;
        }
        
        startSeconds = totSec;
        
        hourText.text = @"";
        minuteText.text = @"";
        secondText.text = @"";
        
        
        [undoButton setHidden:FALSE];
        seekAction = 2;
        [goButton setTitle:@"End" forState:UIControlStateNormal];
        [startTimeButton setHidden:FALSE];
        [startTimeButton setTitle:ss forState:UIControlStateNormal];
        [goButton setHidden:FALSE];
        [secondText setHidden:FALSE];
        [secondLabel setHidden:FALSE];
        [minuteText setHidden:FALSE];
        [minuteLabel setHidden:FALSE];
        [hourText setHidden:FALSE];
        [hourLabel setHidden:FALSE];
        [hourText becomeFirstResponder];
    }
    else if(seekAction == 2){
        NSString *ht = hourText.text;
        NSString *mt = minuteText.text;
        NSString *st = secondText.text;
        int hour;
        int minute;
        int second;
        
        if(ht.length < 1){
            hour = 0;
        }
        else{
            hour = [ht intValue];
        }
        if(mt.length < 1){
            minute = 0;
        }
        else{
            minute = [mt intValue];
        }
        if(st.length < 1){
            second = 0;
        }
        else{
            second = [st intValue];
        }
        //NSLog(@"%d%d",hour,minute);
        Float64 totSec = (hour*3600) + (minute * 60) + second;
        
        if(totSec > totalSeconds){
            totSec = totalSeconds;
        }
        if(totSec <= startSeconds){
            totSec = startSeconds + 1;
        }
        
        endSeconds = totSec;
        
        hourText.text = @"";
        minuteText.text = @"";
        secondText.text = @"";
        
        [hourText resignFirstResponder];
        [minuteText resignFirstResponder];
        [secondText resignFirstResponder];
        
        [undoButton setHidden:TRUE];
        [goButton setHidden:TRUE];
        [startTimeButton setHidden:TRUE];
        [secondText setHidden:TRUE];
        [secondLabel setHidden:TRUE];
        [minuteText setHidden:TRUE];
        [minuteLabel setHidden:TRUE];
        [hourText setHidden:TRUE];
        [hourLabel setHidden:TRUE];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Clip"
                                                        message:[NSString stringWithFormat:@"Enter Title for Clip:"]
                                                       delegate:self cancelButtonTitle:@"Trim"
                                              otherButtonTitles:nil];
        
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
    }
    
    
}
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([type isEqualToString:@"mp3"]){
        if([[[alert textFieldAtIndex:0] text] length] > 0){
            NSLog(@"Title: %@", [[alert textFieldAtIndex:0] text]);
            croppedTitle =[[alert textFieldAtIndex:0] text];
            NSURL *path;
            if([theTitle containsString:@"m4a"]){
                path = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@",@"Documents/",theTitle,@".m4a"]]];
            }else{
                path = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@",@"Documents/",theTitle,@".mp3"]]];
            }
            AVAsset *asset = [AVAsset assetWithURL:path];
            
            [self exportAsset:asset toFilePath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@",@"Documents/",croppedTitle,@".m4a"]]];
            //[[NSUserDefaults standardUserDefaults] setObject:[[alert textFieldAtIndex:0] text] forKey:@"USERNAME"];
        }
    }
    else{
        if([[[alert textFieldAtIndex:0] text] length] > 0){
            [self changeCroppedTitleFrom:theTitle to:[[alert textFieldAtIndex:0]text]];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSMutableArray *ct = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:@"croppedTitles"]];
            NSLog(@"%@", ct);
            [ct insertObject:[[alert textFieldAtIndex:0]text] atIndex:[ct indexOfObject:theTitle]];
            [ct removeObject:theTitle];
            
            [prefs setObject:ct forKey:@"croppedTitles"];
            [prefs synchronize];
            
            
            [currentSermonLabel setText:[[alert textFieldAtIndex:0]text]];
            currentSermonLabel.numberOfLines = 0;
            currentSermonLabel.textAlignment = NSTextAlignmentCenter;
            [currentSermonLabel sizeToFit];
            currentSermonLabel.center = CGPointMake([self view].center.x, 134);
            NSLog(@"%@", ct);
        }
    }
}

- (IBAction)favorited:(id)sender {
    NSString* fff = [NSString stringWithFormat:@"%@%@%@",teacher,theTitle,@"favorite"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    
    
    UIImage *img;
    if(favorited){
        img = [UIImage imageNamed:@"starGray.png"];
        [prefs setBool:false forKey:fff];
        favorited = FALSE;
        
        
        NSMutableArray *favoriteTitleArray = [[prefs objectForKey:@"favoriteTitles"] mutableCopy];
        NSMutableArray *favoriteURLArray = [[prefs objectForKey:@"favoriteSites"] mutableCopy];
        NSMutableArray *favoriteTeachersArray = [[prefs objectForKey:@"favoriteTeachers"] mutableCopy];
        
        if(favoriteTitleArray == nil){
            NSLog(@"nillllll");
            
            favoriteTitleArray = [NSMutableArray array];
            favoriteTeachersArray = [NSMutableArray array];
            favoriteURLArray = [NSMutableArray array];
        }
        int index = [favoriteTitleArray indexOfObject:theTitle];
        [favoriteTitleArray removeObject:theTitle];
        [favoriteURLArray removeObject:websiteURL];
        [favoriteTeachersArray removeObjectAtIndex:index];
        
        NSLog(@"%@",favoriteTitleArray);
        
        
        
        
        [prefs setObject:favoriteTitleArray forKey:@"favoriteTitles"];
        [prefs setObject:favoriteURLArray forKey:@"favoriteSites"];
        [prefs setObject:favoriteTeachersArray forKey:@"favoriteTeachers"];
    }
    else{
        img = [UIImage imageNamed:@"star.png"];
        [prefs setBool:true forKey:fff];
        favorited = TRUE;
        
        
        
        
        NSMutableArray *favoriteTitleArray = [[prefs objectForKey:@"favoriteTitles"] mutableCopy];
        NSMutableArray *favoriteURLArray = [[prefs objectForKey:@"favoriteSites"] mutableCopy];
        NSMutableArray *favoriteTeachersArray = [[prefs objectForKey:@"favoriteTeachers"] mutableCopy];
        
        if(favoriteTitleArray == nil){
            NSLog(@"nillllll");
            
            favoriteTitleArray = [NSMutableArray array];
            favoriteTeachersArray = [NSMutableArray array];
            favoriteURLArray = [NSMutableArray array];
        }
        
        [favoriteTitleArray insertObject:theTitle atIndex:0];
        [favoriteURLArray insertObject:websiteURL atIndex:0];
        [favoriteTeachersArray insertObject:teacher atIndex:0];
        
        NSLog(@"%@",favoriteTitleArray);
        
        
        
        
        [prefs setObject:favoriteTitleArray forKey:@"favoriteTitles"];
        [prefs setObject:favoriteURLArray forKey:@"favoriteSites"];
        [prefs setObject:favoriteTeachersArray forKey:@"favoriteTeachers"];
        
        
        
        
    }
    [favoriteStarButton setImage:img forState:UIControlStateNormal];
    
    [prefs synchronize];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(!note){
        [player pause];
        [timer invalidate];
    }
}


- (BOOL)exportAsset:(AVAsset *)avAsset toFilePath:(NSString *)filePath {
    NSLog(@"HEY");
    // we need the audio asset to be at least 50 seconds long for this snippet
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    //NSLog(@"%f",duration);
    if (duration < 3.0){
        cropSuccess = 2;
        NSLog(@"A");
        return NO;
    }
    
    // get the first audio track
    NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    //NSLog(@"%d", [tracks count]);
    if ([tracks count] == 0){
        cropSuccess = 2;
        NSLog(@"B");
        return NO;
    }
    
    AVAssetTrack *track = [tracks objectAtIndex:0];
    
    // create the export session
    // no need for a retain here, the session will be retained by the
    // completion handler since it is referenced there
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:avAsset
                                           presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession){
        cropSuccess = 2;
        NSLog(@"C");
        return NO;
    }
    
    // create trim time range - 20 seconds starting from 30 seconds into the asset
    NSLog(@"%d", startSeconds);
    NSLog(@"%d", endSeconds);
    CMTime startTimes = CMTimeMake(startSeconds, 1);
    CMTime stopTimes = CMTimeMake(endSeconds, 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTimes, stopTimes);
    /*
     // create fade in time range - 10 seconds starting at the beginning of trimmed asset
     CMTime startFadeInTime = startTimes;
     CMTime endFadeInTime = CMTimeMake(40, 1);
     CMTimeRange fadeInTimeRange = CMTimeRangeFromTimeToTime(startFadeInTime,
     endFadeInTime);*/
    
    // setup audio mix
    AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *exportAudioMixInputParameters =
    [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    
    //[exportAudioMixInputParameters setVolumeRampFromStartVolume:1.0 toEndVolume:1.0
    //timeRange:fadeInTimeRange];
    exportAudioMix.inputParameters = [NSArray
                                      arrayWithObject:exportAudioMixInputParameters];
    
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPath:filePath]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    exportSession.timeRange = exportTimeRange; // trim time range
    exportSession.audioMix = exportAudioMix; // fade in audio mix
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            croppedTitles = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:@"croppedTitles"]];
            croppedTeachers = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:@"croppedNames"]];
            
            [croppedTitles addObject:croppedTitle];
            [croppedTeachers addObject:teacher];
            
            [prefs setObject:croppedTitles forKey:@"croppedTitles"];
            [prefs setObject:croppedTeachers forKey:@"croppedNames"];
            [prefs synchronize];
            
            //[ToastView showToastInParentView:self.view withText:@"Trim Successful" withDuaration:5.0];
            cropSuccess = 1;
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            //[ToastView showToastInParentView:self.view withText:@"Trim Failed" withDuaration:5.0];
            cropSuccess = 2;
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            
            NSLog(@"Export Session Status: %d", exportSession.status);
        }
    }];
    
    return YES;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

- (void)changeCroppedTitleFrom: (NSString*) oldTitle to:(NSString*)newTitle{
    BOOL result;
    NSString *fullPath, *filename, *newName;
    NSString *dir = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSEnumerator *enumerator = [[fm contentsOfDirectoryAtPath:dir error:nil] objectEnumerator];
    NSLog(@"%@",dir);
    while(filename=[enumerator nextObject]){
        if ([filename isEqualToString:[NSString stringWithFormat:@"%@%@",oldTitle,@".m4a"]]) {
            fullPath = [dir stringByAppendingPathComponent:filename];
            if (!([fm fileExistsAtPath:fullPath isDirectory:&result]&&result)) { // skip directory
                newName = [dir stringByAppendingString:[NSString stringWithFormat:@"%@%@",newTitle,@".m4a"]];
                result = [fm moveItemAtPath:fullPath toPath:newName error:nil];
            }
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
