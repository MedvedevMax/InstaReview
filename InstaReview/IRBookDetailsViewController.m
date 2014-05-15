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
#import "IRAppRatingController.h"
#import "IRMoreInfoTableViewController.h"

#import "UIImage+Resize.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+DrawImage.h"
#import "UIImage+WhiteColorTransparent.h"
#import "UIImage+MaskImage.h"

#define kTableViewBookDetailsSection        0
#define kTableViewBookReviewsSection        1

#define kTableViewTagBackgroundView         110
#define kTableViewTagBackgroundImage        100
#define kTableViewTagCoverImage             101
#define kTableViewTagTitleLabel             102
#define kTableViewTagAuthorLabel            103

#define kTableViewTagRatingImage            100

#define kTableViewReviewTagTitle            100
#define kTableViewReviewTagReviewer         101
#define kTableViewReviewTagThumbImage       102
#define kTableViewReviewTagText             103
#define kTableViewReviewTagDate             104
#define kTableViewReviewTagSeparator        110

@interface IRBookDetailsViewController ()

@property (nonatomic, retain) UIImage *originalCoverImage;
@property (nonatomic, retain, readonly) UIImage *blankCoverImage;

@property (nonatomic, retain) UIImage *blurredBackgroundImage;
@property (nonatomic, retain) UIImage *circleCoverImage;

@property (weak, nonatomic) IBOutlet UILabel *noReviewsLabel;

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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.noReviewsLabel.hidden = self.currentBook.reviews.count > 0;
}

-(void)viewDidDisappear:(BOOL)animated
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Showing an advice to rate the app
        [[IRAppRatingController sharedInstance] showAppRatingPromptIfNeeded];
    });
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
        return 2;
    else
        return 1;       // no "reviews" section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kTableViewBookDetailsSection:
            return 1;
            
        case kTableViewBookReviewsSection:
            return [self.currentBook.reviews count];
            
        default:
            break;
    }
    
    return 0;
}

#pragma mark - Cells

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = NULL;
    
    switch (indexPath.section) {
        case kTableViewBookDetailsSection:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Book Info" forIndexPath:indexPath];
            [self assignCurrentBookToCell:cell];
        }
            break;
            
        case kTableViewBookReviewsSection:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Review" forIndexPath:indexPath];

            IRBookReview *review = [self.currentBook.reviews objectAtIndex:indexPath.row];
            [self assignReview:review toCell:cell];
            
            UIView *separator = [cell viewWithTag:kTableViewReviewTagSeparator];
            separator.hidden = indexPath.row == self.currentBook.reviews.count - 1;
        }
            break;
    }
    return cell;
}

- (void)assignCurrentBookToCell:(UITableViewCell *)cell
{
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:kTableViewTagTitleLabel];
    UILabel *authorLabel = (UILabel*)[cell viewWithTag:kTableViewTagAuthorLabel];
    
    titleLabel.text = self.currentBook.name;
    authorLabel.text = self.currentBook.author;
    
    UIImageView *backgroundImageView = (UIImageView*)[cell viewWithTag:kTableViewTagBackgroundImage];
    UIImageView *coverImageView = (UIImageView*)[cell viewWithTag:kTableViewTagCoverImage];
    
    UIImage *currentCover = nil;
    if (self.currentBook.coverImage) {
        currentCover = self.currentBook.coverImage;
    }
    else {
        currentCover = self.blankCoverImage;
    }
    
    BOOL needsTransition = NO;
    
    if (self.originalCoverImage == nil || self.originalCoverImage != currentCover) {
        needsTransition = self.originalCoverImage != nil;
        if (needsTransition) {
            // assign old values
            backgroundImageView.image = self.blurredBackgroundImage;
            coverImageView.image = self.circleCoverImage;
        }
        
        self.originalCoverImage = currentCover;
        self.blurredBackgroundImage = [self getBlurredBackgroundForCover:currentCover
                                                                withSize:backgroundImageView.bounds.size];
        
        self.circleCoverImage = [self cropBookCoverToCircle:currentCover];
    }
    
    if (needsTransition) {
        // Do the transition a little later
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:backgroundImageView
                              duration:0.8f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                backgroundImageView.image = self.blurredBackgroundImage;
                            } completion:nil];
            
            [UIView transitionWithView:coverImageView
                              duration:0.8f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                coverImageView.image = self.circleCoverImage;
                            } completion:nil];
        });
    }
    else {
        backgroundImageView.image = self.blurredBackgroundImage;
        coverImageView.image = self.circleCoverImage;
    }
    
    UIView *backgroundView = (UIView*)[cell viewWithTag:kTableViewTagBackgroundView];
    if (!backgroundView.layer.shadowOpacity) {
        backgroundView.layer.shadowColor = [[UIColor blackColor] CGColor];
        backgroundView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
        backgroundView.layer.shadowOpacity = 0.1f;
        backgroundView.layer.shadowRadius = 5.0f;
    }
}

