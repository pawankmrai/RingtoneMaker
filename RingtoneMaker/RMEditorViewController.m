//
//  RMEditorViewController.m
//  RingtoneMaker
//
//  Created by Sandeep Nasa on 2/19/13.
//  Copyright (c) 2013 Pawan Rai. All rights reserved.
//

#import "RMEditorViewController.h"

@interface RMEditorViewController ()
{

    NSTimer *currentTimer;
}
@property (strong, nonatomic) RangeSlider *slider;
@property (strong, nonatomic) IBOutlet UIImageView *playerHeaderMark;
@property (strong, nonatomic) IBOutlet UIView *highlightView;

@property (strong, nonatomic) IBOutlet UIView *sliderHoldView;
@property (strong, nonatomic) IBOutlet UILabel *seekLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *waveScrollView;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property(strong, nonatomic) AVPlayer *RMPlayer;
- (IBAction)showMediaPicker:(id)sender;
- (IBAction)saveRingtone:(id)sender;
- (IBAction)playPause:(id)sender;
- (IBAction)showFileList:(id)sender;

@end

@implementation RMEditorViewController
@synthesize RMPlayer;
@synthesize playPauseButton;
@synthesize waveScrollView;
@synthesize seekLabel;
@synthesize sliderHoldView;
@synthesize playerHeaderMark;
@synthesize highlightView;
@synthesize slider;
@synthesize playUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self playMusicFile:playUrl];

	// Do any additional setup after loading the view.
    UIImage *bubbleImage=[UIImage imageNamed:@"audioBubble.png"];
    UIImageView *waveImageView=[[UIImageView alloc ] initWithFrame:waveScrollView.bounds];
    [waveImageView setImage:bubbleImage];
    [waveScrollView addSubview:waveImageView];
    [waveScrollView setContentSize:CGSizeMake(bubbleImage.size.width, bubbleImage.size.height)];
    
   
    //CGRect frame=CGRectMake(3, 239, 300, 23);
    slider=  [[RangeSlider alloc] initWithFrame:sliderHoldView.bounds];
    slider.minimumValue = 1;
    slider.selectedMinimumValue = 0;
    slider.maximumValue = 100;
    slider.selectedMaximumValue = 10;
    slider.minimumRange = 5;
    slider.maximumRange = 40;
    [slider addTarget:self action:@selector(updateRangeLabel:) forControlEvents:UIControlEventValueChanged];
    [self.sliderHoldView addSubview:slider];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMediaPicker:(id)sender {
   
    ////remove observer 
    if (RMPlayer!=nil) {
        [RMPlayer removeObserver:self forKeyPath:@"status" context:nil];
    }
    
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    mediaPicker.delegate = self;
    //mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.prompt = @"Select songs to play";
    [self presentModalViewController:mediaPicker animated:YES];
}
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{

    if (mediaItemCollection) {
        
        playUrl=[mediaItemCollection.representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
        NSLog(@"url---%@", playUrl);
        [self playMusicFile:playUrl];
    }
    [self dismissModalViewControllerAnimated: YES];  
}
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissModalViewControllerAnimated: YES];
}

-(void)playMusicFile:(NSURL *)musicURL{

    AVAsset *asset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
    AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
    
    RMPlayer = [AVPlayer playerWithPlayerItem:anItem];
    
    [RMPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == RMPlayer && [keyPath isEqualToString:@"status"]) {
        if (RMPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
        } else if (RMPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayer Ready to Play");
        } else if (RMPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
        }
    }
       
    currentTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}
-(void)onTimer:(NSTimer *)timer{

    AVPlayerItem *currentItem = RMPlayer.currentItem;
    CMTime totalDuration = currentItem.duration; //total time
    CMTime currentTime = currentItem.currentTime; //playing time
    
    //////////////current time ////////////////////////////////////////
    long currentPlaybackTime=currentTime.value/currentTime.timescale;
	int currentHours = (currentPlaybackTime / 3600);
	int currentMinutes = ((currentPlaybackTime / 60) - currentHours*60);
	int currentSeconds = (currentPlaybackTime % 60);
    NSString *currentString=[NSString stringWithFormat:@"Current Time:-%i:%02d:%02d", currentHours, currentMinutes, currentSeconds];
    
    //////////////total time ////////////////////////////////////////
    long totalPlaybackTime=totalDuration.value/totalDuration.timescale;
	int totalHours = (totalPlaybackTime / 3600);
	int totalMinutes = ((totalPlaybackTime / 60) - totalHours*60);
	int totalSeconds = (totalPlaybackTime % 60);
    NSString *totalDurationString=[NSString stringWithFormat:@"Total Time:-%i:%02d:%02d", totalHours, totalMinutes, totalSeconds];
    
    
	self.seekLabel.text = [NSString stringWithFormat:@"  %@------------%@",currentString,totalDurationString];

    
    float xM=currentPlaybackTime;
    [playerHeaderMark setFrame:CGRectMake(xM, playerHeaderMark.frame.origin.y, playerHeaderMark.bounds.size.width, playerHeaderMark.bounds.size.height)];
}

