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

@interface IRReviewsAPI ()

@property (nonatomic, strong) IRHTTPClient *httpClient;
@property (nonatomic, strong) IRReviewsFetcher *reviewsFetcher;
@property (nonatomic, strong) IRPhotoPreparer *photoPreparer;

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

- (NSArray *)getBooksForPhoto:(UIImage *)photo
{
    #define IMG_JPEG_QUALITY 0.5f
    
    UIImage *imageToUpload = [self.photoPreparer prepareImageForRecognition:photo];
    NSData *imgData = UIImageJPEGRepresentation(imageToUpload, IMG_JPEG_QUALITY);
    NSLog(@"Image preprocessing completed. Sending %u kb", imgData.length / 1024);
    
    IRRecognitionResponse *response = [self.reviewsFetcher getResponseForJPEGRepresentation:imgData];
    NSLog(@"Response received: %d; confidence = %f", response.success, response.confidence);

    return response.books;
}

- (void)downloadCoverForBook:(IRBookDetails *)book
{
    @synchronized(book.coverImage)
    {
        if (!book.coverImage && book.coverUrl.length > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [self.httpClient downloadImage:book.coverUrl];

                dispatch_sync(dispatch_get_main_queue(), ^{
                    book.coverImage = image;
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

@end
