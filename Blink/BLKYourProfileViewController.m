//
//  BLKYourProfileViewController.m
//  Blink
//
//  Created by Chad Newbry on 2/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKYourProfileViewController.h"
#import "BLKNSUserDefaultsHelper.h"
#import <Parse/Parse.h>

enum BLKProfileState {
    BLKProfileStateViewing,
    BLKProfileStateEditingWithKeyboard,
    BLKProfileStateEditingWithoutKeyboard,
    
};
typedef enum BLKProfileState BLKProfileState;


@interface BLKYourProfileViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContainer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeStateButton;

@property (weak, nonatomic) IBOutlet UIView *blueBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;

@property (nonatomic) UITextField * activeTextField;
@property (nonatomic, strong) UITextField * nameTextField;
@property (nonatomic, strong) UITextField * quoteTextField;
@property (nonatomic, strong) UITextField * collegeTextField;
@property (nonatomic, strong) UITextField * statusTextField;

@property (nonatomic) NSMutableArray * textFieldArray; // probably could just populate this array based on the labels in BasisProfileVC
//This would avoid having the five uitextfields above

@property (nonatomic) BLKProfileState currentState;

@end

@implementation BLKYourProfileViewController


#pragma mark-- SetUp

- (void)setBLKUser:(BLKUser *)user {
    
    self.username = [[BLKNSUserDefaultsHelper getUserPropertyStringForKey:BLK_NAME] mutableCopy];
    self.college = [[BLKNSUserDefaultsHelper getUserPropertyStringForKey:BLK_COLLEGE] mutableCopy];
    self.quote = [[BLKNSUserDefaultsHelper getUserPropertyStringForKey:BLK_QUOTE] mutableCopy];
    self.relationshipStatus = [[BLKNSUserDefaultsHelper getUserPropertyStringForKey:BLK_RELATIONSHIP_STATUS] mutableCopy];
    
    //image is set in basic profile vc
    
    [super setBLKUser:user];
}

#pragma mark-- LazyInstantiation

-(NSMutableArray *)textFieldArray {
    if (!_textFieldArray) _textFieldArray = [[NSMutableArray alloc] init];
    
    return _textFieldArray;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //check to see if any NSUserDefaults aren't set
    
    if (![BLKNSUserDefaultsHelper getUserPropertyStringForKey:BLK_NAME] ||
        ![BLKNSUserDefaultsHelper getUserPropertyStringForKey:BLK_COLLEGE] ||
        ![BLKNSUserDefaultsHelper getUserPropertyStringForKey:BLK_QUOTE] ||
        ![BLKNSUserDefaultsHelper getUserPropertyStringForKey:BLK_RELATIONSHIP_STATUS]) {
        
        //some of the defaults haven't been set so save them
        
        [BLKNSUserDefaultsHelper setUserPropertyStringForKey:self.username key:BLK_NAME];
        [BLKNSUserDefaultsHelper setUserPropertyStringForKey:self.college key:BLK_COLLEGE];
        [BLKNSUserDefaultsHelper setUserPropertyStringForKey:self.quote key:BLK_QUOTE];
        [BLKNSUserDefaultsHelper setUserPropertyStringForKey:self.relationshipStatus key:BLK_RELATIONSHIP_STATUS];
        
        dispatch_queue_t saveImage = dispatch_queue_create("save image", NULL);
        dispatch_async(saveImage, ^{
            [self saveUIImageToCache:self.profileImage];
        });

        
    }

}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //initilization
    [self setStateViewing];

    self.scrollViewContainer.delegate = self; // could possibly take out
    
    //handle the keyboard notification
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    
    /* failed attempt to dismiss keyboard on swipe

    UISwipeGestureRecognizer* swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
        [self.scrollViewContainer setUserInteractionEnabled:YES];
    [self.scrollViewContainer addGestureRecognizer:swipeDownGestureRecognizer];
    [self setLablesToHidden:YES];
     */
}


/*
- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    
    if (self.currentState == BLKProfileStateEditingWithKeyboard) {
        [self setStateEditingWithoutKeyboard];
    }
    
} */

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
    if (!_nameTextField) {
        
        _nameTextField = [[UITextField alloc] init];
        [self setUpTextField:_nameTextField tag:1 defaultString:@"Name Here"];
    } else {
        self.nameTextField.hidden = false;
    }
    
    if (!_quoteTextField) {
        _quoteTextField = [[UITextField alloc] init];
        [self setUpTextField:_quoteTextField tag:2 defaultString:@"What's on your mind?"];
    } else {
        self.quoteTextField.hidden = false;
    }
    
    if (!_collegeTextField) {
        _collegeTextField = [[UITextField alloc] init];
        [self setUpTextField:_collegeTextField tag:3 defaultString:@"College?"];
    } else {
        self.collegeTextField.hidden = false;
    }
    
    if (!_statusTextField) {
        _statusTextField = [[UITextField alloc] init];
        [self setUpTextField:_statusTextField tag:4 defaultString:@"Relationship Status?"];
    } else {
        self.statusTextField.hidden = false;
    }
    
    [self.blueBackgroundView setHidden:NO];
}

