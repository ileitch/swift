// RUN: %target-swift-ide-test -print-indexed-symbols -include-locals -source-filename %s | %FileCheck %s

// Helpers
let intValue = 1
let stringValue = ""
func calledFunc(value: Int) {}

@propertyWrapper
struct Wrapped<T> {
    let wrappedValue: T
    init(wrappedValue: T) {}
}

// Begin tests

let typedProperty: Int = 1
// CHECK: [[@LINE-1]]:5 | variable/Swift | typedProperty | {{.*}} | Def | rel: 0
// CHECK: [[@LINE-2]]:20 | struct/Swift | Int | {{.*}} | Ref,RelCont | rel: 1
// CHECK-NEXT: RelCont | variable/Swift | typedProperty | {{.*}}

let propertyWithExpressionReference = typedProperty
// CHECK: [[@LINE-1]]:5 | variable/Swift | propertyWithExpressionReference | {{.*}} | Def | rel: 0
// CHECK: [[@LINE-2]]:39 | variable/Swift | typedProperty | {{.*}} | Ref,Read,RelCont | rel: 1
// CHECK-NEXT: RelCont | variable/Swift | propertyWithExpressionReference | {{.*}}
// CHECK: [[@LINE-4]]:39 | function/acc-get/Swift | getter:typedProperty | {{.*}} | Ref,Call,Impl,RelCont | rel: 1
// CHECK-NEXT: RelCont | variable/Swift | propertyWithExpressionReference | {{.*}}

var propertyWithExplicitAccessors: Int {
    get {
        calledFunc(value: 0)
        // CHECK: [[@LINE-1]]:9 | function/Swift | calledFunc(value:) | {{.*}} | Ref,Call,RelCall,RelCont | rel: 1
        // CHECK-NEXT: RelCall,RelCont | function/acc-get/Swift | getter:propertyWithExplicitAccessors | {{.*}}
        return 0
    }
    set {
        calledFunc(value: 0)
        // CHECK: [[@LINE-1]]:9 | function/Swift | calledFunc(value:) | {{.*}} | Ref,Call,RelCall,RelCont | rel: 1
        // CHECK-NEXT: RelCall,RelCont | function/acc-set/Swift | setter:propertyWithExplicitAccessors | {{.*}}
    }
}

let tupleTypedProperty: (Int, String) = (1, "")
// CHECK: [[@LINE-1]]:5 | variable/Swift | tupleTypedProperty | {{.*}} | Def | rel: 0
// CHECK: [[@LINE-2]]:26 | struct/Swift | Int | {{.*}} | Ref,RelCont | rel: 1
// CHECK-NEXT: RelCont | variable/Swift | tupleTypedProperty | {{.*}}
// CHECK: [[@LINE-4]]:31 | struct/Swift | String | {{.*}} | Ref,RelCont | rel: 1
// CHECK-NEXT: RelCont | variable/Swift | tupleTypedProperty | {{.*}}

let (tupleElementA, tupleElementB): (Int, String) = (intValue, stringValue)
// CHECK: [[@LINE-1]]:38 | struct/Swift | Int | {{.*}} | Ref,RelCont | rel: 2
// CHECK-NEXT: RelCont | variable/Swift | tupleElementA | {{.*}}
// CHECK-NEXT: RelCont | variable/Swift | tupleElementB | {{.*}}
// CHECK: [[@LINE-4]]:43 | struct/Swift | String | {{.*}} | Ref,RelCont | rel: 2
// CHECK-NEXT: RelCont | variable/Swift | tupleElementA | {{.*}}
// CHECK-NEXT: RelCont | variable/Swift | tupleElementB | {{.*}}
// CHECK: [[@LINE-7]]:54 | variable/Swift | intValue | {{.*}} | Ref,Read,RelCont | rel: 2
// CHECK-NEXT: RelCont | variable/Swift | tupleElementA | {{.*}}
// CHECK-NEXT: RelCont | variable/Swift | tupleElementB | {{.*}}
// CHECK: [[@LINE-10]]:54 | function/acc-get/Swift | getter:intValue | {{.*}} | Ref,Call,Impl,RelCont | rel: 2
// CHECK-NEXT: RelCont | variable/Swift | tupleElementA | {{.*}}
// CHECK-NEXT: RelCont | variable/Swift | tupleElementB | {{.*}}
// CHECK: [[@LINE-13]]:64 | variable/Swift | stringValue | {{.*}} | Ref,Read,RelCont | rel: 2
// CHECK-NEXT: RelCont | variable/Swift | tupleElementA | {{.*}}
// CHECK-NEXT: RelCont | variable/Swift | tupleElementB | {{.*}}
// CHECK: [[@LINE-16]]:64 | function/acc-get/Swift | getter:stringValue | {{.*}} | Ref,Call,Impl,RelCont | rel: 2
// CHECK-NEXT: RelCont | variable/Swift | tupleElementA | {{.*}}
// CHECK-NEXT: RelCont | variable/Swift | tupleElementB | {{.*}}

let closureTypedProperty: ((Int) -> Void) = { _ in }
// CHECK: [[@LINE-1]]:5 | variable/Swift | closureTypedProperty | {{.*}} | Def | rel: 0
// CHECK: [[@LINE-2]]:29 | struct/Swift | Int | {{.*}} | Ref,RelCont | rel: 1
// CHECK-NEXT: RelCont | variable/Swift | closureTypedProperty | {{.*}}
// CHECK: [[@LINE-4]]:37 | type-alias/Swift | Void | {{.*}} | Ref,RelCont | rel: 1
// CHECK-NEXT: RelCont | variable/Swift | closureTypedProperty | {{.*}}

