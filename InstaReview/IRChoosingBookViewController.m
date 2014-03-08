//
//  IRChoosingBookViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRChoosingBookViewController.h"

#import "IRBookDetails.h"
#import "IRBookDetailsViewController.h"
#import "IRReviewsAPI.h"

#import "UIImage+Resize.h"

@interface IRChoosingBookViewController ()

@end

@implementation IRChoosingBookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (IRBookDetails *book in [self.delegate books]) {
        [book addObserver:self forKeyPath:@"coverImage" options:NSKeyValueObservingOptionNew context:nil];
        [[IRReviewsAPI sharedInstance] downloadCoverForBook:book];
    }
}

- (void)dealloc
{
    for (IRBookDetails *book in [self.delegate books]) {
        [book removeObserver:self forKeyPath:@"coverImage"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"coverImage"]) {
        if ([[self.delegate books] containsObject:object]) {
            [self.tableView reloadRowsAtIndexPaths:
                    @[[NSIndexPath indexPathForRow:[[self.delegate books] indexOfObject:object] inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.delegate books] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Book Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    IRBookDetails *book = [[self.delegate books] objectAtIndex:indexPath.row];
    cell.textLabel.text = book.name;
    cell.detailTextLabel.text = book.author;
    
    if (book.coverImage) {
        cell.imageView.image = [book.coverImage resizedImage:CGSizeMake(30, 45) interpolationQuality:kCGInterpolationHigh];
    }
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // remove "back" button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([segue.identifier isEqualToString:@"Show Book Details"]) {
        IRBookDetailsViewController *detailsVC = segue.destinationViewController;
        detailsVC.currentBook = [[self.delegate books] objectAtIndex:[[self.tableView indexPathForCell:sender] row]];
    }
}

@end
