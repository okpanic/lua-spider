A web scraper for lua. Content is downloaded with either curl or headless-chrome, and HTML is parsed with gumbo. Xpath like expressions are used to extract content from parsed documents.  

Requires [torch paths](https://github.com/torch/paths) rock, penlight [stringx](https://stevedonovan.github.io/Penlight/api/libraries/pl.stringx.html) and [file](https://stevedonovan.github.io/Penlight/api/libraries/pl.file.html), and either curl or chrome with the [lua-chrome](https://github.com/okpanic/lua-chrome) rock, and [lua-gumbo](https://github.com/craigbarnes/lua-gumbo).

Spider has three parts, the crawler, parser, and extractor. For simple websites curl works well enough, but to scrape some js heavy sites I recommend switching to headless-chrome.

Install gumbo

```bash
git clone https://github.com/google/gumbo-parser
cd gumbo*
sudo ./gumbo.sh
sudo cp ./etc/profile.d/gumbolib.sh /etc/profile.d/
source /etc/profile
luarocks install gumbo
```

Install Lua-cURL, and lua-chrome.

```lua
luarocks install Lua-cURL
luarocks install https://github.com/okpanic/lua-chrome/raw/master/lua-chrome-1.0-1.src.rock

```

Simple example scraping a blog.

```lua
url = "http://quotes.toscrape.com/"

spider = require'lua-spider':new()
crawl = spider.assign.crawler("chrome")
parse = spider.assign.parser()
xpath = spider.assign.extractor()

html = crawl(url)
doc = parse(html) --this is the gumbo document tree

posts = xpath(doc, "//div[@class=quote]") --by default xpath returns a document tree

post = {}
for k, v in ipairs(posts) do
post[#post+1] = { content = xpath(v, "//span[@class=text]", "text")[1], --extract text
                  author = xpath(v, "//small[@class=author]", "text")[1],
                  tags = xpath(v, "//div[@class=tag]//a", "text") } --or 'href' for link
end
```

Output will look like:
```lua
{
  1 : 
    {
      author : "Albert Einstein"
      content : "“The world as we have created it is a process of our thinking. It cannot be changed without changing our thinking.”"
      tags : 
        {
          1 : "change"
          2 : "deep-thoughts"
          3 : "thinking"
          4 : "world"
        }
    }
  2 : 
    {
      author : "J.K. Rowling"
      content : "“It is our choices, Harry, that show what we truly are, far more than our abilities.”"
      tags : 
        {
          1 : "abilities"
          2 : "choices"
        }
    }
  3 : 
    {
      author : "Albert Einstein"
      content : "“There are only two ways to live your life. One is as though nothing is a miracle. The other is as though everything is a miracle.”"
      tags : 
        {
          1 : "inspirational"
          2 : "life"
          3 : "live"
          4 : "miracle"
          5 : "miracles"
        }
    }
  4 : 
    {
      author : "Jane Austen"
      content : "“The person, be it gentleman or lady, who has not pleasure in a good novel, must be intolerably stupid.”"
      tags : 
        {
          1 : "aliteracy"
          2 : "books"
          3 : "classic"
          4 : "humor"
        }
    }
  5 : 
    {
      author : "Marilyn Monroe"
      content : "“Imperfection is beauty, madness is genius and it's better to be absolutely ridiculous than absolutely boring.”"
      tags : 
        {
          1 : "be-yourself"
          2 : "inspirational"
        }
    }
  6 : 
    {
      author : "Albert Einstein"
      content : "“Try not to become a man of success. Rather become a man of value.”"
      tags : 
        {
          1 : "adulthood"
          2 : "success"
          3 : "value"
        }
    }
  7 : 
    {
      author : "André Gide"
      content : "“It is better to be hated for what you are than to be loved for what you are not.”"
      tags : 
        {
          1 : "life"
          2 : "love"
        }
    }
  8 : 
    {
      author : "Thomas A. Edison"
      content : "“I have not failed. I've just found 10,000 ways that won't work.”"
      tags : 
      {
  1 : 
    {
      author : "Albert Einstein"
      content : "“The world as we have created it is a process of our thinking. It cannot be changed without changing our thinking.”"
      tags : 
        {
          1 : "change"
          2 : "deep-thoughts"
          3 : "thinking"
          4 : "world"
        }
    }
  2 : 
    {
      author : "J.K. Rowling"
      content : "“It is our choices, Harry, that show what we truly are, far more than our abilities.”"
      tags : 
        {
          1 : "abilities"
          2 : "choices"
        }
    }
  3 : 
    {
      author : "Albert Einstein"
      content : "“There are only two ways to live your life. One is as though nothing is a miracle. The other is as though everything is a miracle.”"
      tags : 
        {
          1 : "inspirational"
          2 : "life"
          3 : "live"
          4 : "miracle"
          5 : "miracles"
        }
    }
  4 : 
    {
      author : "Jane Austen"
      content : "“The person, be it gentleman or lady, who has not pleasure in a good novel, must be intolerably stupid.”"
      tags : 
        {
          1 : "aliteracy"
          2 : "books"
          3 : "classic"
          4 : "humor"
        }
    }
  5 : 
    {
      author : "Marilyn Monroe"
      content : "“Imperfection is beauty, madness is genius and it's better to be absolutely ridiculous than absolutely boring.”"
      tags : 
        {
          1 : "be-yourself"
          2 : "inspirational"
        }
    }
  6 : 
    {
      author : "Albert Einstein"
      content : "“Try not to become a man of success. Rather become a man of value.”"
      tags : 
        {
          1 : "adulthood"
          2 : "success"
          3 : "value"
        }
    }
  7 : 
    {
      author : "André Gide"
      content : "“It is better to be hated for what you are than to be loved for what you are not.”"
      tags : 
        {
          1 : "life"
          2 : "love"
        }
    }
  8 : 
    {
      author : "Thomas A. Edison"
      content : "“I have not failed. I've just found 10,000 ways that won't work.”"
      tags : 
        {
          1 : "edison"
          2 : "failure"
          3 : "inspirational"
          4 : "paraphrased"
        }
    }
  9 : 
    {
      author : "Eleanor Roosevelt"
      content : "“A woman is like a tea bag; you never know how strong it is until it's in hot water.”"
      tags : 
        {
          1 : "misattributed-eleanor-roosevelt"
        }
    }
  10 : 
    {
      author : "Steve Martin"
      content : "“A day without sunshine is like, you know, night.”"
      tags : 
        {
          1 : "humor"
          2 : "obvious"
          3 : "simile"
        }
    }
}
  {
          1 : "edison"
          2 : "failure"
          3 : "inspirational"
          4 : "paraphrased"
        }
    }
  9 : 
    {
      author : "Eleanor Roosevelt"
      content : "“A woman is like a tea bag; you never know how strong it is until it's in hot water.”"
      tags : 
        {
          1 : "misattributed-eleanor-roosevelt"
        }
    }
  10 : 
    {
      author : "Steve Martin"
      content : "“A day without sunshine is like, you know, night.”"
      tags : 
        {
          1 : "humor"
          2 : "obvious"
          3 : "simile"
        }
    }
}
```