- (void)assignReview:(IRBookReview *)review toCell:(UITableViewCell *)cell
{
    #define MAX_TITLE_TEXT_LENGTH 15
    
    UILabel *title = (UILabel*)[cell viewWithTag:kTableViewReviewTagTitle];
    UILabel *date = (UILabel*)[cell viewWithTag:kTableViewReviewTagDate];
    UIImageView *thumbImage = (UIImageView*)[cell viewWithTag:kTableViewReviewTagThumbImage];
    UILabel *text = (UILabel*)[cell viewWithTag:kTableViewReviewTagText];
    UILabel *reviewer = (UILabel*)[cell viewWithTag:kTableViewReviewTagReviewer];
    
    int rating = [review.rate intValue];
    NSString *titleText = review.title;
    NSString *reviewText = review.text;
    
    if (titleText.length > MAX_TITLE_TEXT_LENGTH) {
        reviewText = [NSString stringWithFormat:@"%@.\n\n%@", titleText, reviewText];
        titleText = nil;
    }
    
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
    
    if (rating > 3) {
        thumbImage.image = [UIImage imageNamed:@"Good.png"];
    }
    else if (rating < 3) {
        thumbImage.image = [UIImage imageNamed:@"Awful.png"];
    }
    else {
        thumbImage.image = [UIImage imageNamed:@"Bad.png"];
    }
    
    text.text = reviewText;
    reviewer.text = review.reviewer;
    
    if (review.date) {
        date.hidden = NO;
        date.text = [NSDateFormatter localizedStringFromDate:review.date
                                                   dateStyle:NSDateFormatterLongStyle
                                                   timeStyle:NSDateFormatterNoStyle];
        text.text = [text.text stringByAppendingString:@"\n\n"];
    } else {
        date.hidden = YES;
    }
}

- (UIImage*)getBlurredBackgroundForCover:(UIImage *)coverImage withSize:(CGSize)size
{
    CGFloat newHeight = coverImage.size.height * (size.width / coverImage.size.width);
    UIImage *resultImage = [coverImage resizedImage:CGSizeMake(size.width, newHeight)
                               interpolationQuality:kCGInterpolationLow];
    
    CGFloat topCropPoint = MAX(0, resultImage.size.height / 2 - size.height / 2);
    CGFloat cropHeight = MIN(size.height, resultImage.size.height);
    resultImage = [resultImage croppedImage:CGRectMake(0, topCropPoint, resultImage.size.width, cropHeight)];
    
    resultImage = [resultImage applyBlurWithRadius:25
                                         tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.25f]
                             saturationDeltaFactor:0.5f
                                         maskImage:nil];
    
    UIImage *overlayImage = [UIImage imageNamed:@"BlurBgOverlay.png"];
    resultImage = [resultImage drawImage:overlayImage
                                  inRect:CGRectMake(0, 0, resultImage.size.width, resultImage.size.height)];
    
    return resultImage;
}

- (UIImage*)cropBookCoverToCircle:(UIImage *)coverImage
{
    #define TOP_POSITION_IN_TEMPLATE    25
    #define COVER_WIDTH                 104
    
    #define SIZE_WIDTH                  147
    #define SIZE_HEIGHT                 147
    #define SCALE                       2.0f
    
    UIImage *resultImage = [UIImage blankImageWithSize:CGSizeMake(SIZE_WIDTH, SIZE_HEIGHT) scale:SCALE];
    
    CGFloat coverHeight = coverImage.size.height * ((float)COVER_WIDTH / coverImage.size.width);
    UIImage *resizedCroppedCover = [[coverImage makeWhiteColorTransparent]
                                    resizedImage:CGSizeMake(COVER_WIDTH, coverHeight)
                                       interpolationQuality:kCGInterpolationHigh];
    resizedCroppedCover = [resizedCroppedCover croppedImage:CGRectMake(0, 0, COVER_WIDTH, resultImage.size.height - TOP_POSITION_IN_TEMPLATE)];
    
    CGFloat imageLeftPos = resultImage.size.width / 2 - resizedCroppedCover.size.width / 2;
    resultImage = [resultImage drawImage:resizedCroppedCover
                                  inRect:CGRectMake(imageLeftPos, TOP_POSITION_IN_TEMPLATE, resizedCroppedCover.size.width, resizedCroppedCover.size.height)];
    
    resultImage = [resultImage applyEllipseMask];
    return resultImage;
}

