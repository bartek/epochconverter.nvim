## epochconverter.nvim

Unix epoch timestamps are the great but can be difficult to read at a glance. I
wanted a plugin which would annotate log files and other data as I read it with
a human readable version of the timestamp. This is it.

TODO:

- [ ] Better identification of a timestamp string (very naive atm)
- [ ] Timezone selector

### Prerequisites

* Neovim 0.8+ (using `nvim_buf_set_extmark`, which deprecated previous related commands around 0.6)

### Installation

Install with a plugin manager, e.g. packer:

    use 'bartek/epochconverter.nvim'

And explicitly load it:

    ; nvim/after/plugin/epochconverter.lua
    local epochconverter = require('epochconverter').load()
