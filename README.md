# Lua Option

Options are useful for handling `nil`-value cases. Any time that an operation might return `nil`, it is useful to instead return an Option, which will indicate that the value might be `nil`, and should be explicitly checked before using the value. This will help prevent common bugs caused by `nil` values that can fail silently.

Inspired by Rust's [Option](https://doc.rust-lang.org/std/option/) module.

## API

### Constructors

#### `Option.Some(anyNonNilValue: any): Option<any>`
Construct an Option with _some_ value.

#### `Option.Wrap(value: any): Option<any>`
Construct an Option with some _or_ no value.

### Static Fields

#### `Option.None: Option<None>`
Represent no value.

### Static Methods

#### `Option.Is(value: any): boolean`
Checks if the passed `value` is an Option type.

#### `Option.Assert(value: any): void`
Checks if the passed `value` is an Option type and throws an error if not.

--------------

### Object Methods

#### `opt:Match(matchTable: table): any`
Match the option to either None or Some. The `matchTable` should look like such:

```lua
{
	Some = function(someNonNilValue) ... end;
	None = function() ... end;
}
```

Additionally, Match can return values:

```lua
local value = Option.Some(32):Match {
	Some = function(v) return v * 2 end;
	None = function() return 0 end;
}
```

#### `opt:IsSome(): boolean`
Returns `true` if the option represents some non-`nil` value.

```lua
print(Option.Some(32):IsSome()) -- > true
print(Option.None:IsSome()) -- > false
```

#### `opt:IsNone(): boolean`
Returns `true` if the option represents a `nil` value.

```lua
print(Option.Some(32):IsNone()) -- > false
print(Option.None:IsNone()) -- > true
```

#### `opt:Unwrap(): any`
Returns the value inside the option. Throws an error if None. To avoid an error being thrown, it is recommended to check `IsSome()` before calling this method.

```lua
local opt = Option.Some(32)
if opt:IsSome() then
	local value = opt:Unwrap()
end
```

The below example will throw an error:
```lua
local opt = Option.None
local value = opt:Unwrap() -- ERROR: Cannot unwrap option of None type
```

#### `opt:Contains(value: any): boolean`
Returns `true` if `opt` is Some and its value is equal to the `value` argument. Will always return `false` if the option is None.

```lua
local opt = Option.Some(32)
print(opt:Contains(32)) -- > true
```

#### `opt:Expect(message: string): void`
Throw `message` error if `opt` is `None`.

```lua
local opt = Option.None
opt:Expect("I was hoping this wasn't None, but here we are")
```

#### `opt:ExpectNone(message: string): void`
Throw `message` error if `opt` is _not_ `None`.

```lua
local opt = Option.Some(32)
opt:ExpectNone("If only this were None, I'd be happy")
```

#### `opt:UnwrapOr(default: any): any`
If `opt` is `Some`, then it will return the unwrapped value. Else, it will return the given `default` value.

```lua
local opt1 = Option.Some(32)
local opt2 = Option.None
print(opt1:UnwrapOr(10)) -- > 32
print(opt2:UnwrapOr(10)) -- > 10
```

#### `opt:UnwrapOrElse(defaultFunc: () -> any): any`
Same as `UnwrapOr`, except it will invoke the `defaultFunc` value if `opt` is `None`.

```lua
local function Default()
	return 10
end

local opt1 = Option.Some(32)
local opt2 = Option.None
print(opt1:UnwrapOr(Default)) -- > 32
print(opt2:UnwrapOr(Default)) -- > 10
```

#### `opt:And(optB: Option<any>): Option<any>`
If `opt` is `Some`, returns `optB`, otherwise returns `None`. `optB` can be of None type.

```lua
local opt1 = Option.Some(32)
local opt2 = Option.Some(20)
print(opt1:And(opt2) == opt2) -- > true

local opt1 = Option.None
local opt2 = Option.Some(20)
print(opt1:And(opt2) == opt2) -- > false
```

#### `opt:AndThen(andThenFunc: (value: any) -> Option<any>): Option<any>`
If `opt` is `Some`, then the `andThenFunc` is invoked with the unwrapped value of `opt`. Otherwise, returns `None`. The function must return another Option. This is useful for chaining options together.

