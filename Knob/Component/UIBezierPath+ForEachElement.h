//
//  UIBezierPath+ForEachElement.h
//  Knob
//
//  Created by Jelle Vandenbeeck on 28/03/15.
//  Copyright (c) 2015 Jelle Vandenbeeck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (ForEachElement)

- (void)forEachElement:(void (^)(CGPathElement const *element))block;

@end