func containingFunc(param: Int) {
    // CHECK: [[@LINE-1]]:6 | function/Swift | containingFunc(param:) | {{.*}} | Def | rel: 0

    let localProperty = param
    // CHECK: [[@LINE-1]]:9 | variable(local)/Swift | localProperty | {{.*}} | Def,RelChild | rel: 1
    // CHECK: [[@LINE-2]]:25 | param/Swift | param | {{.*}} | Ref,Read,RelCont | rel: 1
    // CHECK-NEXT: RelCont | variable(local)/Swift | localProperty | {{.*}}

    calledFunc(value: localProperty)
    // CHECK: [[@LINE-1]]:5 | function/Swift | calledFunc(value:) | {{.*}} | Ref,Call,RelCall,RelCont | rel: 1
    // CHECK-NEXT: RelCall,RelCont | function/Swift | containingFunc(param:) | {{.*}}

    // Ignored declarations do not act as containers.
    let _ = intValue
    // CHECK: [[@LINE-1]]:13 | variable/Swift | intValue | {{.*}} | Ref,Read,RelCont | rel: 1
    // CHECK-NEXT: RelCont | function/Swift | containingFunc(param:) | {{.*}}
}

func functionWithReturnType() -> Int { 0 }
// CHECK: [[@LINE-1]]:6 | function/Swift | functionWithReturnType() | {{.*}} | Def | rel: 0
// CHECK: [[@LINE-2]]:34 | struct/Swift | Int | {{.*}} | Ref,RelCont | rel: 1
// CHECK-NEXT: RelCont | function/Swift | functionWithReturnType() | {{.*}}

func functionWithParameter(a: Int) {}
// CHECK: [[@LINE-1]]:6 | function/Swift | functionWithParameter(a:) | {{.*}} | Def | rel: 0
// CHECK: [[@LINE-2]]:31 | struct/Swift | Int | {{.*}} | Ref,RelCont | rel: 1
// CHECK-NEXT: RelCont | function/Swift | functionWithParameter(a:) | {{.*}}

func functionWithGenericConstraint<T: Equatable>(type: T) {}
// CHECK: [[@LINE-1]]:6 | function/Swift | functionWithGenericConstraint(type:) | {{.*}} | Def | rel: 0
// CHECK: [[@LINE-2]]:39 | protocol/Swift | Equatable | {{.*}} | Ref,RelCont | rel: 1
// CHECK-NEXT: RelCont | function/Swift | functionWithGenericConstraint(type:) | {{.*}}

func functionWithGenericClause<T>(type: T) where T: Equatable {}
// CHECK: [[@LINE-1]]:6 | function/Swift | functionWithGenericClause(type:) | {{.*}} | Def | rel: 0
// CHECK: [[@LINE-2]]:53 | protocol/Swift | Equatable | {{.*}} | Ref,RelCont | rel: 1
// CHECK-NEXT: RelCont | function/Swift | functionWithGenericClause(type:) | {{.*}}

struct SomeStruct {
    static let staticProperty: Int = 1
    // CHECK: [[@LINE-1]]:16 | static-property/Swift | staticProperty | {{.*}} | Def,RelChild | rel: 1
    // CHECK: [[@LINE-2]]:32 | struct/Swift | Int | {{.*}} | Ref,RelCont | rel: 1
    // CHECK-NEXT: RelCont | static-property/Swift | staticProperty | {{.*}}

    lazy var lazyProperty: Int = { 1 }()
    // CHECK: [[@LINE-1]]:14 | instance-property/Swift | lazyProperty | {{.*}} | Def,RelChild | rel: 1
    // CHECK: [[@LINE-2]]:28 | struct/Swift | Int | {{.*}} | Ref,RelCont | rel: 1
    // CHECK-NEXT: RelCont | instance-property/Swift | lazyProperty | {{.*}}

    @Wrapped
    var wrappedProperty: Int = 1
    // CHECK: [[@LINE-2]]:6 | struct/Swift | Wrapped | {{.*}} | Ref,RelCont | rel: 1
    // CHECK-NEXT: RelCont | instance-property/Swift | wrappedProperty | {{.*}}
    // CHECK: [[@LINE-4]]:6 | constructor/Swift | init(wrappedValue:) | {{.*}} | Ref,Call,Impl,RelCont | rel: 1
    // CHECK-NEXT: RelCont | instance-property/Swift | wrappedProperty | {{.*}}
    // CHECK: [[@LINE-5]]:9 | instance-property/Swift | wrappedProperty | {{.*}} | Def,RelChild | rel: 1
    // CHECK: [[@LINE-6]]:26 | struct/Swift | Int | {{.*}} | Ref,RelCont | rel: 1
    // CHECK-NEXT: RelCont | instance-property/Swift | wrappedProperty | {{.*}}

    init(a: Int) {}
    // CHECK: [[@LINE-1]]:5 | constructor/Swift | init(a:) | {{.*}} | Def,RelChild | rel: 1
    // CHECK-NEXT: RelChild | struct/Swift | SomeStruct | {{.*}}
    // CHECK: [[@LINE-3]]:13 | struct/Swift | Int | {{.*}} | Ref,RelCont | rel: 1
    // CHECK-NEXT: RelCont | constructor/Swift | init(a:) | {{.*}}
}
