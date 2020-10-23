--/ Project: bitop.lua
--/ Version: 2.2
--/ Author: H3x0R
--/ Summary: A project to replace bitwise operations in Lua 5.1 without use of external libraries. Version 2 adds documentation, gives more accurate results, and is overall more optimized and faster than version 1.
--/ License: Bottom of script.

local mod, max, floor, insert, concat = math.fmod, math.max, math.floor, table.insert, table.concat
local ValidateArguments = function(...) -- Too lazy to copy and paste asserts.
    local Args = {...}

    local FName;
    local Expected;
    for Key, Value in ipairs(Args) do
        if Key == 1 then
            FName = Value
        elseif Key % 2 ~= 0 then
            assert(type(Value) == Expected, "bad argument #"..((Key / 2) - 0.5).." to '"..FName.."' ("..Expected.." expected, got "..type(Value)..")")
        else
            Expected = Value
        end
    end
end

local bit = {}
local Bit32MaxUnsigned = 0xFFFFFFFF -- Max unsigned 32 bit number.
local Bit32MaxToBit = 0xFFFFFFFF + 1

local TempBit = {}
local TempBit_Sorted = {}

--/ Function: CreateBitTable
--/ Type: Internal
--/ Summary: Splits a number into bits.
--/ Arguments: <number> Number, <bool> IsAdding
local function CreateBitTable(Num, C)
    ValidateArguments("CreateBitTable", "number", Num)
    if not Num then return end
	if not C then
		TempBit = {}
		TempBit_Sorted = {}
	end
	
	if (Num or 0) == 0 then
		for Key, Value in pairs(TempBit) do
			TempBit_Sorted[#TempBit - Key + 1] = Value
		end
		
		return TempBit_Sorted
	end
	
	insert(TempBit, mod(Num, 2))
	return CreateBitTable(floor(Num / 2), true)
end

--/ Function: CreateBitOperation
--/ Type: Internal
--/ Summary: Creates a bitwise operation with a truth table.
--/ Arguments: <table> TruthTable
local function CreateBitOperation(TruthTable)
    ValidateArguments("CreateBitOperation", "table", TruthTable)
    local function TTCheck(X, Y)
        X = X or 0
        Y = Y or 0
        
        for _, Combination in pairs(TruthTable) do
            if X == Combination[1] and Y == Combination[2] then
                return Combination[3]
            end
        end
    end
    
    local function Operation(X, Y)
        if not Y then
            return X
        end
        
        X = CreateBitTable(X)
        Y = CreateBitTable(Y)
        
        local Ret = {}
        local XLen, YLen = #X, #Y
        local Largest = max(XLen, YLen)
        for Key = 0, Largest - 1 do
			local V1, V2 = X[XLen - Key], Y[YLen - Key]
			if not (V1 or V2) then
			    break
			end
			
            Ret[Largest - Key] = TTCheck(V1, V2)
        end
        
        return Operation(tonumber(concat(Ret), 2))
    end
    
    return Operation
end

--/ Function: tobit
--/ Type: External
--/ Summary: Calculates a 32 bit number from a number.
--/ Arguments: <number> Number
local function tobit(Number)
    ValidateArguments("tobit", "number", Number)
    Number = mod(Number, Bit32MaxToBit)
    if Number >= 0x80000000 then -- Calculate 32bit
        Number = Number - Bit32MaxToBit
        return Number
    end
    
    return Number
end

--/ Function: tohex
--/ Type: External
--/ Summary: Converts a number into a hexadecimal string.
--/ Arguments: <number> Number, <number> Places = 8
local function tohex(Number, Places)
    ValidateArguments("tohex", "number", Number, "number", Places)
    Places = Places or 8
    return string.format("%0"..tostring(Places).."x", Number)
end

--/ Function: band
--/ Type: External
--/ Summary: Preforms a bitwise AND on two numbers.
--/ Arguments: <number> X, <number> Y
local band = CreateBitOperation({
    {0, 0, 0};
    {0, 1, 0};
    {1, 0, 0};
    {1, 1, 1};
})

--/ Function: bor
--/ Type: External
--/ Summary: Preforms a bitwise OR on two numbers.
--/ Arguments: <number> X, <number> Y
local bor = CreateBitOperation({
    {0, 0, 0};
    {0, 1, 1};
    {1, 0, 1};
    {1, 1, 1};
})

--/ Function: bxor
--/ Type: External
--/ Summary: Preforms a bitwise XOR on two numbers.
--/ Arguments: <number> X, <number> Y
local bxor = CreateBitOperation({
    {0, 0, 0};
    {0, 1, 1};
    {1, 0, 1};
    {1, 1, 0};
})

--/ Function: bnot
--/ Type: External
--/ Summary: Preforms a bitwise NOT on one number.
--/ Arguments: <number> X
local function bnot(X)
    ValidateArguments("bnot", "number", X)
    return tobit(Bit32MaxUnsigned - X)
end

local lshift, rshift;
--/ Function: lshift
--/ Type: External
--/ Summary: Preforms a bitwise left shift on one number.
--/ Arguments: <number> X, <number> By
lshift = function(X, By)
    ValidateArguments("lshift", "number", X, "number", By)
    if By < 0 then
        return rshift(X, -By)
    end

	return mod(X * 2 ^ By, Bit32MaxUnsigned)
end

--/ Function: rshift
--/ Type: External
--/ Summary: Preforms a bitwise right shift on one number.
--/ Arguments: <number> X, <number> By
rshift = function(X, By)
    ValidateArguments("rshift", "number", X, "number", By)
    By = By or 1
    if By < 0 then
        return lshift(X, -By)
    end

	return floor(mod(X, Bit32MaxUnsigned) / 2 ^ By)
end

--/ Function: arshift
--/ Type: External
--/ Summary: Preforms a logical left-right shift on one number.
--/ Arguments: <number> X, <number> By
local function arshift(X, By)
    ValidateArguments("arshift", "number", X, "number", By)
    X = mod(X, Bit32MaxUnsigned)
	
	if By >= 0 then
		if By > 31 then
			return (By >= 0x80000000) and Bit32MaxToBit or 0
		else
			local Shifted = rshift(X, By)
			if X >= 0x80000000 then 
				Shifted = Shifted + lshift(2 ^ By - 1, 32 - By)
			end
			
			return Shifted
		end
	else
		return lshift(X, -By)
	end
end

--/ Function: bswap
--/ Type: External
--/ Summary: Swaps the bits of one number.
--/ Arguments: <number> X
local function bswap(X)
    ValidateArguments("bswap", "number", X)
    local S1 = band(X, 0xFF)
    X = rshift(X, 8)

    local S2 = band(X, 0xFF)
    X = rshift(X, 8)

    local S3 = band(X, 0xFF)
    X = rshift(X, 8)

    local S4 = band(X, 0xFF)
    return lshift(lshift(lshift(S1, 8) + S2, 8) + S3, 8) + S4
end

--/ Function: ror
--/ Type: External
--/ Summary: Rotates the bits of a number right.
--/ Arguments: <number> X, <number> By
local function ror(X, By)
    By = By % 32
    return rshift(X, By) + lshift(band(2 ^ By - 1), 32 - By)
end

--/ Function: rol
--/ Type: External
--/ Summary: Rotates the bits of a number left.
--/ Arguments: <number> X, <number> By
local function rol(X, By)
    return ror(X, -By)
end

--------------------------
---- EXPORT FUNCTIONS ----
--------------------------
--/ CHANGES:
--/ Added extra argument support.
--/ Fixed argument validation.

bit.tobit = tobit
bit.tohex = tohex
bit.band = function(X, Y, Z, ...) 
    ValidateArguments("band", "number", X)
    if Z then
        return bit.band(bit.band(X, Y), Z, ...)
    elseif Y then
        return tobit(band(X % Bit32MaxUnsigned, Y % Bit32MaxUnsigned))
    else
        return tobit(X)
    end
end

bit.bor = function(X, Y, Z, ...)
    ValidateArguments("bor", "number", X)
    if Z then
        return bit.bor(bit.bor(X, Y), Z, ...)
    elseif Y then
        return tobit(bor(X % Bit32MaxUnsigned, Y % Bit32MaxUnsigned))
    else
        return tobit(X)
    end
end

bit.bxor = function(X, Y, Z, ...)
    ValidateArguments("bxor", "number", X)
    if Z then
        return bit.bxor(bit.bxor(X, Y), Z, ...)
    elseif Y then
        return tobit(bxor(X % Bit32MaxUnsigned, Y % Bit32MaxUnsigned))
    else
        return tobit(X)
    end
end

bit.bnot = function(X)
    return tobit(bnot(X))
end

bit.lshift = function(X, By)
	return tobit(lshift(X, By))
end

bit.rshift = function(X, By)
	return tobit(rshift(X, By))
end

bit.arshift = function(X, By)
	return tobit(arshift(X, By))
end

bit.bswap = function(X)
    return tobit(bswap(X))
end

bit.ror = function(X, By)
    ValidateArguments("ror", "number", X, "number", By)
    return ror(X, By)
end

bit.rol = function(X, By)
    ValidateArguments("rol", "number", X, "number", By)
    return rol(X, By)
end

bit.rrotate = function(X, By)
    ValidateArguments("rrotate", "number", X, "number", By)
    return ror(X, By)
end

bit.lrotate = function(X, By)
    ValidateArguments("lrotate", "number", X, "number", By)
    return rol(X, By)
end

return bit

--[[
    Copyright (c) 2020 H3x0R

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]