//
//  IRReviewsAPI.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRReviewsAPI.h"

#import "IRReviewsFetcher.h"
#import "IRPhotoPreparer.h"
#import "IRHTTPClient.h"
#import "IRPersistencyManager.h"

#import "UIImage+Resize.h"
#import "UIImage+WhiteColorTransparent.h"

@interface IRReviewsAPI ()

@property (nonatomic, strong) IRHTTPClient *httpClient;
@property (nonatomic, strong) IRReviewsFetcher *reviewsFetcher;
@property (nonatomic, strong) IRPhotoPreparer *photoPreparer;
@property (nonatomic, strong) IRPersistencyManager *persistencyManager;

@property (strong) dispatch_queue_t gettingBooksTask;
@property (strong) dispatch_semaphore_t waitingSemaphore;

@property (strong) IRRecognitionResponse *recognitionResponse;
@end

@implementation IRReviewsAPI

+ (id)sharedInstance
{
    static IRReviewsAPI *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[IRReviewsAPI alloc] init];
    });
    return _sharedInstance;
}

- (void)beginGettingBooksForPhoto:(UIImage *)photo
{
    #define IMG_JPEG_QUALITY 0.5f
    
    if (self.gettingBooksTask) {
        self.gettingBooksTask = nil;
    }
    
    self.gettingBooksTask = dispatch_queue_create("Getting Books Queue", nil);
    dispatch_semaphore_t waitingSemaphore = dispatch_semaphore_create(0);
    self.waitingSemaphore = waitingSemaphore;
    
    dispatch_async(self.gettingBooksTask, ^{
        UIImage *imageToUpload = [self.photoPreparer prepareImageForRecognition:photo];
        NSData *imgData = UIImageJPEGRepresentation(imageToUpload, IMG_JPEG_QUALITY);
        NSLog(@"Image preprocessing completed. Sending %d kb", (int)(imgData.length / 1024));
        
        IRRecognitionResponse *response = [self.reviewsFetcher getResponseForJPEGRepresentation:imgData];
        NSLog(@"Response received: %d; confidence = %f", response.success, response.confidence);
        
        self.recognitionResponse = response;
        dispatch_semaphore_signal(waitingSemaphore);
    });
}

- (NSArray *)waitAndGetBooks
{
    if (!self.waitingSemaphore) {
        return nil;
    }
    
    dispatch_semaphore_wait(self.waitingSemaphore, DISPATCH_TIME_FOREVER);
    return self.recognitionResponse.books;
}

- (void)addBookToViewed:(IRBookDetails *)book
{
    [self.persistencyManager addBookToViewed:book];
}

- (void)removeBookFromViewed:(IRBookDetails *)book
{
    [self.persistencyManager removeBookFromViewed:book];
}

- (NSArray*)getAllViewedBooks
{
    return [self.persistencyManager getAllViewedBooks];
}

- (void)saveViewedBooksHistory
{
    [self.persistencyManager saveHistory];
}

- (void)downloadCoverForBook:(IRBookDetails *)book
{
    #define COVER_IMG_WIDTH 195
    #define COVER_IMG_HEIGHT 300
    @synchronized(book.coverImage)
    {
        if (!book.coverImage && book.coverUrl.length > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *coverImage = [self.httpClient downloadImage:book.coverUrl];

                // Resizing & saving aspect ratio
                double aspectRatioWidth = coverImage.size.width * (COVER_IMG_HEIGHT / coverImage.size.height);
                coverImage = [coverImage resizedImage:CGSizeMake(aspectRatioWidth, COVER_IMG_HEIGHT) interpolationQuality:kCGInterpolationDefault];
                
                // Cropping to desired size
                int xCrop = MAX(0, (aspectRatioWidth - COVER_IMG_WIDTH) / 2);
                coverImage = [coverImage croppedImage:CGRectMake(xCrop, 0, COVER_IMG_WIDTH, COVER_IMG_HEIGHT)];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    book.coverImage = coverImage;
                });
            });
        }
    }
}

#pragma mark - Properties lazy instantiation

- (IRHTTPClient*)httpClient
{
    if (!_httpClient) {
        _httpClient = [[IRHTTPClient alloc] init];
    }
    
    return _httpClient;
}

- (IRReviewsFetcher*)reviewsFetcher
{
    if (!_reviewsFetcher)
        _reviewsFetcher = [[IRReviewsFetcher alloc] init];
    
    return _reviewsFetcher;
}

- (IRPhotoPreparer *)photoPreparer
{
    if (!_photoPreparer) {
        _photoPreparer = [[IRPhotoPreparer alloc] init];
    }
    
    return _photoPreparer;
}

- (IRPersistencyManager *)persistencyManager
{
    if (!_persistencyManager) {
        _persistencyManager = [[IRPersistencyManager alloc] init];
    }
    
    return _persistencyManager;
}

@end
