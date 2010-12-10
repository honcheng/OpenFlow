/**
 * Copyright (c) 2009 Alex Fajkowski, Apparent Logic LLC
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
#import "AFOpenFlowViewController.h"
#import "UIImageExtras.h"
#import "AFGetImageOperation.h"
#import "SBJSON.h"

@implementation AFOpenFlowViewController
@synthesize imageInfoArray;

- (void)dealloc {
	[self.imageInfoArray release];
	[loadImagesOperationQueue release];
	[interestingPhotosDictionary release];
	
    [super dealloc];
}

- (void)awakeFromNib {
	
	loadImagesOperationQueue = [[NSOperationQueue alloc] init];
	
	NSString *jsonFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"sample.json"];
	NSString *jsonString = [NSString stringWithContentsOfFile:jsonFilePath encoding:NSUTF8StringEncoding error:nil];
	SBJSON *jsonParser = [SBJSON new];
	id response = [jsonParser objectWithString:jsonString];
	[jsonParser release];
	if (response)
	{
		self.imageInfoArray = [response objectForKey:@"images"];
	}
	[(AFOpenFlowView *)self.view setNumberOfImages:[self.imageInfoArray count]];
}

- (IBAction)infoButtonPressed:(id)sender {
	
	UIAlertView *alertView = [[UIAlertView alloc] init];
	[alertView setTitle:@"About OpenFlow"];
	[alertView setMessage:@"The original OpenFlow code was from https://github.com/thefaj/OpenFlow. I just modified it to remove Flickr"];
	[alertView addButtonWithTitle:@"Dismiss"];
	[alertView show];
	[alertView release];
}

- (void)imageDidLoad:(NSArray *)arguments {
	UIImage *loadedImage = (UIImage *)[arguments objectAtIndex:0];
	NSNumber *imageIndex = (NSNumber *)[arguments objectAtIndex:1];
	
	// Only resize our images if they are coming from Flickr (samples are already scaled).
	// Resize the image on the main thread (UIKit is not thread safe).
	//if (interestingnessRequest)
	//	loadedImage = [loadedImage cropCenterAndScaleImageToSize:CGSizeMake(225, 225)];

	[(AFOpenFlowView *)self.view setImage:loadedImage forIndex:[imageIndex intValue]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (UIImage *)defaultImage {
	return [UIImage imageNamed:@"default.png"];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
	AFGetImageOperation *getImageOperation = [[AFGetImageOperation alloc] initWithIndex:index viewController:self];

	if (self.imageInfoArray) {
		NSURL *photoURL = [NSURL URLWithString:[[self.imageInfoArray objectAtIndex:index] objectForKey:@"img_path"]];
		getImageOperation.imageURL = photoURL;
	}
	
	[loadImagesOperationQueue addOperation:getImageOperation];
	[getImageOperation release];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index 
{
	NSLog(@"Cover Flow selection did change to %d", index);
}

- (NSString*)openFlowView:(AFOpenFlowView *)openFlowView titleForIndex:(int)index 
{
	return [[self.imageInfoArray objectAtIndex:index] objectForKey:@"title"];
}

@end