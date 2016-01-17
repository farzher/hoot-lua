local function factory()
  -- Our new hoot object :3
    local hoot = {}
  -- When you call hoot(self), self gets shoved in this list as the key with a wrapped version as the value
    local wrapped_list
  -- For iteration performance, all timers from all objects also exist here
  -- (This means they need to be created and cleared in pairs :/ )
    local timer_set
  -- Will be set to hoot(hoot), which is used for static hoot. calls
    local wrapped_hoot

  -- Wrapper class (in factory for closure!)
    local Wrapper = {}
    function Wrapper:__index(key) return Wrapper[key] end
    function Wrapper:get(key) return self.timers[key] end
    function Wrapper:clear(key)
      local timer = self.timers[key]
      if not timer then return end
      self.timers[key] = nil
      timer_set[timer] = nil
      return true
    end
    function Wrapper:destroy()
      for i=1, #self.timers do local timer = self.timers[i]
        timer_set[timer] = nil
      end
      wrapped_list[self.original] = nil
    end
    function Wrapper:set(f, delay, options)
      local key

      -- If f is string, default key to f
        if type(f)=='string' then key = f end

      -- options
        if options then

          -- options.key
            if options.key~=nil then key = options.key end

          -- options.onlyif
            if options.onlyif=='notexists' then
              if self.timers[key] then return end
            elseif options.onlyif=='notactive' then
              if self.timers[key] and self.timers[key].delay>0 then return end
            elseif options.onlyif=='exists' then
              if not self.timers[key] then return end
            elseif options.onlyif=='active' then
              if not (self.timers[key] and self.timers[key].delay>0) then return end
            end
        end

      -- If no key, pick a unqiue random key
        if not key then
          repeat
            key = math.random()
          until self.timers[key]==nil
      -- If a timer with the same key already exists, we need to clear it from the timer_set!
        else
            local existing_timer = self.timers[key]
            if existing_timer then timer_set[existing_timer] = nil end
        end

      -- Create the timer, insert it into the wrapper's timers and the global timer set
        local timer = {wrapped=self, key=key, delay=delay, f=f, options=options}
        self.timers[key] = timer
        timer_set[timer] = true

      return key
    end

  function hoot:__call(original)
    if wrapped_list[original] then return wrapped_list[original] end

    local wrapped = setmetatable({original=original, timers={}}, Wrapper)
    wrapped_list[original] = wrapped
    return wrapped
  end
  function hoot.update(dt)
    -- We can't handle finished timers during the loop because of user `f` code messing with timer keys before current timers are cleared
      local finished_list

    -- Loop all existing timers
      for timer in pairs(timer_set) do
        timer.delay = timer.delay - dt

        -- Timer is finished!
          if timer.delay<=0 then
            if not finished_list then finished_list = {} end
            finished_list[#finished_list+1] = timer

            timer.wrapped:clear(timer.key)
          end
      end

    if finished_list then
      for i=1, #finished_list do local timer = finished_list[i]
        local original = timer.wrapped.original

        -- f
          if type(timer.f)=='string' then
            if original[timer.f] then original[timer.f](original) end
          elseif type(timer.f)=='function' then
            timer.f(original)
          end
      end
    end
  end
  function hoot.set(...) return wrapped_hoot:set(...) end
  function hoot.get(...) return wrapped_hoot:get(...) end
  function hoot.clear(...) return wrapped_hoot:clear(...) end
  function hoot.destroy() wrapped_list = {} timer_set = {} wrapped_hoot = hoot(hoot) end
  function hoot.new() return factory() end

  hoot = setmetatable(hoot, hoot)
  -- Used to init fresh variables (destroy is more of a "reset")
    hoot.destroy()
  return hoot
end

return factory()
