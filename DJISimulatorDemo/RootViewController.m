//
//  DJIRootViewController.m
//
//  Created by DJI on 8/6/2016.
//  Copyright © 2016 DJI. All rights reserved.
//

#import "RootViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"

@interface RootViewController ()<DJISDKManagerDelegate>

@property(nonatomic, weak) DJIBaseProduct* product;
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

- (IBAction)onConnectButtonClicked:(id)sender;

@end

@implementation RootViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString* appKey = @""; //TODO: Please enter your App Key here
    
    if ([appKey length] == 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [DemoUtility showAlertViewWithTitle:nil message:@"Please enter your App Key" cancelAlertAction:cancelAction defaultAlertAction:nil viewController:self];
    }
    else
    {
        [DJISDKManager registerApp:appKey withDelegate:self];
    }
    
    if(self.product){
        [self updateStatusBasedOn:self.product];
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initUI];
    
}

- (void)initUI
{
    self.title = @"DJISimulator Demo";
    self.modelNameLabel.hidden = YES;
    //Disable the connect button by default
    [self.connectButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - DJISDKManager Delegate Methods

- (void)sdkManagerDidRegisterAppWithError:(NSError *)error
{
    if (!error) {
        
        [DJISDKManager startConnectionToProduct];
        
    }else
    {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [DemoUtility showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"Registration Error:%@", error] cancelAlertAction:cancelAction defaultAlertAction:nil viewController:self];
        
        [self.connectButton setEnabled:NO];
    }
    
}

- (void)sdkManagerProductDidChangeFrom:(DJIBaseProduct *)oldProduct to:(DJIBaseProduct *)newProduct
{
    if (newProduct) {
        self.product = newProduct;
        [self.connectButton setEnabled:YES];
        
    } else {
        
        NSString* message = [NSString stringWithFormat:@"Connection lost. Back to root."];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (![self.navigationController.topViewController isKindOfClass:[RootViewController class]]) {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
        }];
        [DemoUtility showAlertViewWithTitle:nil message:message cancelAlertAction:cancelAction defaultAlertAction:backAction viewController:self];

        [self.connectButton setEnabled:NO];
        self.product = nil;
    }
    
    [self updateStatusBasedOn:newProduct];
}

- (IBAction)onConnectButtonClicked:(id)sender {
    
}

-(void) updateStatusBasedOn:(DJIBaseProduct* )newConnectedProduct {
    if (newConnectedProduct){
        self.connectStatusLabel.text = NSLocalizedString(@"Status: Product Connected", @"");
        self.modelNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Model: \%@", @""),newConnectedProduct.model];
        self.modelNameLabel.hidden = NO;
        
    }else {
        self.connectStatusLabel.text = NSLocalizedString(@"Status: Product Not Connected", @"");
        self.modelNameLabel.text = NSLocalizedString(@"Model: Unknown", @"");
    }
}


@end
