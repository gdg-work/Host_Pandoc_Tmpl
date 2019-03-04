--
-- Improves lists when converting to ODT, by adding list styles to lists, and
-- apropriate paragraph styles to list items. Only lists that are one level deep
-- are supported; in lists with two or more levels, only the innermost level is
-- improved, generating strange results.
--
-- In bullet lists, the list style turns to that in variable `listStyle`,
-- and the paragraph style of list items turns to that in variable
-- `listParaStyle`.
--
-- In ordered lists, the list style turns to that in variable `numListStyle`,
-- and the paragraph style of list items turns to that in variable
-- `numListParaStyle`.
--
-- Currently, just italics, bold, links and line blocks are preserved in lists;
-- all other markup is ignored.
--
-- dependencies: util.lua, need to be in the same directory of this filter
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018
-- license: GPL version 3 or later
local List = require 'pandoc.List'

local listStyle = 'List_20_1'
local listParaStyle = 'ListPara'

local numListStyle = 'Numbering_20_1'
local numListParaStyle = 'numListPara'

local utilPath = string.match(PANDOC_SCRIPT_FILE, '.*[/\\]')
require ((utilPath or '') .. 'util')

local tags = {}
tags.listStart = '<text:list text:style-name=\"' .. listStyle .. '\">'
tags.numListStart = '<text:list text:style-name=\"' .. numListStyle .. '\">'
tags.listEnd = '</text:list>'

tags.listItemStart = '<text:list-item>'
tags.listItemEnd = '</text:list-item>'


-- utility function: check if a string is nil or empty
local function isempty(s)
  return s == nil or s == ''
end

-- print a data structure (possibly recursively)
function print_r(arr, indentLevel)
  local str = ""
  local indentStr = "#"
  if(indentLevel == nil) then
    print(print_r(arr, 0))
    return
  end
  for i = 0, indentLevel do
    indentStr = indentStr .. "  "
  end
  for index, value in pairs(arr) do
    if type(value) == "table" then
      str = str..indentStr..index..": \n"..print_r(value, (indentLevel + 1))
    else 
      if not isempty(value) then
        str = str..indentStr..index..": "..value.."\n"
      end
    end
  end
  return str
end

-- join a table to a string
-- from http://www.wellho.net/resources/ex.php4?item=u105/spjo
function joinToString(delimiter, list)
  local len = #list
  if len == 0 then
    return ""
  end
  local string = list[1]
  if isempty(string) then
    return ""
  end
  for i = 2, len do
    string = string .. delimiter .. list[i]
  end
  return string
end

local function listHasInnerList(list)
  local hasInnerList = false
  pandoc.walk_block(list, {
    RawBlock = function (raw)
      hasInnerList = true
    end
  })
  return hasInnerList
end

local function getFilter(forOrderedList)
  local blockToRaw = util.blockToRaw
  blockToRaw.Plain = function (item)
    local paraStyle = listParaStyle
    if forOrderedList then
      paraStyle = numListParaStyle
    end
    local paraStartTag = '<text:p text:style-name=\"' .. paraStyle .. '\">'
    local para = paraStartTag .. pandoc.utils.stringify(item) .. '</text:p>'
    local content = tags.listItemStart .. para .. tags.listItemEnd
    return pandoc.Plain(pandoc.Str(content))
  end
  return blockToRaw
end

local function getListStart(isOrdered)
  if isOrdered then
    return tags.numListStart
  else
    return tags.listStart
  end
end
-- returns a sequence of tags for list item's starting in OpenDocument
-- as a string
local function getListItemStart(isOrdered)
  local listItemBeginTags = ""
  if isOrdered then
    listItemBeginTags = (tags.listItemStart .. '<text:p text:style-name=\"' ..  numListParaStyle .. '\">') 
  else
    listItemBeginTags = (tags.listItemStart .. '<text:p text:style-name=\"' ..  listParaStyle .. '\">') 
  end
  return listItemBeginTags
end

local function procString(strValue, isOrdered)
  print ("*TRC* procString called, param 1 is " .. strValue)
  util.putTagsOnContent(
      { pandoc.RawBlock('opendocument', value) },
      getListItemStart(isOrdered), 
      "</text:p></text:list-item>"
    )
end

local function procTable(tblValue, isOrdered)
  outList = {}
  print ("*TRC* procTable called")
  for k, v in pairs(tblValue) do
    print("*DBG* Processing key " .. k)
    pandocResult = pandoc.walk_block(
      v, 
      {
        -- { Plain = procString(elem, isOrdered) },
        -- { Para = procString(elem, isOrdered) },
        { OrderedList = getFilter(isOrdered) },
        { BulletList = getFilter(isOrdered) }
      }
    )
    print("*DBG* Inserting result of processing for key " .. k)
    table.insert(outList, pandocResult)
  end
  return outList
