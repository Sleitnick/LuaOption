package.path = package.path .. ";./src/option.lua"
local Option = require("./src/option")

local Test = {_tests = {}}

function Test:Add(name, func, expectFail)
	assert(type(func) == "function", "Expected function for test")
	if (type(name) ~= "string") then
		name = "Test"
	end
	table.insert(self._tests, {Name = name, Func = func; ExpectFail = expectFail})
end

function Test:Run()
	local n = #self._tests
	local succeeded = 0
	for i,test in ipairs(self._tests) do
		local success, val, msg = pcall(function()
			return test.Func()
		end)
		if (test.ExpectFail) then
			success = (not success)
		elseif (success) then
			success = val
			val = msg or ""
		end
		print(("[%i/%i] %s: %s"):format(i, n, test.Name, success and "SUCCESS" .. (test.ExpectFail and " (" .. tostring(val) .. ")" or "") or "FAIL (" .. tostring(val) .. ")"))
		if (success) then
			succeeded = (succeeded + 1)
		end
	end
	print(("TEST RESULTS: %i/%i tests successful"):format(succeeded, n))
end


Test:Add("Should successfully create Some number", function()
	local opt = Option.Some(32)
	return opt:IsSome()
end)
Test:Add("Should successfully create Some string", function()
	local opt = Option.Some("Hello world")
	return opt:IsSome()
end)
Test:Add("Should successfully create Some bool true", function()
	local opt = Option.Some(true)
	return opt:IsSome()
end)
Test:Add("Should successfully create Some bool false", function()
	local opt = Option.Some(false)
	return opt:IsSome()
end)
Test:Add("Should successfully create Some function", function()
	local opt = Option.Some(function() end)
	return opt:IsSome()
end)
Test:Add("Should successfully create Some thread", function()
	local opt = Option.Some(coroutine.create(function() end))
	return opt:IsSome()
end)
Test:Add("Should successfully create Some table", function()
	local opt = Option.Some({})
	return opt:IsSome()
end)
Test:Add("Should successfully reference None", function()
	return Option.None
end)

Test:Add("Should fail to create Some of nil", function()
	Option.Some(nil)
end, true)

Test:Add("Should successfully wrap value", function()
	local opt = Option.Wrap("abc")
	return opt:IsSome()
end)
Test:Add("Should successfully wrap nil", function()
	local opt = Option.Wrap(nil)
	return opt:IsNone()
end)

Test:Add("Should successfully unwrap value", function()
	local opt = Option.Some("abc")
	return opt:Unwrap() == "abc"
end)

Test:Add("Should fail to unwrap nil", function()
	local opt = Option.None
	opt:Unwrap()
end, true)

Test:Add("And Some", function()
	local opt1 = Option.Some(true)
	local opt2 = Option.Some(32)
	return opt1:And(opt2) == opt2
end)
Test:Add("And None", function()
	local opt1 = Option.None
	local opt2 = Option.Some(32)
	return opt1:And(opt2) == Option.None
end)

Test:Add("AndThen", function()
	local result = Option.Some(10)
		:AndThen(function(value)
			return Option.Some(value * 2)
		end)
	return result:Contains(20)
end)
Test:Add("AndThen fail to return option", function()
	local result = Option.Some(10)
		:AndThen(function(value)
			return (value * 2)
		end)
	return result:Contains(20)
end, true)
Test:Add("AndThen None", function()
	local result = Option.None
		:AndThen(function(value)
			return Option.Some(value * 2)
		end)
	return result:IsNone()
end)

Test:Add("Or First", function()
	local opt1 = Option.Some(5)
	local opt2 = Option.Some(10)
	return opt1:Or(opt2) == opt1
end)
Test:Add("Or First", function()
	local opt1 = Option.Some(5)
	local opt2 = Option.Some(10)
	return opt1:Or(opt2) == opt1
end)

Test:Add("OrElse Some", function()
	local opt1 = Option.Some(5)
	local opt2 = Option.Some(10)
	local function orElse()
		return opt2
	end
	return opt1:OrElse(orElse) == opt1
end)
Test:Add("OrElse None", function()
	local opt1 = Option.None
	local opt2 = Option.Some(10)
	local function orElse()
		return opt2
	end
	return opt1:OrElse(orElse) == opt2
end)
Test:Add("OrElse fail to return Option", function()
	local opt1 = Option.None
	local function orElse()
		return 10
	end
	opt1:OrElse(orElse)
end, true)

Test:Add("XOr Some|Some|None", function()
	local opt1 = Option.Some(10)
	local opt2 = Option.Some(20)
	return opt1:XOr(opt2) == Option.None
end)
Test:Add("XOr Some|None|Some", function()
	local opt1 = Option.Some(10)
	local opt2 = Option.None
	return opt1:XOr(opt2) == opt1
end)
Test:Add("XOr None|Some|Some", function()
	local opt1 = Option.None
	local opt2 = Option.Some(20)
	return opt1:XOr(opt2) == opt2
end)
Test:Add("XOr None|None|None", function()
	local opt1 = Option.None
	local opt2 = Option.None
	return opt1:XOr(opt2) == Option.None
end)

Test:Add("Filter Some Match", function()
	local opt = Option.Some(10)
	local filter = function(value)
		return value == 10
	end
	return opt:Filter(filter) == opt
end)
Test:Add("Filter Some No Match", function()
	local opt = Option.Some(10)
	local filter = function(value)
		return value ~= 10
	end
	return opt:Filter(filter) == Option.None
end)
Test:Add("Filter None", function()
	local opt = Option.None
	local filter = function(value)
		return value == 10
	end
	return opt:Filter(filter) == Option.None
end)

Test:Add("Contains Success", function()
	local opt = Option.Some(10)
	return opt:Contains(10)
end)
Test:Add("Contains Fail", function()
	local opt = Option.Some(10)
	return not opt:Contains(20)
end)

Test:Add("Equality same object", function()
	local opt1 = Option.Some(10)
	return opt1 == opt1
end)
Test:Add("Equality same value", function()
	local opt1 = Option.Some(10)
	local opt2 = Option.Some(10)
	return opt1 == opt2
end)
Test:Add("Equality different value", function()
	local opt1 = Option.Some(10)
	local opt2 = Option.Some(20)
	return opt1 ~= opt2
end)
Test:Add("Equality against none", function()
	local opt1 = Option.Some(10)
	local opt2 = Option.None
	return opt1 ~= opt2
end)
Test:Add("Equality not equal to non option", function()
	local opt1 = Option.Some(10)
	return opt1 ~= 10
end)
Test:Add("Equality nones", function()
	local opt1 = Option.None
	local opt2 = Option.None
	return opt1 == opt2
end)

Test:Add("tostring None", function()
	local opt1 = Option.None
	return tostring(opt1) == "Option<None>"
end)
Test:Add("tostring Some Number", function()
	local opt1 = Option.Some(32)
	return tostring(opt1) == "Option<number>"
end)


Test:Run()