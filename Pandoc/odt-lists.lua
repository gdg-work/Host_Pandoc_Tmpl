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

local listStyle = 'List_20_1'
local listParaStyle = 'listPara'
local numListStyle = 'Numbering_20_1'
local numListParaStyle = 'numListPara'

local utilPath = string.match(PANDOC_SCRIPT_FILE, '.*[/\\]')
require ((utilPath or '') .. 'util')

local tags = {}
tags.listStart     = '<text:list text:style-name = \"' .. listStyle .. '\">'
tags.numListStart  = '<text:list text:style-name = \"' .. numListStyle .. '\">'
tags.listEnd       = '</text:list>'
tags.listItemStart = '<text:list-item>'
tags.listItemEnd   = '</text:list-item>'

-- utility function: check if a string is nil or empty
local function isempty(s)
    return s == nil or s == ''
end

-- print a data structure (possibly recursively)
local function print_r(arr, indentLevel)
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

local function listHasInnerList(list)
    local hasInnerList = false
    pandoc.walk_block(list, {
        RawBlock = function (raw)
            hasInnerList = true
        end
    })
    return hasInnerList
end

-- get a right LIST start tag depending of list type
local function getListStartTags(forOrderedList)
    if forOrderedList then
        return tags.numListStart
    end
    return tags.listStart
end

local function putTagsOnContent(textContent, startTag, endTag)
  table.insert(textContent, 1, pandoc.RawBlock("opendocument", startTag))
  table.insert(textContent, pandoc.RawBlock("opendocument", endTag))
  return textContent
end


-- get a right paragraph start tag depending of list type
local function getParaStartTag(forOrderedList)
    local paraStyle = listParaStyle
    if forOrderedList then
        paraStyle = numListParaStyle
    end
    local paraStartTag = '<text:p text:style-name=\"' .. paraStyle .. '\">'
    return paraStartTag
end

local function getListItemFilter(forOrderedList)
    local blockToRaw = util.blockToRaw
    local paraStartTag = getParaStartTag(forOrderedList)

-- temporary --    blockToRaw.Inline = function(item)
-- temporary --        print("*DBG block2raw.Inline called with parameter:")
-- temporary --        print_r(item)
-- temporary --        print("--------------------------------------------")
-- temporary --        local para = paraStartTag .. pandoc.utils.stringify(item) .. '</text:p>'
-- temporary --        return pandoc.Str(para)
-- temporary --    end

    blockToRaw.LineBlock = function (item)
        print("*DBG block2raw.LineBlock called with parameter:")
        print_r(item)
        print("--------------------------------------------")
    end

    blockToRaw.Plain = function (item)
        print("*DBG block2raw.Plain called")
        local para = paraStartTag .. pandoc.utils.stringify(item) .. '</text:p>'
        local content = tags.listItemStart .. para .. tags.listItemEnd
        return pandoc.Plain(pandoc.Str(content))
    end

    blockToRaw.Para = function (item)
        print("*DBG block2raw.Para called")
        local para = paraStartTag .. pandoc.utils.stringify(item) .. '</text:p>'
        local content = tags.listItemStart .. para .. tags.listItemEnd
        return pandoc.Para(pandoc.Str(content))
    end

    blockToRaw.Block = function (item)
        print("*DBG block2raw.Block called")
        local para = paraStartTag .. pandoc.utils.stringify(item) .. '</text:p>'
        local content = tags.listItemStart .. para .. tags.listItemEnd
        return pandoc.Block(pandoc.Str(content))
    end

    return blockToRaw
end

-- makes a paragraph from list
local function blockInListToPara(isOrdered)
    local sParaStartTag = getParaStartTag(isOrdered)
    local sParaEndTag = '</text:p>'
    return function(aPara)
        return sParaStartTag .. pandoc.utils.stringify(aPara) .. sParaEndTag
    end
end

