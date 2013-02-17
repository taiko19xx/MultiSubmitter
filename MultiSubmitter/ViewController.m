//
//  ViewController.m
//  MultiSubmitter
//
//  Created by Toshihiko Kimura on 2013/02/17.
//
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, retain) UIImage *globalImage;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark InterfaceBuilder Action

- (IBAction)touchTakePhotoButton:(id)sender {
    [self showPicker:UIImagePickerControllerSourceTypeCamera];
    
}
- (IBAction)touchSelectPhotoButton:(id)sender {
    [self showPicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)touchInputViewCancelButton:(id)sender {
    [self closePostWindow];
}

- (IBAction)touchInputViewOKButton:(id)sender {
    [self submitTweet:self.inputText.text];
    [self submitFacebook:self.inputText.text];
    [self closePostWindow];
}

-(void)closePostWindow {
    [_inputText resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        [_coverView setAlpha:0.0];
        [_inputView setAlpha:0.0];
    }];
}

#pragma mark -
#pragma mark Submit logic

-(void)submitTweet:(NSString *)status {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler = ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if(responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if(statusCode >= 200 && statusCode < 300) {
                NSLog(@"Succeed!");
                [self updateTwitterStatusLabel:@"OK!"];
            } else {
                NSLog(@"Failed... StatusCode:%d %@",statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
                [self updateTwitterStatusLabel:@"Failed..."];
            }
        } else {
             NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
            [self updateTwitterStatusLabel:@"Failed..."];
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler = ^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:twitterType];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
            NSDictionary *params = @{@"status": status};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:params];
            NSData *imageData = UIImageJPEGRepresentation(_globalImage, 1.0f);
            [request addMultipartData:imageData withName:@"media[]" type:@"image/jpeg" filename:@"image.jpg"];
            [request setAccount:[accounts lastObject]];
            [request performRequestWithHandler:requestHandler];
        } else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@", [error localizedDescription]);
            [self updateTwitterStatusLabel:@"Failed..."];
        }
    };
    
    
    [accountStore requestAccessToAccountsWithType:twitterType options:nil completion:accountStoreHandler];
    [self updateTwitterStatusLabel:@"Sending..."];
}

-(void)submitFacebook:(NSString *)status {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ ACFacebookAppIdKey: @"xxxxxxxxxxxxxx", ACFacebookPermissionsKey: @[@"publish_stream"], ACFacebookAudienceKey: ACFacebookAudienceFriends };
    
    SLRequestHandler requestHandler = ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if(responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if(statusCode >= 200 && statusCode < 300) {
                NSLog(@"Succeed!");
                [self updateFacebookStatusLabel:@"OK!"];
            } else {
                NSLog(@"Failed... StatusCode:%d %@",statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
                [self updateFacebookStatusLabel:@"Failed..."];
            }
        } else {
             NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
            [self updateFacebookStatusLabel:@"Failed..."];
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler = ^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:facebookType];
            NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
            NSDictionary *params = @{@"message": status};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:url parameters:params];
            NSData *imageData = UIImageJPEGRepresentation(_globalImage, 1.0f);
            [request addMultipartData:imageData withName:@"source" type:@"multipart/form-data" filename:@"image.jpg"];
            [request setAccount:[accounts lastObject]];
            [request performRequestWithHandler:requestHandler];
        } else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",[error localizedDescription]);
            [self updateFacebookStatusLabel:@"Failed..."];
        }
    };

    [accountStore requestAccessToAccountsWithType:facebookType options:options completion:accountStoreHandler];
    [self updateFacebookStatusLabel:@"Sending..."];
}

#pragma mark -
#pragma mark Label update

-(void)updateTwitterStatusLabel:(NSString *)text {
    [_twitterStatusLabel setText:text];
}

-(void)updateFacebookStatusLabel:(NSString *)text {
    [_facebookStatusLabel setText:text];
}

#pragma mark -
#pragma mark UIImagePickerController

-(void)showPicker:(UIImagePickerControllerSourceType)source {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setSourceType:source];
    [picker setAllowsEditing:NO];
    [picker setDelegate:self];
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [UIView animateWithDuration:0.3 animations:^{
            [_coverView setAlpha:0.6];
            [_inputView setAlpha:1.0];
        }];
    
    self.globalImage = image;
}
@end
