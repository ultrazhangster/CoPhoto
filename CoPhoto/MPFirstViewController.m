//
//  MPFirstViewController.m
//  CoPhoto
//
//  Created by Yuduo Zhang on 7/di10/13.
//  Copyright (c) 2013 Yuduo Zhang. All rights reserved.
//

#import "MPFirstViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MPFirstViewController ()

@end

@implementation MPFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupAdvertiser
{
    MCPeerID *myPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    MCSession *session = [[MCSession alloc] initWithPeer:myPeerID];
    
    self.advertiserSession = session;
    
    self.advertiserSession.delegate = self;
    
    if (!self.assistant) {
        self.assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"yammer" discoveryInfo:nil session:self.advertiserSession];
    }
    
    NSLog(@"%@", self.assistant);
    
    [self.assistant start];
}

// Advertiser delegate methods
- (void)advertiserAssitantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    NSLog(@"advertiserAssitantWillPresentInvitation");
}

- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    NSLog(@"advertiserAssistantDidDismissInvitation");
}

- (void)setupBrowser
{
    if(!self.browserViewController) {
        MCPeerID *myPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
        MCSession *session = [[MCSession alloc] initWithPeer:myPeerID];
        
        self.browserSession = session;
        
        self.browserViewController = [[MCBrowserViewController alloc] initWithServiceType:@"yammer" session:session];
        self.browserViewController.delegate = self;
    }
    
    [self presentViewController:self.browserViewController animated:YES completion:nil];
    NSLog(@"%@", self.browserViewController);
}

// Browser VC delegate methods
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    NSLog(@"browserViewControllerDidFinish");
    
    [self.browserViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSArray *peerIDs = [self.browserViewController.session connectedPeers];
    
    NSURL *MyURL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"png"];
    
    for (MCPeerID *peerID in peerIDs) {
        [self.browserViewController.session sendResourceAtURL:MyURL
                                                     withName:@"HI"
                                                       toPeer:peerID
                                        withCompletionHandler:^(NSError *error) {
                                            
                                            NSLog(@"YOU DID IT");
        }];
    }
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    NSLog(@"browserViewControllerWasCancelled");
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

// Session delegate methods
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"peerID didChangeState %d", state);
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"didStartReceivingResourceWithName");
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"didReceiveData");
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"didReceiveStream");
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"didFinishReceivingResourceWithName");
    [self.imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:localURL]]];
}

- (IBAction)startBrowser:(id)sender
{
    [self setupAdvertiser];
    [self setupBrowser];
}
@end
