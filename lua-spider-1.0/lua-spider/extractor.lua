local bones = require("lua-spider.bones")

   local function istable(t)
      if type(t) == "table" then return true else return false end
   end
   
   local function iselement(e)
      if not istable(e) then return false end
      if istable(e) then
         if e.type and e.type == "element" then
   	 return true
         else
   	 return false
         end
      end
   end
   
   local function isdocument(d)
      if not istable(d) then return false else
         if d.type and d.type == "document" then
   	 return true
         else
   	 return false
         end
      end
   end
   
   local function melt(t, o)
      o = o or {}
      if istable(t) then
         if not iselement(t) then
   	 for i = 1, #t do
   	    o = melt(t[i], o)
   	 end
         else
   	 o[#o+1] = t
         end
      end
      if not o or not o[1] then
         return nil
      else
         return o
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
   
   local function hasattribute(e, a)
      if e:hasAttributes() then
         if e.attributes then
   	 if e.attributes[a] then
   	    return true
   	 else
   	    return false
   	 end
         else
   	 return false
         end
      else
         return false
      end
   end
   
   local function hasattributevalue(e, a, v)
      if e:hasAttributes() then
         if e.attributes then
   	 if e.attributes[a] then
   	    if string.match(e.attributes[a].value, v) then
   	       return true
   	    else
   	       return false
   	    end
   	 else
   	    return false
   	 end
         else
   	 return false
         end
      else
         return false
      end
   end
   

   
   local match = {}
   
   function match.getAllByTag(doc, tag, _ind)
      if not isdocument(doc) then
         doc = melt(doc)
      else
         doc = {doc}
      end
      if not doc then return nil end
      local out = {}
      for i = 1, #doc do
         out[#out+1] = doc[i]:getElementsByTagName(tag)
      end
      if not out[1] then
         return nil
      else
         if _ind then
            return out[_ind]
         else
            return out
         end
      end
   end
   
   function match.getByAttribute(doc, attr, attrval, _ind)
      if not isdocument(doc) then
         doc = melt(doc)
      end
      if not doc then return nil end
      local out = {}
      for i = 1, #doc do
         if hasattribute(doc[i], attr) then
            if attrval then
               if hasattributevalue(doc[i], attr, attrval) then
                  out[#out+1] = doc[i]
               end
            else
               out[#out+1] = doc[i]
            end
         end
      end
      if not out[1] then
         return nil
      else
         if _ind then
            return out[_ind]
         else
            return out
         end
      end
   end
   
   function match.getByText(doc, txt, _ind)
      if not isdocument(doc) then
         doc = melt(doc)
      end
      if not doc then return nil end
      local out = {}
      for _, v in ipairs(doc) do
         if type(v) ~= "number" then
            if v.textContent then
               if txt then
                  if string.match(v.textContent, txt) then
                     out[#out+1] = v
                  end
               else
                  out[#out+1] = v
               end
            end
         end
      end
      if not out[1] then
         return nil
      else
         if _ind then
            return out[_ind]
         else
            return out
         end
      end
   end
   

local function extractText(doc)
   local out
   if not doc then return nil end
   if type(doc) == "table" and #doc >= 1 then
      for i = 1, #doc do
         if type(doc[i]) ~= "number" then
            if doc[i].type == "element" then
               if doc[i].textContent then
                  if not out then out = {} end
                  out[#out+1] = doc[i].textContent
               end
            else
               if type(doc[i]) == "table" then
                  if not out then out = {} end
                  out[#out+1] = extractText(doc[i])
               end
            end
         end
      end
   elseif type(doc) == "table" and doc.type and doc.type == "document" then
      if doc.childNodes then
         for j = 1, #doc.childNodes do
            if not out then out = {} end
            out[#out+1] = extractText(doc.childNodes[j])
         end
      end
   else
      return "nil"
   end
   if type(out) == "table" then
      if type(out[1]) == "table" then
         return melttable(out)
      else
         return out
      end
   else
      return out
   end
end

local function extractAttr(doc, attr)
   if not isdocument(doc) then
      doc = melt(doc)
   end
   if not doc then return nil end
   local out = {}
   for i = 1, #doc do
      if hasattribute(doc[i], attr) then
         out[#out+1] = doc[i].attributes[attr].value
      end
   end
   if not out[1] then
      return "nil"
   else
      return melttable(out)
   end
end

local function splitXpath(xp)
   local doubleslash = "!dblslash!"
   local procedure = {}
   assert(type(xp) == "string")
   if string.match(xp, "/") then
      xp = xp:gsub("//", "/" .. doubleslash)
      xp = xp:gsub("^/", "")
      xp = bones.split(xp, "/")
      for _, j in ipairs(xp) do
         while j ~= "" do
            if string.match(j, "^" .. doubleslash) then
               j = j:gsub("^" .. doubleslash, "")
               procedure[#procedure+1] = { how = "getAllByTag",
                                           what = j:gsub('^(%w+).*','%1') }
            else
               procedure[#procedure+1] = { how = "getAllByTag",
                                           what = j:gsub('^(%w+).*','%1') }
            end
            if string.match(j, "%b[]") then
               if string.match(j, "[^%]]%[%d+%]") then
                  procedure[#procedure+1] = { how = "getByIndex",
                                              what = j:gsub("^.+%[(%d+)%].*", "%1") }
                  procedure[#procedure].what = tonumber(procedure[#procedure].what)
               end
               if string.match(j, "^.+%b[@[^=]+.*].*") then
                  procedure[#procedure+1] = { how = "getByAttribute",
                                              what = j:gsub('^.+%b[@([^=]+).*].*','%1') }
                  if string.match(j, "^.+%b[@.+=.+].*") then
                     procedure[#procedure+1] = { how = "getByAttributeValue",
                                                 what = j:gsub('^.+%b[@.+=(.-)].*','%1') }
                  end
               elseif string.match(j, "^.+%b[text%b()%s*.*].*") then
                  procedure[#procedure+1] = { how = "getByText" }
                  if string.match(j, "^.+%b[text%b()%s*=.+].*") then
                     procedure[#procedure+1] = { how = "getByTextContent",
                                                 what = j:gsub('^.+%b[text%b()%s*=(.-)].*', '%1') }
                  end
               end
               if string.match(j, "%]%[%d+%]") then
                  procedure[#procedure+1] = { how = "getByIndex",
                                              what = j:gsub("^.+%[(%d+)%].*", "%1") }
                  procedure[#procedure].what = tonumber(procedure[#procedure].what)
               end
               if string.match(j, "^.+%b[text%b()%s*.*].*") then
                  procedure[#procedure+1] = { how = "getByText" }
                  if string.match(j, "^.+%b[text%b()%s*=.+].*") then
                     procedure[#procedure+1] = { how = "getByTextContent",
                                                 what = j:gsub('^.+%b[text%b()%s*=(.-)].*', '%1') }
                  end
               end
            end
            j = j:gsub(".*", "")
         end
      end
   end
   if type(procedure) == "table" and procedure[1] and procedure[1]["what"] then
      for k, v in ipairs(procedure) do
         procedure[k]["what"] = procedure[k]["what"]:gsub("%-", "%%-")
      end
   end
   return procedure
end

local function xpathiter(doc, xp)
   local counter = 1
   while counter < #xp+1 do
      if xp[counter] and xp[counter].how == "getAllByTag" then
         if xp[counter+1] and xp[counter+1].how == "getByIndex" then
            doc = match[xp[counter].how](doc, xp[counter].what, xp[counter+1].what)
            counter = counter+2
         else
            doc = match[xp[counter].how](doc, xp[counter].what)
            counter = counter+1
         end
      end
      if xp[counter] and xp[counter].how == "getByAttribute" then
         if xp[counter+1] and xp[counter+1].how == "getByAttributeValue" then
            if xp[counter+2] and xp[counter+2].how == "getByIndex" then
               doc = match[xp[counter].how](doc, xp[counter].what, xp[counter+1].what, xp[counter+2].what)
               counter = counter+3
            else
               doc = match[xp[counter].how](doc, xp[counter].what, xp[counter+1].what)
               counter = counter+2
            end
         else
            if xp[counter+1] and xp[counter+1].how == "getByIndex" then
               doc = match[xp[counter].how](doc, xp[counter].what, "NA", xp[counter+1].what)
               counter = counter+2
            else
               doc = match[xp[counter].how](doc, xp[counter].what)
               counter = counter+1
            end
         end
      end
      if xp[counter] and xp[counter].how == "getByText" then
         if xp[counter+1] and xp[counter+1].how == "getByTextContent" then
            if xp[counter+2] and xp[counter+2].how == "getByIndex" then
               doc = match[xp[counter].how](doc, xp[counter].what, xp[counter+1].what, xp[counter+2].what)
               counter = counter+3
            else
               doc = match[xp[counter].how](doc, xp[counter].what, xp[counter+1].what)
               counter = counter+2
            end
         else
            if xp[counter+1] and xp[counter+1].how == "getByIndex" then
               doc = match[xp[counter].how](doc, xp[counter].what, "NA", xp[counter+1].what)
               counter = counter+2
            else
               doc = match[xp[counter].how](doc, xp[counter].what)
               counter = counter+1
            end
         end
      end
   end
   return doc
end

local function extractor(doc, xp, ext)
   assert(type(doc) == "table")
   assert(type(xp) == "string")
   doc = xpathiter(doc, splitXpath(xp))
   if not ext then
      return doc or "nil"
   elseif ext == "text" then
      return extractText(doc) or "nil"
   else
      return extractAttr(doc, ext) or "nil"
   end
end

return extractor
