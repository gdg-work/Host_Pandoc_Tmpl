-- A sample filter: return a comment instead of a paragraph
return {
    {
        Para = function(p)
            return { 
                pandoc.RawBlock('opendocument', "<!-- begin of para -->"),
                p,
                pandoc.RawBlock('opendocument', "<!-- end of para -->"),
            }
        end 
    },
    {
        Strong = function (elem)
          return pandoc.SmallCaps(elem.c)
        end,
    }
}
-- vim:expandtab:softtabstop=4:ts=4:shiftwidth=4
