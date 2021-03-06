//
//  CoreDataHelper.m
//  FlightSearchService
//
//  Created by Андрей Щекатунов on 28.07.2021.
//

#import "CoreDataHelper.h"

@interface CoreDataHelper ()

	@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
	@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
	@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@end

@implementation CoreDataHelper

//Singleton CoreDataHelper

+ (instancetype)sharedInstance {
	static CoreDataHelper *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[CoreDataHelper alloc] init];
		[instance setup];
	});
	return instance;
}

- (void)setup {
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FavoriteTicket" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

	NSURL *docsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	NSURL *storeURL = [docsURL URLByAppendingPathComponent:@"base.sqlite"];
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];

	NSPersistentStore* store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];

	if (!store) {
		abort();
	}
	_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	_managedObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
}

- (void)save {
	NSError *error;
	[self.managedObjectContext save: &error];
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
}

- (FavoriteTicket *)favoriteFromTicket:(Ticket *)ticket {
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteTicket"];
	request.predicate = [NSPredicate
						 predicateWithFormat:@"price == %ld AND airline == %@ AND from == %@ AND to == %@ AND departure == %@ AND expires == %@ AND flightNumber == %ld",
						 [[ticket valueForKey:@"price"] integerValue],
						 ticket.airline,
						 ticket.from,
						 ticket.to,
						 ticket.departure,
						 ticket.expires,
						 [[ticket valueForKey:@"flightNumber"] integerValue]];
	return [[_managedObjectContext executeFetchRequest:request error:nil] firstObject];
}

- (FavoriteMapPriceTicket *)favoriteMapWithPrice:(MapWithPrice *)price {
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteMapPriceTicket"];
	request.predicate = [NSPredicate
						 predicateWithFormat:@"price == %ld AND from == %@ AND to == %@ AND departure == %@",
						 (long)price.price,
						 price.origin.name,
						 price.destination.name,
						 price.departure];
	return [[_managedObjectContext executeFetchRequest:request error:nil] firstObject];
}

- (BOOL)isFavorite:(Ticket *)ticket {
	return [self favoriteFromTicket:ticket] != nil;
}

- (BOOL)isFavoriteMapWithPrice:(MapWithPrice *)price {
	return [self favoriteMapWithPrice:price] != nil;
}

- (void)addToFavorite:(Ticket *)ticket {
	FavoriteTicket *favorite = [NSEntityDescription
								insertNewObjectForEntityForName:@"FavoriteTicket"
								inManagedObjectContext:_managedObjectContext];
	favorite.price = ticket.price.intValue;
	favorite.airline = ticket.airline;
	favorite.departure = ticket.departure;
	favorite.expires = ticket.expires;
	favorite.flightNumber = ticket.flightNumber.intValue;
	favorite.returnDate = ticket.returnDate;
	favorite.from = ticket.from;
	favorite.to = ticket.to;
	favorite.created = [NSDate date];

	[self save];
}

- (void)removeFromFavorite:(Ticket *)ticket {
	FavoriteTicket *favorite = [self favoriteFromTicket:ticket];
	if (favorite) {
		[_managedObjectContext deleteObject:favorite];
		[self save];
	}
}

- (void)addToFavoriteMapWithPrice:(MapWithPrice *)price {
	FavoriteMapPriceTicket *mapPriceFavorite = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteMapPriceTicket" inManagedObjectContext:_managedObjectContext];
	mapPriceFavorite.price = price.price;
	mapPriceFavorite.departure = price.departure;
	mapPriceFavorite.from = price.origin.name;
	mapPriceFavorite.to = price.destination.name;
	mapPriceFavorite.created = [NSDate date];

	[self save];
}

- (void)removeFromFavoriteMapWithPrice:(MapWithPrice *)price {
	FavoriteMapPriceTicket *mapPrice = [self favoriteMapWithPrice:price];
	if (mapPrice) {
		[_managedObjectContext deleteObject:mapPrice];
		[self save];
	}
}

- (void)removeFromFavoriteMapWithPriceFromTable:(FavoriteMapPriceTicket *)price {
	if (price) {
		[_managedObjectContext deleteObject:price];
		[self save];
	}
}

- (NSArray *)favorites {
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteTicket"];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
	return [_managedObjectContext executeFetchRequest:request error:nil];
}

- (NSArray *)favoritesMapWithPrices {
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteMapPriceTicket"];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"departure" ascending:NO]];
	return [_managedObjectContext executeFetchRequest:request error:nil];
}

@end
