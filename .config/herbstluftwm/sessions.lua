#!/usr/bin/env lua

-- This pipe receives hooks emitted by herbstluftmwm
local hooks, msg = io.popen("herbstclient -i")
if not hooks then error(msg) end

---------------------------------
-- General helper functions
---------------------------------

local fmt = string.format
table.unpack = table.unpack or unpack
table.pack   = table.pack or function(...)
  return {n = select('#', ...), ...}
end

local function errorf(str, ...)
  error(fmt(str, ...))
end

local function infof(str, ...)
  io.write("INFO: ", fmt(str, ...), "\n")
end

local function find(t, v)
  for k in pairs(t) do
    if t[k] == v then
      return k
    end
  end
end

-- Iterate over a table with numeric indices
-- until finding a nil one.
-- In case there are no holes, it returns the next avaiable index.
local function findhole(t)
  local len = select('#', table.unpack(t))
  for i = 1, len do
    if t[i] == nil then
      return i
    end
  end
  return len+1
end

-- Iterate over a table with numeric indices
-- until finding a nil one.
-- In case there are no holes, it returns the next avaiable index.
local function findfilled(t)
  local len = select('#', table.unpack(t))

  for i = 1, len do
    if t[i] ~= nil then
      return i
    end
  end
end

local function split(str, delimiter)
  local hook, args = "", {}
  local isfirst = true
  for word in string.gmatch(str, fmt("([^%s]+)", delimiter)) do
    if isfirst then
      hook, isfirst = word, false
    else
      table.insert(args, word)
    end
  end
  return hook, args
end

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- Interface for herbstclient command
local hc = setmetatable({
  query = function(attr)
    local pipe = io.popen(fmt("herbstclient get_attr %s", attr))
    local s = pipe:read("*a")
    pipe:close()
    s = string.gsub(s, '[\n\r]+', ' ')
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    return s
  end
  }, {
  __call = function(_, ...)
    return os.execute(fmt("herbstclient %s", table.concat(table.pack(...), " ")))
  end,

  __index = function(t, k)
    return function(...)
      return t(k, ...)
    end
  end
})

-----------------------------------------------
-- Session manipulation
-----------------------------------------------

-- Store all sessions
sessions = {}

-- Index of the currently active session.
--The intent is to use it in conjunction with the sessions list above.
active_session = nil

local hlwm_separator = "|"
local hlwm_index_separator = "@"

