//
//  UIBezierPath+ForEachElement.m
//  Knob
//
//  Created by Jelle Vandenbeeck on 28/03/15.
//  Copyright (c) 2015 Jelle Vandenbeeck. All rights reserved.
//

#import "UIBezierPath+ForEachElement.h"

typedef void (^UIBezierPath_forEachElement_Block)(CGPathElement const *element);

@implementation UIBezierPath (forEachElement)

static void applyBlockToPathElement(void *info, CGPathElement const *element) {
    __unsafe_unretained UIBezierPath_forEachElement_Block block =(__bridge  UIBezierPath_forEachElement_Block)info;
    block(element);
}

- (void)forEachElement:(void (^)(const CGPathElement *))block {
    CGPathApply(self.CGPath, (__bridge void *)block, applyBlockToPathElement);
}

@end
