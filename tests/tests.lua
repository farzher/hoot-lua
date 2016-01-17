local luaunit = require('luaunit')
local hoot = dofile('../hoot.lua')

local EQUALS = luaunit.assertEquals
local NIL = function(a) luaunit.assertEquals(a, nil) end
local NOT_NIL = function(a) luaunit.assertNotEquals(a, nil) end

function test()
  local totalms = 0
  local async_count = 0
  local function async_assert_ms(ms)
    async_count = async_count + 1
    return function()
      async_count = async_count - 1
      EQUALS(totalms, ms)
    end
  end
  local function async_called(times)
    async_count = async_count + times
    return function() async_count = async_count - 1 end
  end

  local entity = {}




  NIL(hoot(entity):get('a'))

  local hoot2 = hoot.new()
  local key = hoot(entity):set('a', 1)
  local key2 = hoot2(entity):set('a', 2)
  EQUALS(hoot(entity):get(key).delay, 1)
  EQUALS(hoot2(entity):get(key).delay, 2)

  NIL(hoot({}):get(key))

  hoot(entity):set(async_assert_ms(1), 1)

  NIL(hoot(entity):set('active', 1, {onlyif='active'}))
  hoot(entity):set('active', 1)
  NOT_NIL(hoot(entity):set('active', 1, {onlyif='active'}))
  hoot(entity):set('active', 0)
  NIL(hoot(entity):set('active', 1, {onlyif='active'}))

  NIL(hoot(entity):set('exists', 1, {onlyif='exists'}))
  hoot(entity):set('exists', 1)
  NOT_NIL(hoot(entity):set('exists', 1, {onlyif='exists'}))
  hoot(entity):set('exists', 0)
  NOT_NIL(hoot(entity):set('exists', 1, {onlyif='exists'}))

  NOT_NIL(hoot(entity):set('notactive', 1, {onlyif='notactive'}))
  hoot(entity):set('notactive', 1)
  NIL(hoot(entity):set('notactive', 1, {onlyif='notactive'}))
  hoot(entity):set('notactive', 0)
  NOT_NIL(hoot(entity):set('notactive', 1, {onlyif='notactive'}))

  NOT_NIL(hoot(entity):set('notexists', 1, {onlyif='notexists'}))
  hoot(entity):set('notexists', 1)
  NIL(hoot(entity):set('notexists', 1, {onlyif='notexists'}))
  hoot(entity):set('notexists', 0)
  NIL(hoot(entity):set('notexists', 1, {onlyif='notexists'}))

  hoot(entity):set('clear', 1)
  hoot(entity):clear('clear')
  NIL(hoot(entity):get('clear'))

  local entity2 = {}
  local entity2_hoot = hoot(entity2)
  entity2_hoot:set('a', 1)
  entity2_hoot:destroy()
  NIL(hoot(entity2):get('a'))
  -- using entity2_hoot after it's destroied will cause issues!
    NOT_NIL(entity2_hoot:get('a'))
  hoot(entity2):set('a', 1)
  EQUALS(hoot(entity2):get('a').delay, 1)

  local tmp_hoot = hoot.new()
  local tmp_entity = {}
  tmp_hoot(tmp_entity):set(nil, 1, {key='a'})
  NOT_NIL(tmp_hoot(tmp_entity):get('a'))
  tmp_hoot(tmp_entity):set('b', 1, {key=false})
  NIL(tmp_hoot(tmp_entity):get('b'))
  tmp_hoot.destroy()
  NIL(tmp_hoot(tmp_entity):get('a'))

  -- this is a nice performance test
    for i=1, 1000 do
      local tmp_entity = {}
      tmp_entity.func = async_called(1)
      hoot(tmp_entity):set('func', 1*1000)
      hoot(tmp_entity):set('func', 1*1000)
    end

  local tmp_entity = {}
  tmp_entity.func = async_called(2)
  hoot(tmp_entity):set('func', 1, {key='a'})
  hoot(tmp_entity):set('func', 1, {key='b'})

  hoot(entity):set('clear', 1)
  -- hoot(entity):set('noclear', 1, {noclear=true})

  local key = hoot.set('a', 555)
  NOT_NIL(hoot.get(key))
  NOT_NIL(hoot(hoot):get(key))
  hoot(hoot):clear(key)
  NIL(hoot.get(key))

  -- This should keep calling itself
    async_called(60*1000/100 + 1)
    local function reset()
      async_count=async_count-1
      hoot.set(reset, 100, {key='reset'})
    end
    reset()





  -- -- Normal timer counters
  --   local counter = 0
  --   local Entity = {}
  --   function Entity:__index(key) return Entity[key] end
  --   function Entity:init() self.timer = 0 end
  --   function Entity:update(dt)
  --     self.timer = self.timer - dt

  --     if self.timer <= 0 then
  --       self.timer = 60
  --       self:trigger()
  --     end
  --   end
  --   function Entity:trigger() counter=counter+1 end
  --   local entities = {}
  --   for i=1, 10000 do
  --     local entity = setmetatable({}, Entity)
  --     entity:init()
  --     table.insert(entities, entity)
  --   end
  --   for i=1, 1000 do
  --     for i=1, #entities do local entity = entities[i]
  --       entity:update(1)
  --     end
  --   end
  --   print(counter)



  -- -- Hoot
  --   local tmp_hoot = hoot.new()
  --   local counter = 0
  --   local Entity = {}
  --   function Entity:__index(key) return Entity[key] end
  --   function Entity:init() self.hoot=tmp_hoot(self) self:trigger() end
  --   function Entity:trigger() counter=counter+1 self.hoot:set('trigger', 60) end
  --   local entities = {}
  --   for i=1, 10000 do
  --     local entity = setmetatable({}, Entity)
  --     entity:init()
  --     table.insert(entities, entity)
  --   end
  --   for i=1, 1000 do
  --     tmp_hoot.update(1)
  --   end
  --   print(counter)


  -- -- Hump
  --   local Timer = require 'timer'
  --   local counter = 0
  --   local Entity = {}
  --   function Entity:__index(key) return Entity[key] end
  --   function Entity:init() self:trigger() end
  --   function Entity:trigger() counter=counter+1 Timer.add(60, function() self:trigger() end) end
  --   local entities = {}
  --   for i=1, 10000 do
  --     local entity = setmetatable({}, Entity)
  --     entity:init()
  --     table.insert(entities, entity)
  --   end
  --   for i=1, 1000 do
  --     Timer.update(1)
  --   end
  --   print(counter)







  function try_dash(ms)
    return not hoot(entity):set('dash_right_timer', ms, {onlyif='notexists'})
  end

  local dt = 1
  while totalms<1000*60 do
    totalms = totalms + dt
    hoot.update(dt)

    if totalms==1 then

    elseif totalms==100 then
      EQUALS(try_dash(10), false)

    elseif totalms==111 then
      EQUALS(try_dash(10), false)

    elseif totalms==120 then
      EQUALS(try_dash(10), true)

    elseif totalms==150 then
      EQUALS(try_dash(10), false)
      EQUALS(try_dash(10), true)
    end
  end

  NIL(hoot(entity):get('clear'))
  -- NOT_NIL(hoot(entity):get('noclear'))


  EQUALS(async_count, 0)
end

os.exit(luaunit.LuaUnit.run())