local function tags_string(session)
  local tags = {}

  for k, tag in pairs(session.tags) do
    tags[#tags + 1] = {key = k, tag = tag}
  end

  table.sort(tags, function(x, y) return x.key < y.key end)

  for k, v in ipairs(tags) do
    sep = (v.key == session.active) and hlwm_index_separator or (hlwm_index_separator .. hlwm_index_separator)
    tags[k] = fmt("%s%s%s", v.key, hlwm_index_separator, v.tag)
  end

  local a = table.concat(tags, hlwm_separator)
  print(a)
  return "'" .. table.concat(tags, hlwm_separator) .. "'"
end

local function sessions_string(sessions)
  local names = {}

  for k in pairs(sessions) do
    names[#names + 1] = k
  end

  return "'" .. table.concat(names, hlwm_separator) .. "'"
end

local function notify_wm()
  local current = sessions[active_session]

  hc.set_attr("my_sessions", sessions_string(sessions))
  hc.set_attr("my_session_tags", tags_string(current))

  for name, session in pairs(sessions) do
    hc.set_attr("my_session_tags_" .. name, tags_string(session))
  end

  -- Tell wm that we switched focus
  hc.set_attr("my_session", active_session)
end

local methods = {
  add_tag = function(session, tag, index, move)

    -- Do nothing if the session already has this tag
    if find(session.tags, tag) then
      infof("Session '%s' already contains tag '%s'", session.name, tag)
      return
    end

    -- ~:~ Default parameters ~:~ --
    -- Index is the first nil value on the list;
    -- Tag name is "<session>_<Index>";
    index = index or findhole(session.tags)
    tag   = tag   or fmt("%s_%d", session.name, index)

    infof("Adding %s[%s] = %s", session.name, index, tag)

    session.tags[index] = tag

    -- Guarantee that this tag exists on WM
    -- TODO: THIS IS A HACK needed because of tag-erasure.
    -- Sometimes the other daemon deletes the new tag before we can move the window to it.
    if move then
      hc(fmt("chain . add %s . move %s", tag, tag))
    else
      hc.add(tag)
    end

    -- If this is the first tag on session, it becomes active
    if not session.active then
      session.active = index
    end
  end,

  remove_tag = function(session, tag)
    local tags = session.tags

    for k in pairs(tags) do
      if tags[k] == tag then
        infof("removing tag %s from session %s", tag, session.name)
        tags[k] = nil
      end
    end

    -- When removing the active tag, it is necessary to activate a new one.
    -- It searches in index order.
    -- If the session is empty, this will properly remove the active field.
    if session.active_tag == tag then
      session.active = findfilled(session.tags)
    end
  end,

  -- Enter a session at a given index (active tag by default)
  enter = function(session, index)
    index = index or session.active or 1

    if not session.tags[index] then -- This index has no tag
      infof("Session '%s' has no tag with index %s", session.name, index)
      session:add_tag(nil, index)
    end

    -- Mark this tag as the new active
    -- and tell window manager to use it.
    active_session = session.name
    session.active = index
    hc.use(session.active_tag)
  end,

  isempty = function(session)
    return not next(session.tags)
  end
}

local session_mt = {
  __index = function(t, k)
    if k == "active_tag" then
      local index = t.active
      return t.tags[index]
    elseif methods[k] ~= nil then
      return methods[k]
    end
  end
}

local function Session(name)
  return setmetatable({
    name = name,
    tags = {},
    active = nil,
    }, session_mt)
end

-- This is a dispatch table defining how to react to each hook.
local actions
actions = {
  session_create = function(name, ...)
    if sessions[name] then
        errorf("A session called '%s' already exists", name)
    end

    local session  = Session(name)
    sessions[name] = session

    local tags = table.pack(...)
    for i = 1, tags.n do
      session:add_tag(tags[i])
    end

    -- Hack to expose tag information to external scripts
    hc.new_attr("string", "my_session_tags_" .. name)

    -- Enter the session if there is no other
    if not active_session then
      session:enter()
    end
  end,

  session_enter = function(name, unparsed_index)
    local session = sessions[name]
    local index   = tonumber(unparsed_index)

    if not session then
      errorf("No session '%s'", name)
    end

    session:enter(index)
  end,

  session_rename = function(old, new)
    if not sessions[old] then
      errorf("No session '%s'", old)
    end

    if sessions[new] then
      errorf("Session '%s' already exists", new)
    end

    sessions[new] = sessions[old]
    sessions[old] = nil
    sessions[new].name = new

    local s = hc.query("my_session_tags_" .. old)
    hc.new_attr("string", "my_session_tags_" .. new, fmt('"%s"', s))
    hc.remove_attr("my_session_tags_" .. old)
  end,

  session_merge = function(rip, target)
    if not sessions[rip] or not sessions[target] then
      errorf("One of the sessions %s and %s does not exist", rip, target)
    end

    if active_session == rip then
      errorf("Cannot delete active session %s", rip)
    end

    -- Movw all tags to target
    for _, tag in ipairs(sessions[rip].tags) do
      sessions[target]:add_tag(tag)
    end

    sessions[rip] = nil

    hc.remove_attr("my_session_tags_" .. rip)
  end,

  session_tag_add = function(name, tag, unparsed_index)
    local index   = tonumber(unparsed_index)
    local session = sessions[name]

    session:add_tag(tag, index)
  end,

  session_tag_remove = function(name, tag)
    local session   = sessions[name]

    if session.active_tag == tag then
      errorf("Cannot remove active tag '%s' from session '%s'", tag, name)
    end

    session:remove_tag(tag)
  end,

  session_tag_swap = function(name, unparsed_i1, unparsed_i2)
    local session = sessions[name]
    local i1, i2 = tonumber(unparsed_i1), tonumber(unparsed_i2)

    session.tags[i1], session.tags[i2] = session.tags[i2], session.tags[i1]

    -- Make sure that we don't lose the active focus
    if     session.active == i1 then
      session.active = i2
    elseif session.active == i2 then
      session.active = i1
    end
  end,

  session_window_move = function(name, unparsed_index)
    local session = sessions[name]
    local index   = tonumber(unparsed_index)

    if not session then
      errorf("No session '%s'", name)
    end

    -- When the target tag does not exist,
    -- we first have to create it (with a default name)
    if not session.tags[index] then
      session:add_tag(nil, index, true)
    else
      hc.move(session.tags[index])
    end
  end,

  -- Herbstlutftwm's internal hooks.
  -- These are fired automatically when some tag-changing event happens.

  tag_added   = function(tag)
    local session = sessions[active_session]

    if hc.attr("tags.by-name." .. tag) then
      infof("Trying to add tag '%s' but it already exists", tag)
    else
      session:add_tag(tag)
    end
  end,

  tag_removed = function(tag)
    for _, session in pairs(sessions) do
      session:remove_tag(tag)
    end
  end,

  tag_renamed = function(old, new)
    for _, session in pairs(sessions) do
      tags = session.tags
      for k in pairs(tags) do
        if tags[k] == old then
          infof("Renaming tag %s to %s on sesssion %s", old, new, session.name)
          tags[k] = new
        end
      end
    end
  end,

  tag_changed = function(tag)
    local session = sessions[active_session]
    local index = find(session.tags, tag)

    if index then
      session.active = index
    end
  end,

  -- Synchronize hlwm attributes with this script's state
  attribute_changed = function(path, old, new)
    if path == "my_session" then
      sessions[new]:enter()
    end
  end
}

local function pread(cmd, mode)
  local pipe = io.popen(cmd)
  local out = pipe:read(mode)
  pipe:close()
  return out
end


local function restore_from_attributes()
  -- Reload sessions
  local my_sessions = pread("herbstclient get_attr my_sessions", "*l")

  if my_sessions then
    for name in string.gmatch(my_sessions, fmt("([^%s]+)", hlwm_separator)) do
      sessions[name] = Session(name)

      -- Restore tags for this session
      local my_session_tags = pread("herbstclient get_attr my_session_tags_" .. name, "*l")

      if my_session_tags then
        for word in my_session_tags:gmatch(fmt("([^%s]+)", hlwm_separator)) do
          local index, tag = word:match("(%d+)" .. hlwm_index_separator .. "(.*)")
          print("restore", name, index, tag)
          if index and tag then
            sessions[name]:add_tag(tag, tonumber(index))
          end
        end
      end
    end
  end

  -- Activate current saved session
  local my_session = pread("herbstclient get_attr my_session", "*l")
  if my_session then
    sessions[my_session]:enter()
  end
end

------------------------------
-- The running script
------------------------------

-- Store info in the wm for external querying
hc.new_attr("string", "my_session")
hc.new_attr("string", "my_sessions")
hc.new_attr("string", "my_session_tags")

-- Try restoring after reload
local code, msg = pcall(restore_from_attributes)
if not code then
  io.write("RESTORE: ", msg)
end

for line in hooks:lines() do
  -- Herbstluftwm emits hooks as tab separated strings
  local hook, args = split(line, "\t")
  print(hook)
  for k, v in ipairs(args) do
    print(k, v)
  end
  print("------------------")

  if hook == "reload" then
    break
  end

  if hook == "debug" then
    debug.debug()
  end

  if actions[hook] then
    local code, msg = pcall(actions[hook], table.unpack(args))

    if code then
      code, msg = pcall(notify_wm)
      if not code then
        io.write(fmt("NOTIFY_ERROR: %s\n", msg))
      end
    else
      io.write(fmt("WARN: %s\n", msg))
    end
  end
end

hooks:close()
