//
//  ViewController.h
//  MultiSubmitter
//
//  Created by Toshihiko Kimura on 2013/02/17.
//
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (IBAction)touchTakePhotoButton:(id)sender;
- (IBAction)touchSelectPhotoButton:(id)sender;
- (IBAction)touchInputViewCancelButton:(id)sender;
- (IBAction)touchInputViewOKButton:(id)sender;



@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITextView *inputText;
@property (weak, nonatomic) IBOutlet UILabel *twitterStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookStatusLabel;

@end
