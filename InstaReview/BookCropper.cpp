//
//  BookCropper.cpp
//  openCVTest
//
//  Created by Max Medvedev on 4/16/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#include "BookCropper.h"
#include <math.h>

#define START_THREASHOLD 1
#define END_THREASHOLD 8

#define BEST_APPROX_AREA 0.65
#define BEST_SCALE_FACTOR_X 6
#define BEST_SCALE_FACTOR_Y 9

#define ENOUGH_GOODNESS 0.7

#define TRANSFORMED_IMAGE_HEIGHT 300

cv::Mat BookCropper::getBookImage(const cv::Mat &src)
{
    squares.clear();
    for (int thresh = START_THREASHOLD; thresh <= END_THREASHOLD; thresh++) {
        findSquares(src, squares, thresh);
    }
    
    const float best_scale_factor = (float)BEST_SCALE_FACTOR_X / BEST_SCALE_FACTOR_Y;
    
    vector<Point> bestSquare;
    float bestGoodness = 0;
    float bestSquareScaleFactor = 0;
    
    float imgArea = src.rows * src.cols;
    vector<vector<Point> >::iterator it;
    for (it = squares.begin(); it != squares.end(); it++) {
        float approxArea = fabs(contourArea(*it)) / imgArea;
        if (approxArea < 0.4) continue;
        
        float maxCos = calcMaxCosine(*it);
        
        Size2f size = calcSquareSize(*it);
        float scaleFactor = size.width / size.height;
        
        float isBestArea = (1.0 - fabs(BEST_APPROX_AREA - approxArea) / MAX(BEST_APPROX_AREA, 1 - BEST_APPROX_AREA));
        float isBestCos = (1.0 - maxCos / 0.2);
        float isBestScaleFactor = (1.0 - fabs(best_scale_factor - scaleFactor) / MAX(best_scale_factor, 1 - best_scale_factor));
        
        float goodness = isBestArea * 0.5 + isBestCos * 0.2 + isBestScaleFactor * 0.3;
        
        //cout << isBestArea << "," << isBestCos << "," << isBestScaleFactor << " : " << goodness << endl;
        if (goodness > bestGoodness) {
            bestSquare = *it;
            bestGoodness = goodness;
            bestSquareScaleFactor = scaleFactor;
        }
    }
    
    if (bestGoodness < ENOUGH_GOODNESS) {
        float scaleCoef = sqrt(BEST_APPROX_AREA / (BEST_SCALE_FACTOR_X * BEST_SCALE_FACTOR_Y));
        int bestSqWidth = (int)(BEST_SCALE_FACTOR_X * scaleCoef * src.cols);
        int bestSqHeight = (int)(BEST_SCALE_FACTOR_Y * scaleCoef * src.cols);
        
        bestSquare = vector<Point>();
        bestSquare.push_back(Point(src.cols / 2 - bestSqWidth / 2, src.rows / 2 - bestSqHeight / 2));
        bestSquare.push_back(Point(src.cols / 2 + bestSqWidth / 2, src.rows / 2 - bestSqHeight / 2));
        bestSquare.push_back(Point(src.cols / 2 + bestSqWidth / 2, src.rows / 2 + bestSqHeight / 2));
        bestSquare.push_back(Point(src.cols / 2 - bestSqWidth / 2, src.rows / 2 + bestSqHeight / 2));
        bestSquareScaleFactor = best_scale_factor;
    }
    
    Mat transformed = getPaperAreaFromImage(src, bestSquare,
                                            (int)(TRANSFORMED_IMAGE_HEIGHT * bestSquareScaleFactor),
                                            TRANSFORMED_IMAGE_HEIGHT);
    return transformed;
}

void BookCropper::findSquares(const Mat& image, vector<vector<Point> >& squares, int threshold)
{
    Mat blurred, hsl, gray0(image.size(), CV_8U), gray;
    GaussianBlur(image, blurred, Size(7, 7), 2.0, 2.0);
    
    vector<vector<Point> > contours;
    cv::cvtColor(blurred, hsl, CV_RGB2Lab);
    
    cv::Mat hslChannels[3];
    cv::split(hsl, hslChannels);
    
    gray0 = hslChannels[0];
    Canny(gray0, gray, threshold * 50, threshold * 100, 5);
    dilate(gray, gray, Mat(), Point(-1,-1), 3);
    
    findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
    for (size_t i = 0; i < contours.size(); i++) {
        if (fabs(contourArea(contours[i])) > 5000) {
            convexHull(contours[i], contours[i]);
            
            vector<Point> approx;
            approxPolyDP(Mat(contours[i]), approx, arcLength(Mat(contours[i]), true)*0.02, true);
            
            if (approx.size() == 4) {
                if (calcMaxCosine(approx) < 0.2) {
                    squares.push_back(approx);
                }
            }
        }
    }
}

