local bones = require("lua-spider.bones")
local filter = {}

function filter._containing( text, query )
   local out
   if type(text) == "table" then
      out = {}
      for _, v in ipairs(text) do
	 if string.match(v, query) then
	    out[#out+1] = v
	 end
      end
   else
      if string.match(text, query) then
	 out = text
      end
   end
   if out then
      return out
   else
      return nil
   end
end

function filter._cutout( text, cut )
   local out
   if type(text) == "table" then
      out = {}
      for _, v in ipairs(text) do
	 out[#out+1] = v:gsub(cut, "")
      end
   else
      out = text:gsub(cut, "")
   end
   if out then
      return out
   else
      return nil
   end
end

function filter._trimwhitespace( text )
   return bones.trimwhitespace(text)
end

function filter._rootlink( url, root )
   local t
   if type(url) == "table" then
      t = {}
      for k, v in ipairs(url) do
	 t[k] = filter._cutout(v, "[%&|%?]ie%=UTF8.*")
	 if not string.match(t[k], root) then
	    t[k] = root .. "/" .. t[k]:gsub("^/", "")
	 end
      end
   else
      t = filter._cutout(url, "[%&|%?]ie%=UTF8.*")
      if not string.match(t, root) then
	 t = root .. "/" .. t:gsub("^/", "")
      end
   end
   return t
end

function filter._gsub( s, g )
   return s:gsub(g[1], g[2]) or nil
end

function filter._pricefix( price )
   local t
   if type(price) == "table" then
      t = {}
      for k, v in ipairs(price) do
	 t[k] = filter._cutout(v, "%$")
	 t[k] = filter._cutout(t[k], ",")
      end
   else
      t = filter._cutout(price, "%$")
      t = filter._cutout(t, ",")
   end
   return tonumber(t)
end

function filter._justext( html )
   local out = {}
   local htmlf = bones.temppath() .. ".html"
   bones.writefile(htmlf, html)
   local cmd = [[python -m justext --no-headings -s English "$htmlfile"]]
   cmd = cmd:gsub("$htmlfile", htmlf)
   local ex = assert(io.popen(cmd))
   for line in ex:lines() do
      out[#out+1] = line:gsub("^%b<p> ", "")
   end
   return out or nil
end

return filter
