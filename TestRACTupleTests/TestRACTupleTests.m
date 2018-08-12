//
//  TestRACTupleTests.m
//  TestRACTupleTests
//
//  Created by ys on 2018/8/12.
//  Copyright © 2018年 ys. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <ReactiveCocoa.h>

@interface TestRACTupleTests : XCTestCase

@end

@implementation TestRACTupleTests

- (void)testRACTuplePack
{
    RACTuple *tuple = RACTuplePack(@(1), @(2));
    NSLog(@"RACTuplePack -- %@", tuple);
    
    // 打印日志如下：
    /*
     2018-08-12 17:00:21.548262+0800 TestRACTuple[46495:9889422] RACTuplePack -- <RACTuple: 0x600000012ce0> (
     1,
     2
     )
     */
}

- (void)testRACTupleUnpack
{
    RACTuple *tuple = RACTuplePack(@(1), @(2));
    RACTupleUnpack(NSNumber *number1, NSNumber *number2) = tuple;
    NSLog(@"RACTupleUnpack -- %@ -- %@", number1, number2);
    
    // 打印日志如下：
    /*
     2018-08-12 17:03:03.919722+0800 TestRACTuple[46664:9898579] RACTupleUnpack -- 1 -- 2
     */
}

- (void)test_tupleNil
{
    RACTupleNil *nil1 = [RACTupleNil tupleNil];
    RACTupleNil *nil2 = [RACTupleNil tupleNil];
    NSLog(@"tupleNil -- %@ -- %@", nil1, nil2);
    
    // 打印日志如下：
    /*
     2018-08-12 17:05:14.905132+0800 TestRACTuple[46777:9905544] tupleNil -- <RACTupleNil: 0x600000207540> -- <RACTupleNil: 0x600000207540>
     */
}

- (void)test_equal
{
    RACTuple *tuple1 = [RACTuple tupleWithObjects:@(1), @(2), nil];
    RACTuple *tuple2 = tuple1;
    RACTuple *tuple3 = [RACTuple tupleWithObjects:@(1), @(2), nil];
    RACTuple *tuple4 = [RACTuple tupleWithObjects:@(1), @(3), nil];
    
    NSLog(@"equal -- %@ -- %@ -- %@ -- %@", tuple1, tuple2, tuple3, tuple4);
    NSLog(@"equal -- %d -- %d -- %d", [tuple1 isEqual:tuple2], [tuple1 isEqual:tuple3], [tuple1 isEqual:tuple4]);
    
    // 打印日志如下：
    /*
     2018-08-12 17:10:21.677911+0800 TestRACTuple[47013:9921207] equal -- <RACTuple: 0x604000005540> (
     1,
     2
     ) -- <RACTuple: 0x604000005540> (
     1,
     2
     ) -- <RACTuple: 0x604000005560> (
     1,
     2
     ) -- <RACTuple: 0x604000005580> (
     1,
     3
     )
     2018-08-12 17:10:21.678304+0800 TestRACTuple[47013:9921207] equal -- 1 -- 1 -- 0
     */
}

- (void)test_Enumerating
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @(2), @(3), nil];
    for (NSNumber *number in tuple) {
        NSLog(@"Enumerating -- %@", number);
    }
    
    // 打印日志如下:
    /*
     2018-08-12 17:46:12.879880+0800 TestRACTuple[47403:9946784] Enumerating -- 1
     2018-08-12 17:46:12.880064+0800 TestRACTuple[47403:9946784] Enumerating -- 2
     2018-08-12 17:46:12.880165+0800 TestRACTuple[47403:9946784] Enumerating -- 3
     */
}

- (void)test_copy
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @(2), nil];
    RACTuple *tuple1 = [tuple copy];
    NSLog(@"copy - %@ - %@", tuple, tuple1);
    
    // 打印日志如下:
    /*
     2018-08-12 17:49:38.201583+0800 TestRACTuple[47592:9957830] copy - <RACTuple: 0x604000003310> (
     1,
     2
     ) - <RACTuple: 0x604000003310> (
     1,
     2
     )
     */
}

- (void)test_code
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@(1), nil];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tuple];
    if (data) {
        RACTuple *tuple1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"code -- %@ -- %@", tuple, tuple1);
    }
    
    // 打印日志：
    /*
     2018-08-12 17:54:46.112251+0800 TestRACTuple[47844:9973666] code -- <RACTuple: 0x60400001a450> (
     1
     ) -- <RACTuple: 0x60400001a480> (
     1
     )
     */
}

