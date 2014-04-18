//
//  BookCropper.h
//  openCVTest
//
//  Created by Max Medvedev on 4/16/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#ifndef __openCVTest__BookCropper__
#define __openCVTest__BookCropper__

#include "opencv2/core/core.hpp"
#include "opencv2/imgproc/imgproc.hpp"

using namespace cv;
using namespace std;

class BookCropper {
public:
    Mat getBookImage(const Mat & src);
    
    const vector<vector<Point2i> > & getSquares() const {
        return squares;
    }
    
private:
    static double angle( Point2i pt1, Point2i pt2, Point2i pt0 );
    static float calcMaxCosine(const vector<Point2i> & square);
    static Size2i calcSquareSize(const vector<Point2i> & square);
    static Point2i getCenter(vector<Point2i> Point2is);
    static vector<Point2i> sortSquarePointsClockwise(vector<Point2i> square);
    static float distanceBetweenPoints(Point2i p1, Point2i p2);
    
    vector<vector<Point2i> > squares;
    cv::Mat getPaperAreaFromImage(cv::Mat image, std::vector<cv::Point2i> square, int width, int height);
    void findSquares(const Mat& image, vector<vector<Point2i> >& squares, int threshold);
};

#endif /* defined(__openCVTest__BookCropper__) */
