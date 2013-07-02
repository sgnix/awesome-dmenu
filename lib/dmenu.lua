---------------------------------------------------------------------------
-- Native dmenu for the Awesome window manager.
-- Written by Stefan G. (naturalist@github)
-- License: BSD
---------------------------------------------------------------------------

local awful = require("awful")
local textbox = require("wibox.widget.textbox")
local keygrabber = require("awful.keygrabber")
local beautiful = require("beautiful")

local index = 0
local typed = ""

local _dmenu = {
    nor_bg_color = beautiful.bg_normal or "black",
    nor_fg_color = beautiful.fg_normal or "white",
    sel_bg_color = beautiful.bg_focus or "white",
    sel_fg_color = beautiful.fg_focus or "black",
    separator    = " | ",
    prompt       = "Run:"
}
local dmenu = {}
local mt = {}
setmetatable(dmenu, mt)

local function get_names(str)
    local names = {}
    for k, _ in pairs(dmenu.items) do
        if str == nil or str == "" then
            table.insert(names, k)
        else
            if string.find(k, str) then
                table.insert(names, k)
            end
        end
    end
    table.sort(names)
    return names
end

local function draw()
    local formatted = {}
    for i, k in ipairs(dmenu.names) do
        local val = k
        if index % #dmenu.names + 1 == i then
            val = "<span background='" ..  dmenu.sel_bg_color ..
                  "' foreground='" ..  dmenu.sel_fg_color .. "'>" ..
                  k .. "</span>"
        end
        table.insert(formatted, val)
    end

    local prompt = string.format(
        '<span foreground="%s" background="%s">%s</span>',
        dmenu.sel_fg_color, dmenu.sel_bg_color, dmenu.prompt
    )

    local items = string.format(
        '<span foreground="%s" background="%s">%s</span>',
        dmenu.nor_fg_color, dmenu.nor_bg_color,
        table.concat(formatted, dmenu.separator)
    )

    local markup = string.format(
        '%s (%s) %s',
        prompt, typed, items
    )

    dmenu.textbox:set_markup( markup )
end

function dmenu.new(items, args)
    local args = args or {}
    for k, _ in pairs(_dmenu) do
        if args[k] then _dmenu[k] = args[k] end
    end
    dmenu.textbox = textbox()
    if args.font then dmenu.textbox:set_font(args.font) end
    dmenu.items = items
    return dmenu
end

function dmenu:show()
    dmenu.names = get_names(typed)
    local grabber
    grabber = keygrabber.run(function(mod, key, event)
        if event == "release" then return end

        local _typed = typed

        if key == "Right" then
            index = index + 1
        elseif key == "Left" then
            index = index - 1
        elseif #key == 1 and (string.lower(key) >= "a" or string.lower(key) <= "z") then
            typed = typed .. key
        elseif key == "BackSpace" then
            if typed ~= "" then
                typed = string.sub(typed, 1, #typed - 1)
            end
        elseif key == "Return" or key == "Escape" then
            if key == "Return" then
                local callback = dmenu.items[self.names[index + 1]]
                if type(callback) == "function" then
                    callback()
                elseif type(callback) == "string" then
                    awful.util.spawn(callback)
                end
            end
            keygrabber.stop(grabber)
            self:hide()
            return
        end

        if typed ~= _typed then
            dmenu.names = get_names(typed)
        end

        draw()
    end)
end

function dmenu:hide()
   self.textbox:set_markup("")
   index = 0
   typed = ""
end

function mt:__call(...)
    return dmenu.new(...)
end

function mt.__index(t, k)
    return _dmenu[k]
end

function mt.__newindex(t, k, v)
    _dmenu[k] = v
    if k == "names" then
        index = 0
        draw()
    end
end

return dmenu