- (void)test_tupleWithObjectsFromArray
{
    NSArray *array = @[@(1), NSNull.null, @(2)];
    RACTuple *tuple1 = [RACTuple tupleWithObjectsFromArray:array];
    RACTuple *tuple2 = [RACTuple tupleWithObjectsFromArray:array convertNullsToNils:YES];
    NSLog(@"tupleWithObjectsFromArray -- %@ -- %@", [tuple1 objectAtIndex:1], [tuple2 objectAtIndex:1]);
    
    // 打印日志：
    /*
     2018-08-12 18:01:08.918020+0800 TestRACTuple[48181:9994069] tupleWithObjectsFromArray -- <null> -- (null)
     */
}

- (void)test_tupleWithObjects
{
    RACTuple *tuple1 = [RACTuple tupleWithObjects:@(1), nil, @(2), nil];
    RACTuple *tuple2 = [RACTuple tupleWithObjects:@(1), [RACTupleNil tupleNil], @(2), nil];
    NSLog(@"tupleWithObjects -- %@ -- %@", tuple1, tuple2);
    
    // 打印日志：
    /*
     2018-08-12 18:04:18.575558+0800 TestRACTuple[48333:10003693] tupleWithObjects -- <RACTuple: 0x600000007660> (
     1
     ) -- <RACTuple: 0x600000007690> (
     1,
     "<null>",
     2
     )
     */
}

- (void)test_objectAtIndex
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @(2), nil];
    NSLog(@"objectAtIndex -- %@ -- %@ -- %@", [tuple objectAtIndex:-1], [tuple objectAtIndex:0], [tuple objectAtIndex:2]);
    
    // 打印日志：
    /*
     2018-08-12 18:08:13.772026+0800 TestRACTuple[48531:10016043] objectAtIndex -- (null) -- 1 -- (null)
     */
}

- (void)test_allObjects
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@(1), [NSNull null], @(2), nil];
    NSLog(@"allObjects -- %@", [tuple allObjects]);
    
    // 打印日志：
    /*
     2018-08-12 18:09:57.500308+0800 TestRACTuple[48627:10021917] allObjects -- (
     1,
     "<null>",
     2
     )
     */
}

- (void)test_tupleByAddingObject
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @(2), nil];
    RACTuple *tuple1 = [tuple tupleByAddingObject:@"3"];
    NSLog(@"tupleByAddingObject -- %@", tuple1);
    RACTuple *tuple2 = [tuple tupleByAddingObject:nil];
    NSLog(@"tupleByAddingObject -- %@", tuple2);

    // 打印日志：
    /*
     2018-08-12 18:13:16.836348+0800 TestRACTuple[50529:10137576] tupleByAddingObject -- <RACTuple: 0x600000015240> (
     1,
     2,
     3
     )
     2018-08-12 18:13:16.837194+0800 TestRACTuple[50529:10137576] tupleByAddingObject -- <RACTuple: 0x600000015260> (
     1,
     2,
     "<null>"
     )
     */
}

- (void)test_count
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @"2", nil];
    NSLog(@"count -- %ld", tuple.count);
    
    // 打印日志：
    /*
     2018-08-12 18:14:48.930810+0800 TestRACTuple[48889:10037610] count -- 2
     */
}

- (void)test_value
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @(2), @(3), @(4), @5, @6, @7, @8, @9, nil];
    NSLog(@"value -- %@ -- %@ -- %@ -- %@ -- %@ -- %@", tuple.first, tuple.second, tuple.third, tuple.fourth, tuple.fifth, tuple.last);
    
    // 打印日志：
    /*
     2018-08-12 18:17:45.352995+0800 TestRACTuple[49055:10047385] value -- 1 -- 2 -- 3 -- 4 -- 5 -- 9
     */
}

- (void)test_rac_sequence
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @(2), nil];
    NSLog(@"rac_sequence -- %@", [tuple rac_sequence]);
    
    // 打印日志：
    /*
     2018-08-12 18:19:28.986037+0800 TestRACTuple[49157:10053178] rac_sequence -- <RACTupleSequence: 0x6040002399c0>{ name = , tuple = (
     1,
     2
     ) }
     */
}

- (void)test_trampoline
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @(2), @"3", nil];
    RACTupleUnpackingTrampoline *trampoline = [RACTupleUnpackingTrampoline trampoline];
    NSNumber *number1;
    NSNumber *number2;
    NSString *string;
    NSArray *array = @[[NSValue valueWithPointer:&number1], [NSValue valueWithPointer:&number2], [NSValue valueWithPointer:&string]];
    trampoline[array] = tuple;
    NSLog(@"trampoline -- %@ -- %@ -- %@", number1, number2, string);
    
    // 打印日志：
    /*
     2018-08-12 19:20:36.395290+0800 TestRACTuple[50192:10116319] trampoline -- 1 -- 2 -- 3
     */
}

@end
