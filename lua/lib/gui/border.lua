require('lib.functions')
require('lib.gui.common')
require('lib.gui.gobject')
require('lib.gui.tools')

require('PLoop')

PLoop(function(_ENV)
    namespace "gui"

    class "Border"(function(_ENV)
        inherit "GObject"

        __Sealed__()
        enum "Style" {
            None = 'none',
            Shadow = 'shadow',
            Double = {"╔", "═", "╗", "║", "╝", "═", "╚", "║"},
            Rounded = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            Single = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
            Solid = { "▛", "▀", "▜", "▐", "▟", "▄", "▙", "▌" }
        }

        function Border(self, widget, opts)
            super(self, opts)

            self.widget = widget
            self.style = opts.style or Style.None

            self.relative = self.widget.relative

            self.dirty = true

            self.bufopts.buflisted = false
            self.bufopts.modifiable = true
            self.winopts.winblend = self.winopts.winblend or 100
        end

        function __SetupGeometry(self)
            local geom = self.widget:Geometry()
            self.geometry = Rect(geom.x - 1, geom.y - 1, geom.width + 2, geom.height + 2)
            self.dirty = false
        end

        function SetGeometry(self, geometry)
            assert(false, "don't call Border:SetGeometry directly")
        end

        function Show(self)
            if self.style == Style.None or self.style == Style.Shadow then
                return
            end

            self:Create()

            local geom = self.widget:Geometry()

            local context = { 
                self.style[1] .. string.rep(self.style[2], geom.width) .. self.style[3] 
            }
            local middle_line = self.style[8] .. string.rep(' ', geom.width) .. self.style[4]
            for i=1, geom.height do
                table.insert(context, middle_line)
            end
            table.insert(
            context, 
            self.style[7] .. string.rep(self.style[6], geom.width) .. self.style[5]
            )

            vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, context)
            vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
        end
    end)
end)