- (void)setUpTextField:(UITextField *)textField tag:(int)tag defaultString:(NSString *)defaultString {
    
    UILabel * tempLabel = [self getLabelFromTag:tag];
    
    [textField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:defaultString]];
    [textField setFrame:tempLabel.frame];
    [textField setTextAlignment:tempLabel.textAlignment];
    [textField setBackgroundColor:tempLabel.backgroundColor];
    [textField setTag:tag];
    [textField setDelegate:self];
    [self.scrollViewContainer addSubview:textField];
    [textField setTextColor:[UIColor whiteColor]];
    [textField setClearButtonMode:UITextFieldViewModeAlways];
    [textField setAttributedText:tempLabel.attributedText];
    
    //TODO
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:18.0 ]; //DANGEROUS not a good way to do this
    
    NSMutableString * tempString = [[NSMutableString alloc] initWithString:@""];
    if (!(tempLabel.text == nil)) {
        tempString = (NSMutableString *)tempLabel.text;
    }
    
    textField.attributedText = [[NSAttributedString alloc] initWithString:tempString
                                                                attributes:([NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName])];

    [self.textFieldArray addObject:textField];
}

- (void)hideTextFields {
    [self.textFieldArray setValue:[NSNumber numberWithBool:true] forKey:@"hidden"];
    [self.blueBackgroundView setHidden:YES];
}

-(void)setStateViewing {
    [self hideTextFields]; //hides editable texts fields
    self.changeImageButton.hidden = YES;
    [self.changeStateButton setTitle:@"Edit"];
    [self.activeTextField resignFirstResponder]; // ends current editing session and dismisses keyboard
    [self.scrollViewContainer setContentOffset:CGPointZero animated:YES]; // scroll to top
    [self setNormalViewToHidden:NO];
    
    self.currentState = BLKProfileStateViewing;
}

- (void)setStateEditingWithKeyboard {
    [self.changeStateButton setTitle:@"Done"];
    [self setupTextFields];
    self.changeImageButton.hidden = NO;
    [self.scrollViewContainer scrollRectToVisible:CGRectMake(0.0, 1000, 320, 22) animated:YES];
    [self setNormalViewToHidden:YES];
    
    self.currentState = BLKProfileStateEditingWithKeyboard;


}

- (void)setStateEditingWithoutKeyboard {
    [self.changeStateButton setTitle:@"Done"];
    [self setupTextFields];
    self.changeImageButton.hidden = NO;
    [self.activeTextField resignFirstResponder]; // ends current editing session and dismisses keyboard
    [self.scrollViewContainer setContentOffset:CGPointZero animated:YES]; // move the scroll view back to 0,0
    
    [self setNormalViewToHidden:YES];
    
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
    
    //saves any text field changes to both user defaults and parse
    if (self.activeTextField.tag == 1) {
        self.username = [[NSMutableString alloc] initWithString:self.activeTextField.text];
        [BLKUser currentUser].profileName = self.username;
        [BLKNSUserDefaultsHelper setUserPropertyStringForKey:self.username key:BLK_NAME];
        self.user.username = self.username;
    } else if (self.activeTextField.tag == 2) {
         self.quote = [[NSMutableString alloc] initWithString:self.activeTextField.text];
        [BLKUser currentUser].quote = self.quote;
        [BLKNSUserDefaultsHelper setUserPropertyStringForKey:self.quote key:BLK_QUOTE];
        self.user.quote = self.quote;
    } else if (self.activeTextField.tag == 4) {
        self.relationshipStatus = [[NSMutableString alloc] initWithString:self.activeTextField.text];
        [BLKUser currentUser].relationshipStatus = self.relationshipStatus;
        self.user.relationshipStatus = self.relationshipStatus;
        [BLKNSUserDefaultsHelper setUserPropertyStringForKey:self.relationshipStatus key:BLK_RELATIONSHIP_STATUS];
    } else if (self.activeTextField.tag == 3) {
        self.college = [[NSMutableString alloc] initWithString:self.activeTextField.text];
        [BLKUser currentUser].college = self.college;
        self.user.college = self.college;
        [BLKNSUserDefaultsHelper setUserPropertyStringForKey:self.college key:BLK_COLLEGE];
    }
    
    //TODO all the if statements above: does this reference to the saved BLKUser work for saving the data?
    
    self.activeTextField = nil;
    
    [[BLKUser currentUser] saveInBackground];
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
    
    self.profileImage = info[UIImagePickerControllerOriginalImage];
    
    [self saveUIImageToCache:self.profileImage];
    
    NSData *data = UIImageJPEGRepresentation(self.profileImage, 1.0f);
    
    //save PFFile to parse
    PFFile *file = [PFFile fileWithData:data];
    [BLKUser currentUser].profilePicture = file;
    [[BLKUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
             NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            NSLog(@"Saved image");
        }
    }];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)saveUIImageToCache:(UIImage *)image {
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    
    //save image to the documents folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //gets the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"profile.jpg"];
    [data writeToFile:filePath atomically:YES];
    
    //save image path string to NSUserDefaults
    [BLKNSUserDefaultsHelper setUserPropertyStringForKey:filePath key:BLK_PROFILE_IMAGE];
    
}


@end
