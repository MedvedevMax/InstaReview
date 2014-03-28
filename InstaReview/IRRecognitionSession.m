//
//  IRRecognitionSession.m
//  InstaReview
//
//  Created by Max Medvedev on 3/29/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRRecognitionSession.h"
#import "IRHTTPClient.h"
#import "IRReviewsFetcher.h"

#import "MLIMGURUploader.h"
#import "UIImage+Resize.h"
#import "UIImage+Filters.h"

@interface IRRecognitionSession ()

@property (nonatomic, strong) IRReviewsFetcher *reviewsFetcher;

@property (nonatomic, strong) NSMutableArray *imageURLs;
@property (atomic) BOOL isCurrentlyPushing;

@end

@implementation IRRecognitionSession

#define IMGUR_CLIENT_ID @"abefe443c6d1bee"
#define IMG_JPEG_QUALITY 0.2f

- (void)pushPhoto:(UIImage *)image
{
    self.isCurrentlyPushing = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // preprocessing a photo
        UIImage *imageToUpload = [self prepareImageForRecognition:image];
        NSData *imgData = UIImageJPEGRepresentation(imageToUpload, IMG_JPEG_QUALITY);
        
        // uploading to "imgur"
        [MLIMGURUploader uploadPhoto:imgData
                               title:@"Book cover"
                         description:@"cover of some book"
                       imgurClientID:IMGUR_CLIENT_ID
                     completionBlock:^(NSString *imgURL) {
                         
                         NSLog(@"Image successfuly uploaded to: %@", imgURL);
                         [self.imageURLs addObject:imgURL];
                         self.isCurrentlyPushing = NO;
                         
                     } failureBlock:^(NSURLResponse *response, NSError *error, NSInteger status) {
                         NSLog(@"A problem occured while uploading image: %@", error);
                         self.isCurrentlyPushing = NO;
                     }];
    });
}

- (NSArray*)recognizeAndGetReviews
{
    // waiting for all uploads to be finished
    while (self.isCurrentlyPushing) {
        [NSThread sleepForTimeInterval:0.1f];
    }
    
    if (self.imageURLs.count == 0) {
        return nil;
    }
    
    NSMutableArray *responses = [[NSMutableArray alloc] init];
    
    // recognizing all photos simultaneously
    dispatch_group_t recognitionGroup = dispatch_group_create();
    for (NSString *imgURL in self.imageURLs) {
        dispatch_group_async(recognitionGroup,
                             dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                             ^{
                                 IRRecognitionResponse *response = [self.reviewsFetcher getResponseForCoverUrl:imgURL];
                                 if (response.success) {
                                     [responses addObject:response];
                                 }
                             });
    }
    
    dispatch_group_wait(recognitionGroup, DISPATCH_TIME_FOREVER);
    
    // finding most confindent result
    IRRecognitionResponse *bestResponse = nil;
    for (IRRecognitionResponse *response in responses) {
        if (!bestResponse ||
            response.confidence > bestResponse.confidence) {
            bestResponse = response;
        }
    }
    
    return bestResponse.books;
}

- (UIImage*)prepareImageForRecognition:(UIImage *)sourceImage
{
#define IMG_WIDTH                   288
#define IMG_HEIGHT                  384
#define WIDTH_BORDER_PERCENTAGE     12
#define HEIGHT_BORDER_PERCENTAGE    8
    
    // resising
    UIImage *newImage = [sourceImage resizedImage:CGSizeMake(IMG_WIDTH, IMG_HEIGHT)
                             interpolationQuality:kCGInterpolationHigh];
    
    // cropping
    int borderWidth = IMG_WIDTH * WIDTH_BORDER_PERCENTAGE / 100.0;
    int borderHeight = IMG_HEIGHT * HEIGHT_BORDER_PERCENTAGE / 100.0;
    newImage = [newImage croppedImage:CGRectMake(borderWidth, borderHeight,
                                                 IMG_WIDTH - borderWidth * 2, IMG_HEIGHT - borderHeight * 2)];
    
    // applying filters
    newImage = [newImage processImageForRecognition];
    
    return newImage;
}


#pragma mark - Properties lazy instantiation

- (IRReviewsFetcher*)reviewsFetcher
{
    if (!_reviewsFetcher)
        _reviewsFetcher = [[IRReviewsFetcher alloc] init];
    
    return _reviewsFetcher;
}

- (NSMutableArray *)imageURLs
{
    if (!_imageURLs) {
        _imageURLs = [[NSMutableArray alloc] init];
    }
    
    return _imageURLs;
}

@end
