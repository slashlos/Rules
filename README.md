Purpose
--------------

Rules is a collection of methods to allow rule / formula evaluation via sqlite3 queries.  A growing number of applications require the ability to verify settings, which if can be represented by a formala string, can be captured in a rule.

The idea is to capture the rules formula and supporating values within a dictionary. Each dictionary encompasses a single rule.  Multiple dictionary rules can be contains in a larger dictioonary called a "check book". Rule dictionarys can also be kept in an array. For each rule the following values are kept:

	index	- unique index
	name	- rule name; used to locate each rule
	text	- rule text description
	rule	- rule formula equation
	args	- rule format dictionary of arguments; see below
	state	- rule last execution state

Each value within the args dictionary represents a single value. i.e, these two values for 'a' are the same as they reference an ivar getter to a target object.

	@"a" : @{@"target":myRec, @"getter":@"a"}
	@"a" : @"myRec.a"

If an arg's 'value' is dictionary, it will be searched for a 'target' and 'getter' value. Otherwise, the value is presumed to be a scalar.

For rule batch processing, from an array or check book, or the processing of rules or a single rule the NSMutableDicionary -evaluate method returns whether the rule(s) proof to be true.

The formula (rule statement) is a colon encoded formula symbols that at run-time is substituted for values within an associated argument (args) rule dictionary value. The :colon formula name matches by name within the rule's args values dictionary.

For example, create a check book dictionary with two rules, then evaluate them. Consider

	@interface myRec : NSObject
	{
		NSInteger a, b, c;
	}
	+ (id)withValA:(NSInteger)valA valB:(NSInteger)valB valC:(NSInteger)valC;
	@end

	@implementation myRec
	@synthesize a, b, c;
	+ (id)withValA:(NSInteger)valA valB:(NSInteger)valB valC:(NSInteger)valC
	{
		myRec * rec = [[self alloc] init];
		rec.a = valA;
		rec.b = valB;
		rec.c = valC;
		return rec;
	}
	@end

then using Rules to create some rules

	NSMutableDictionary * rules = [NSMutableDictionary dictionary];
	myRec * rec = [myRec withValA:1 valB:2 valC:3];

	//	Rule involving scalars
	[rules addRule:@"scalars";
			  text:@"simple scalars"
		   formula:@":c = :a + :b"
			 using:@{
					@"a" : @(a),
					@"b" : @(b),
					@"c" : @(c)
					}];

	//	Rule involving object ivar(s)
	[rules addRule:@"ivars";
			  text:@"simple scalars"
		formula:@":c = :a + :b"
			 using:@{
					@"a" : @{@"target":myRec, @"getter":@"a"},
					@"b" : @{@"target":myRec, @"getter":@"b"},
					@"c" : @{@"target":myRec, @"getter":@"c"}
					}];

now evaluate them at once which all should proof

	BOOL proofed = [rules evaluate];
	NSLog(@"rules evaluated ", (proofed ? @"OK" : @"NO"));

of a single rule - which should not proof

	myRec.a = 75;
	myRec.b = 75;
	myRec.c = 100;

	proofed = [rules[@"ivars"] evaluate];
	NSLog(@"rule evaluated ", (proofed ? @"OK" : @"NO"));


Setup
-------

To use the Rules in an app, drag the Rules project into your project. You will need the fmdb project also on github:

	https://github.com/ccgus/fmdb

The path to this sub-project is currently noted at ~/GitHub/fmdb; update to where you place yours.

Rules Category Methods
--------------------------

Rules extends several classes with following methods:

NSMutableArray
--------------------------
- (void)addRule:(NSString *)name text:(NSString *)text formula:(NSString *)formula using:(NSDictionary *)args;

	adds a new rule; type is currently a string but also is a nice placeholder for a handy object.  Each rule is an NSMutableDictionary object, since each contains a state flag which can be updated.

NSArray
--------------------------
- (BOOL)evaluate

	evaluates all rules within the array

NSMutableDictionary
--------------------------
- (void)addRule:(NSString *)name text:(NSString *)text formula:(NSString *)formula using:(NSDictionary *)args;
- (BOOL)evaluate;
	evaluations a single rule (NSMutableDictionary)


FMDatabase Framework
-------------------------

Rules makes use of the FMDatabase Framework package found also on github:

	https://github.com/ccgus/fmdb

    
Release Notes
----------------

Version 0.0

- Initial release

/los
