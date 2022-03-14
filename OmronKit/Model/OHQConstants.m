//
//  OHQConstants.m
//  OmronKit
//
//  Created by Waqar Malik on 2/14/22.
//

#import "OHQConstants.h"

// Get Description of Company Identifier
NSString * CompanyIdentifierDescription(UInt16 arg) {
	static NSArray *companyIdentifierStrings;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *path = [bundle pathForResource:@"CompanyNames" ofType:@"plist"];
		companyIdentifierStrings = [NSArray arrayWithContentsOfFile:path];
	});

	NSString *ret = @"Unknown";
	if (arg < companyIdentifierStrings.count) {
		ret = [NSString stringWithFormat:@"%@", companyIdentifierStrings[arg]];
	}
	return ret;
}
