//
//  Soar.h
//  Soar
//
//  Created by Bailey Seymour on 9/24/14.
//  Copyright (c) 2014 Bailey Seymour. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for Soar.
FOUNDATION_EXPORT double SoarVersionNumber;

//! Project version string for Soar.
FOUNDATION_EXPORT const unsigned char SoarVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Soar/PublicHeader.h>
#define soar_orig(class, function, args...) orig_##class##_##function (args){}
#define soar_begin_hooks(optionalName) \
__attribute__((constructor))\
void initSoarHooks_##optionalName() {
#define soar_end_hooks }
#define soar_hook(oldSymbolName, newSymbolName, origSymbol) MSHookFunction([Soar findSymbol:origSymbol], [Soar hookSwiftFunctionWithSymbol:oldSymbolName withNewSymbol:newSymbolName], NULL)

@interface Soar : NSObject
- (NSString *)searchForSymbolMatching:(NSArray *)matches;
+ (NSArray *)allSymbolsInExecutable:(NSString *)executablePath;
+ (void *)findSymbol:(NSString *)symbol;
+ (void *)hookSwiftFunctionWithSymbol:(NSString *)symbol withNewSymbol:(NSString *)newSymbol;

@end


