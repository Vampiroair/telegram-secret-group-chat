started = 0
our_id = 0

function vardump(value, depth, key)
  local linePrefix = ""
  local spaces = ""
  
  if key ~= nil then
    linePrefix = "["..key.."] = "
  end
  
  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do spaces = spaces .. "  " end
  end
  
  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces ..linePrefix.."(table) ")
    else
      print(spaces .."(metatable) ")
        value = mTable
    end		
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)	== 'function' or 
      type(value)	== 'thread' or 
      type(value)	== 'userdata' or
      value		== nil
  then
    print(spaces..tostring(value))
  else
    print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
  end
end

print ("HI, this is lua script")

function ok_cb(extra, success, result)
end

function on_msg_receive (msg)
  if started == 0 then
    return
  end
  if msg.out then
    return
  end

  if (msg.text == ':ping') then
    if (msg.to.id == our_id) then
      send_msg (msg.from.print_name, 'pongx', ok_cb, false)
    else
      send_msg (msg.to.print_name, 'pong', ok_cb, false)
    end
    return
  end
  if (msg.text == ':PING') then
    if (msg.to.id == our_id) then
      fwd_msg (msg.from.print_name, msg.id, ok_cb, false)
    else
      fwd_msg (msg.to.print_name, msg.id, ok_cb, false)
    end
    return
  end

  -- broadcasting message
  local friend_list = {'!_Mr_A', '!_Mr_B', '!_Mr_C', '!_Mr_D'}
  for i = 1, #friend_list do
    if (msg.to.print_name == friend_list[i]) then
      -- skip
    else
      send_msg(friend_list[i], string.sub(msg.to.print_name, 3) .. ': ' .. msg.text, ok_cb, false)
    end
  end
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

function cron()
  -- do something
  postpone (cron, false, 1.0)
end

function on_binlog_replay_end ()
  started = 1
  postpone (cron, false, 1.0)
end
