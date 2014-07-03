//
//  WeatherClient.m
//  Weather
//
//The MIT License (MIT)
//
//Copyright (c) <year> <copyright holders>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.
//

#import "WeatherClient.h"

@implementation WeatherClient

//Step 1 - Make this a singleton
+ (instancetype)sharedClient {
	static id sharedInstance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURL *tmpBaseURL = [NSURL URLWithString:kAPIBaseUrl];
		sharedInstance = [[self alloc] initWithBaseURL:tmpBaseURL];
	});
	
	return sharedInstance;
}

//Step 2 - creating a custom initializer
- (id)initWithBaseURL:(NSURL *)inURL
{
    self = [super init];
    if (self) {
        
		NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
		NSURLSession *tmpSession =   [NSURLSession sessionWithConfiguration:sessionConfig
																   delegate:self
															  delegateQueue:nil];
		self.session = tmpSession;
		self.baseURL = inURL;
    }
    return self;
}

#pragma mark --
#pragma mark - Public Instance Methods

//Step 3 - Start Creating a method that will take a location and return a completion block containing a weatherObserveration model instance, for now just create an empty weatherObservation class and include it.
- (void)getCurrentWeatherForLocation:(CLLocation *)location completion:(void(^)(WeatherObservation *weatherObservation, NSError *error))completion{
	if(location){
		
		NSString *getRequestParameters = [NSString stringWithFormat:@"conditions/q/%.6f,%.6f.json", location.coordinate.latitude, location.coordinate.longitude];
		NSURL *tmpRequestURL = [self.baseURL URLByAppendingPathComponent:getRequestParameters];
		WeatherClient *client = [WeatherClient sharedClient];
		NSURLSessionDataTask *dataTask = [client.session dataTaskWithURL:tmpRequestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			
			if(!error){
				NSDictionary *tmpDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
				
				WeatherObservation *tmpWeatherObservation = [WeatherObservation observationWithDictionary:tmpDictionary[@"current_observation"]];
				completion(tmpWeatherObservation, nil);
			}else{
				completion(nil,error);
			}
			
		}];
		[dataTask resume];
		
	}
}

//Step 7 - Later it will be useful to asynchronously load images, so this method will be needed
- (void)getImageWithURLString:(NSString *)inURL completion:(void(^)(UIImage *image, NSError *error))completion{
	if(inURL){
		NSURL *tmpURL = [NSURL URLWithString:inURL];
		WeatherClient *client = [WeatherClient sharedClient];
		NSURLSessionDownloadTask *downloadTask = [client.session downloadTaskWithURL:tmpURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
			
			if(error){
				NSLog(@"There was an error downloading the image");
				completion(nil,error);
			}else{
				UIImage *tmpImage = [[UIImage alloc] init];
				tmpImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
				completion(tmpImage,nil);
			}
		}];
		[downloadTask resume];
	}
	
}

@end
