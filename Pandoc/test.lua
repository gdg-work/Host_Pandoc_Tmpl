-- A sample filter: return a comment instead of a paragraph
if FORMAT ~= 'odt' then
    return {}
end

-- What type is this element of ?
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

-- {{{1 List paragraph (function)
ListPara = function(elem)
    print("ListPara called")
    return  { 
        pandoc.RawBlock('opendocument', '<text:p style="ListPara">'),
        -- print (pandoc.utils.stringify(pandoc.walk_block(elem))),
        pandoc.RawBlock('opendocument', pandoc.utils.stringify(pandoc.walk_block(elem))),
        pandoc.RawBlock('opendocument', "</text:p>"),
    }
    -- return pandoc.RawBlock('odt', "<text:p><!-- ListPara -->PlaceHolder</text:p>")
    --[[
    -- Почему-то здесь:
    -- 1) Если я возвращаю один RawBlock, то при работе фильтра пишется сообщение "[INFO] Not rendering RawBlock (Format "odt") "<!-- ListPara -->"
    -- 2) Если я возвращаю список даже из 1 элемента ({RawBlock, RawBlock}), то не выдаётся ничего. Видимо, несовпадение типов?
    ]]--
end


InBulletListCallbacks = function()
    return {
        Para = ListPara,
    }
end

-- OrderedList callback function {{{1
OrderedList = function (element)
    for i, item in ipairs(element.content) do
        if item and type(item) == 'table' then
            for j, nested_item in ipairs(item) do
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == 'Para' then
                    element.content[i][j] = pandoc.Para(nested_item.content)
                end
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == "OrderedList" then
                    print('Internal ordered list')
                    print_type(nested_item)
                    element.content[i][j] = pandoc.OrderedList(nested_item.content)
                end
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == "BulletList" then
                    print('Internal bullet list')
                    print_type(nested_item)
                    element.content[i][j] = pandoc.OrderedList(nested_item.content)
                end
            end
        end
    end
    return element
end
-- }}}1

-- BulletList callback function {{{1
BulletList = function (element)
    print("Bullet list on 1st level")
    for i, item in ipairs(element.content) do
        if item and type(item) == 'table' then
            for j, nested_item in ipairs(item) do
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == 'Para' then
                    -- element.content[i][j] = pandoc.Para(nested_item.content)
                    element.content[i] = ListPara(nested_item)
                end
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == "BulletList" then
                    print('Internal bullet list in bullet list')
                    print_type(nested_item)
                    element.content[i][j] = pandoc.BulletList(nested_item.content)
                end
                if nested_item ~= nil and nested_item.t ~= nil and nested_item.t == "OrderedList" then
                    print('Internal ordered list in bullet list')
                    print_type(nested_item)
                    element.content[i][j] = pandoc.OrderedList(nested_item.content)
                end
            end
        end
    end
    return element
end
-- }}}1

-- vim:expandtab:softtabstop=4:ts=4:shiftwidth=4
