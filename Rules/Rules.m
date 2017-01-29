//
//  Rules.m
//  Rules
//
//  Created by Carlos D. Santiago on 10/31/16.
//  Copyright © 2016 Carlos D. Santiago. All rights reserved.
//

#import "Rules.h"

NSString * DebugDatabase = @"debugDatabase";

@implementation FMDatabase (Rules)
- (NSDictionary *)doQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)args
{
	NSMutableDictionary * rets = [[NSMutableDictionary alloc] init];
	FMResultSet * rs = nil;

	if ((rs = [self executeQuery:sql withParameterDictionary:args]))
	{
		NSMutableArray * rows = [[NSMutableArray alloc] init];
		id fldnam, fldval;

		//	build all return information into a single dictionary
		[rets setObject:rows forKey:@"rows"];

		while ([rs next])
		{
			NSMutableDictionary * values = [NSMutableDictionary dictionary];

			for (int c=0; c<[rs columnCount]; c++)
			{
				fldnam = [rs columnNameForIndex:c];
				fldval = [rs objectAtIndexedSubscript:c];

				//	Note fetch pref as int to test verboseness
				if (GBLINT(DebugDatabase) > 1)
				{
					NSLog(@"%@ = '%@'", fldnam, fldval);
				}
				//	fldnam might be #,$ indicating order(#) and name($); take last
				[values setObject:fldval
						   forKey:[[fldnam componentsSeparatedByString:@","] lastObject]];
			}
			[rows addObject:values];
		}
	}

	[rets setValue:@([self lastErrorCode]) forKey:@"lastErrorCode"];
	[rets setValue:[self lastErrorMessage] forKey:@"lastErrorMessage"];
	[rets setValue:@(rs != nil && ![self lastErrorCode]) forKey:@"result"];

	return rets;
}
@end

@implementation NSMutableArray(Rules)
//	Generate an array from a comma separated values list file
- (void)addRule:(NSString *)name
		   text:(NSString *)text
		formula:(NSString *)formula
		  using:(NSDictionary *)args
{
	NSMutableDictionary * test = [NSMutableDictionary dictionaryWithDictionary:
								  @{@"index"	: @([self count]),
									@"text"		: text,
									@"name"		: name,
									@"rule"		: formula,
									@"args"		: args,
									@"state"	: @0
								   }];

	//	Initially all statement evaluations are false
	[self addObject:test];
}
@end

@implementation NSArray (Rules)
- (BOOL)evaluate
{
	FMDatabase * db = [FMDatabase databaseWithPath:NULL];
	BOOL proofed = YES;

	if (![db open]) return NO;

	//	Evaluate our rules via sqlite3; de-reference NSDictionary values
	//	to simple scalar numeric and return back our evaluation value
	for (NSMutableDictionary * rule in self)
	{
		//	Pass our database used for evaluation
		rule[@"db"] = db;
		proofed &= [rule evaluate];
		rule[@"db"] = nil;
	}

	[db close];
	return proofed;
}
@end

@implementation NSMutableDictionary (Rules)
//	Generate an array from a comma separated values list file
- (void)addRule:(NSString *)name
		   text:(NSString *)text
		formula:(NSString *)formula
		  using:(NSDictionary *)args
{
	NSMutableDictionary * rule = [NSMutableDictionary dictionaryWithDictionary:
								  @{@"index"	: @([self count]),
									@"text"		: text,
									@"name"		: name,
									@"rule"		: formula,
									@"args"		: args,
									@"state"	: @0
								   }];

	//	Initially all statement evaluations are false
	self[name] = rule;
}

- (BOOL)evaluate
{
	FMDatabase * db = self[@"db"];
	NSDictionary * rs = nil;
	BOOL proofed = YES;

	//	If we don't already have a database, get one now it's a temp anyway
	if (!db) db = [FMDatabase databaseWithPath:NULL];
	if (![db open]) return NO;

	//	Evaluate our rule via sqlite3; de-reference NSDictionary values
	//	to simple scalar numeric and return back our evaluation value
	for (NSString * name in self.allKeys)
	{
		NSMutableDictionary * rule = self[name];

		//	Fetch formula and args
		NSMutableDictionary * args = [NSMutableDictionary dictionaryWithDictionary:self[@"args"]];
		NSString * stmt = [NSString stringWithFormat:@"select %@;", rule[@"rule"]];

		for (NSString * key in [args allKeys])
		{
			id value = args[key];

			if ([value isKindOfClass:[NSDictionary class]])
			{
				SEL getter = NSSelectorFromString(value[@"getter"]);
				id  target = value[@"target"];

				//	http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
				if ([target respondsToSelector:getter])
					args[key] = ((id (*)(id,SEL))[target methodForSelector:getter])(target, getter);
				else
					args[key] = @(0);
			}
		}

		rs = [db doQuery:stmt withParameterDictionary:args];
		rule[@"state"] = rs[@"result"];
		proofed &= [rule[@"state"] boolValue];
	}


	return proofed;
}
@end