end

local function pandoc_list_to_string(aList)
  local len = #aList
  print("*TRC* list_to_string called with a list of length " .. len)
  if len == 0 then return "" end
  local strRet = pandoc.utils.stringify(aList[1]['text'])
  print("*DBG* first element is " .. strRet)
  for i = 2, len do
    strRet = strRet .. pandoc.utils.stringify(aList[i]['text'])
  end
  print("*DBG* list_to_string return: " .. strRet)
  return strRet
end

local function listFilter(list, isOrdered)
  local outList = {}
  if list == nil or list.content == nil or #list.content == 0 then return "" end
  print ("*TRC* listFilter called with list of " .. #list.content .. " elements")
  print('========== Begin of the list contents ========')
  print_r(list)
  print('=========== End of the list contents =========')
  table.insert(outList, pandoc.RawBlock('opendocument', '<!-- the list -->'))
  -- table.insert(outList, pandoc.RawBlock('opendocument', 
  --    getListItemStart(isOrdered) .. 'placeholder for list contents' .. '</text:p>' .. tags.listItemEnd ))
  for _, value in pairs(list.content) do
    if type(value) == 'table' then
      table.insert(outList, listFilter(value['text'], isOrdered))
    else
      if isempty(value) then
        print("*DBG* Skippend an empty value with a key " .. key)
      else
        print("*DBG* processing list key " .. key .. " with value " .. value)
        table.insert(outList, procString(value, isOrdered))
      end
    end
  end
  table.insert(outList, pandoc.RawBlock('opendocument', '<!-- end of list -->'))
  local listTag = getListStart(isOrdered)
  -- local rawList = listTag .. pandoc.utils.stringify(outList) .. tags.listEnd
  util.putTagsOnContent(outList, listTag, tags.listEnd)
  -- print("*DBG* raw list for return from listFilter")
  -- print_r(outList)
  return (pandoc.RawBlock('opendocument',  pandoc_list_to_string(outList)))
end

function BulletList(list)
  if FORMAT == 'odt' then
    return listFilter(list, false)
  end
end

function OrderedList(list)
  if FORMAT == 'odt' then
    return listFilter(list, true)
  end
end

-- END OF PROGRAM --

local function MylistFilter(list, isOrdered)
  if listHasInnerList(list) then
    -- here we can select inner list and call listFilter with that list
    if isOrdered then
        local OutList = {}
        local lKeys = {}
        local lValues = {}
        table.insert(OutList, pandoc.RawBlock('opendocument', '<!-- this list has an internal components -->'))
        table.insert(OutList, pandoc.RawBlock('opendocument', tags.numListStart))
        -- BufferTable = {}
        -- for k, v in pairs(list.content) do
        --  table.insert(BufferTable, listFilter(v, true))
        -- end
        -- -- attempt to debug --
        for k,v  in pairs(list.content) do
          table.insert(lKeys, k)
          table.insert(lValues, v)
        end

        -- print('========== Begin of the list contents ========')
        -- print_r(lValues)
        -- print('=========== End of the list contents =========')

        table.insert(OutList, pandoc.RawBlock('opendocument',
            "<text:list-item><text:p text:style-name=\"" ..  numListParaStyle .. "\">"))
        for k,v in pairs(lValues) do
          joinToString(" ", pandoc.utils.stringify(v))
        end
        table.insert(OutList, pandoc.RawBlock('opendocument', "</text:p></text:list-item>"))
        table.insert(OutList, pandoc.RawBlock('opendocument', tags.listEnd))
        table.insert(OutList, pandoc.RawBlock('opendocument', '<!-- end of complex list -->'))
      return OutList
    else
      return {
        pandoc.RawBlock('opendocument', '<!-- this list has an internal components -->'),
        list,
        pandoc.RawBlock('opendocument', '<!-- end of complex list -->'),
      }
    end
  end
  print('========== Begin of the SIMPLE list contents ========')
  print_r(list)
  print('=========== End of the SIMPLE list contents =========')
  list = pandoc.walk_block(list, getFilter(isOrdered))
  local listTag = tags.listStart
  if isOrdered then
    listTag = tags.numListStart
  end
  local rawList = listTag .. pandoc.utils.stringify(list) .. tags.listEnd
  return pandoc.RawBlock('opendocument', rawList)
end

-- vim:ts=2:softtabstop=2:expandtab:shiftwidth=2
