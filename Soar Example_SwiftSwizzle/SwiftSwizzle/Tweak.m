//
//  Tweak.m
//  SwiftSwizzle
//
//  Created by Bailey Seymour on 9/23/14.
//  Copyright (c) 2014 Bailey Seymour. All rights reserved.
//

#import "Tweak.h"
#import <CydiaSubstrate/CydiaSubstrate.h>

//Define orig function placeholder
void soar_orig(BlueClass, hello, NSString *name)
//Begin Hook Constructor
soar_begin_hooks(MyTweak)

//Define symbol name manually for BlueClass.hello
NSString *_sym_BlueClass_hello = @"_TFC12SwiftSwizzle9BlueClass5hellofMS0_FCSo8NSStringT_";
//Alternatively you could use [[Soar new] searchForSymbolMatching:@[@"_TF", @"BlueClass", @"hello"]]; to search the executable for the symbol name but it's slower

//Define symbol name manually for RedClass.hellogoodbye
NSString *_sym_RedClass_goodbye = @"_TFC12SwiftSwizzle8RedClass12hellogoodbyefMS0_FCSo8NSStringT_";

//Hook original function with new function and specifiy the soar original function symbol name: orig_$class_$func
soar_hook(_sym_BlueClass_hello, _sym_RedClass_goodbye, @"orig_BlueClass_hello");

soar_end_hooks