local function listFilter(list, isOrdered)
    -- print("*DBG* listFilter called with a list with a length of " .. #list.content .. ' elements')
    -- print_r(list)
    local elementsList = {}

    -- makes a list item
    -- parameters: a list element (table of one or more block elements)
    -- returns: a list item as a stringblock element 
    local function processListItem(elem)
        local retStr = ""
        local elemKey = ""
        local elemValue = ""
        print("*TRC* processListItem called")
        -- print('PLI parameter: table of length ' .. #elem)
        -- print_r(elem)
        -- print("---------------")
        local strInternals=""
        for elemKey, elemValue in pairs(elem) do
            print('PLI value in list: key = ' .. elemKey)
            print_r(elemValue)
            print("---------------")
            local blockList = pandoc.walk_block(elemValue, getListItemFilter(isOrdered))
            -- print("listFilter: walk_block result")
            -- print_r(blockList)
            -- print("-----------------------------")
            strInternals = strInternals .. blockInListToPara(isOrdered)(blockList)
        end
        -- retStr = '<!-- List item placeholder -->'
        retStr = tags.listItemStart .. strInternals ..tags.listItemEnd
        print("PLI return")
        print(retStr)
        print("----------")
        return retStr
    end


    if listHasInnerList(list) then
        -- so, we have at least 1 element of the list that is a list itself
        return listFilter(list.content[1])
    end

    -- walk throw list's elements in a cycle
    elementsList = (list.content):map(processListItem)
    -- print("*DBG* Elements list before stringifying")
    -- print_r(elementsList)
    -- local el_as_strings = elementsList:map(pandoc.utils.stringify)
    -- print_r(elementsList)
    local el_as_string = table.concat(elementsList, '\n')
    -- print("EL as a string: '" .. el_as_string .. "'")
    -- print("-------------------------------------")

    local rawList = getListStartTags(isOrdered) .. "\n" .. el_as_string .. "\n" .. tags.listEnd
    print("*DBG* listFilter: return as a string: '" .. rawList .. "'")
    return pandoc.RawBlock('opendocument', rawList)
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



--[[
  for k, v in pairs(list.content) do
      -- here k will be # of list item, v is an array of blocks
      local insideItemBlocks = {}
      if type(v) == "table" then
          print("*DBG* listFilter: item is a table of " .. #v .. " elements  with key " .. k)
          if #v == 1 then
              print("*DBG* listItemBlock with key " .. k .. " before walking:")
              print_r(v)
              print("-------------------------------------")
              insideItemBlocks = util.putTagsOnContent(pandoc.walk_block(v[1]), tags.listItemStart, tags.listItemEnd )
              table.insert(elementsList, insideItemBlocks)
          else
              -- there are inner elements
              for key, listItemBlock in pairs(v) do
                  print("*DBG* listItemBlock with key " .. key .. " before walking:")
                  print_r(listItemBlock.content)
                  print("-------------------------------------")
                  table.insert(insideItemBlocks, 
                               pandoc.walk_block(listItemBlock.content, getListItemFilter(isOrdered))
                              )
              end

              util.putTagsOnContent(insideItemBlocks, tags.listItemStart, tags.listItemEnd )
              table.insert(elementsList, insideItemBlocks)
          end
      else
          print("*DBG* simple element in list, strange! Key -->" .. k .. ", value --> " .. v)
          list = Pandoc.Str(v)
      end
  end
 list = pandoc.walk_block(list, getListItemFilter(isOrdered))

 local function li_to_string(elem)
     local strRet = ''
     if (type(elem) == "table" and elem ~= nil) then
         print("*DBG* li_to_string: parameter")
         print_r(elem)
         print("-----------------------------")
         strRet = pandoc.utils.stringify(elem[1])
         if strRet == nil then
             print("strRet is NIL")
         else
             print("*DBG* el 1 as a string: '" .. strRet .. "'")
             for i=2, #elem do
                 strRet = strRet .. pandoc.utils.stringify(elem[i])
             end
         end
         -- return table.concat(elem:map(pandoc.utils.stringify)) 
     end
     return strRet
 end
]]--

-- vim:ts=4:softtabstop=4:expandtab:shiftwidth=4