double BookCropper::angle( Point pt1, Point pt2, Point pt0 )
{
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

float BookCropper::calcMaxCosine(const vector<Point> & square)
{
    double maxCosine = 0;
    
    for( int j = 2; j < 5; j++ )
    {
        // find the maximum cosine of the angle between joint edges
        double cosine = fabs(angle(square[j%4], square[j-2], square[j-1]));
        maxCosine = MAX(maxCosine, cosine);
    }
    return maxCosine;
}

Size BookCropper::calcSquareSize(const vector<Point> & square)
{
    float width_1 = (fabs(square[1].x - square[0].x) + fabs(square[3].x - square[2].x)) / 2.0;
    float height_1 = (fabs(square[2].y - square[1].y) + fabs(square[3].y - square[0].y)) / 2.0;
    
    float width_2 = (fabs(square[3].x - square[0].x) + fabs(square[2].x - square[1].x)) / 2.0;
    float height_2 = (fabs(square[1].y - square[0].y) + fabs(square[2].y - square[3].y)) / 2.0;
    
    return Size2f(MAX(width_1, width_2), MAX(height_1, height_2));
}

cv::Point BookCropper::getCenter( std::vector<cv::Point> points )
{
    cv::Point center = cv::Point( 0.0, 0.0 );
    
    for( size_t i = 0; i < points.size(); i++ ) {
        center.x += points[ i ].x;
        center.y += points[ i ].y;
    }
    
    center.x = center.x / points.size();
    center.y = center.y / points.size();
    
    return center;
}

std::vector<cv::Point> BookCropper::sortSquarePointsClockwise(std::vector<cv::Point> square)
{
    cv::Point center = getCenter( square );
    
    std::vector<cv::Point> sorted_square;
    for( size_t i = 0; i < square.size(); i++ ) {
        if ( (square[i].x - center.x) < 0 && (square[i].y - center.y) < 0 ) {
            switch( i ) {
                case 0:
                    sorted_square = square;
                    break;
                case 1:
                    sorted_square.push_back( square[1] );
                    sorted_square.push_back( square[2] );
                    sorted_square.push_back( square[3] );
                    sorted_square.push_back( square[0] );
                    break;
                case 2:
                    sorted_square.push_back( square[2] );
                    sorted_square.push_back( square[3] );
                    sorted_square.push_back( square[0] );
                    sorted_square.push_back( square[1] );
                    break;
                case 3:
                    sorted_square.push_back( square[3] );
                    sorted_square.push_back( square[0] );
                    sorted_square.push_back( square[1] );
                    sorted_square.push_back( square[2] );
                    break;
            }
            break;
        }
    }
    
    return sorted_square;
    
}

float BookCropper::distanceBetweenPoints( cv::Point p1, cv::Point p2 )
{
    if( p1.x == p2.x ) {
        return abs( p2.y - p1.y );
    }
    else if( p1.y == p2.y ) {
        return abs( p2.x - p1.x );
    }
    else {
        float dx = p2.x - p1.x;
        float dy = p2.y - p1.y;
        return sqrt( (dx*dx)+(dy*dy) );
    }
}

cv::Mat BookCropper::getPaperAreaFromImage(cv::Mat image, std::vector<cv::Point> square, int width, int height)
{
    // declare used vars
    cv::Point2f imageVertices[4];
    int scaleFactor;
    cv::Mat paperImage;
    cv::Mat paperImageCorrected;
    cv::Point2f paperVertices[4];
    
    // sort square corners for further operations
    square = BookCropper::sortSquarePointsClockwise( square );
    
    // rearrange to get proper order for getPerspectiveTransform()
    imageVertices[0] = square[0];
    imageVertices[1] = square[1];
    imageVertices[2] = square[3];
    imageVertices[3] = square[2];
    
    scaleFactor = 1;
    paperImage = cv::Mat( height*scaleFactor, width*scaleFactor, CV_8UC3 );
    paperVertices[0] = cv::Point( 0, 0 );
    paperVertices[1] = cv::Point( width*scaleFactor, 0 );
    paperVertices[2] = cv::Point( 0, height*scaleFactor );
    paperVertices[3] = cv::Point( width*scaleFactor, height*scaleFactor );
    
    cv::Mat warpMatrix = getPerspectiveTransform( imageVertices, paperVertices );
    cv::warpPerspective(image, paperImage, warpMatrix, paperImage.size(), cv::INTER_LINEAR, cv::BORDER_CONSTANT );
    
    return paperImage;
}