-(void)playPauseToggle:(NSInteger )tag{
    
   // NSLog(@"tag--%d",tag);

    if (tag==1) {
        [playPauseButton setImage:[UIImage imageNamed:@"button-pause"] forState:UIControlStateNormal];
        [playPauseButton setTag:2];
    }
    else if (tag==2){
    
        [playPauseButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateNormal];
        [playPauseButton setTag:1];
    }
    
}
- (IBAction)playPause:(id)sender {
    
    if ([sender tag]==1) {
        [RMPlayer play];
    }
    else if ([sender tag]==2){
    
        [RMPlayer pause];
    }
    [self playPauseToggle:[sender tag]];
}


- (IBAction)showFileList:(id)sender {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *fileEnumerator = [manager enumeratorAtPath:documentsPath];
    
    for (NSString *filename in fileEnumerator) {
        // Do something with file
        NSLog(@"file name---%@", filename);
    }

}

- (NSString *)documentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return documentPath;
}


- (IBAction)saveRingtone:(id)sender {
    
    //NSString *path=@"ipod-library://item/item.mp3?id=-6716130163078444151";
    
    AVPlayerItem *currentItem = RMPlayer.currentItem;
    NSArray *metadataList = [currentItem.asset commonMetadata];
    NSString *fileName;
    NSString * newFilePath;
    for (AVMetadataItem *metaItem in metadataList) {
        
        //NSLog(@"%@",[metaItem commonKey]);
        // NSLog(@"title---%@",[metaItem valueForKey:@"value"]);
        
        if ([[metaItem commonKey] isEqualToString:@"title"]) {
            fileName = (NSString *)[metaItem value];
            NSLog(@" title : %@", (NSString *)[metaItem value]);
        }
    }
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString* foofile = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4r",fileName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    if (fileExists) {
        
        int r = arc4random() % 100;
        fileName=[NSString stringWithFormat:@"%@,%d",fileName,r];
        NSLog(@"mod file--%@", fileName);
        newFilePath = [[self documentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4r",fileName]];
        
    }else{
        
         newFilePath = [[self documentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4r",fileName]];
        
    }
    
    AVAsset *asset=[AVAsset assetWithURL:playUrl];       
    CMTime currentTime = currentItem.currentTime; //playing time
    [self exportAsset:asset toFilePath:newFilePath withTime:currentTime];
}

- (BOOL)exportAsset:(AVAsset *)avAsset toFilePath:(NSString *)filePath withTime:(CMTime )currentTime{
    
    // we need the audio asset to be at least 50 seconds long for this snippet
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    if (duration < 50.0) return NO;
    
    // get the first audio track
    NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    if ([tracks count] == 0) return NO;
    
    AVAssetTrack *track = [tracks objectAtIndex:0];
    
    // create the export session
    // no need for a retain here, the session will be retained by the
    // completion handler since it is referenced there
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:avAsset
                                           presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession) return NO;
    
    // create trim time range - 20 seconds starting from 30 seconds into the asset
    //CMTime startTime = CMTimeMake(30, 1);
    CMTime startTime = currentTime;
    CMTime stopTime = CMTimeMake(50, 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    // create fade in time range - 10 seconds starting at the beginning of trimmed asset
    CMTime startFadeInTime = startTime;
    CMTime endFadeInTime = CMTimeMake(40, 1);
    CMTimeRange fadeInTimeRange = CMTimeRangeFromTimeToTime(startFadeInTime,
                                                            endFadeInTime);
    
    // setup audio mix
    AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *exportAudioMixInputParameters =
    [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    
    [exportAudioMixInputParameters setVolumeRampFromStartVolume:0.0 toEndVolume:1.0
                                                      timeRange:fadeInTimeRange];
    exportAudioMix.inputParameters = [NSArray
                                      arrayWithObject:exportAudioMixInputParameters];
    
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPath:filePath]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    exportSession.timeRange = exportTimeRange; // trim time range
    exportSession.audioMix = exportAudioMix; // fade in audio mix
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %d", exportSession.status);
        }
    }];
    
    return YES;
}

- (void)viewDidUnload {
    [self setPlayPauseButton:nil];
    [self setWaveScrollView:nil];
    [self setSeekLabel:nil];
    [self setSliderHoldView:nil];
    [self setPlayerHeaderMark:nil];
    [self setHighlightView:nil];
    [super viewDidUnload];
}
@end
