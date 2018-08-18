##### 了解过`swift`的人应该知道元祖，而`RACTuple`就相当于元祖。

下面分析中用到的所有测试用例[在这里](https://github.com/jianghui1/TestRACTuple)。

首先看下`.h`中的文件。
***
    #define RACTuplePack(...) \
        RACTuplePack_(__VA_ARGS__)
        
    #define RACTuplePack_(...) \
    ([RACTuple tupleWithObjectsFromArray:@[ metamacro_foreach(RACTuplePack_object_or_ractuplenil,, __VA_ARGS__) ]])
    
    #define RACTuplePack_object_or_ractuplenil(INDEX, ARG) \
    (ARG) ?: RACTupleNil.tupleNil,
可知道`RACTuplePack`通过调用`RACTuple`的`tupleWithObjectsFromArray:`方法生成一个元祖对象。

测试用例：
    
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
***
    #define RACTupleUnpack(...) \
            RACTupleUnpack_(__VA_ARGS__)
    
    #define RACTupleUnpack_(...) \
        metamacro_foreach(RACTupleUnpack_decl,, __VA_ARGS__) \
        \
        int RACTupleUnpack_state = 0; \
        \
        RACTupleUnpack_after: \
            ; \
            metamacro_foreach(RACTupleUnpack_assign,, __VA_ARGS__) \
            if (RACTupleUnpack_state != 0) RACTupleUnpack_state = 2; \
            \
            while (RACTupleUnpack_state != 2) \
                if (RACTupleUnpack_state == 1) { \
                    goto RACTupleUnpack_after; \
                } else \
                    for (; RACTupleUnpack_state != 1; RACTupleUnpack_state = 1) \
                        [RACTupleUnpackingTrampoline trampoline][ @[ metamacro_foreach(RACTupleUnpack_value,, __VA_ARGS__) ] ]
可知，`RACTupleUnpack`通过`RACTupleUnpackingTrampoline`类获取元祖内的值。

测试用例：

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
***
##### 接下来是`RACTupleNil`类，提供了一个`tupleNil`方法，查看`.m`中的实现：
    + (RACTupleNil *)tupleNil {
    	static dispatch_once_t onceToken;
    	static RACTupleNil *tupleNil = nil;
    	dispatch_once(&onceToken, ^{
    		tupleNil = [[self alloc] init];
    	});
    	
    	return tupleNil;
    }
    
    #pragma mark NSCopying
    
    - (id)copyWithZone:(NSZone *)zone {
    	return self;
    }
    
    #pragma mark NSCoding
    
    - (id)initWithCoder:(NSCoder *)coder {
    	// Always return the singleton.
    	return self.class.tupleNil;
    }
    
    - (void)encodeWithCoder:(NSCoder *)coder {
    }
`RACTupleNil`是个单例类，代表着一个空的对象，方便代替空值存到元祖中。

测试用例：

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
***
##### 接下来就是`RACTuple`类了，
* `first` 元祖中的第一个值。
* `second` 元祖中的第二个值。
* `third` 元祖中的第三个值。
* `fourth` 元祖中的第四个值。
* `fifth` 元祖中的第五个值。
* `last` 元祖中的最后一个值。
* `+ (instancetype)tupleWithObjectsFromArray:(NSArray *)array;` 通过`array`初始化一个元祖对象。
* `+ (instancetype)tupleWithObjectsFromArray:(NSArray *)array convertNullsToNils:(BOOL)convert;`通过`array` `convert`初始化一个元祖对象。
* `+ (instancetype)tupleWithObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;`通过一系列`object`初始化元祖对象。
* `- (id)objectAtIndex:(NSUInteger)index;`获取元祖中指定索引`index`下的对象。注意，这里不同于`NSArray`，如果`index`越界，不会造成崩溃，而是返回`nil`值。
* `- (NSArray *)allObjects;`以数组的形式获取元祖的所有对象。
* `- (instancetype)tupleByAddingObject:(id)obj;`向元祖中增加对象。

##### 接下来看看`.m`中方法的实现。

    @interface RACTuple ()
    @property (nonatomic, strong) NSArray *backingArray;
    @end
`RACTuple`中有个数组类型的实例变量`backingArray`。其实元祖中的值就是保存在这个数组当中的。
***
    - (instancetype)init {
    	self = [super init];
    	if (self == nil) return nil;
    	
    	self.backingArray = [NSArray array];
    	
    	return self;
    }
初始化方法， 同时初始化`backingArray`数组。
***
    - (NSString *)description {
    	return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, self.allObjects];
    }
格式化打印日志。
***
    - (BOOL)isEqual:(RACTuple *)object {
    	if (object == self) return YES;
    	if (![object isKindOfClass:self.class]) return NO;
    	
    	return [self.backingArray isEqual:object.backingArray];
    }
重写`isEqual`方法用于定义元祖相等的原则，元祖对象的指针相等或者元祖对象的数组通过`isEqual:`方法相等。