#pragma mark - Headers & Footers

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kTableViewBookDetailsSection:
            return nil;
            
        case kTableViewBookReviewsSection:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Rating Cell"];
            UIImageView *ratingImageView = (UIImageView*)[cell viewWithTag:kTableViewTagRatingImage];
            
            if (!ratingImageView.image) {
                UIImage *fiveStarImage = [UIImage imageNamed:@"Stars.png"];
                CGRect cropFrame = CGRectMake(0, 0,
                                              fiveStarImage.size.width *
                                              (self.currentBook.rating.doubleValue / 5.0) * 2,
                                              fiveStarImage.size.height * 2);
                ratingImageView.image = [fiveStarImage croppedImage:cropFrame];
            }
            return cell;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    #define RATING_CELL_HEIGHT  42
    
    switch (section) {
        case kTableViewBookDetailsSection:
            return CGFLOAT_MIN;
            
        case kTableViewBookReviewsSection:
            return RATING_CELL_HEIGHT;
            
        default:
            break;
    }
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.currentBook.reviews.count == 0 && section == 0) {    // when no books
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        
        return view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {             // when no books
        if (self.currentBook.reviews.count == 0) {
            CGFloat topHeight = [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            topHeight += 64;    // navigation bar height
            topHeight += 48;    // fix
            
            CGFloat centerY = (self.view.frame.size.height - topHeight) / 2;
            centerY -= self.noReviewsLabel.frame.size.height / 2;
            
            return centerY;
        }
    }
    
    return 0;
}

#pragma mark - Cell Heights

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGFloat height = 0;
    
    switch (indexPath.section) {
        case kTableViewBookDetailsSection:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Book Info"];
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:kTableViewTagTitleLabel];
            NSDictionary *titleTextAttributes = @{NSFontAttributeName:titleLabel.font};
            
            NSString *text = self.currentBook.name;
            height = cell.bounds.size.height - titleLabel.frame.size.height;
            height += [text boundingRectWithSize:constraintSize
                                         options:NSLineBreakByWordWrapping |NSStringDrawingUsesLineFragmentOrigin
                                      attributes:titleTextAttributes context:nil].size.height;
        }
            break;
            
        case kTableViewBookReviewsSection:
        {
            IRBookReview *review = [self.currentBook.reviews objectAtIndex:indexPath.row];
            NSString *reviewText = [review text];
            if (review.title.length > MAX_TITLE_TEXT_LENGTH) {
                reviewText = [[review.title stringByAppendingString:@".\n\n"] stringByAppendingString:reviewText];
            }
            
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Review"];
            UILabel *textLabel = (UILabel*)[cell viewWithTag:kTableViewReviewTagText];
            UILabel *dateLabel = (UILabel*)[cell viewWithTag:kTableViewReviewTagDate];

            NSDictionary *reviewTextAttributes = @{NSFontAttributeName:textLabel.font};
            
            height = cell.bounds.size.height - textLabel.frame.size.height;
            height += [reviewText boundingRectWithSize:constraintSize
                                               options:NSLineBreakByWordWrapping |NSStringDrawingUsesLineFragmentOrigin
                                            attributes:reviewTextAttributes context:nil].size.height;
            
            if (review.date) {
                height += dateLabel.frame.size.height;
            }
        }
            break;
    }
    
    return height;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"More Info"]) {
        IRMoreInfoTableViewController *destination = segue.destinationViewController;
        destination.currentBook = self.currentBook;
    }
}

#pragma mark - Setters & Getters

@synthesize blankCoverImage = _blankCoverImage;

- (UIImage *)blankCoverImage
{
    if (!_blankCoverImage) {
        _blankCoverImage = [UIImage imageNamed:@"blankCover.png"];
    }
    
    return _blankCoverImage;
}

@end
