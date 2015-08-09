##[hoot.lua](https://raw.github.com/farzher/hoot-lua/master/hoot.lua) (Handles-free Object Oriented Timer)
A better way to deal with timer events. Intended for [LÖVE](https://love2d.org/)


##What? Why?

To cleanup this type of code
```lua
self.wakeup_timer = 0
self.is_down = false

function Enemy:knockdown()
  self.is_down = true
  self.wakeup_timer = 1
end

function Enemy:update(dt)
  if self.is_down then
    self.wakeup_timer = self.wakeup_timer - dt
    if self.wakeup_timer <= 0 then
      self.is_down = false
    end
  end

  if self.is_down then print('Im down!') end
end
```

And replace it with this type of code
```lua
function Enemy:knockdown()
  hoot(self):set('is_down', 1)
end

function Enemy:update()
  if hoot(self):get('is_down') then print('Im down!') end
end
```



##Installation
```lua
hoot = require 'hoot'

function love.update(dt) hoot.update(dt) end
```


##Usage Examples


Set the lifespan of this object to 5 seconds
```lua
function Bullet:destroy()
  -- TODO: Remove object from game
end
hoot(self):set('destroy', 5)
```


When hit, toggle being flipped on our side. If flipped for 2 seconds, automatically jump back up
```lua
function Creep:hit()
  self.is_flipped = not self.is_flipped

  if self.is_flipped then
    hoot(self):set('hit', 2)
  else
    hoot(self):clear('hit')
  end

  -- Jump up
    self.vy = -200
    self.body:setLinearVelocity(self.vx, self.vy)
end
```
![](https://raw.github.com/farzher/hoot-lua/master/wakeup.gif)


Get stuck on walls for a bit, so we don't need frame perfect timing to wall jump away instead of fall off
```lua
if self.inputs.dir == self.x_normal then
  -- We're trying to leave; start timer to allow us to leave
    if hoot(self):get('stuck_on_wall') then hoot(self):set('stuck_on_wall', 1/6, {ifactive='nop'}) end
else
  -- Keep us stuck
    hoot(self):set('stuck_on_wall', -1)
end

if not hoot(self):get('stuck_on_wall') then
  -- TODO: Accept inputs to move off the wall
end
```
![](https://raw.github.com/farzher/hoot-lua/master/wallstick.gif)


##Full Documentation (it's not much)

###`hoot(self):set(f, delay, options)`

Set a new timer that will trigger after `delay` seconds.

`f` can be a `function` or `string` of a function name on `self`. If it exists it'll be called with `self` as the first argument when `delay` counts down to `0`.

You can also set `f` to a string that doesn't exist as a function, to use the timer as a boolean variable like in the wall jump example. `stuck_on_wall` isn't a function



###`hoot(self):get(key)`
Returns timer info if currently exists, else `nil`

Timer info looks like this `{delay=0.8, f='mycallback'}`. `delay` is the seconds left until it triggers


###`hoot(self):clear(key)`
Clear the timer. It'll never trigger

###`hoot(self):destroy()`
Cleanup all `hoot` memory associated with `self`

###`hoot.update(dt)`
Don't forget to put this in `love.update`. Otherwise nothing will happen!



##Other Tips
- `hoot` does not store anything on your table, it's left completely untouched.
- Each timer has a `key`, which is set to `f` if it's a string, or `options.key`

  If you call `set` and the `key` already exists, the default behavior is to clear the old timer and replace it.

  You can change this behavior by setting `options.ifactive="nop"` which will instead leave the old timer alone and not set the new one

  Or you can leave `key` empty, which will always stack more timers. `options.key=false` can be used to clear the key

- Setting a `delay` of `-1` will make the timer exist forever (`get` will return it), but it won't be active (`options.ifactive` won't trigger)
