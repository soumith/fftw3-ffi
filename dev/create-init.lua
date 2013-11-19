--  Adapted from https://github.com/torch/sdl2-ffi/blob/master/dev/create-init.lua
print[[
-- Do not change this file manually
-- Generated with dev/create-init.lua

local ffi = require 'ffi'
local C = ffi.load('fftw3')
local fftw = {}

require 'fftw3.cdefs'

local function register(luafuncname, funcname)
   local symexists, msg = pcall(function()
                              local sym = C[funcname]
                           end)
   if symexists then
      fftw[luafuncname] = C[funcname]
   end
end
]]

local defined = {}

local txt = io.open('cdefs.lua'):read('*all')
for funcname in txt:gmatch('fftw_([^%=,%.%;<%s%(%)]+)%s*%(') do
   if funcname and not defined[funcname] then
      local luafuncname = funcname:gsub('^..', function(str)
                                                  if str == 'RW' then
                                                     return str
                                                  else
                                                     return string.lower(str:sub(1,1)) .. str:sub(2,2)
                                                  end
                                               end)
      print(string.format("register('%s', 'fftw_%s')", luafuncname, funcname))
      defined[funcname] = true
   end
end

print()

for defname in txt:gmatch('fftw_([^%=,%.%;<%s%(%)|%[%]]+)') do
   if not defined[defname] then
      print(string.format("register('%s', 'fftw_%s')", defname, defname))
   end
end

print[[

return fftw
]]
