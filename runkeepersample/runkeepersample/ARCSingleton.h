//
//  EDPSingleton.h
//  TestPrep
//
//  Created by Travis Foster on 9/30/11.
//  Copyright (c) 2011 -. All rights reserved.
//

#ifndef EDP_Singleton_h
#define EDP_Singleton_h


// ARC-compatible singleton using blocks 

#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(__CLASSNAME__)	\
    \
+ (__CLASSNAME__*) sharedInstance;


#define SYNTHESIZE_SINGLETON_FOR_CLASS(__CLASSNAME__)	\
    \
static __CLASSNAME__* _##__CLASSNAME__##_sharedInstance = nil;	\
\
+ (__CLASSNAME__*) sharedInstance	\
{	\
    static dispatch_once_t _##__CLASSNAME__##_Once = 0;	\
    dispatch_once(&_##__CLASSNAME__##_Once, ^{	\
        _##__CLASSNAME__##_sharedInstance = [[self alloc] init]; \
    });	\
    \
    return _##__CLASSNAME__##_sharedInstance;	\
}	

#endif // EDP_Singleton_h
