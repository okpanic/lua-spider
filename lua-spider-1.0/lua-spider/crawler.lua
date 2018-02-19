local bones = require("lua-spider.bones")

local _crawler = {}

_crawler = {
   filter = require("lua-spider.filter"),
   extract = require("lua-spider.extractor"),
   cURL = require("cURL"),
   gumbo = require("gumbo"),
   _chrome = require("lua-chrome"),
   redis = { port = 9000, uri = '127.0.0.1' },
   log = bones.log,
   html = {},
   doc = {}
}

function _crawler.prefilter(_doc, _v, _filter, npass)
   local temp
   for k, v in pairs(_filter) do
      if not npass then
         npass = _crawler.extract(_doc, _v.xpath, _v.selection) or ""
      end
      if npass and type(npass) == "table" then
         temp = {}
         for i, j in ipairs(npass) do
            temp[i] = _crawler.filter["_" .. k](j, v)
         end
      else
         temp = _crawler.filter["_" .. k](npass, v)
      end
   end
   return temp
end

function _crawler.scrape(_doc, _v)
   if _v.filter then
      if #_v.filter > 1 then
         local f
         for _, ifilter in ipairs(_v.filter) do
            f = _crawler.prefilter(_doc, _v, ifilter, f)
         end
         return f
      else
         return _crawler.prefilter(_doc, _v, _v.filter)
      end
   else
      return _crawler.extract(_doc, _v.xpath, _v.selection) or ""
   end
end

function _crawler.curl( uri, headers )
   local dat = {}
   local con = _crawler.cURL.easy()
   headers = headers or {"User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleCrawlerKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36"}
   con:setopt_ssl_verifypeer(false)
   con:setopt_httpheader(headers)
   con:setopt_url(uri)
   con:perform({writefunction = function(str) dat[#dat+1] = str end})
   dat = table.concat(dat, "")
   return dat
end

function _crawler.chrome( uri )
   local chrome = _crawler._chrome:new()
   chrome.url = uri
   local ok, err = pcall(chrome.dump, chrome)
   if not ok then
      print(err)
      return nil      
   else
      return chrome.dom
   end
end

function _crawler.parse( rawhtml )
   return _crawler.gumbo.parse(rawhtml)
end

function _crawler:new(g)
   g = g or {}
   setmetatable(g, self)
   self.__index = self
   return g
end

function _crawler:fulltext(url)
   return _crawler.filter["_justext"](self.html[url])
end

function _crawler:crawl(url, node)
   local out
   if type(url) ~= "string" then
      -- self.log.error("URL field given to crawler is not a string")
   end
   -- self.log.info("Crawling " .. url)
   if node.xpath then
      if string.match(url, "file://") then
         url = url:gsub("file://", "")
         self.html[url] = bones.readfile(url)
      else
         self.html[url] = self.html[url] or self.chrome(url) or self.curl(url)
      end
      self.doc[url] = self.doc[url] or self.parse(self.html[url])
      out = self.scrape(self.doc[url], node)
   elseif node.fulltext then
      self.html[url] = self.html[url] or self.curl(url)
      out = self.fulltext(self.html[url])
   elseif node.file then
      out = self.dlfile(self.curl(url, node.header or nil))
   end
   return out or nil
end

function _crawler:dlfile(url, chead)
   local out
   if type(url) ~= "string" then
      self.log.error("URL field given to crawler is not a string")
   end
   self.log.info("Downloading content at " .. url)
   out = self.curl(url, chead)
   return out or nil
end

local crawler = _crawler:new()

return crawler
