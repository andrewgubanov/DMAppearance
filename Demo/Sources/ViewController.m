//
//  ViewController.m
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright (c) 2015 Andrew Gubanov. All rights reserved.
//

#import "ViewController.h"
#import "DMUIElipse.h"
#import "DMUISquare.h"
#import "DMObjectsRenderer.h"
#import "DMView.h"

@interface ViewController ()
@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    DMUIElipse *appearance = [DMUIElipse appearance];
    appearance.fillColor = [UIColor redColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DMUISquare *root = [[DMUISquare alloc] initWithCGFrame:self.view.bounds];
    root.fillColor = [UIColor blackColor];
    
    DMUIElipse *elipse = [[DMUIElipse alloc] initWithCGFrame:CGRectMake(100.0f, 100.0f, 40.f, 40.0f)]; //default fill color
    [root addChild:elipse];
    
    elipse = [[DMUIElipse alloc] initWithCGFrame:CGRectMake(200.0f, 100.0f, 40.f, 40.0f)];
    elipse.fillColor = [UIColor greenColor];
    [root addChild:elipse];
    
    DMObjectsRenderer *renderer = [[DMObjectsRenderer alloc] initWithRootObject:root];
    [(DMView *)self.view setRenderer:renderer];
}

@end