测试用例如下：

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
***
    - (NSUInteger)hash {
    	return self.backingArray.hash;
    }
元祖对象的`hash`值就是`backingArray`的`hash`值。
***
    - (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    	return [self.backingArray countByEnumeratingWithState:state objects:buffer count:len];
    }
快速枚举协议方法，通过`backingArray`完成该协议方法的实现。

测试用例：

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
***
    - (instancetype)copyWithZone:(NSZone *)zone {
    	// we're immutable, bitches!
    	return self;
    }
通过此方法可知元祖不支持拷贝。

测试用例：

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
***

    - (id)initWithCoder:(NSCoder *)coder {
    	self = [self init];
    	if (self == nil) return nil;
    	
    	self.backingArray = [coder decodeObjectForKey:@keypath(self.backingArray)];
    	return self;
    }
    
    - (void)encodeWithCoder:(NSCoder *)coder {
    	if (self.backingArray != nil) [coder encodeObject:self.backingArray forKey:@keypath(self.backingArray)];
    }
序列化方法，主要是对`backingArray`的序列化。

测试用例：

    - (void)test_code
    {
        RACTuple *tuple = [RACTuple tupleWithObjects:@(1), nil];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tuple];
        if (data) {
            RACTuple *tuple1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSLog(@"code -- %@ -- %@", tuple, tuple1);
        }
        
        // 测试用例：
        /*
         2018-08-12 17:54:46.112251+0800 TestRACTuple[47844:9973666] code -- <RACTuple: 0x60400001a450> (
         1
         ) -- <RACTuple: 0x60400001a480> (
         1
         )
         */
    }
***
    + (instancetype)tupleWithObjectsFromArray:(NSArray *)array {
    	return [self tupleWithObjectsFromArray:array convertNullsToNils:NO];
    }
    
    + (instancetype)tupleWithObjectsFromArray:(NSArray *)array convertNullsToNils:(BOOL)convert {
    	RACTuple *tuple = [[self alloc] init];
    	
    	if (convert) {
    		NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
    		for (id object in array) {
    			[newArray addObject:(object == NSNull.null ? RACTupleNil.tupleNil : object)];
    		}
    		
    		tuple.backingArray = newArray;
    	} else {
    		tuple.backingArray = [array copy];
    	}
    	
    	return tuple;
    }
类初始化方法，将`array`中的数据放到元祖对象的`backingArray`中。通过`convert`决定是否将数组中的`NSNull`对象转换成`RACTupleNil`对象。

测试用例：

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
***
    + (instancetype)tupleWithObjects:(id)object, ... {
    	RACTuple *tuple = [[self alloc] init];
    
    	va_list args;
    	va_start(args, object);
    
    	NSUInteger count = 0;
    	for (id currentObject = object; currentObject != nil; currentObject = va_arg(args, id)) {
    		++count;
    	}
    
    	va_end(args);
    
    	if (count == 0) {
    		tuple.backingArray = @[];
    		return tuple;
    	}
    	
    	NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:count];
    	
    	va_start(args, object);
    	for (id currentObject = object; currentObject != nil; currentObject = va_arg(args, id)) {
    		[objects addObject:currentObject];
    	}
    
    	va_end(args);
    	
    	tuple.backingArray = objects;
    	return tuple;
    }
通过对可变参数的循环获取到所有的参数对象，并保存到`backingArray`中，完成初始化操作。注意，可变参数是以`nil`结束的。类似于`NSArray`的方法。

测试用例：

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
***
    - (id)objectAtIndex:(NSUInteger)index {
    	if (index >= self.count) return nil;
    	
    	id object = self.backingArray[index];
    	return (object == RACTupleNil.tupleNil ? nil : object);
    }
获取`backingArray`中索引`index`对应的值，里面针对索引做了判断，防止越界。如果对象是`RACTupleNil.tupleNil`返回`nil`。

测试用例：

    - (void)test_objectAtIndex
    {
        RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @(2), nil];
        NSLog(@"objectAtIndex -- %@ -- %@ -- %@", [tuple objectAtIndex:-1], [tuple objectAtIndex:0], [tuple objectAtIndex:2]);
        
        // 打印日志：
        /*
         2018-08-12 18:08:13.772026+0800 TestRACTuple[48531:10016043] objectAtIndex -- (null) -- 1 -- (null)
         */
    }
***
    - (NSArray *)allObjects {
    	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:self.backingArray.count];
    	for (id object in self.backingArray) {
    		[newArray addObject:(object == RACTupleNil.tupleNil ? NSNull.null : object)];
    	}
    	
    	return newArray;
    }
通过对`backingArray`的遍历获取到所有的值，并保存到数组中返回，注意如果数组中的对象是`RACTupleNil.tupleNil`，则将使用`NSNull.null`代替，还原出原始值。

测试用例：

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
***
    - (instancetype)tupleByAddingObject:(id)obj {
    	NSArray *newArray = [self.backingArray arrayByAddingObject:obj ?: RACTupleNil.tupleNil];
    	return [self.class tupleWithObjectsFromArray:newArray];
    }
