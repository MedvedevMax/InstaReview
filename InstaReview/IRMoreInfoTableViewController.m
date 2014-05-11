//
//  IRMoreInfoTableViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 5/11/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRMoreInfoTableViewController.h"

@interface IRMoreInfoTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *descriptionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *priceCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *buyButtonCell;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation IRMoreInfoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.currentBook.name;
    
    if (self.currentBook.description) {
        self.descriptionLabel.text = self.currentBook.description;
    }
    else {
        self.descriptionLabel.text = NSLocalizedString(@"No description available.", @"''No description' comment");
    }
    self.priceLabel.text = self.currentBook.price;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.currentBook.price.length > 0) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return (self.currentBook.url.length > 0) ? 2 : 1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        CGSize constraintSize = CGSizeMake(self.descriptionLabel.frame.size.width, MAXFLOAT);
        NSDictionary *descriptionTextAttributes = @{NSFontAttributeName:self.descriptionLabel.font};
        
        CGFloat height = self.descriptionCell.bounds.size.height - self.descriptionLabel.frame.size.height;
        height += [self.descriptionLabel.text boundingRectWithSize:constraintSize
                                                           options:NSLineBreakByWordWrapping |NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:descriptionTextAttributes
                                                           context:nil].size.height;
        
        return height;
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {
        return self.buyButtonCell.frame.size.height;
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 45;
    }
    
    return UITableViewAutomaticDimension;
}

- (IBAction)buyButtonTapped
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.currentBook.url]];
}

@end
