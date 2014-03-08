//
//  IRBookDetailsViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRBookDetailsViewController.h"
#import "IRBookReview.h"

#define kTableViewBookDetailsSection 0
#define kTableViewBookDescriptionSection 1
#define kTableViewBookReviewsSection 2

@interface IRBookDetailsViewController ()

@end

@implementation IRBookDetailsViewController

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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.currentBook.reviews.count > 0)
        return 3;
    else
        return 2;       // no "reviews" section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kTableViewBookDetailsSection:
        case kTableViewBookDescriptionSection:
            return 1;

        case kTableViewBookReviewsSection:
            return [[self.currentBook reviews] count];
            
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = NULL;
    
    switch (indexPath.section) {
        case kTableViewBookDetailsSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Book Info" forIndexPath:indexPath];
            
            
            break;

        case kTableViewBookDescriptionSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Book Description" forIndexPath:indexPath];
            cell.textLabel.text = self.currentBook.description;
            break;
            
        case kTableViewBookReviewsSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Review" forIndexPath:indexPath];
            IRBookReview *review = [self.currentBook.reviews objectAtIndex:indexPath.row];
            cell.textLabel.text = review.shortText;
            break;
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
