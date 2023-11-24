# telescope-symbols.nvim

`telescope-symbols` provide its users with the ability of picking symbols and
insert them at point.


## Installation


```vim
Plug 'nvim-telescope/telescope-symbols.nvim'
```

## Usage

Running `:Telescope symbols` will populate the symbol picker with all the
built-in sources.

Otherwise, if you want to use a single or a number of symbol set, then pass a
table with the symbol sources you like to use :

```vim
:lua require'telescope.builtin'.symbols{ sources = {'emoji'} }
:lua require'telescope.builtin'.symbols{ sources = {'emoji', 'kaomoji', 'gitmoji'} }
```

In order for any source to be registered by telescope-symbols, it needs to be
under your runtimepath inside `data/telescope-sources/`.

So if you are only interested in one of the sources provided in this repository,
then download the desired source manually and copy it to the appropriate
location. In that case you don't have to install this extension.

For Example: `~/.config/nvim/data/telescope-sources/my_symbols.json`

## Custom symbol sources

With `telescope-symbol`, you can easily create your own source via creating new
file or extend current ones.

### Symbol source format

The source files have to be decoded in `json` with the following format:

```json
[
  [
    "symbol",
    "description" // used to fuzzy find
  ],
]

```

### Symbol locations

In order for custom source to be registered by `telescope-symbols`, it needs to
be under your runtimepath inside `data/telescope-sources/`.

For Example:
`~/.config/nvim/data/telescope-sources/my_symbols.json`

## Credit

All credit goes to the creators of those files.

- [emoji](https://www.unicode.org/Public/emoji/15.1/emoji-test.txt)
- [kaomoji](https://github.com/kuanyui/kaomoji.el/blob/master/kaomoji-data.el)
- [math](https://raw.githubusercontent.com/wspr/unicode-math/ef5688f303d7010138632ab45ef2440d3ca20ee5/unicode-math-table.tex)
- [latex](https://raw.githubusercontent.com/wspr/unicode-math/ef5688f303d7010138632ab45ef2440d3ca20ee5/unicode-math-table.tex)
- [gitmoji](https://gitmoji.dev/api/gitmojis)
