//
//  RMViewController.m
//  RingtoneMaker
//
//  Created by Sandeep Nasa on 2/18/13.
//  Copyright (c) 2013 Pawan Rai. All rights reserved.
//

#import "RMViewController.h"
#import "RMEditorViewController.h"

@interface RMViewController ()

@property(strong,nonatomic) NSURL *tempUrl;
@end

@implementation RMViewController
@synthesize tempUrl;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)loadMusicPage:(id)sender {
    
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    mediaPicker.delegate = self;
    //mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.prompt = @"Select songs to play";
    [self presentModalViewController:mediaPicker animated:YES];
    
    //[self performSegueWithIdentifier:@"loadMusicPlayer" sender:sender];
    //[self performSegueWithIdentifier:@"loadPlayer" sender:sender];
}
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        
        tempUrl=[mediaItemCollection.representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
        NSLog(@"url---%@", tempUrl);
    }
    
    [self dismissModalViewControllerAnimated: YES];
    [self performSelector:@selector(switchController:) withObject:nil afterDelay:0.5];
    
}
-(void)switchController:(id)sender{

    [self performSegueWithIdentifier:@"loadMusicPlayer" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([[segue identifier] isEqualToString: @"loadMusicPlayer"]) {
        
        RMEditorViewController *vc=segue.destinationViewController;
        vc.playUrl=tempUrl;        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