将`obj`添加到`backingArray`数组中，同时进行了空值判断，防止崩溃。

测试用例：

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
***
    - (NSUInteger)count {
    	return self.backingArray.count;
    }
返回`backingArray`的`count`值。

测试用例：
    
    - (void)test_count
    {
        RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @"2", nil];
        NSLog(@"count -- %ld", tuple.count);
        
        // 打印日志：
        /*
         2018-08-12 18:14:48.930810+0800 TestRACTuple[48889:10037610] count -- 2
         */
    }
***
    - (id)first {
    	return self[0];
    }
    
    - (id)second {
    	return self[1];
    }
    
    - (id)third {
    	return self[2];
    }
    
    - (id)fourth {
    	return self[3];
    }
    
    - (id)fifth {
    	return self[4];
    }
    
    - (id)last {
    	return self[self.count - 1];
    }
通过语法糖，返回指定索引下的值。这里为什么可以这么使用呢？

因为元祖实现了`objectAtIndexedSubscript:`方法，便可以使用上面的语法糖。
    
    - (id)objectAtIndexedSubscript:(NSUInteger)idx {
    	return [self objectAtIndex:idx];
    }
通过调用`objectAtIndex:`获取到指定索引下的对象。

测试用例：

    - (void)test_value
    {
        RACTuple *tuple = [RACTuple tupleWithObjects:@(1), @(2), @(3), @(4), @5, @6, @7, @8, @9, nil];
        NSLog(@"value -- %@ -- %@ -- %@ -- %@ -- %@ -- %@", tuple.first, tuple.second, tuple.third, tuple.fourth, tuple.fifth, tuple.last);
        
        // 打印日志：
        /*
         2018-08-12 18:17:45.352995+0800 TestRACTuple[49055:10047385] value -- 1 -- 2 -- 3 -- 4 -- 5 -- 9
         */
    }
***
##### 接着就是`RACTuple (RACSequenceAdditions)`类目中的方法，
    - (RACSequence *)rac_sequence {
    	return [RACTupleSequence sequenceWithTupleBackingArray:self.backingArray offset:0];
    }
通过`backingArray`生成一个`RACTupleSequence`对象。如果对`RACTupleSequence` 还不了解，请看[这篇文章](https://blog.csdn.net/jianghui12138/article/details/81808940)。

测试用例：

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
***
##### `RACTuple (ObjectSubscripting)`中的方法`objectAtIndexedSubscript:`上面已经分析过了。
***
##### 接下来看`RACTupleUnpackingTrampoline`。


    + (instancetype)trampoline {
    	static dispatch_once_t onceToken;
    	static id trampoline = nil;
    	dispatch_once(&onceToken, ^{
    		trampoline = [[self alloc] init];
    	});
    	
    	return trampoline;
    }
通过类方法初始化一个单例对象。
***
    - (void)setObject:(RACTuple *)tuple forKeyedSubscript:(NSArray *)variables {
    	NSCParameterAssert(variables != nil);
    	
    	[variables enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger index, BOOL *stop) {
    		__strong id *ptr = (__strong id *)value.pointerValue;
    		*ptr = tuple[index];
    	}];
    }
通过对`variables`循环遍历，将`tuple`中的值保存到`variables`数组中的对象`value` 的 `pointerValue` 上。注意，实现该方法的话同样可以像使用`NSDictionary`一样，使用语法糖对该对象进行`key-value`赋值。之前说过`RACTupleUnpack`中就是使用了这个方法，如下：

    #define RACTupleUnpack_(...) \
        metamacro_foreach(RACTupleUnpack_decl,, __VA_ARGS__) \
        \
        int RACTupleUnpack_state = 0; \
        \
        RACTupleUnpack_after: \
            ; \
            metamacro_foreach(RACTupleUnpack_assign,, __VA_ARGS__) \
            if (RACTupleUnpack_state != 0) RACTupleUnpack_state = 2; \
            \
            while (RACTupleUnpack_state != 2) \
                if (RACTupleUnpack_state == 1) { \
                    goto RACTupleUnpack_after; \
                } else \
                    for (; RACTupleUnpack_state != 1; RACTupleUnpack_state = 1) \
                        [RACTupleUnpackingTrampoline trampoline][ @[ metamacro_foreach(RACTupleUnpack_value,, __VA_ARGS__) ] ]
注意最后的`[RACTupleUnpackingTrampoline trampoline][ @[ metamacro_foreach(RACTupleUnpack_value,, __VA_ARGS__) ] ]`刚好是以数组作为`key`值的，也就是上面方法中的`variables`，如果此时将一个元祖对象赋值过去，那么`@[ metamacro_foreach(RACTupleUnpack_value,, __VA_ARGS__)`这个数组刚好就可以拿到元祖中所有的值了。

测试用例：

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


##### 上面就是有关`RACTuple`的所有方法，其实作用跟`NSArray`一样，只不过做了一些额外的操作防止操作过程中出现崩溃现象。
