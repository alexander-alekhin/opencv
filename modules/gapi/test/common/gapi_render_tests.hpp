// This file is part of OpenCV project.
// It is subject to the license terms in the LICENSE file found in the top-level directory
// of this distribution and at http://opencv.org/license.html.
//
// Copyright (C) 2018 Intel Corporation


#ifndef OPENCV_GAPI_RENDER_TESTS_HPP
#define OPENCV_GAPI_RENDER_TESTS_HPP

#include "gapi_tests_common.hpp"
#include "api/render_priv.hpp"
#include "api/render_ocv.hpp"

namespace opencv_test {

using Prims = cv::gapi::wip::draw::Prims;
using Prim  = cv::gapi::wip::draw::Prim;

/** GTest parameter for Prims */
struct PrimsTestParam
{
    enum Value {
        RECTS,
        CIRCLES,
        LINES,
        MOSAICS,
        IMAGES,
        POLYGONS,
        TEXTS
    } val_;

    PrimsTestParam(Value val) : val_(val) {}
    void PrintTo(std::ostream* os) const
    {
        static const char* svals[] = { "RECTS", "CIRCLES", "LINES", "MOSAICS", "IMAGES", "POLYGONS", "TEXTS" };
        if (val_ >= 0 && val_ < (sizeof(svals) / sizeof(svals[0])))
            *os << svals[val_];
        else
            *os << "UNKNOWN(" << (int)val_ << ")";
    }

    Prims create()
    {
#define rect1 Prim{cv::gapi::wip::draw::Rect{cv::Rect{101, 101, 199, 199}, cv::Scalar{153, 172, 58},  1, LINE_8, 0}}
#define rect2 Prim{cv::gapi::wip::draw::Rect{cv::Rect{100, 100, 199, 199}, cv::Scalar{153, 172, 58},  1, LINE_8, 0}}
#define rect3 Prim{cv::gapi::wip::draw::Rect{cv::Rect{0  , 0  , 199, 199}, cv::Scalar{153, 172, 58},  1, LINE_8, 0}}
#define rect4 Prim{cv::gapi::wip::draw::Rect{cv::Rect{100, 100, 0, 199  }, cv::Scalar{153, 172, 58},  1,  LINE_8, 0}}
#define rect5 Prim{cv::gapi::wip::draw::Rect{cv::Rect{0  , -1 , 199, 199}, cv::Scalar{153, 172, 58},  1,  LINE_8, 0}}
#define rect6 Prim{cv::gapi::wip::draw::Rect{cv::Rect{100, 100, 199, 199}, cv::Scalar{153, 172, 58},  10, LINE_8, 0}}
#define rect7 Prim{cv::gapi::wip::draw::Rect{cv::Rect{100, 100, 200, 200}, cv::Scalar{153, 172, 58},  1, LINE_8, 0}}
#define box1  Prim{cv::gapi::wip::draw::Rect{cv::Rect{101, 101, 200, 200}, cv::Scalar{153, 172, 58}, -1, LINE_8, 0}}
#define box2  Prim{cv::gapi::wip::draw::Rect{cv::Rect{100, 100, 199, 199}, cv::Scalar{153, 172, 58},  -1, LINE_8, 0}}
#define rects Prims{rect1, rect2, rect3, rect4, rect5, rect6, rect7, box1, box2}

#define circle1 Prim{cv::gapi::wip::draw::Circle{cv::Point{200, 200}, 100, cv::Scalar{153, 172, 58}, 1, LINE_8, 0}}
#define circle2 Prim{cv::gapi::wip::draw::Circle{cv::Point{10, 30}  , 2  , cv::Scalar{153, 172, 58}, 1, LINE_8, 0}}
#define circle3 Prim{cv::gapi::wip::draw::Circle{cv::Point{75, 100} , 50 , cv::Scalar{153, 172, 58}, 5, LINE_8, 0}}
#define circles Prims{circle1, circle2, circle3}

#define line1 Prim{cv::gapi::wip::draw::Line{cv::Point{50, 50}, cv::Point{250, 200}, cv::Scalar{153, 172, 58}, 1, LINE_8, 0}}
#define line2 Prim{cv::gapi::wip::draw::Line{cv::Point{51, 51}, cv::Point{51, 100}, cv::Scalar{153, 172, 58}, 1, LINE_8, 0}}
#define lines Prims{line1, line2}

#define mosaic1 Prim{cv::gapi::wip::draw::Mosaic{cv::Rect{100, 100, 200, 200}, 5, 0}}
#define mosaics Prims{mosaic1}

#define image1 Prim{cv::gapi::wip::draw::Image{cv::Point(100, 100), cv::Mat(cv::Size(200, 200), CV_8UC3, cv::Scalar::all(255)),\
                                                                    cv::Mat(cv::Size(200, 200), CV_32FC1, cv::Scalar::all(1))}}

#define image2 Prim{cv::gapi::wip::draw::Image{cv::Point(100, 100), cv::Mat(cv::Size(200, 200), CV_8UC3, cv::Scalar::all(255)),\
                                                                    cv::Mat(cv::Size(200, 200), CV_32FC1, cv::Scalar::all(0.5))}}

