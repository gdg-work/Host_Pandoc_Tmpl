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

-- get a right paragraph start tag depending of list type
local function getStartTag(forOrderedList)
    local paraStyle = listParaStyle
    if forOrderedList then
        paraStyle = numListParaStyle
    end
    local paraStartTag = '<text:p text:style-name=\"' .. paraStyle .. '\">'
    return paraStartTag
end

local function getFilter(forOrderedList)
    local blockToRaw = util.blockToRaw
    local paraStartTag = getStartTag(forOrderedList)

    blockToRaw.Plain = function (item)
        local para = paraStartTag .. pandoc.utils.stringify(item) .. '</text:p>'
        local content = tags.listItemStart .. para .. tags.listItemEnd
        return pandoc.Plain(pandoc.Str(content))
    end

    blockToRaw.Para = function (item)
        if type(item) == "table" then
            print("*DBG* Block2Raw_Para: parameter is a table")
        end
        local para = paraStartTag .. pandoc.utils.stringify(item) .. '</text:p>'
        local content = tags.listItemStart .. para .. tags.listItemEnd
        return pandoc.Para(pandoc.Str(content))
    end

    return blockToRaw
end

local function getListItemFilter(forOrderedList)
    local blockToRaw = util.blockToRaw
    blockToRaw.BulletList = function(item)
        print("*DBG* A bullet list element inside list item")
    end
    blockToRaw.Plain = function(item)
        print("*DBG* plain string inside list item")
    end

    blockToRaw.Para = function(item)
        if type(item) == "table" then
            print("*DBG* Block2Raw_Para: parameter is a table")
        end
        print("*DBG* Elements of item in BlockToRaw.Block:")
        print_r(item)
        print("*DBG* A block element inside list item")
    end

    return blockToRaw
end

local function listFilter(list, isOrdered)
    print("*DBG* listFilter called with a list with a length of " .. #list.content .. ' elements')
    print_r(list)

    if listHasInnerList(list) then
        return list
    end

    -- walk throw list's elements in a cycle
    list = pandoc.walk_block(list, getListItemFilter(isOrdered))
    local rawList = getListStartTags(isOrdered) .. pandoc.utils.stringify(list) .. tags.listEnd
    print(rawList)
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
-- vim:ts=4:softtabstop=4:expandtab:shiftwidth=4
