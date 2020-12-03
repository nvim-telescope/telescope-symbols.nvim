local Job = require'plenary.job'

local download_file = function(source, callback)
  local output = {}
  Job:new {
    command = 'curl',
    args = { '-s', source },
    on_stdout = function(_, line)
      line = callback(line)
      if line then
        table.insert(output, line)
      end
    end
  }:sync()
  return output
end

local format_json = function(file)
  local output = {}
  Job:new {
    command = 'jq',
    args = { '.', file },
    on_stdout = function(_, line)
      table.insert(output, line)
    end
  }:sync()
  return output
end

local write_to_file = function(source, filename)
  local sourced_file = require('plenary.debug_utils').sourced_filepath()
  local base_directory = vim.fn.fnamemodify(sourced_file, ":h:h")
  local dir = base_directory .. '/data'
  if vim.loop.fs_stat(dir) == nil then
    assert(vim.loop.fs_mkdir(dir, 493))
  end
  dir = dir .. '/telescope-sources/'
  if vim.loop.fs_stat(dir) == nil then
    assert(vim.loop.fs_mkdir(dir, 493))
  end

  local file = dir .. filename
  local fd = assert(vim.loop.fs_open(file, "w", 438))
  assert(vim.loop.fs_write(fd, source, 0))

  if vim.fn.executable('jq') then
    local formated_source = vim.fn.join(format_json(file), '\n')
    assert(vim.loop.fs_write(fd, formated_source, 0))
  end
  assert(vim.loop.fs_close(fd))
end

-- https://stackoverflow.com/questions/26071104/more-elegant-simpler-way-to-convert-code-point-to-utf-8/26237757#26237757
local utf8 = function(cp)
  if cp < 128 then
    return string.char(cp)
  end
  local s = ""
  local prefix_max = 32
  while true do
    local suffix = cp % 64
    s = string.char(128 + suffix)..s
    cp = (cp - suffix) / 64
    if cp < prefix_max then
      return string.char((256 - (2 * prefix_max)) + cp)..s
    end
    prefix_max = prefix_max / 2
  end
end

local get_emoji_source = function()
  local source = download_file('https://www.unicode.org/Public/emoji/13.1/emoji-test.txt', function(line)
    if not line:find('; fully.qualified') then -- only emojis
      return nil
    end
    if line:find([[‍]]) then -- gets rid of concatenates emojis.
      return nil
    end
    -- skin/hair colors which are used to create some emojis in different colors. Useless for us
    local skin = { '🏻', '🏼', '🏽', '🏾', '🏿', '🦰', '🦱', '🦳', '🦲' }
    for _, v in ipairs(skin) do
      if line:find(v) then
        return nil
      end
    end
    line = line:gsub('.* # ', '')
    line = line:gsub(' E[0-9]*.[0-9]', '')
    line = line:gsub('%s', '   ', 1)
    local symbol, description = line:match('(.+)%s%s%s(.*)')
    return { symbol, description }
  end)
  local json = vim.fn.json_encode(source)
  write_to_file(json, 'emoji.json')
end

local get_math_source = function()
  local download_source = 'https://raw.githubusercontent.com/wspr/unicode-math/ef5688f303d7010138632ab45ef2440d3ca20ee5/unicode-math-table.tex'
  local source = download_file(download_source, function(line)
    if line:sub(1, 8) ~= [[\Unicode]] then
      return nil
    end
    local symbol, description = line:match('.*{(.*)}{.*}{.*}{(.*)}')
    symbol = symbol:gsub('"', '0x')
    symbol = tonumber(symbol)
    symbol = utf8(symbol)
    return { symbol, description }
  end)
  local json = vim.fn.json_encode(source)
  write_to_file(json, 'math.json')
end

local get_latex_source = function()
  local download_source = 'https://raw.githubusercontent.com/wspr/unicode-math/ef5688f303d7010138632ab45ef2440d3ca20ee5/unicode-math-table.tex'
  local source = download_file(download_source, function(line)
    if line:sub(1, 8) ~= [[\Unicode]] then
      return nil
    end
    local symbol, description = line:match('.*{.*}{(.*)}{.*}{(.*)}')
    symbol = symbol:gsub('%s*$', '')
    return { symbol, description }
  end)
  local json = vim.fn.json_encode(source)
  write_to_file(json, 'latex.json')
end

local get_kaomoji_source = function()
  local download_source = 'https://raw.githubusercontent.com/kuanyui/kaomoji.el/90a1490743b2a30762f5454c9d9309018eff83dd/kaomoji-data.el'
  local source = download_file(download_source, function(line)
    if not line:find('%s%.%s') then
      return nil
    end
    local tmp_table = vim.split(line, ' %. ')
    tmp_table[1] = tmp_table[1]:match('^%s*\'*%(*(.*)%)%s*$')
    tmp_table[1] = tmp_table[1]:gsub('"', '')
    tmp_table[1] = tmp_table[1]:gsub('%s*$', '') -- There are also trailing whitespaces inside ()

    tmp_table[2] = tmp_table[2]:match('^"(.+)"%s*%)$')

    line = tmp_table[2] .. '   ' .. tmp_table[1]
    return { tmp_table[2], tmp_table[1] }
  end)
  local json = vim.fn.json_encode(source)
  write_to_file(json, 'kaomoji.json')
end

get_emoji_source()
get_math_source()
get_latex_source()
get_kaomoji_source()
