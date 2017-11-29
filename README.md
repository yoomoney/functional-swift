Yandex Money Functional Swift library

# Functor

Transfer `A<T> -> A<U>` with `T -> U`  

```swift
let ƒ: (T) -> U

let a: T? = T()

let b: U? = ƒ <^> a
let c: U? = U() <^ a
let d: U? = a ^> U()
```

# Applicative

Applicative is a wrapper, that can apply wrapped function to wrapped
value.

Applicative transfer `A<T> -> A<U>` with `A<(T) -> U>`.

```swift
let ƒ: Optional<(T) -> U>

let a: T? = T()

let b: U? = ƒ <*> a
```

Applicative also has several auxiliary functions for applying a function
multiple arguments to the wrapped arguments:

```swift
liftA2: ((T, U) -> V, A<T>, A<U>) -> A<V>

liftA3: ((T, U, V) -> W, A<T>, A<U>, A<V>) -> A<W>
```

# Monad

Transfer `A<T> -> A<U>` with `T -> A<U>`

```swift
let ƒ: (T) -> U?

let a: T? = T()

let b: U? = ƒ -<< a
let c: U? = a >>- ƒ
```

# Monoid

Type which can be composed

```swift
struct Sum {
    let number: Integer
    
    init(_ number: Integer) {
        self.number = number
    }
}

extension Sum: Monoid {
    static func mempty() -> Sum {
        return Sum(0)
    }
    
    func mappend(_ monoid: Sum) -> Sum {
        return Sum(number + monoid.number)
    }
}

let numbers = [5, 8, 9, 0, 1, 7, 8]
let sum = numbers.map(Sum.init).mconcat().number // = 38
```