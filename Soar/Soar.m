//
//  Soar.m
//  Soar
//
//  Created by Bailey Seymour on 9/24/14.
//  Copyright (c) 2014 Bailey Seymour. All rights reserved.
//

#import "Soar.h"
#import <dlfcn.h>
#import <CydiaSubstrate/CydiaSubstrate.h>
#import "NSTask.h"

static NSMutableArray *readInput(NSString *contents) {
    NSMutableArray *dict = [NSMutableArray new];
    if(contents&&![contents isEqualToString:@""]) {
        NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:@"\\s([^\\s]*+)$" options:NSRegularExpressionAnchorsMatchLines error:nil];
        NSArray *values = [regex matchesInString:contents options:0 range:[contents rangeOfString:contents]];
        if (values.count>0) {
            for (NSTextCheckingResult *value in values) {
                NSRange matchRange = [value range];
                NSString *keyAndVal = [contents substringWithRange:matchRange];
                if ([keyAndVal characterAtIndex:0] == ' ')keyAndVal = [keyAndVal substringFromIndex:1];
                
                if ([keyAndVal characterAtIndex:0] == '_')keyAndVal = [keyAndVal substringFromIndex:1];
                
                if([keyAndVal characterAtIndex:0] != '\n')
                [dict addObject:keyAndVal];
            }
        }
    }
    return dict;
}

@interface Soar ()
{
    NSArray *allSymbols;
}
@end

@implementation Soar

NSString *soar_swift_mangleSimpleClass(NSString *exe, NSString *cls)
{
    size_t r12 = strlen(exe.UTF8String);
    size_t r14 = strlen(cls.UTF8String);
    char *result;
    int rax = strcmp(cls.UTF8String, "Swift");
    if (rax != 0) {
        asprintf(&result, "_TtC%zu%s%zu%s", r12, exe.UTF8String, r14, cls.UTF8String);
    }
    else {
        asprintf(&result, "_TtCSs%zu%s", r14, cls.UTF8String);
    }

    return [NSString stringWithCString:result encoding:NSUTF8StringEncoding];
}

NSString *soar_swift_mangleSimpleProtocol(NSString *exe, NSString *cls)
{
    size_t r12 = strlen(exe.UTF8String);
    size_t r14 = strlen(cls.UTF8String);
    char *result;
    int rax = strcmp(cls.UTF8String, "Swift");
    if (rax != 0) {
        asprintf(&result, "_TtP%zu%s%zu%s_", r12, exe.UTF8String, r14, cls.UTF8String);
    }
    else {
        asprintf(&result, "_TtPSs%zu%s_", r14, cls.UTF8String);
    }

    return [NSString stringWithCString:result encoding:NSUTF8StringEncoding];
}

/* Possibly UNSAFE / Performance Degrading */

+ (void)cacheSymbol:(NSString *)symbol toDefaults:(NSString *)defaults withKey:(NSString *)key
{
    NSString *plistPath = [NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", NSHomeDirectory(), defaults];
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!plist) plist = [NSMutableDictionary dictionary];
    
    [plist setObject:symbol forKey:key];
    
    [plist writeToFile:plistPath atomically:YES];
}

/* Possibly UNSAFE / Performance Degrading */

+ (NSString *)cachedSymbolWithKey:(NSString *)key fromDefaults:(NSString *)defaults;
{
    NSString *plistPath = [NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", NSHomeDirectory(), defaults];
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!plist) plist = [NSMutableDictionary dictionary];
    
    return plist[key];
}

/* Possibly UNSAFE / Performance Degrading / Best for Debugging */

- (NSString *)searchForSymbolMatching:(NSArray *)matches
{
    if (!allSymbols)
        allSymbols = [Soar allSymbolsInExecutable:[NSBundle mainBundle].executablePath];
    
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSString *symbol in allSymbols) {
        BOOL didNotMatch = NO;
        for (int i = 0; matches.count > i; i++) {
            if ([symbol rangeOfString:matches[i]].location == NSNotFound) {
                didNotMatch = YES;
                break;
            }
        }
        if (didNotMatch == NO) {
            [results addObject:symbol];
        }
    }
    
    return results[0];
}

+ (NSArray *)allSymbolsInExecutable:(NSString *)executablePath
{
    //printf("%s\n", soar_swift_mangleSimpleClass(@"SwiftSwizzle", @"BlueClass").UTF8String);
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/nm"];
    [task setArguments:[NSArray arrayWithObjects:executablePath, nil]];
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];

    [task waitUntilExit];
    [task launch];
    
    NSString *string = [[NSString alloc] initWithData:[[outputPipe fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    
    return readInput(string);
}

+ (void *)findSymbol:(NSString *)symbol
{
    return dlsym(RTLD_DEFAULT, symbol.UTF8String);
}

/*--- This needs more work. I need help understanding how the function name mangling works ---*/

+ (NSString *)symbolNameForFunction:(NSString *)function inClass:(NSString *)class withArgs:(NSArray *)args returnTypes:(NSArray *)returnTypes inBin:(NSString *)bin
{
    NSString *result = @"_TFC";
    
    result = [result stringByAppendingFormat:@"%lu%@%lu%@%lu%@fMS0_F", bin.length, bin, class.length, class, function.length, function];
    
    if (args) {
        
        for (NSString *arg in args) {
            NSString *_typeP = arg;
            if ([_typeP hasPrefix:@"_Tt"]) _typeP = [_typeP substringFromIndex:3];
            else {
                _typeP = [NSString stringWithFormat:@"%lu%@", _typeP.length, _typeP];
            }
            result = [result stringByAppendingString:_typeP];
        }
    }
    
    result = [result stringByAppendingString:@"T"];
    
    if (returnTypes) {
        for (NSString *type in returnTypes) {
            NSString *_typeP = type;
            if ([_typeP hasPrefix:@"_Tt"]) _typeP = [_typeP substringFromIndex:3];
            else {
                _typeP = [NSString stringWithFormat:@"%lu%@", _typeP.length, _typeP];
            }
            
            result = [result stringByAppendingString:_typeP];
        }
    }
    
    result = [result stringByAppendingString:@"_"];
    
    
    return result;
}

+ (void *)hookSwiftFunctionWithSymbol:(NSString *)symbol withNewSymbol:(NSString *)newSymbol
{
    void *orig;
    MSHookFunction([Soar findSymbol:symbol], [Soar findSymbol:newSymbol], &orig);
    if (orig) {
        printf("Hooked: %s with: %s\n", symbol.UTF8String, newSymbol.UTF8String);
        
    }
    else  printf("Failed to hook: %s with: %s\n", symbol.UTF8String, newSymbol.UTF8String);
    
    
    return orig;
}

@end
