//
//  RWViewController.m
//  RWReactivePlayground
//
//  Created by Colin Eberhardt on 18/12/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "RWViewController.h"
#import "RWDummySignInService.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RWViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *signInFailureText;

@property (nonatomic) BOOL passwordIsValid;
@property (nonatomic) BOOL usernameIsValid;
@property (strong, nonatomic) RWDummySignInService *signInService;

@end

@implementation RWViewController

- (void)viewDidLoad {
    [super viewDidLoad];



    self.signInService = [RWDummySignInService new];

    // handle text changes for both text fields
    [self.usernameTextField addTarget:self action:@selector(usernameTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(passwordTextFieldChanged) forControlEvents:UIControlEventEditingChanged];

    // initially hide the failure message
    self.signInFailureText.hidden = YES;

//    [[[self.usernameTextField.rac_textSignal map:^id(NSString* value) {
//        return @{@"textLength" : @(value.length)};
//    }]
//        filter:^BOOL(NSDictionary* value) {
//            return [value[@"textLength"] integerValue] > 3;
//    }]  subscribeNext:^(NSDictionary* x) {
//        NSLog(@"%@",x[@"textLength"]);
//    }];

//    RACSignal* signal = self.usernameTextField.rac_textSignal;
//    RACSignal* filterdSignal = [signal filter:^BOOL(NSString* value) {
//        return value.length > 3;
//    }];
//    [filterdSignal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];


//    RACSignal* validUserNameSignal = [self.usernameTextField.rac_textSignal map:^id(NSString* value) {
//        return @([self isValidUsername:value]);
//    }];
//    RACSignal* validPasswordSignal = [self.passwordTextField.rac_textSignal map:^id(NSString* value) {
//        return @([self isValidPassword:value]);
//    }];
//
//    [validUserNameSignal subscribeNext:^(NSNumber* x) {
//        self.usernameTextField.backgroundColor = [x boolValue] == true ? [UIColor colorWithRed:0.3 green:1 blue:0.5 alpha:1] : [UIColor redColor];
//    }];
//
//    [validPasswordSignal subscribeNext:^(NSNumber* x) {
//        self.passwordTextField.backgroundColor = [x boolValue] == true ? [UIColor colorWithRed:.3 green:1 blue:.5 alpha:1] : [UIColor redColor];
//    }];

    RACSignal* validUsernameSignal = [self.usernameTextField.rac_textSignal
                                  map:^id(NSString* value) {
                                      return @([self isValidUsername:value]);
                                  }];

    RACSignal* validPasswordSignal = [self.passwordTextField.rac_textSignal
                                  map:^id(NSString* value) {
                                      return @([self isValidPassword:value]);
                                  }];
    [[validUsernameSignal map:^id(NSNumber* value) {
        return [value boolValue] ? [UIColor greenColor] : [UIColor yellowColor];
     }] subscribeNext:^(UIColor* x) {
         self.usernameTextField.backgroundColor = x;
     }];

    [[validPasswordSignal map:^id(NSNumber* value) {
        return [value boolValue] ? [UIColor greenColor] : [UIColor yellowColor];
    }] subscribeNext:^(UIColor* x) {
        self.passwordTextField.backgroundColor = x;
    }];


//    [self updateUIState];
}

- (BOOL)isValidUsername:(NSString *)username {
    return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length > 3;
}

- (IBAction)signInButtonTouched:(id)sender {
    // disable all UI controls
    self.signInButton.enabled = NO;
    self.signInFailureText.hidden = YES;

    // sign in
    [self.signInService signInWithUsername:self.usernameTextField.text
                                  password:self.passwordTextField.text
                                  complete:^(BOOL success) {
                                      self.signInButton.enabled = YES;
                                      self.signInFailureText.hidden = success;
                                      if (success) {
                                          [self performSegueWithIdentifier:@"signInSuccess" sender:self];
                                      }
                                  }];
}


// updates the enabled state and style of the text fields based on whether the current username
// and password combo is valid
- (void)updateUIState {
//    self.usernameTextField.backgroundColor = self.usernameIsValid ? [UIColor clearColor] : [UIColor yellowColor];
//    self.passwordTextField.backgroundColor = self.passwordIsValid ? [UIColor clearColor] : [UIColor yellowColor];
    self.signInButton.enabled = self.usernameIsValid && self.passwordIsValid;
}

- (void)usernameTextFieldChanged {
    self.usernameIsValid = [self isValidUsername:self.usernameTextField.text];
    [self updateUIState];
}

- (void)passwordTextFieldChanged {
    self.passwordIsValid = [self isValidPassword:self.passwordTextField.text];
    [self updateUIState];
}

@end
