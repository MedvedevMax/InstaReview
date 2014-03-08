//
//  IRBookDetailsViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRBookDetailsViewController.h"
#import "IRBookReview.h"
#import "IRReviewsAPI.h"

#define kTableViewBookDetailsSection        0
#define kTableViewBookDescriptionSection    1
#define kTableViewBookReviewsSection        2

#define kTableViewTagCoverImage             100
#define kTableViewTagBookTitle              101
#define kTableViewTagAuthor                 102
#define kTableViewTagYear                   103
#define kTableViewTagRating                 104

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
    [[IRReviewsAPI sharedInstance] downloadCoverForBook:self.currentBook]; 
}

#pragma mark - Observing book cover image

- (void)setCurrentBook:(IRBookDetails *)currentBook
{
    if (_currentBook) {
        [_currentBook removeObserver:self forKeyPath:@"coverImage"];
    }
    
    _currentBook = currentBook;
    [_currentBook addObserver:self forKeyPath:@"coverImage" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc
{
    if (_currentBook) {
        [_currentBook removeObserver:self forKeyPath:@"coverImage"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"coverImage"]) {
        if (object == self.currentBook) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
            [self assignCurrentBookToCell:cell];
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

- (void)assignCurrentBookToCell:(UITableViewCell *)cell
{
    UIImageView *coverImage = (UIImageView*)[cell viewWithTag:kTableViewTagCoverImage];
    UILabel *title = (UILabel*)[cell viewWithTag:kTableViewTagBookTitle];
    UILabel *author = (UILabel*)[cell viewWithTag:kTableViewTagAuthor];
    UILabel *year = (UILabel*)[cell viewWithTag:kTableViewTagYear];
    UILabel *rating = (UILabel*)[cell viewWithTag:kTableViewTagRating];
    
    title.text = self.currentBook.name;
    author.text = self.currentBook.author;
    year.text = self.currentBook.published;
    rating.text = [self.currentBook.rating stringValue];
    
    if (self.currentBook.coverImage) {
        coverImage.image = self.currentBook.coverImage;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    #define TEXT_MARGIN 25;
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
    
    UITableViewCell *cell = NULL;
    NSString *text = NULL;
    CGSize cellSize;
    
    switch (indexPath.section) {
        case kTableViewBookDetailsSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Book Info"];
            cellSize = cell.bounds.size;
            break;
            
        case kTableViewBookDescriptionSection:
            text = self.currentBook.description;
            cellSize = [text boundingRectWithSize:constraintSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes context:nil].size;
            cellSize.height += TEXT_MARGIN;
            break;
            
        case kTableViewBookReviewsSection:
            text = [[self.currentBook.reviews objectAtIndex:indexPath.row] shortText];
            cellSize = [text boundingRectWithSize:constraintSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes context:nil].size;
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
