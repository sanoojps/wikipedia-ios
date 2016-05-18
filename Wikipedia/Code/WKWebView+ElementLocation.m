//  Created by Monte Hurd on 12/28/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "WKWebView+ElementLocation.h"

@implementation WKWebView (ElementLocation)

//- (CGPoint)getScreenCoordsForHtmlImageWithSrc:(NSString*)src {
//    NSString* strToEval =
//        [NSString stringWithFormat:@"window.elementLocation.getElementRectAsJson(window.elementLocation.getImageWithSrc('%@'));", src];
//    NSString* jsonString = [self stringByEvaluatingJavaScriptFromString:strToEval];
//    if (jsonString.length == 0) {
//        return CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
//    }
//    NSData* jsonData       = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError* error         = nil;
//    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
//    if (error) {
//        return CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
//    }
//    NSString* top  = (NSString*)jsonDict[@"top"];
//    NSString* left = (NSString*)jsonDict[@"left"];
//
//    void (^ zeroOutNulls)(NSString**) = ^(NSString** str){
//        if ([*str isMemberOfClass :[NSNull class]]) {
//            *str = @"0";
//        }
//    };
//    zeroOutNulls(&top);
//    zeroOutNulls(&left);
//
//    return CGPointMake(left.floatValue, top.floatValue);
//}

//- (CGPoint)getWebViewCoordsForHtmlImageWithSrc:(NSString*)src {
//    CGPoint p = [self getScreenCoordsForHtmlImageWithSrc:src];
//
//    return CGPointMake(
//        p.x + floor(self.scrollView.contentOffset.x),
//        p.y + floor(self.scrollView.contentOffset.y)
//        );
//}

- (void)getScreenRectForHtmlElementWithId:(NSString*)elementId completion:(void (^)(CGRect rect))completion {
    [self evaluateJavaScript:[NSString stringWithFormat:@"window.elementLocation.getElementRect(document.getElementById('%@'));", elementId]
           completionHandler:^(id _Nullable obj, NSError* _Nullable error) {
        if (!error && obj) {
            NSAssert([obj objectForKey:@"X"] &&
                     [obj objectForKey:@"Y"] &&
                     [obj objectForKey:@"Width"] &&
                     [obj objectForKey:@"Height"]
                     , @"Required keys missing from dictionary destined to be converted to a CGRect");
            CGRect rect;
            if (CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(obj), &rect)) {
                completion(rect);
                return;
            }
        }
        completion(CGRectNull);
    }];
}

- (void)getWebViewRectForHtmlElementWithId:(NSString*)elementId completion:(void (^)(CGRect rect))completion {
    [self getScreenRectForHtmlElementWithId:elementId completion:^(CGRect rect) {
        CGPoint p = CGPointMake(
            rect.origin.x + floor(self.scrollView.contentOffset.x),
            rect.origin.y + floor(self.scrollView.contentOffset.y)
            );
        rect.origin = p;
        completion(rect);
    }];
}

- (void)getIndexOfTopOnScreenElementWithPrefix:(NSString*)prefix count:(NSUInteger)count completion:(void (^)(id index, NSError* error))completion {
    [self evaluateJavaScript:[NSString stringWithFormat:@"window.elementLocation.getIndexOfFirstOnScreenElement('%@', %lu)", prefix, count]
           completionHandler:^(id _Nullable index, NSError* _Nullable error) {
        completion(index, error);
    }];
}

@end