#define image3 Prim{cv::gapi::wip::draw::Image{cv::Point(100, 100), cv::Mat(cv::Size(200, 200), CV_8UC3, cv::Scalar::all(255)),\
                                                                    cv::Mat(cv::Size(200, 200), CV_32FC1, cv::Scalar::all(0.0))}}

#define images Prims{image1, image2, image3}

#define polygon1 Prim{cv::gapi::wip::draw::Poly{ {cv::Point{100, 100}, cv::Point{50, 200}, cv::Point{200, 30}, cv::Point{150, 50} }, cv::Scalar{153, 172, 58}, 1, LINE_8, 0} }
#define polygons Prims{polygon1}

#define text1 Prim{cv::gapi::wip::draw::Text{"TheBrownFoxJump", cv::Point{100, 100}, FONT_HERSHEY_SIMPLEX, 2, cv::Scalar{102, 178, 240}, 1, LINE_8, false} }
#define texts Prims{text1}

        switch ((Value)val_)
        {
        case RECTS: return rects;
        case CIRCLES: return circles;
        case LINES: return lines;
        case MOSAICS: return mosaics;
        case IMAGES: return images;
        case POLYGONS: return polygons;
        case TEXTS: return texts;
        }
        CV_Error(Error::StsInternal, "");
    }
}; // PrimsTestParam
static inline void PrintTo(const PrimsTestParam& v, std::ostream* os) { v.PrintTo(os); }


using TestArgs = std::tuple<cv::Size, PrimsTestParam, cv::gapi::GKernelPackage>;

template<typename T>
class RenderWithParam : public testing::TestWithParam<T>
{
protected:
    void SetUp()
    {
        auto param = testing::TestWithParam<T>::GetParam();
        sz = get<0>(param);
        prims = get<1>(param).create();
        pkg = get<2>(param);

        MatType type = CV_8UC3;
        mat_ocv.create(sz, type);
        mat_gapi.create(sz, type);
        cv::randu(mat_ocv, cv::Scalar::all(0), cv::Scalar::all(255));
        mat_ocv.copyTo(mat_gapi);
    }

    cv::Size sz;
    std::vector<cv::gapi::wip::draw::Prim> prims;
    cv::gapi::GKernelPackage pkg;

    cv::Mat y_mat_ocv, uv_mat_ocv, y_mat_gapi, uv_mat_gapi, mat_ocv, mat_gapi;
};

struct RenderNV12 : public RenderWithParam<TestArgs>
{
    void ComputeRef()
    {
        cv::gapi::wip::draw::BGR2NV12(mat_ocv, y_mat_ocv, uv_mat_ocv);

        // NV12 -> YUV
        cv::Mat upsample_uv, yuv;
        cv::resize(uv_mat_ocv, upsample_uv, uv_mat_ocv.size() * 2, cv::INTER_LINEAR);
        cv::merge(std::vector<cv::Mat>{y_mat_ocv, upsample_uv}, yuv);

        cv::gapi::wip::draw::drawPrimitivesOCVYUV(yuv, prims);

        // YUV -> NV12
        std::vector<cv::Mat> chs(3);
        cv::split(yuv, chs);
        cv::merge(std::vector<cv::Mat>{chs[1], chs[2]}, uv_mat_ocv);
        y_mat_ocv = chs[0];
        cv::resize(uv_mat_ocv, uv_mat_ocv, uv_mat_ocv.size() / 2, cv::INTER_LINEAR);
    }
};

struct RenderBGR : public RenderWithParam<TestArgs>
{
    void ComputeRef()
    {
        cv::gapi::wip::draw::drawPrimitivesOCVBGR(mat_ocv, prims);
    }
};

} // opencv_test

#endif //OPENCV_GAPI_RENDER_TESTS_HPP
