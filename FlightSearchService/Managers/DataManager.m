//
//  DataManager.m
//  FlightSearchService
//
//  Created by Андрей Щекатунов on 21.07.2021.
//

#import "DataManager.h"
#import "Country.h"
#import "City.h"
#import "Airport.h"

@interface DataManager()

	@property (nonatomic, strong) NSMutableArray *countriesArray;
	@property (nonatomic, strong) NSMutableArray *citiesArray;
	@property (nonatomic, strong) NSMutableArray *airportsArray;

@end

@implementation DataManager

//Singleton DataManager

+ (instancetype)sharedInstance {
	static DataManager *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[DataManager alloc] init];
	});
	return instance;
}

//Reading JSON files countries, cities and airports

- (void)loadData {
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{

		NSArray *countriesJsonArray = [self arrayFromFileName:@"countries" ofType:@"json"];
		self -> _countriesArray = [self createObjectsFromArray:countriesJsonArray withType:DataSourceTypeCountry];

		NSArray *citiesJSONArray = [self arrayFromFileName:@"cities" ofType:@"json"];
		self -> _citiesArray = [self createObjectsFromArray:citiesJSONArray withType:DataSourceTypeCity];

		NSArray *airportsJSONArray = [self arrayFromFileName:@"airports" ofType:@"json"];
		self -> _airportsArray = [self createObjectsFromArray:airportsJSONArray withType:DataSourceTypeAirport];

		dispatch_async(dispatch_get_main_queue(), ^ {
			[[NSNotificationCenter defaultCenter] postNotificationName:kDataManagerLoadDataDidComplete object:nil];
		});
		NSLog(@"Complete load data");
	});
}

//Create objects from array

- (NSMutableArray *)createObjectsFromArray:(NSArray *)array withType:(DataSourceType)type {
	NSMutableArray *results = [NSMutableArray new];
	for (NSDictionary *jsonObject in array) {
		if (type == DataSourceTypeCountry) {
			Country *country = [[Country alloc] initWithDictionary:jsonObject];
			[results addObject: country];
		}
		else if (type == DataSourceTypeCity) {
			City *city = [[City alloc] initWithDictionary:jsonObject];
			[results addObject: city];
		}
		else if (type == DataSourceTypeAirport) {
			Airport *airport = [[Airport alloc] initWithDictionary:jsonObject];
			[results addObject: airport];
		}
	}
	return results;
}

- (NSArray *)arrayFromFileName:(NSString *)fileName ofType:(NSString *)type {
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
	NSData *data = [NSData dataWithContentsOfFile:path];
	return  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

- (NSArray *)countries {
	return _countriesArray;
}

- (NSArray *)cities {
	return _citiesArray;
}

- (NSArray *)airports {
	return _airportsArray;
}

- (City *)cityForIata:(NSString *)iata {
	if (iata) {
		for (City *city in _citiesArray) {
			if ([city.code isEqualToString:iata]) {
				return city;
			}
		}
	}
	return nil;
}

- (City *)cityForLocation:(CLLocation *)location {
	for (City *city in self.citiesArray) {
		if (ceilf(city.coordinate.latitude) == ceilf(location.coordinate.latitude) && ceilf(city.coordinate.longitude) == ceilf(location.coordinate.longitude)) {
			return city;
		}
	}
	return nil;
}

@end
