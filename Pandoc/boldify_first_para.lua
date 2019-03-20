OrderedList = function (element)
  for i, item in ipairs(element.content) do
    local first = item[1]
    if first and first.t == 'Para' then
      element.content[i][1] = pandoc.Para{pandoc.Strong(first.content)}
    end
  end
  return element
end

BulletList = OrderedList
