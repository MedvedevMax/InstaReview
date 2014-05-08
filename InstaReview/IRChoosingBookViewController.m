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
#import "UIImage+WhiteColorTransparent.h"

@interface IRChoosingBookViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation IRChoosingBookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (IRBookDetails *book in self.books) {
        [book addObserver:self forKeyPath:@"coverImage" options:NSKeyValueObservingOptionNew context:nil];
        [[IRReviewsAPI sharedInstance] downloadCoverForBook:book];
    }
    
    switch (self.kind) {
        case kChoosingBookViewControllerDidYouMean:
            self.navigationItem.title = NSLocalizedString(@"Did you mean...", @"'did you mean' navigation bar title");
            self.navigationItem.rightBarButtonItem = nil;
            
            self.view.backgroundColor = [UIColor whiteColor];
            break;
        case kChoosingBookViewControllerHistory:
            self.navigationItem.title = NSLocalizedString(@"Recently viewed", @"'recents' navigation bar title");
            self.navigationItem.rightBarButtonItem = self.doneButton;

            self.view.backgroundColor = [UIColor clearColor];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)dealloc
{
    for (IRBookDetails *book in self.books) {
        [book removeObserver:self forKeyPath:@"coverImage"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"coverImage"]) {
        if ([self.books containsObject:object]) {
            [self.tableView reloadRowsAtIndexPaths:
                    @[[NSIndexPath indexPathForRow:[self.books indexOfObject:object] inSection:0]]
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
    return [self.books count];
}

#define COVER_WIDTH     40
#define COVER_HEIGHT    60
#define CELL_BORDER     10

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Book Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Assigning background view
    if (!cell.backgroundView) {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7f];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    // Assigning book info
    IRBookDetails *book = [self.books objectAtIndex:indexPath.row];
    cell.textLabel.text = book.name;
    cell.detailTextLabel.text = book.author;
    
    if (cell.imageView.image == nil) {
        if (book.coverImage) {
            cell.imageView.image = [[book.coverImage resizedImage:CGSizeMake(COVER_WIDTH, COVER_HEIGHT) interpolationQuality:kCGInterpolationHigh] makeWhiteColorTransparent];
        }
        else {
            cell.imageView.image = [[UIImage imageNamed:@"blankCover.png"] resizedImage:CGSizeMake(COVER_WIDTH, COVER_HEIGHT) interpolationQuality:kCGInterpolationHigh];
        }
    }
    else {
        if (book.coverImage && cell.imageView.image != book.coverImage) {
            [UIView transitionWithView:cell.imageView
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                cell.imageView.image = [[book.coverImage resizedImage:CGSizeMake(COVER_WIDTH, COVER_HEIGHT) interpolationQuality:kCGInterpolationHigh] makeWhiteColorTransparent];
                            } completion:nil];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return COVER_HEIGHT + CELL_BORDER;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.kind == kChoosingBookViewControllerHistory;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        IRBookDetails *bookToRemove = [self.books objectAtIndex:indexPath.row];
        [self removeBookFromHistory:bookToRemove];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)removeBookFromHistory:(IRBookDetails *)book
{
    [[IRReviewsAPI sharedInstance] removeBookFromViewed:book];
    [book removeObserver:self forKeyPath:@"coverImage"];
    
    self.books = [[IRReviewsAPI sharedInstance] getAllViewedBooks];
}

#pragma mark - Navigation
- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // remove "back" button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([segue.identifier isEqualToString:@"Show Book Details"]) {
        IRBookDetailsViewController *detailsVC = segue.destinationViewController;
        detailsVC.currentBook = [self.books objectAtIndex:[[self.tableView indexPathForCell:sender] row]];
    }
}

@end
