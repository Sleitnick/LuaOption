# Lua Option

Options are useful for handling `nil`-value cases. Any time that an operation might return `nil`, it is useful to instead return an Option, which will indicate that the value might be `nil`, and should be explicitly checked before using the value. This will help prevent common bugs cause by `nil` values that can fail silently.

Inspired by Rust's [Option](https://doc.rust-lang.org/std/option/) module.

## API

### `opt = Option.Some(anyNonNilValue)`
Construct an Option with _some_ value.

### `opt = Option.None`
Represent no value.

--------------

### `opt:Match(matchTable)`
Match the option to either None or Some. The `matchTable` should look like such:

```lua
{
	Some = function(someNonNilValue) ... end;
	None = function() ... end;
}
```

### `opt:IsSome()`
Returns `true` if the option represents some non-`nil` value.

### `opt:IsNone()`
Returns `true` if the option represents a `nil` value.

### `opt:Unwrap()`
Returns the value inside the option. Throws an error if None.

### `opt:Contains(value)`
Returns `true` if `opt` is Some and its value is equal to the `value` argument.

### `opt:Expect(message)`
Throw `message` error if `opt` is None.

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