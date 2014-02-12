//
//  ViewController.m
//  CredentialManager
//
//  Created by Bharath Nagaraj Rao on 11/02/14.
//  Copyright (c) 2014 Bharath Nagaraj Rao. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "UserCredentials.h"


#define REGISTRATION_SUCCESS    @"User registered successfully"
#define REGISTRATION_FAILURE    @"Oops! Registration Failed!"
#define LOGIN_SUCCESS           @"User logged in successfully"
#define LOGIN_FAILURE           @"Oops! Username & Password don not match!"
#define EMPTY_FORM_FIELD        @"Username and Password cannot be blank"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *launchFlag = [userDefaults objectForKey:@"LaunchFlag"];
    self.isFirstTimeLaunch = (launchFlag.length) >0 ? NO:YES;
    
    [self showLaunchScreen];
    
}

-(void)showLaunchScreen
{
    if (self.isFirstTimeLaunch) {

        self.registrationView.hidden = NO;
        self.loginView.hidden = YES;
        
    }else{
        
        self.registrationView.hidden = YES;
        self.loginView.hidden = NO;
    }
}

#pragma mark - Registration/Login methods

- (IBAction)registerUser:(id)sender
{
    if (self.usernameTextFieldForRegistration.text.length && self.passwordTextFieldForRegistration.text.length) {
        
        BOOL isSuccess = [self isRegistrationLoginSuccess];
        if (isSuccess) {
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@"1" forKey:@"LaunchFlag"];
            [userDefaults synchronize];
            
            [self showAlertWithMessage:REGISTRATION_SUCCESS];
            
            self.isFirstTimeLaunch = NO;
            [self showLaunchScreen];
            
           
        }
        else{
            
            [self showAlertWithMessage:REGISTRATION_FAILURE];
    
        }
    }
    else{
        
        [self showAlertWithMessage:EMPTY_FORM_FIELD];
    }
}


-(void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)cancelRegistration:(id)sender
{
    //Clear the text fields when user taps on Cancel
    self.usernameTextFieldForRegistration.text = @"";
    self.passwordTextFieldForRegistration.text = @"";
    self.usernameTextFieldForLogin.text = @"";
    self.passwordTextFieldForLogin.text = @"";
}

- (IBAction)loginUser:(id)sender
{
    if (self.usernameTextFieldForLogin.text.length && self.passwordTextFieldForLogin.text.length) {
        
        BOOL isSuccess = [self isRegistrationLoginSuccess];
        if (isSuccess) {
            
            [self showAlertWithMessage:LOGIN_SUCCESS];
        }
        else{
            
             [self showAlertWithMessage:LOGIN_FAILURE];
        }
    }
    else{
        
        [self showAlertWithMessage:EMPTY_FORM_FIELD];
    }

}


-(BOOL)isRegistrationLoginSuccess
{
    BOOL isSuccess = NO;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    // Fetch all the available username/password stored in the database
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserCredentials"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count]) {
        
        UserCredentials *userCredentials = [fetchedObjects objectAtIndex:0];
        if ([[userCredentials.username lowercaseString] isEqualToString:[self.usernameTextFieldForLogin.text lowercaseString]]
            && [[userCredentials.password lowercaseString] isEqualToString:[self.passwordTextFieldForLogin.text lowercaseString]])
        {
            
            userCredentials.username = self.usernameTextFieldForLogin.text;
            userCredentials.password = self.passwordTextFieldForLogin.text;
            if (![context save:&error]) {
                NSLog(@"Error in saving Credentials: %@", [error localizedDescription]);
            }else{
                NSLog(@"Update Credentials in DB : Username - %@, Password - %@", userCredentials.username, userCredentials.password);
                isSuccess = YES;
            }
        }
        else{
            
            isSuccess = NO;
        }
   
    }else{
        
        UserCredentials *userCredentials = [NSEntityDescription insertNewObjectForEntityForName:@"UserCredentials" inManagedObjectContext:context];
        userCredentials.username = self.usernameTextFieldForRegistration.text;
        userCredentials.password = self.passwordTextFieldForRegistration.text;
        
        if (![context save:&error]) {
            NSLog(@"Error in saving Credentials: %@", [error localizedDescription]);
        }else{
            NSLog(@"Insert Credentials in DB : Username - %@, Password - %@", userCredentials.username, userCredentials.password);
            isSuccess = YES;
        }
        
    }

    return isSuccess;
}

#pragma mark - Core Data methods




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
