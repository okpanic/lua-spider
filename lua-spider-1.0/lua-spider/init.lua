local bones = require("lua-spider.bones")

local _spider = {
   crawler = require("lua-spider.crawler"),
   extractor = require("lua-spider.extractor")
}

   local function isparam(t)
      if not t then return false end
      if type(t) ~= "table" then return false end
      for k, v in pairs(t) do
         if k ~= "filter" and k ~= "url" then
   	 if type(v) == "table" then
   	    return false
   	 else
   	    return true
   	 end
         end
      end
   end
   
   local function islink(l, cake)
      if not l then return false end
      if type(l) == "table" then return false end
      if string.match(l, "http") then return false end
      if string.match(l, "%.") then
         l = bones.split(l, ".")
      else
         l = {l}
      end
      if cake[l[1]] then
         return true
      else
         return false
      end
   end
   
   local function melttable(arr)
      if type(arr) == "table" then
         local result = {}
         local function toflat(_arr)
   	 for _, v in ipairs(_arr) do
   	    if type(v) == "table" then
   	       toflat(v)
   	    else
   	       table.insert(result, v)
   	    end
   	 end
         end
         toflat(arr)
         return result
      else
         return arr
      end
   end
   
   local function getlink(l, outputcake)
      assert(type(l) == "string")
      assert(type(outputcake) == "table")
      if string.match(l, "%.") then
         l = bones.split(l, ".")
      else
         l = {l}
      end
      for _, j in ipairs(l) do
         if not outputcake[j] then
   	 error("Link path incorrect")
         end
         outputcake = outputcake[j]
      end
      return outputcake
   end
   
   local function isnewlayer(t)
      if not t then return false end
      if type(t) ~= "table" then return false end
      for k, v in pairs(t) do
         if k ~= "filter" and k ~= "url" then
   	 if type(v) == "table" then
   	    if isparam(v) then
   	       return true
   	    end
   	 end
         end
      end
      return false
   end
   
   local function _crawl(_url, _node)
      aspider = aspider or _spider.crawler:new()
      if type(_url) == "table" then
         local out = {}
         for i, j in ipairs(_url) do
   	 out[i] = aspider:crawl(j, _node)
         end
         return melttable(out)
      else
         return aspider:crawl(_url, _node)
      end
   end
   
   local function wraptable(st)
      if not st then return {""} end 
      if (type(st) == "string")
         or (type(st) == "number")
      then
         return {st}
      elseif type(st) == "table" then
         return st
      else
         error("wtf " .. type(st))
      end
   end

   local function copytable(cake, layer, parent, _metaout)
      local output = {}
      local metaout = _metaout or {}
      layer = layer or cake
      if layer.url then
         if parent and islink(layer.url, parent) then
   	 layer.url = getlink(layer.url, parent)
         end
      end
   
      for k, v in pairs(layer) do
         if isparam(v) and k ~= "url" then
   	 output[k] = _crawl(layer.url, v) or {}
   	 output[k] = melttable(output[k])
   	 output[k] = wraptable(output[k])
   	 output[k] = melttable(output[k])
         metaout[k] = metaout[k] or {}
         metaout[k][#metaout[k]+1] = { template = v, output = output[k], thing = layer }
         end
      end
   
      if layer.drill then
         layer.drillcount = layer.drillcount or 3
         layer.drillcount = tonumber(layer.drillcount)-1
         for _ = 1, layer.drillcount do
   	 for k, v in pairs(layer) do
   	    if isparam(v) and k ~= "url" then
   	       output[k] = output[k] or {}
   	       table.insert(output[k], _crawl(output.drill[#output.drill], v) or {})
   	       output[k] = melttable(output[k])
   	       output[k] = wraptable(output[k])
   	       output[k] = melttable(output[k])
               metaout[k] = metaout[k] or {}
               metaout[k][#metaout[k]+1] = { template = v, output = output[k], thing = layer }
   	    end
   	 end
         end
         table.remove(output.drill)
         table.insert(output.drill, 1, layer.url)
      end
      for k, v in pairs(layer) do
         if isnewlayer(v) then
   	 output[k] = copytable(cake, v, output, metaout)
         end
      end
      return output, metaout
   end

   function _spider:new(c)
      c = c or {}
      setmetatable(c, self)
      self.__index = self
      return c
   end

function _spider:crawl(template)
   local out = {}
   local metaout = {}
   if template then
      out, metaout = copytable(template)
   end
   return out, metaout
end

function _spider:dump(_url)
   local chrome = require("lua-chrome"):new()
   chrome.url = _url
   local ok, err = pcall(chrome.dump, chrome)
   if not ok then
      print(err)
      return nil
   else
      return chrome.dom
   end
end

_spider.assign = {}
_spider.assign.crawler = function(_type) if _type and _type == "curl" then return _spider.crawler.curl else return _spider.crawler.chrome end end
_spider.assign.parser = function() return _spider.crawler.parse end
_spider.assign.extractor = function() return _spider.extractor end

local spider = _spider:new()

return spider
