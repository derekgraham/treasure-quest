//
//  SummaryViewController.m
//  Treasure-Quest
//
//  Created by Rick  on 8/4/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "SummaryViewController.h"
#import "FoursquareAPI.h"
#import "WaitPageViewController.h"
@import Parse;

@interface SummaryViewController ()

@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UILabel *questNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPlayersLabel;
@property (weak, nonatomic) IBOutlet UILabel *objectivesLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
- (IBAction)createButtonSelected:(UIButton *)sender;

@end

@implementation SummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *token = @"IPVFQK21YIYRBOAM3JHLKAQXDU2LSDVAUFBLZ1ILNINHBMZY";
    
    self.finalLat = [NSString stringWithFormat:@"%f", self.finalCoordinate.latitude];
    self.finalLong = [NSString stringWithFormat:@"%f", self.finalCoordinate.longitude];
    NSLog(@"Lat: %@, long: %@", self.finalLat, self.finalLong);
    
    
    if (token)
    {
        [FoursquareAPI getFoursquareData:@"query" finalLat:self.finalLat finalLong:self.finalLong radius:[self.maxDistance stringValue] completionHandler:^(NSArray *results, NSError *error) {
            if (error)
            {
                NSLog(@"%@", error.localizedDescription);
            }
            self.searchResults = results;
        }];
    }

}

- (void)setupView {
    self.questNameLabel.text = self.questName;
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"Players: %@", self.players];
    self.objectivesLabel.text = [NSString stringWithFormat:@"Total Objectives: %@", self.objectives];
    self.descriptionLabel.text = self.gameDescription;
}


- (IBAction)createButtonSelected:(UIButton *)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [UIColor darkGrayColor];
    [self.view addSubview:spinner];
    spinner.center = CGPointMake(160, 250);
    spinner.tag = 12;
    [spinner startAnimating];
    
    PFObject *quest = [PFObject objectWithClassName:@"Quest"];
    quest[@"name"] = self.questName;
    quest[@"info"] = self.gameDescription;
    quest[@"maxplayers"] = self.players;
    NSMutableArray *currentPlayers = [[NSMutableArray alloc]init];
    [currentPlayers addObject:[PFUser currentUser].objectId];
    quest[@"players"] = currentPlayers;
    
    [quest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
     
            WaitPageViewController *viewController = [[UIStoryboard storyboardWithName:@"Waiting" bundle:nil] instantiateViewControllerWithIdentifier:@"waitingStoryboard"];

            NSLog(@"Saved successfully");
            viewController.questName = self.questName;
            
            [[self.view viewWithTag:12] stopAnimating];
            [self.navigationController pushViewController:viewController animated:YES];
            
        } else {
            [[self.view viewWithTag:12] stopAnimating];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error Saving"
                                                                                     message:@"Quest unable to save, please try again."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
            
            NSLog(@"ERROR: %@:", error);
        }
    }];
}
@end
