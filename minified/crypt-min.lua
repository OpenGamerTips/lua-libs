--/ crypt.lua by H3x0R
local a,b,c,d,e=math.random,string.sub,string.format,string.byte,string.char;local f={}local g="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789`~!@#$%^&*()-_=+[{]}\\|\"';:?/.>,<"f.random=function(h)assert(type(h)=="number","bad argument #1 to 'random' (number expected, got "..type(h)..")")assert(h<=1024 and h>0,"size cannot be negative or exceed 1024")local i=""for j=1,h do local k=a(1,#g)i=i..b(g,k,k)end;return i end;f.binary={}f.binary.encode=function(l)l=tonumber(l)assert(type(l)=="number","bad argument #1 to 'encode' (Tuple<string, number> expected, got "..type(l)..")")local m=''for j=7,0,-1 do local n=2^j;if l>=n then m=m..'1'l=l-n else m=m..'0'end end;return m end;f.binary.decode=function(o)assert(type(o)=="string","bad argument #1 to 'encode' (string expected, got "..type(o)..")")return tonumber(o,2)end;f.hex={}f.hex.encode=function(p,q)assert(type(p)=="string","bad argument #1 to 'encode' (string expected, got "..type(p)..")")return p:gsub(".",function(r)r=d(r)return q and c("%02X",r)or c("%02x",r)end)end;f.hex.decode=function(p)assert(type(p)=="string","bad argument #1 to 'decode' (string expected, got "..type(p)..")")return p:gsub("..",function(s)s=tonumber(s,16)return e(s)end)end;f.base64={}f.base64.index='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'f.base64.encode=function(p,t)assert(type(p)=="string","bad argument #1 to 'encode' (string expected, got "..type(p)..")")local u=""local m=""local v=""p:gsub(".",function(r)r=d(r)m=m..f.binary.encode(r)end)if#m%3==2 then if not t then v="=="end;m=m.."0000000000000000"elseif#m%3==1 then if not t then v="="end;m=m.."00000000"end;m:gsub("......",function(w)local x=f.binary.decode(w)u=u..b(f.base64.index,x+1,x+1)end)return b(u,1,-1-#v)..v end;f.base64.decode=function(p)assert(type(p)=="string","bad argument #1 to 'decode' (string expected, got "..type(p)..")")local y=p:gsub("%s","")local z=y:gsub("=","")local A=""local m=""z:gsub(".",function(r)local x=string.find(f.base64.index,r)if not x then error("invalid character")return nil end;m=m..b(f.binary.encode(x-1),3)end)m:gsub("........",function(w)A=A..e(f.binary.decode(w))end)local B=#y-#z;if B==1 or B==2 then A=b(A,1,-1)end;return A end;return f