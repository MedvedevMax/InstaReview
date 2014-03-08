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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    #define TEXT_MARGIN 10;
    
    UITableViewCell *cell = NULL;
    CGSize cellSize;
    
    switch (indexPath.section) {
        case kTableViewBookDetailsSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Book Info"];
            cellSize = cell.bounds.size;
            break;
            
        case kTableViewBookDescriptionSection:
            cellSize = [self.currentBook.description sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0f]}];
            cellSize.height += TEXT_MARGIN;
            break;
            
        case kTableViewBookReviewsSection:
            cellSize = [[[self.currentBook.reviews objectAtIndex:indexPath.row] shortText]
                        sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0f]}];
            cellSize.height += TEXT_MARGIN;
            break;
    }
    
    return cellSize.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kTableViewBookDescriptionSection:
            return @"Description";
            
        case kTableViewBookReviewsSection:
            return @"Reviews";
            
        default:
            break;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kTableViewBookDetailsSection:
            return CGFLOAT_MIN;
            
        default:
            break;
    }
    return UITableViewAutomaticDimension;
}

@end
