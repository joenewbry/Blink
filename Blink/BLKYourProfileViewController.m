//
//  BLKYourProfileViewController.m
//  Blink
//
//  Created by Chad Newbry on 2/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKYourProfileViewController.h"

enum BLKProfileState {
    BLKProfileStateEditingWithKeyboard,
    BLKProfileStateEditingWithoutKeyboard,
    BLKProfileStateViewing
};
typedef enum BLKProfileState BLKProfileState;


@interface BLKYourProfileViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeStateButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContainer;

@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelInformation;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *collegeLabel;
@property (weak, nonatomic) IBOutlet UILabel *relationshipLabel;


@property (nonatomic) UITextField * activeTextField;
@property (nonatomic, strong) UITextField * textFieldName;
@property (nonatomic, strong) UITextField * textFieldInformation;


@property (nonatomic) BLKProfileState currentState;

@end




@implementation BLKYourProfileViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //initilization
    [self setStateViewing];

    self.scrollViewContainer.delegate = self; // could possibly take out
    
    //handle the keyboard notification
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //required to make scroll view function properly
    [self.scrollViewContainer setContentSize:CGSizeMake(320, 1000)];
    self.scrollViewContainer.scrollEnabled = NO; // user can't scroll it
}



#pragma mark-- StateChange
- (IBAction)changeImageButton:(UIButton *)sender {
    
    //call a UIImagePickerController
    
     if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypePhotoLibrary)]) {
     
     UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
     
     [imgPicker setDelegate:self];
     [self presentViewController:imgPicker animated:true completion:NULL];
     }
}



- (IBAction)changeStateButton:(id)sender {
    
    if (self.currentState == BLKProfileStateViewing) {
        [self setStateEditingWithoutKeyboard];
    } else if (self.currentState == BLKProfileStateEditingWithKeyboard ||
               self.currentState == BLKProfileStateEditingWithoutKeyboard) {
        [self setStateViewing];
    }
}

- (void)setupTextFields {
    
    //set up TextFields to Edit
    if (!_textFieldName) {
        
        _textFieldName = [[UITextField alloc] init];
        [self.textFieldName setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Name Here"]];
        [self.textFieldName setFrame:self.profileDetailHeaderLabel.frame];
        [self.textFieldName setTextAlignment:NSTextAlignmentCenter];
        [self.textFieldName setBackgroundColor:[[UIColor alloc] initWithRed:(11.0/255.0) green:224.0/255.0 blue:240.0/255.0 alpha:1]];
        [self.textFieldName setTag:1];
        [self.textFieldName setDelegate:self];
        [self.scrollViewContainer addSubview:self.textFieldName];
        [self.textFieldName setAttributedText:[[NSAttributedString alloc] initWithString:self.profileDetailHeaderLabel.text]];

    } else {
        
        //make sure text is current
        self.textFieldName.hidden = false;
        //[self.textFieldName setAttributedText:[[NSAttributedString alloc] initWithString:self.profileDetailHeaderLabel.text]];
    }
    
    
    if (!_textFieldInformation) {
        _textFieldInformation = [[UITextField alloc] init];
        [self.textFieldInformation setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Other Information Here"]];
        [self.textFieldInformation setFrame:self.profileDetailInformationLabel.frame];
        [self.textFieldInformation setTextAlignment:NSTextAlignmentCenter];
        [self.textFieldInformation setTag:2];
        [self.textFieldInformation setDelegate:self];
        [self.scrollViewContainer addSubview:self.textFieldInformation];
        [self.textFieldInformation setAttributedText:[[NSAttributedString alloc] initWithString:self.profileDetailInformationLabel.text]];
        
    } else {
        self.textFieldInformation.hidden = false;
        //[self.textFieldInformation setAttributedText:[[NSAttributedString alloc] initWithString:self.profileDetailInformationLabel.text]];
    }
    
    //make other labels invisibile
    self.labelInformation.hidden = true;
    self.labelName.hidden = true;
}

- (void)hideTextFields {
    self.textFieldName.hidden = YES;
    self.textFieldInformation.hidden = YES;
    
    self.labelInformation.hidden = NO;
    self.labelName.hidden = NO;
}

-(void)setStateViewing {
    [self hideTextFields]; //hides editable texts fields
    self.changeImageButton.hidden = YES;
    [self.changeStateButton setTitle:@"Edit"];
    [self.activeTextField resignFirstResponder]; // ends current editing session and dismisses keyboard
    [self.scrollViewContainer setContentOffset:CGPointZero animated:YES]; // scroll to top
    self.currentState = BLKProfileStateViewing;
    
}

- (void)setStateEditingWithKeyboard {
    
    [self.changeStateButton setTitle:@"Done"];
    [self setupTextFields];
    self.changeImageButton.hidden = NO;
    self.currentState = BLKProfileStateEditingWithKeyboard;
    
    
    [self.scrollViewContainer scrollRectToVisible:CGRectMake(0.0, 1000, 320, 22) animated:YES];

}

- (void)setStateEditingWithoutKeyboard {
    [self.changeStateButton setTitle:@"Done"];
    [self setupTextFields];
    self.changeImageButton.hidden = NO;
   
    [self.activeTextField resignFirstResponder]; // ends current editing session and dismisses keyboard
    [self.scrollViewContainer setContentOffset:CGPointZero animated:YES]; // move the scroll view back to 0,0
    self.currentState = BLKProfileStateEditingWithoutKeyboard;
}

#pragma mark-- KeyboardNotifications

-(void)onKeyboardWillShowNotification:(NSNotification *)keyboardNotification {

    // example drawn from
    // https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
    
    NSDictionary *info=[keyboardNotification userInfo];
    CGSize keyboardSize =[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [self.scrollViewContainer setContentInset:UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)];
    self.scrollViewContainer.scrollIndicatorInsets = self.scrollViewContainer.contentInset; // not sure what this does
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin)) {
        [self setStateEditingWithKeyboard];
    }
    
}



#pragma mark--TextFieldDelegateMethods
// sets the active text field when editing starts
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.activeTextField.tag == 1) {
        self.labelName.text = self.activeTextField.text;
    } else if (self.activeTextField.tag == 2) {
        self.labelInformation.text = self.activeTextField.text;
    }
    
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

//overides return "enter" on keyboard to hide keybaord
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self setStateEditingWithoutKeyboard];
    return YES;
}

#pragma mark - Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark -- UIImagePickerControllerDelegate Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self.profileImage setImage:info[UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
