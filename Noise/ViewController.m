//
//  SCViewController.m
//  Noise
//
//  Created by Gregory Wieber on 1/25/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "ViewController.h"
#import <TheAmazingAudioEngine.h>

@interface ViewController ()

@property (nonatomic, strong) AEAudioController *audioController; // The Amazing Audio Engine
@property (nonatomic, strong) AEBlockChannel *noiseChannel; // our noise 'generator'

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Seed our random number generator
    srand48(time(0));
    
    // We'll be working with floating point samples.
    AudioStreamBasicDescription audioFormat = [AEAudioController nonInterleavedFloatStereoAudioDescription];
    
    // Setup the Amazing Audio Engine:
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:audioFormat];
    
    // Create a channel of audio. At runtime, Core Audio will call the block every time it needs
    // samples.
    AEBlockChannel *noiseChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        
        // We find out how many buffers we have. (Non-Interleaved Stereo formats will
        // should have two -- one for left one for right)
        UInt32 numberOfBuffers = audio->mNumberBuffers;
        
        // iterate over the buffers
        for (int i = 0; i < numberOfBuffers; i++) {
            
            // Tell the buffer how big it needs to be. (frames == samples)
            audio->mBuffers[i].mDataByteSize = frames * sizeof(float);
            
            // Get a pointer to our output. We'll write samples here, and we'll hear
            // those samples through the speaker.
            float *output = (float *)audio->mBuffers[i].mData;
            
            // Compute the samples
            for (int j = 0; j < frames; j++) {
                // Filling out random values will give us noise:
                output[j] = (float)drand48();
                
            }
            
        }
    }];
    
    // Turn down the volume on the channel, so the noise isn't too loud
    [noiseChannel setVolume:.35];
    
    // Add the channel to the audio controller
    [self.audioController addChannels:@[noiseChannel]];
    
    // Hold onto the noiseChannel
    self.noiseChannel = noiseChannel;
    
    // Turn on the audio controller
    NSError *error = NULL;
    [self.audioController start:&error];
    
    if (error) {
        NSLog(@"There was an error starting the controller: %@", error);
    }
}

@end
