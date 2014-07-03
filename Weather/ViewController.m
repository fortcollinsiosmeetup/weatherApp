//
//  ViewController.m
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

#import "ViewController.h"
#import "WeatherClient.h"
#import "LocationManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//Step 16 - fill out the view did load with visual customization and start location manager updates
	__weak ViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"locationManagerlocationDidChange"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"Note: %@", note);
                                                      [weakSelf reloadWeatherData];
                                                  }];
	
    [[LocationManager sharedManager] startMonitoringLocationChanges];
	self.navigationController.title = @"Awesome Weather";
	
	self.title = @"Awesome Weather";
	UIBarButtonItem *button = [[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
							   target:self
							   action:@selector(reloadWeatherData)];
	self.navigationItem.rightBarButtonItem = button;
	
	
	self.containerView.backgroundColor = [UIColor colorWithRed:255.0f/255 green:255.0f/255 blue:255.0f/255 alpha:0.8f];
	self.containerView.layer.cornerRadius = 5.0f;
	
	// drop shadow
	[self.containerView.layer setShadowColor:[UIColor blackColor].CGColor];
	[self.containerView.layer setShadowOpacity:0.3];
	[self.containerView.layer setShadowRadius:3.0];
	
	self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
	self.indicator.center = self.view.center;
	[self.view addSubview:self.indicator];
	[self.indicator bringSubviewToFront:self.view];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
	
	
	self.locationLabel.text = @"";
	self.currentTempLabel.text = @"Now 0°F (0°C)";
	self.feelsLikeTempLabel.text = @"Feels Like 0°F (0°C)";
	self.weatherDescriptionLabel.text = @"";
	self.windDescriptionLabel.text = @"";
	self.humidityLabel.text = @"0 %";
	self.dewpointLabel.text = @"0";
	self.lastUpdateLabel.text = @"";
	
	[self.indicator stopAnimating];


}
//Step 17  - Create a method to handle refreshing the weather data
- (void)reloadWeatherData{
	
	LocationManager *locationManager = [LocationManager sharedManager];
	CLLocation *location = locationManager.currentLocation;
	WeatherClient *tmpClient = [WeatherClient sharedClient];
	
	if(location == nil){
		UIAlertView *noLocationAvailableAlert = [[UIAlertView alloc] initWithTitle:@"No Location Value" message:@"Location Services doesn't yet have your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noLocationAvailableAlert show];
		
		return;
	}
	[self.indicator startAnimating];
	__weak ViewController *weakSelf = self;
	[tmpClient getCurrentWeatherForLocation:location completion:^(WeatherObservation *weatherObservation, NSError *error) {
		if(error){
			NSLog(@"There was a retreival error");
		}else{
			[self updateUIWithWeatherObservation:weatherObservation];
		}
		[weakSelf.indicator stopAnimating];
	}];
}


//Step 18 - Create a method to update the UI when a weatherObservation is retrieved
- (void)updateUIWithWeatherObservation:(WeatherObservation *)inWeatherObservation{
	
	self.locationLabel.text = inWeatherObservation.location[@"City"];
	self.currentTempLabel.text = [NSString stringWithFormat:@"Now %d °F (%d °C)",[inWeatherObservation.temperatureF integerValue],[inWeatherObservation.temperatureC integerValue]];
	self.feelsLikeTempLabel.text = [NSString stringWithFormat:@"Feels like %d °f (%d °C)",[inWeatherObservation.feelsLikeTemperatureF integerValue],[inWeatherObservation.feelsLikeTemperatureC integerValue]];
	self.weatherDescriptionLabel.text = inWeatherObservation.weatherDescription;
	self.windDescriptionLabel.text = inWeatherObservation.windDescription;
	self.humidityLabel.text = inWeatherObservation.relativeHumidity;
	self.dewpointLabel.text = inWeatherObservation.dewpointDescription;
	self.lastUpdateLabel.text = inWeatherObservation.timeString;
	self.locationLabel.text = [inWeatherObservation.location objectForKey:@"full"];
	__weak ViewController *weakSelf = self;
	[[WeatherClient sharedClient] getImageWithURLString:inWeatherObservation.iconUrl completion:^(UIImage *image, NSError *error) {
		if(error){
			NSLog(@"uh oh , the image wasn't returned to the view");
		}else{
			weakSelf.currentConditionImageView.image = image;
		}
	}];
}


@end
