-- A sample filter: return a comment instead of a paragraph
if not (FORMAT == 'odt' or FORMAT == 'opendocument') then
    return {}
end

-- constants
local listStyle        = 'L1'
local listParaStyle    = 'ListPara'
local numListStyle     = 'Numbering_20_1'
local numListParaStyle = 'numListPara'
local listItemStart    = '<text:list-item>'
local listItemEnd      = '</text:list-item>'

-- Helper functions for debugging {{{1

-- print a data structure (possibly recursively) {{{2
local function print_r(arr, indentLevel)

    -- utility function: check if a string is nil or empty
    local function isempty(s)
        return s == nil or s == ''
    end

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
--- }}}2

-- What type is this element of ? {{{2
local function print_type(elem)
    if type(elem) == "table" then
        if elem['t'] ~= nil then
            print("Found element -> " .. elem['t'])
        else
            print('A table, but without type tag')
            for k, v in pairs(elem) do
                print('Found a key: ', k)
            end
        end
    else
        print("Not a complex element")
    end
end
-- }}}2

-- End of helper functions }}}1 

-- test_list function (not used now) {{{1
local function test_list(aList)
    if (aList['t'] == 'BulletList') then
        local listBegin = '<ul class="AList">'
        local listEnd   = "</ul>"
        print("Bullet list found")
        return {
            pandoc.RawBlock('html', listBegin),
            -- elem.content:map(pandoc.walk_block),
            elem.content:map(print_type),
            pandoc.RawBlock('html', listEnd),
        }
    end
    if (aList['t'] == "OrderedList") then
        print('Ordered list found')
        return aList
    end

end
-- }}}1

-- Callbacks for list elements (paragraphs and nested lists) {{{1
-- List paragraph (function){{{2 
BulletListPara = function(elem)
    print("BulletListPara called")
    --[[
    -- Тонкость: результат этой функции присваивается не тому же элементу, который передаётся в неё,
    -- а находящемуся ближе к корню дерева (элементу таблицы)
    --]]
    return  { 
        pandoc.RawBlock('opendocument', '<text:p text:style-name="' .. listParaStyle .. '">'),
        pandoc.RawBlock('opendocument', pandoc.utils.stringify(pandoc.walk_block(elem))),
        pandoc.RawBlock('opendocument', "</text:p>"),
    }
end
-- }}}2

-- List paragraph (function){{{2 
NumberedListPara = function(elem)
    print("NumberedListPara called")
    --[[
    -- Тонкость: результат этой функции присваивается не тому же элементу, который передаётся в неё,
    -- а находящемуся ближе к корню дерева (элементу таблицы)
    --]]
    return  { 
        pandoc.RawBlock('opendocument', '<text:p text:style-name="' .. numListParaStyle .. '">'),
        pandoc.RawBlock('opendocument', pandoc.utils.stringify(pandoc.walk_block(elem))),
        pandoc.RawBlock('opendocument', "</text:p>"),
    }
end
-- }}}2

-- MyBulletList: bullet list at a level > 1 {{{2 
MyBulletList = function(elem)
    print("MyBulletList in-list callback for BulletList elements called")

    apply_walk_blocks = function(list_item_content)
        print("apply_walk_blocks called")
        local elems_list = {}
        for idx, list_item in ipairs(list_item_content) do
            table.insert(elems_list, pandoc.RawBlock('opendocument', listItemStart))
            if list_item ~= nil and list_item.t ~= nil then
                print('MyBulletList: list item of type' .. list_item.t)
            else
                print("Non-typed table as a list element (" .. type(list_item) .. ")")
                if type(list_item) == 'table' then
                    for int_idx, nested_list_item in ipairs(list_item) do
                        if nested_list_item ~= nil and nested_list_item.t ~= nil then
                            print('MyBulletList: nested list item of type ' .. nested_list_item.t)
                            table.insert(elems_list, nested_list_item)
                        end
                    end
                end
            end
            table.insert(elems_list, pandoc.RawBlock('opendocument', listItemEnd))
        end
        return elems_list
    end
    
    local list_items = apply_walk_blocks(elem.content)
    table.insert(list_items, 1, pandoc.RawBlock('opendocument', "<!-- Internal BulletList starts here -->"))
    table.insert(list_items, 2, pandoc.RawBlock('opendocument', '<text:list text:style-name="' ..  listStyle .. '">'))
    table.insert(list_items, pandoc.RawBlock('opendocument', "</text:list>"))
    table.insert(list_items, pandoc.RawBlock('opendocument', "<!-- Internal BulletList ends here -->"))

    print("=========== MyBulletList: Structure of result =============")
    print_r(list_items)
    print("-----------------------------------------------------------")
    return  list_items
end

--- End of list elements' callback }}}1

--  Not ready yet {{{1
InBulletListCallbacks = function()
    return {
        Para = ListPara,
    }
end
-- }}}1

-- OrderedList callback function {{{1
OrderedList = function (element)
    print("Ordered list on top level")
    for i, item in ipairs(element.content) do
        if item and type(item) == 'table' then
            for j, nested_item in ipairs(item) do
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == 'Para' then
                    element.content[i] = NumberedListPara(nested_item)
                end
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == "OrderedList" then
                    print('Internal ordered list')
                    element.content[i][j] = pandoc.OrderedList(nested_item.content)
                end
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == "BulletList" then
                    print('Internal bullet list')
                    element.content[i] = MyBulletList(nested_item)
                end
                -- else do nothing (element.content[i],[j] persists)
            end
        end
    end
    return element
end
-- }}}1

-- BulletList callback function {{{1
BulletList = function (element)
    print("Bullet list on top level")
    for i, item in ipairs(element.content) do
        if item and type(item) == 'table' then
            for j, nested_item in ipairs(item) do
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == 'Para' then
                    element.content[i] = BulletListPara(nested_item)
                end
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == "BulletList" then
                    print('Internal bullet list in bullet list')
                    element.content[i] = MyBulletList(nested_item)
                end
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == "OrderedList" then
                    print('Internal ordered list in bullet list')
                    element.content[i][j] = pandoc.OrderedList(nested_item.content)
                end
            end
        end
    end
    return element
end
-- }}}1

-- vim:expandtab:softtabstop=4:ts=4:shiftwidth=4:foldmethod=marker
