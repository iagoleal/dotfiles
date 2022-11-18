#!/usr/bin/env lua

---------------------------------
-- General helper functions
---------------------------------

local fmt = string.format
table.unpack = table.unpack or unpack

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
local function find_hole(t)
  local len = select('#', table.unpack(t))
  for i = 1, len+1 do
    if t[i] == nil then
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
  local out = {}
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- Interface for herbstclient command
local hc = setmetatable({}, {
  __call = function(_, ...)
    return os.capture(fmt("herbstclient %s", table.concat(table.pack(...), " ")))
  end,

  __index = function(t, k)
    return function(...)
      t(k, ...)
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
end

local function activate_session(name)
  if type(name) == "table" then
    name = find(sessions, name)
  end

  active_session = name

  -- Tell wm that we swtiched focus
  hc.set_attr("my_session", name)
end

local methods = {
  add_tag = function(self, tag, index)
    if index and not tag then
      tag = fmt("%s_%d", active_session, index)
    end

    if find(self.tags, tag) then
      return
    end

    if not index then
      index = find_hole(self.tags)
    end

    hc.add(tag)
    self.tags[index] = tag

    if not self.active then
      self.active = index
    end
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

local function Session(name, ...)
  return setmetatable({
    name = name,
    tags = {...},
    active = select("#", ...) > 0 and 1 or nil,
    }, session_mt)
end

local function isempty(session)
  return not next(session.tags)
end

-- This is a dispatch table defining how to react to each hook.
local actions
actions = {
  session_create = function(name, tag)
    if sessions[name] then
        errorf("A session called '%s' already exists", name)
    end

    local session = Session(name, tag)
    sessions[name] = session

    if session.active then
      hc.use(sessions.active)
    end

    -- Make the session active if it is the first one
    if not active_session then
      activate_session(name)
    end

    hc.new_attr("string", "my_session_tags_" .. name)

  end,

  session_enter = function(name)
    local session = sessions[name]

    if not session then
      errorf("No session '%s'", name)
    elseif isempty(session) then
        infof("Session '%s' nas no tags", name)
        session:add_tag(name .. "_1")
    else
      activate_session(name)

      hc.use(session.active_tag)
    end

  end,

  session_tag_switch = function(unparsed_index)
    local on_session_index = tonumber(unparsed_index)
    local session = sessions[active_session]
    local tag = session.tags[on_session_index]

    if not tag then
      infof("Session '%s' has no tag with index %s", active_session, on_session_index)
      tag = fmt("%s_%d", active_session, on_session_index)
      hc.add(tag)
      actions.session_tag_add(active_session, tag, unparsed_index)
    end

    session.active = on_session_index

    hc.use(tag)
  end,

  session_tag_add = function(session_name, tag, unparsed_index)
    local session   = sessions[session_name]
    local on_session_index = find(session, tag)
    local index = tonumber(unparsed_index)

    if on_session_index then
      session.active = on_session_index
      infof("Session '%s' already contains tag '%s'", session_name, tag)
    elseif session.tags[index] then
      infof("Session '%s' already has tag '%s' on index %d", session_name, tag)
    else
      session:add_tag(tag, index)
    end
  end,

  session_window_move = function(unparsed_index)
    local index = tonumber(unparsed_index)
    local session = sessions[active_session]
    if not session.tags[index] then
      session:add_tag(nil, index)
    end
    hc.move(session.tags[index])
  end,

  -- Herbstlutftwm's internal hooks.
  -- These are fired automatically when some tag-changing event happens.

  tag_added   = function(tag)
    local session = sessions[active_session]
    session:add_tag(tag)
  end,

  tag_removed = function(tag)
    for _, session in pairs(sessions) do
      tags = session.tags
      for k in pairs(tags) do
        if tags[k] == tag then
          infof("removing tag %s from sesssion %s", tag, session.name)
          tags[k] = nil
        end
      end
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
      activate_session(new)
    end
  end
}


local function restore_from_attributes()
  -- Reload sessions
  do
    local my_sessions
    do
      local pipe = io.popen("herbstclient get_attr my_sessions")
      my_sessions = pipe:read("*l")
      pipe:close()
    end

    for name in string.gmatch(my_sessions, fmt("([^%s]+)", hlwm_separator)) do
      actions.session_create(name)

      -- Restore tags for this session
      local pipe = io.popen("herbstclient get_attr my_session_tags_" .. name)
      local my_session_tags = pipe:read("*l")
      pipe:close()

      if my_session_tags then
        for word in my_session_tags:gmatch(fmt("([^%s]+)", hlwm_separator)) do
          local index, tag = word:match("(%d+)" .. hlwm_index_separator .. "(.*)")
          print("restore", name, index, tag)
          if index and tag then
            actions.session_tag_add(name, tag, index)
          end
        end
      end
    end
  end

  -- Activate current saved session
  do
    local pipe = io.popen("herbstclient get_attr my_session")
    local my_session = pipe:read("*l")
    pipe:close()

    actions.session_enter(my_session)
  end
end

------------------------------
-- The running script
------------------------------

-- This pipe receives hooks emitted by herbstluftmwm
local hooks, msg = io.popen("herbstclient -i")
if not hooks then error(msg) end

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
      notify_wm()
    else
      io.write(fmt("WARN: %s\n", msg))
    end
  end

end

hooks:close()
