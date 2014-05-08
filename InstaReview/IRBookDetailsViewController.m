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
#import "UIImage+ImageEffects.h"
#import "UIImage+DrawImage.h"
#import "UIImage+WhiteColorTransparent.h"
#import "UIImage+MaskImage.h"

#define kTableViewBookDetailsSection        0
#define kTableViewBookReviewsSection        1

#define kTableViewTagBackgroundImage        100
#define kTableViewTagCoverImage             101
#define kTableViewTagTitleLabel             102
#define kTableViewTagAuthorLabel            103

#define kTableViewReviewTagTitle            100
#define kTableViewReviewTagReviewer         101
#define kTableViewReviewTagThumbImage       102
#define kTableViewReviewTagText             103
#define kTableViewReviewTagDate             104

@interface IRBookDetailsViewController ()

@property (nonatomic, retain) UIImage *originalCoverImage;
@property (nonatomic, retain) UIImage *blankCoverImage;

@property (nonatomic, retain) UIImage *blurredBackgroundImage;
@property (nonatomic, retain) UIImage *circleCoverImage;

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = NULL;
    
    switch (indexPath.section) {
        case kTableViewBookDetailsSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Book Info" forIndexPath:indexPath];
            [self assignCurrentBookToCell:cell];
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
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                backgroundImageView.image = self.blurredBackgroundImage;
                            } completion:nil];
            
            [UIView transitionWithView:coverImageView
                              duration:0.3
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
    UIImage *resizedCroppedCover = [coverImage resizedImage:CGSizeMake(COVER_WIDTH, coverHeight)
                                       interpolationQuality:kCGInterpolationHigh];
    resizedCroppedCover = [resizedCroppedCover croppedImage:CGRectMake(0, 0, COVER_WIDTH, resultImage.size.height - TOP_POSITION_IN_TEMPLATE)];
    
    resizedCroppedCover = [resizedCroppedCover makeWhiteColorTransparent];
    
    CGFloat imageLeftPos = resultImage.size.width / 2 - resizedCroppedCover.size.width / 2;
    resultImage = [resultImage drawImage:resizedCroppedCover
                                  inRect:CGRectMake(imageLeftPos, TOP_POSITION_IN_TEMPLATE, resizedCroppedCover.size.width, resizedCroppedCover.size.height)];
    
    resultImage = [resultImage applyEllipseMask];
    return resultImage;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    #define REVIEW_CELL_HEIGHT_WITHOUT_TEXT 97
    
    #define TEXT_MARGIN 20
    
    CGSize constraintSize = CGSizeMake(290.0f, MAXFLOAT);

    NSDictionary *reviewTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    NSDictionary *titleTextAttributes = nil;
    
    UITableViewCell *cell = nil;
    UILabel *titleLabel = nil;
    NSString *text = nil;
    
    CGFloat height = 0;
    
    switch (indexPath.section) {
        case kTableViewBookDetailsSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Book Info"];
            titleLabel = (UILabel*)[cell viewWithTag:kTableViewTagTitleLabel];
            titleTextAttributes = @{NSFontAttributeName:titleLabel.font};
            
            text = self.currentBook.name;
            height = cell.bounds.size.height - titleLabel.frame.size.height;
            height += [text boundingRectWithSize:constraintSize
                                         options:NSLineBreakByWordWrapping |NSStringDrawingUsesLineFragmentOrigin
                                      attributes:titleTextAttributes context:nil].size.height;
            break;
            
        case kTableViewBookReviewsSection:
            text = [[self.currentBook.reviews objectAtIndex:indexPath.row] text];

            height = REVIEW_CELL_HEIGHT_WITHOUT_TEXT;
            height += [text boundingRectWithSize:constraintSize
                                         options:NSLineBreakByWordWrapping |NSStringDrawingUsesLineFragmentOrigin
                                      attributes:reviewTextAttributes context:nil].size.height;
            height += TEXT_MARGIN;
            break;
    }
    
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
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

- (UIImage *)blankCoverImage
{
    if (!_blankCoverImage) {
        _blankCoverImage = [UIImage imageNamed:@"blankCover.png"];
    }
    
    return _blankCoverImage;
}

@end
