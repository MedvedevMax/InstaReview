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

#import "UIImage+Resize.h"

#define kTableViewBookDetailsSection        0
#define kTableViewBookDescriptionSection    1
#define kTableViewBookReviewsSection        2

#define kTableViewTagCoverImage             100
#define kTableViewTagBookTitle              101
#define kTableViewTagAuthor                 102
#define kTableViewTagYear                   103
#define kTableViewTagRating                 104

#define kTableViewReviewTagTitle            100
#define kTableViewReviewTagReviewer         101
#define kTableViewReviewTagThumbImage       102
#define kTableViewReviewTagText             103
#define kTableViewReviewTagDate             104

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
    [[IRReviewsAPI sharedInstance] addBookToViewed:self.currentBook];
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
            [self assignReview:review toCell:cell];
            break;
    }
    return cell;
}

- (void)assignCurrentBookToCell:(UITableViewCell *)cell
{
    #define FIVESTAR_RATING_ORIGINAL_WIDTH 129
    
    UIImageView *coverImage = (UIImageView*)[cell viewWithTag:kTableViewTagCoverImage];
    UILabel *title = (UILabel*)[cell viewWithTag:kTableViewTagBookTitle];
    UILabel *author = (UILabel*)[cell viewWithTag:kTableViewTagAuthor];
    UILabel *year = (UILabel*)[cell viewWithTag:kTableViewTagYear];
    UIImageView *rating = (UIImageView*)[cell viewWithTag:kTableViewTagRating];
    
    title.text = self.currentBook.name;
    author.text = self.currentBook.author;
    year.text = [NSString stringWithFormat:@"%@", self.currentBook.year];

    UIImage *fiveStarImage = [UIImage imageNamed:@"5stars.png"];
    CGRect cropFrame = CGRectMake(0, 0,
                               fiveStarImage.size.width *
                                  (self.currentBook.rating.doubleValue / 5.0) * 2,
                              fiveStarImage.size.height * 2);
    
    if (cropFrame.size.width) {        
        rating.image = [fiveStarImage croppedImage:cropFrame];
    }
    else {
        rating.image = nil;
    }
    
    
    if (self.currentBook.coverImage) {
        // Do the transition a little later
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:coverImage
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                coverImage.image = self.currentBook.coverImage;
                            } completion:nil];
        });
    }
}

- (void)assignReview:(IRBookReview *)review toCell:(UITableViewCell *)cell
{
    UILabel *title = (UILabel*)[cell viewWithTag:kTableViewReviewTagTitle];
    UILabel *date = (UILabel*)[cell viewWithTag:kTableViewReviewTagDate];
    UIImageView *thumbImage = (UIImageView*)[cell viewWithTag:kTableViewReviewTagThumbImage];
    UILabel *text = (UILabel*)[cell viewWithTag:kTableViewReviewTagText];
    UILabel *reviewer = (UILabel*)[cell viewWithTag:kTableViewReviewTagReviewer];
    
    int rating = [review.rate intValue];
    NSString *titleText = review.title;
    
    if (titleText.length == 0) {
        if (rating <= 1) {
            titleText = NSLocalizedString(@"Awful", @"Rating =1 comment");
        }
        else if (rating == 2) {
            titleText = NSLocalizedString(@"Very bad", @"Rating = 2 comment");
        }
        else if (rating == 3) {
            titleText = NSLocalizedString(@"Bad", @"Rating = 3 comment");
        }
        else if (rating == 4) {
            titleText = NSLocalizedString(@"Good", @"Rating = 4 comment");
        }
        else if (rating == 5) {
            titleText = NSLocalizedString(@"Awesome", @"Rating = 5 comment");
        }
    }
    
    title.text = titleText;
    
    if (review.date) {
        date.text = [NSDateFormatter localizedStringFromDate:review.date
                                                   dateStyle:NSDateFormatterLongStyle
                                                   timeStyle:NSDateFormatterNoStyle];
    } else {
        date.text = NSLocalizedString(@"Date unknown", @"Unknown review date");
    }
    
    if (rating > 3) {
        thumbImage.image = [UIImage imageNamed:@"thumb-up.png"];
    }
    else if (rating < 3) {
        thumbImage.image = [UIImage imageNamed:@"thumb-down.png"];
    }
    else {
        thumbImage.image = [UIImage imageNamed:@"thumb-neutral.png"];
    }
    text.text = review.text;
    reviewer.text = review.reviewer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    #define TEXT_MARGIN 20;
    #define REVIEW_CELL_HEIGHT_WITHOUT_TEXT 97
    
    CGSize constraintSize = CGSizeMake(290.0f, MAXFLOAT);

    NSDictionary *textAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    
    UITableViewCell *cell = NULL;
    NSString *text = NULL;
    
    CGFloat height = 0;
    
    switch (indexPath.section) {
        case kTableViewBookDetailsSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Book Info"];
            height = cell.bounds.size.height;
            break;
            
        case kTableViewBookDescriptionSection:
            text = self.currentBook.description;
            height = [text boundingRectWithSize:constraintSize
                                          options:NSLineBreakByTruncatingTail |NSStringDrawingUsesLineFragmentOrigin
                                       attributes:textAttributes context:nil].size.height;
            height += TEXT_MARGIN;
            break;
            
        case kTableViewBookReviewsSection:
            text = [[self.currentBook.reviews objectAtIndex:indexPath.row] text];

            height = REVIEW_CELL_HEIGHT_WITHOUT_TEXT;
            height += [text boundingRectWithSize:constraintSize
                                         options:NSLineBreakByWordWrapping |NSStringDrawingUsesLineFragmentOrigin
                                      attributes:textAttributes context:nil].size.height;
            height += TEXT_MARGIN;
            break;
    }
    
    return height;
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
