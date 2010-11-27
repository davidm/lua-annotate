-- luaannotate.lua
-- (C) 2010, David Manura


-- Load annotations file.
local function load_annotations(path)
  local filename = path:match'[^\\/]+$'
  if not filename then
    error('Invalid path ' .. path)
  end
  
  local annotations = {}
  local id
  local text = ''
  local function commit()
    if id then
      --print('DEBUG-luacomment-commit', id, text)
      text = text:gsub('[\r\n]$', '')
      annotations[id] = text
    end
  end

  -- Process line-by-line.
  local fh = assert(io.open(path))
  local linenum = 1
  for line in fh:lines() do
    if line:match'^#' then
      commit()
      local sfile, sname = line:match'^#%s*([^:]+):([%w_]*)'
      if not sfile then
        error('Invalid directive in ' .. path .. ':' .. linenum)
      end
      text = ''
      id = sfile .. ':' .. sname
    else
      text = text .. (text ~= '' and '\n' or '') .. line
    end
    linenum = linenum + 1
  end
  commit()
  
  return annotations
end

-- Locates where annotations should go in source string `code`
-- in file path `path`.
local function place_annotations(code, path, annotations)
  local sfile = path:match'[^\\/]+$'
  
  local notes = {}

  -- Comments on functions/macros/structs
  -- TODO: could be improved (robustness)
  local iline = 1
  for line in (code .. '\n'):gmatch'(.-)\r?\n' do
    local sname =
      line:match'^[%w_ ]-[%w_*]+%s([%w_]+)%s*%b()%s*%{?$' or
      line:match'^#define%s+([%w_]+)' or
      line:match'^typedef%s+struct%s+([%w_]+)' or
      line:match'^typedef%s+union%s+([%w_]+)' or
      line:match'^typedef%s+.*%s+([%w_]+);'
    if sname then
      local id = sfile .. ':' .. sname
      local comment = annotations[id]
      --print('DEBUG-luacomment-comment', comment, id)
      if comment then
        table.insert(notes, {iline, comment})
      end
    end
    iline = iline + 1
  end

  -- Comments on file.
  local filecomment = annotations[sfile .. ':']
  if filecomment then
    if notes[1] and notes[1][1] == 1 then -- existing comment on line 1
      local comment = filecomment .. '\n\n' .. notes[1][2]
      notes[1][2] = comment
    else
      table.insert(notes, 1, {1, filecomment})
    end
  end

  return notes
end

-- Utility function to check whether file exists (actually, is readable).
local function exists_file(path)
  local fh = io.open(path)
  if fh then fh:close() return true end
  return false
end

-- Utility function to load file into string (text mode).
local function read_file(path)
  local fh, err = io.open(path)
  if not fh then
    error('Could not open ' .. path .. ' : ' .. err)
  end
  local data = fh:read'*a'
  fh:close()
  return data
end

-- SciTE specific
if scite_OnOpen then -- if ExtMan installed
  -- Add annotation notes to SciTE buffer.
  local function scite_annotate_buffer(notes)
    editor.AnnotationVisible = 2
    for _, note in ipairs(notes) do
      local iline, comment = unpack(note)
      editor:AnnotationSetText(iline-1, comment)
      --editor:AnnotationStyle[iline] = 1
    end
  end

  -- SciTE ExtMan callback function, on file opened.
  scite_OnOpen(function(path)
    local annotations_path = path:gsub('[^\\/]+$', 'annotations.txt')
    print('DEBUG-luacomment-open', path, annotations_path)
    if exists_file(annotations_path) then
      local code = editor:GetText()
      local annotations = load_annotations(annotations_path)
      local notes = place_annotations(code, path, annotations)
      scite_annotate_buffer(notes)
    end
  end)
	
	return
end

-- Escapes characters in text to allow embedding inside C comment (/* */).
local function cpp_escape_comment(text)
  text = text:gsub('%*/', '* /')
  return text
end

-- Adds annotations to code.
local function cpp_annotate(code, notes)
  local commentofline = {} -- index
  for _, linecomment in ipairs(notes) do
    local iline, comment = unpack(linecomment)
    commentofline[iline] = comment
  end

  -- TODO: could be improved: avoid nested comments
  local iline = 1
  code = (code .. '\n'):gsub('(.-\r?\n)', function(line)
    if commentofline[iline] then
      line = '/*# ' .. cpp_escape_comment(commentofline[iline]) .. '*/\n' .. line
    end
    iline = iline + 1
    return line
  end)
  return code
end

-- Command-line usage: lua luacomment.lua <filename>
local path = ...
if path then
  local annotations_path = path:gsub('[^\\/]+$', 'annotations.txt')
  local code = read_file(path)
  local annotations = load_annotations(annotations_path)
  local notes = place_annotations(code, path, annotations)
  code = cpp_annotate(code, notes)
  io.stdout:write(code)
else
  io.stderr:write('usage: luaannotate.lua <filename>')
	os.exit(1)
end
