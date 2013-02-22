
Native dmenu for the Awesome window manager
===========================================

The dmenu tool that comes with Linux is great, but using in within the Awesome window manager is cumbersome.
This is where _dmenu.lua_ comes handy. It does 99% of what dmenu does, but it plays well with Awesome's rc.lua. In other words, you can select an item from a predefined list of items, then spawn a process or run a callback function.

Usage
-----

In rc.lua:

        local dmenu = require("lib/dmenu")

        ...

        mydmenu = dmenu({
            chromium = "chromium",
            vifm = "vifm",
            vim = terminal .. " -e vim",
            urxvt = function()
                local matcher = function (c)
                    return awful.rules.match(c, {class = 'URxvt'})
                end
                awful.client.run_or_raise(exec, matcher)
            end
        })

        ...

        mywibox:set_widget(mydmenu.textbox)

        ...

        -- Execute
        awful.key({ modkey }, "r", function ()
            mydmenu:show()
        end)

Keys
----

dmenu.lua handles the same keyboard shortcuts as the Linux dmenu. Once activated, it will show a list of the table keys. In the above example that would be _chromium | vifm | vim | urxvt_.
Left and right keys will move the selection. Typing will reduce the list to the items matching the typed string. Return will execute and Escape will exit.

TODO
----

* If the list of items is too long, it gets cut off and navigation stops at the last visible item (as opposed to shifting the items by one and showing the next one).
* A custom key handler could be installed in case someone requires more complicated keyboard shortcuts.