```lua
local opt1 = Option.Some(10)
local opt2 = opt1:AndThen(function(value)
	return Option.Some(value * 2)
end)
print(opt2:Contains(20)) -- > true
```

#### `opt:Or(optB: Option<any>): Option<any>`
If `opt` is `Some`, returns `opt`. Else, returns `optB`.

```lua
local opt1 = Option.Some(10)
local opt2 = Option.Some(20)
local opt = opt1:Or(opt2)
print(opt == opt1) -- > true

local opt1 = Option.None
local opt2 = Option.Some(20)
local opt = opt1:Or(opt2)
print(opt == opt2) -- > true
```

#### `opt:OrElse(orElseFunc: () -> Option<any>): Option<any>`
If `opt` is `Some`, returns `opt`. Else, invokes the `orElseFunc`. The `orElseFunc` must return an Option.

```lua
local opt1 = Option.Some(10)
local opt2 = Option.Some(20)
local opt = opt1:OrElse(function() return opt2 end)
print(opt == opt1) -- > true

local opt1 = Option.None
local opt2 = Option.Some(20)
local opt = opt1:OrElse(function() return opt2 end)
print(opt == opt2) -- > true
```

#### `opt:XOr(optB: Option<any>): Option<any>`
Returns `None` if `opt` and `optB` are both `Some` or are both `None`. Else, returns whichever one is `Some`.

```lua
local opt1 = Option.Some(10)
local opt2 = Option.Some(20)
print(opt1:XOr(opt2) == Option.None) -- > true

local opt1 = Option.None
local opt2 = Option.None
print(opt1:XOr(opt2) == Option.None) -- > true

local opt1 = Option.None
local opt2 = Option.Some(20)
print(opt1:XOr(opt2) == opt2) -- > true

local opt1 = Option.Some(20)
local opt2 = Option.None
print(opt1:XOr(opt2) == opt1) -- > true
```

#### `opt:Filter(predicate: (value: any) -> boolean): Option<any>`
Returns `opt` if `opt` is `Some` and the `predicate` function returns `true` given the unwrapped value of `opt`. Otherwise, returns `None`.

```lua
local opt = Option.Some(10)
local filtered = opt:Filter(function(value) return value == 10 end)
print(opt == filtered) -- > true

local opt = Option.Some(10)
local filtered = opt:Filter(function(value) return value ~= 10 end)
print(opt == Option.None) -- > true
```

--------------------

## Examples

### Find item in table

```lua
local data = {"ABC", "XYZ"}

local function IndexTable(tbl, i)
	if data[i] then
		return Option.Some(data[i])
	end
	return Option.None
end

local item1 = IndexTable(data, 1)
local item5 = IndexTable(data, 5)

item1:Match {
	Some = function(value) print(value) end;
	None = function() print("No item1") end;
}

item5:Match {
	Some = function(value) print(value) end;
	None = function() print("No item5") end;
}

-- Will output:
-- > ABC
-- > No item5
```

### Divide

```lua
-- Returns 'None' if trying to divide by 0:
local function Divide(numerator, denominator)
	if denominator == 0 then
		return Option.None
	end
	return Option.Some(numerator / denominator)
end

local div1 = Divide(20, 5)
local div2 = Divide(40, 0)

-- Using IsSome() and Unwrap() instead of Match():
if div1:IsSome() then
	print(div1:Unwrap())
else
	print("div1 avoided divide-by-0")
end

if div2:IsSome() then
	print(div2:Unwrap())
else
	print("div2 avoided divide-by-0")
end
```

### Random Number

```lua
-- Returns Some(value) if number is > 5, else returns None:
local function RandomNumber()
	local n = math.random(1, 10)
	if n > 5 then
		return Option.Some(n)
	end
	return Option.None
end

-- Check if random number is equal to 8:
if RandomNumber():Contains(8) then
	...
end

-- Handle RandomNumber:
RandomNumber():Match {
	Some = function(n) ... end;
	None = function() ... end;
}

-- Continue to ask for a random number until not None:
local randomNum
repeat
	randomNum = RandomNumber()
until randomNum:IsSome()
print(randomNum:Unwrap())
```
