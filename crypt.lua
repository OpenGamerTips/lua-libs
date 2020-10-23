--/ Project: crypt.lua
--/ Version: 1.0
--/ Author: H3x0R
--/ Summary: Simple cryptography library in Lua 5.1.
--/ License: Bottom of script.

local random, sub, format, byte, char = math.random, string.sub, string.format, string.byte, string.char
local crypt = {}
-- Random String Generation
local CharacterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789`~!@#$%^&*()-_=+[{]}\\|\"';:?/.>,<"
crypt.random = function(Size)
    assert(type(Size) == "number", "bad argument #1 to 'random' (number expected, got "..type(Size)..")")
    assert(Size <= 1024 and Size > 0, "size cannot be negative or exceed 1024")
    local Rand = ""
    for i = 1, Size do
        local RPick = random(1, #CharacterSet)
        Rand = Rand..sub(CharacterSet, RPick, RPick)
    end

    return Rand
end

-- Binary Encoding
crypt.binary = {}
crypt.binary.encode = function(Number)
    Number = tonumber(Number)
    assert(type(Number) == "number", "bad argument #1 to 'encode' (Tuple<string, number> expected, got "..type(Number)..")")

    local Bits = ''
    for i = 7, 0, -1 do
        local Pow = 2 ^ i
        if Number >= Pow then
            Bits = Bits..'1'
            Number = Number - Pow
        else
            Bits = Bits..'0'
        end
    end
    return Bits
end

crypt.binary.decode = function(BitString)
    assert(type(BitString) == "string", "bad argument #1 to 'encode' (string expected, got "..type(BitString)..")")
    return tonumber(BitString, 2)
end

-- Hexadecimal Encoding
crypt.hex = {}
crypt.hex.encode = function(Raw, Cap)
    assert(type(Raw) == "string", "bad argument #1 to 'encode' (string expected, got "..type(Raw)..")")
    return Raw:gsub(".", function(Character)
        Character = byte(Character)
        return Cap and format("%02X", Character) or format("%02x", Character)
    end)
end

crypt.hex.decode = function(Raw)
    assert(type(Raw) == "string", "bad argument #1 to 'decode' (string expected, got "..type(Raw)..")")
    return Raw:gsub("..", function(Hex)
        Hex = tonumber(Hex, 16)
        return char(Hex)
    end)
end

-- Base64 Encoding
crypt.base64 = {}
crypt.base64.index = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
crypt.base64.encode = function(Raw, DoTrail)
    assert(type(Raw) == "string", "bad argument #1 to 'encode' (string expected, got "..type(Raw)..")")
    local Enc = ""
    local Bits = ""
    local Trail = ""

    Raw:gsub(".", function(Character)
        Character = byte(Character)
        Bits = Bits..crypt.binary.encode(Character)
    end)

    if #Bits % 3 == 2 then
        if not DoTrail then Trail = "==" end
        Bits = Bits.."0000000000000000"
    elseif #Bits % 3 == 1 then
        if not DoTrail then Trail = "=" end
        Bits = Bits.."00000000"
    end

    Bits:gsub("......", function(Bytes)
        local Offset = crypt.binary.decode(Bytes)
        Enc = Enc..sub(crypt.base64.index, Offset + 1, Offset + 1)
    end)

    return sub(Enc, 1, -1 - #Trail)..Trail
end

crypt.base64.decode = function(Raw)
    assert(type(Raw) == "string", "bad argument #1 to 'decode' (string expected, got "..type(Raw)..")")
    local SpaceStrip = Raw:gsub("%s", "")
    local TrailStrip = SpaceStrip:gsub("=", "")
    local Dec = ""
    local Bits = ""

    TrailStrip:gsub(".", function(Character)
        local Offset = string.find(crypt.base64.index, Character)
        if not Offset then
            error("invalid character")
            return nil
        end

        Bits = Bits..sub(crypt.binary.encode(Offset - 1), 3)
    end)

    Bits:gsub("........", function(Bytes)
        Dec = Dec..char(crypt.binary.decode(Bytes))
    end)

    local Padding = #SpaceStrip - #TrailStrip
    if Padding == 1 or Padding == 2 then
        Dec = sub(Dec, 1, -1)
    end

    return Dec
end

return crypt

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