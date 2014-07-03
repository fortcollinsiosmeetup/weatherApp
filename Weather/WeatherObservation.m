//
//  WeatherObserver.m
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

#import "WeatherObservation.h"

@implementation WeatherObservation

//Step 5 - Create keymapping in order to better objectify our API return
+ (NSDictionary *)keyMapping{
    static NSDictionary *keyMapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		
        keyMapping = @{
					   @"display_location"             : @"location",
					   @"observation_location"         : @"observationLocation",
					   @"image"                        : @"weatherUndergroundImageInfo",
					   @"observation_time"             : @"timeString",
					   @"observation_time_rfc822"      : @"timeStringRFC822",
					   @"weather"                      : @"weatherDescription",
					   @"wind_string"                  : @"windDescription",
					   @"temperature_string"           : @"temperatureDescription",
					   @"feelslike_string"             : @"feelsLikeTemperatureDescription",
					   @"relative_humidity"            : @"relativeHumidity",
					   @"dewpoint_string"              : @"dewpointDescription",
					   @"icon"                         : @"iconName",
					   @"icon_url"                     : @"iconUrl",
					   @"temp_f"                       : @"temperatureF",
					   @"temp_c"                       : @"temperatureC",
					   @"feelslike_f"                  : @"feelsLikeTemperatureF",
					   @"feelslike_c"                  : @"feelsLikeTemperatureC"
					   };
    });
	
    return keyMapping;
}

//Step 6 - Now create a method that will use the keymapping method and set the property opjects accordingly
+ (instancetype)observationWithDictionary:(NSDictionary *)dictionary{
	
	WeatherObservation *weatherObservation = [[WeatherObservation alloc] init];
    if (dictionary){
		
        NSDictionary *keyMapping = [self keyMapping];
        for (NSString *key in keyMapping){
            id value = dictionary[key];
            if (value){
                [weatherObservation setValue:value forKey:keyMapping[key]];
            }
        }
    }
    return weatherObservation;
}

@end
