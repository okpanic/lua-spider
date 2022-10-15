rockspec_format = "1.0"
package = "lua-spider"
version = "1.0-1"

source = {
  url = "https://github.com/okpanic/lua-spider/raw/master/lua-spider-1.0.tar.gz",
  tag = "1.0"
}

description = {
  summary = "web scraper",
  detailed = "A web scraper for lua based on the gumbo HTML5 parser and xpath like content extraction.",
  homepage = "https://github.com/okpanic/lua-spider",
  license = "GPLv3"
}

dependencies = {
  "lua ~> 5.1"
}

build = {
  type = "builtin",
  modules = {
    ["lua-spider"] = "lua-spider/init.lua",
    ["lua-spider.bones"] = "lua-spider/bones.lua",
    ["lua-spider.filter"] = "lua-spider/filter.lua",
    ["lua-spider.extractor"] = "lua-spider/extractor.lua",
    ["lua-spider.crawler"] = "lua-spider/crawler.lua"
  }
}
