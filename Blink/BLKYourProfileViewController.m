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

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContainer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeStateButton;

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

#pragma mark-- LazyInstantiation

-(NSMutableArray *)textFieldArray {
    if (!_textFieldArray) _textFieldArray = [[NSMutableArray alloc] init];
    
    return _textFieldArray;
}

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
    if (!_nameTextField) {
        
        _nameTextField = [[UITextField alloc] init];
        [self setUpTextField:_nameTextField tag:1 defaultString:@"Name Here"];
    } else {
        
        //make sure text is current
        self.nameTextField.hidden = false;
    }
    
    
    if (!_quoteTextField) {
        _quoteTextField = [[UITextField alloc] init];
        [self setUpTextField:_quoteTextField tag:2 defaultString:@"Other information here"];
    } else {
        self.quoteTextField.hidden = false;
    }
    
    if (!_collegeTextField) {
        _collegeTextField = [[UITextField alloc] init];
        [self setUpTextField:_collegeTextField tag:3 defaultString:@""];
    } else {
        self.collegeTextField.hidden = false;
    }
    
    if (!_statusTextField) {
        _statusTextField = [[UITextField alloc] init];
        [self setUpTextField:_statusTextField tag:4 defaultString:@"Single?"];
    }
    
    
    //make other labels invisibile
    [self setLablesToHidden:true];
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
    [textField setAttributedText:tempLabel.attributedText];

    [self.textFieldArray addObject:textField];
}

- (void)hideTextFields {
    
    [self.textFieldArray setValue:[NSNumber numberWithBool:true] forKey:@"hidden"]; //not sure if this works
    [self setLablesToHidden:false];
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
        self.nameString = [[NSMutableString alloc] initWithString:self.activeTextField.text];
    } else if (self.activeTextField.tag == 2) {
         self.quoteString = [[NSMutableString alloc] initWithString:self.activeTextField.text];
    } else if (self.activeTextField.tag == 3) {
        self.collegeString = [[NSMutableString alloc] initWithString:self.activeTextField.text];
    } else if (self.activeTextField.tag == 4) {
        self.collegeString = [[NSMutableString alloc] initWithString:self.activeTextField.text];
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
    
   
    [self setImgData:[[NSMutableData alloc] initWithData:UIImagePNGRepresentation(info[UIImagePickerControllerOriginalImage]) ]]; //stores NSMutableData but returns image. Might work better store the image as a property instead of theNSMutableData
     [self dismissViewControllerAnimated:NO completion:nil];
}


@end