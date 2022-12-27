#!/usr/bin/env lua

-- This pipe receives hooks emitted by herbstluftmwm
-- We place this in the top in order to not lose any emmited hook
-- while the file is being executed
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

local function keys(t)
  local out = {}
  for k in pairs(t) do
    out[#out+1] = k
  end
  return out
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

-- Interface for herbstclient command
local hc = setmetatable({
  query = function(attr)
    local pipe = io.popen(fmt("herbstclient get_attr %s", attr))
    local s = pipe:read("*a"):gsub("^%s+", ""):gsub("%s+^", ""):gsub("[\r\n]+$", "")
    pipe:close()
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

-- Whole program state.
local Layout = {
  -- Store all sessions by name
  sessions = {},
  -- Index of the currently active session.
  --The intent is to use it in conjunction with the sessions list above.
  active_session = nil,
}

local hlwm_separator = "|"
local hlwm_index_separator = "@"
local hlwm_active_separator = "%"

local function tags_string(session)
  local tags = {}

  for k, tag in pairs(session.tags) do
    tags[#tags + 1] = {key = k, tag = tag}
  end

  table.sort(tags, function(x, y) return x.key < y.key end)

  for k, v in ipairs(tags) do
    local sep = (v.key == session.active) and hlwm_active_separator or hlwm_index_separator
    tags[k] = fmt("%s%s%s", v.key, sep, v.tag)
  end

  local a = table.concat(tags, hlwm_separator)
  print(a)
  return "'" .. table.concat(tags, hlwm_separator) .. "'"
end

local function sessions_string(sessions)
  local names = keys(sessions)
  local outs = {}

  table.sort(names)

  for k, name in ipairs(names) do
    local sep = (name == Layout.active_session) and hlwm_active_separator or hlwm_index_separator
    outs[k] = fmt("%s%s%s", k, sep, name)
  end

  return "'" .. table.concat(outs, hlwm_separator) .. "'"
end

local function notify_wm()
  -- Tell wm that we switched focus
  hc.set_attr("my_session", Layout.active_session)

  hc.set_attr("my_sessions", sessions_string(Layout.sessions))

  for name, session in pairs(Layout.sessions) do
    hc.set_attr("my_session_tags_" .. name, tags_string(session))
  end
end

local session_methods = {
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

    -- Mark this tag as the new active and tell window manager to use it.
    Layout.active_session = session.name
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
    elseif session_methods[k] ~= nil then
      return session_methods[k]
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
local reactions
reactions = {
  session_create = function(name, ...)
    if Layout.sessions[name] then
        errorf("A session called '%s' already exists", name)
    end

    local session  = Session(name)
    Layout.sessions[name] = session

    local tags = table.pack(...)
    for i = 1, tags.n do
      session:add_tag(tags[i])
    end

    -- Hack to expose tag information to external scripts
    hc.new_attr("string", "my_session_tags_" .. name)

    -- Enter the session if there is no other
    if not Layout.active_session then
      session:enter()
    end
  end,

  session_enter = function(name, unparsed_index)
    local session = Layout.sessions[name]
    local index   = tonumber(unparsed_index)

    if not session then
      errorf("No session '%s'", name)
    end

    session:enter(index)
  end,

  session_rename = function(old, new)
    if not Layout.sessions[old] then
      errorf("No session '%s'", old)
    end

    if Layout.sessions[new] then
      errorf("Session '%s' already exists", new)
    end

    Layout.sessions[new] = Layout.sessions[old]
    Layout.sessions[old] = nil
    Layout.sessions[new].name = new

    local s = hc.query("my_session_tags_" .. old)
    hc.new_attr("string", "my_session_tags_" .. new, fmt('"%s"', s))
    hc.remove_attr("my_session_tags_" .. old)
  end,

  session_merge = function(rip, target)
    if not Layout.sessions[rip] or not Layout.sessions[target] then
      errorf("One of the sessions %s and %s does not exist", rip, target)
    end

    if Layout.active_session == rip then
      errorf("Cannot delete active session %s", rip)
    end

    -- Movw all tags to target
    for _, tag in ipairs(Layout.sessions[rip].tags) do
      Layout.sessions[target]:add_tag(tag)
    end

    Layout.sessions[rip] = nil

    hc.remove_attr("my_session_tags_" .. rip)
  end,

  session_tag_add = function(name, tag, unparsed_index)
    local index   = tonumber(unparsed_index)
    local session = Layout.sessions[name]

    session:add_tag(tag, index)
  end,

  session_tag_remove = function(name, tag)
    local session   = Layout.sessions[name]

    if session.active_tag == tag then
      errorf("Cannot remove active tag '%s' from session '%s'", tag, name)
    end

    session:remove_tag(tag)
  end,

  session_tag_swap = function(name, unparsed_i1, unparsed_i2)
    local session = Layout.sessions[name]
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
    local session = Layout.sessions[name]
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
    local session = Layout.sessions[Layout.active_session]

    if hc.attr("tags.by-name." .. tag) then
      infof("Trying to add tag '%s' but it already exists", tag)
    else
      session:add_tag(tag)
    end
  end,

  tag_removed = function(tag)
    for _, session in pairs(Layout.sessions) do
      session:remove_tag(tag)
    end
  end,

  tag_renamed = function(old, new)
    for _, session in pairs(Layout.sessions) do
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
    local session = Layout.sessions[Layout.active_session]
    local index = find(session.tags, tag)

    if index then
      session.active = index
    end
  end,

  -- Synchronize hlwm attributes with this script's state
  attribute_changed = function(path, old, new)
    if path == "my_session" then
      Layout.sessions[new]:enter()
    end
  end
}

local function query_my(str)
  local tag_str = hc.query(str)
  return coroutine.wrap(function()
    for line in tag_str:gmatch("([^%|]+)") do
      local i, status, tag = line:match("(.*)([%@%%])(.*)")
      coroutine.yield(tag, tonumber(i), status == "%")
    end
  end)
end

local function restore_from_attributes()
  -- Reload sessions
  for name, _ , is_active_session in query_my("my_sessions") do
    local session = Session(name)
    Layout.sessions[name] = session

    -- Add tags to this session
    for tag, index, isactive in query_my("my_session_tags_" .. name) do
      print("restore", name, index, tag, isactive)

      session:add_tag(tag, index)

      if isactive then
        session.active = index
      end
    end

    -- Enter the active session
    if is_active_session then
      Layout.sessions[name]:enter()
    end
  end
end

------------------------------
-- The running script
------------------------------

-- Store info in the wm for external querying
hc.new_attr("string", "my_session")
hc.new_attr("string", "my_sessions")

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

  if reactions[hook] then
    local code, msg = pcall(reactions[hook], table.unpack(args))

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
