//
//  Rules.h
//  Rules
//
//  Created by Carlos D. Santiago on 10/31/16.
//  Copyright © 2016 Carlos D. Santiago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"

//! Project version number for Rules.
FOUNDATION_EXPORT double RulesVersionNumber;

//! Project version string for Rules.
FOUNDATION_EXPORT const unsigned char RulesVersionString[];

//	Fetch globals from preferences
#ifndef	GBLBIN
#define	GBLBIN(x)	[[NSUserDefaults standardUserDefaults] boolForKey:(x)]
#endif

//	Fetch globals from preferences
#ifndef	GBLINT
#define	GBLINT(x)	[[NSUserDefaults standardUserDefaults] integerForKey:(x)]
#endif

APPKIT_EXTERN NSString * DebugDatabase;

@interface FMDatabase (Rules)
- (NSDictionary *)doQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)args;
@end

@interface NSMutableArray (Rules)
- (void)addRule:(NSString *)name
		   text:(NSString *)text
		formula:(NSString *)formula
		  using:(NSDictionary *)args;
@end

@interface NSArray (Rules)
- (BOOL)evaluate;
@end

@interface NSMutableDictionary (Rules)
- (void)addRule:(NSString *)name
		   text:(NSString *)text
		formula:(NSString *)formula
		  using:(NSDictionary *)args;
- (BOOL)evaluate;
@end

