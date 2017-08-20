## [hoot.lua](https://raw.github.com/farzher/hoot-lua/master/hoot.lua) (Handleless Object Oriented Timer)
A smarter way to deal with timers. Intended for [LÖVE](https://love2d.org/)


## What? Why?

To cleanup this type of code
```lua
self.fire_cooldown = 0

function Player:update(dt)
  self.fire_cooldown = self.fire_cooldown - dt

  if fire_pressed and self.fire_cooldown <= 0 then
    self.fire_cooldown = 1
    self:fire()
  end
end
```

And replace it with this type of code
```lua
function Player:update()
  if fire_pressed and hoot(self):set('fire_cooldown', 1, {onlyif='notexists'}) then
    -- We were able to set a new cooldown timer!
    self:fire()
  end
end
```



## Installation - *Don't forget to call hoot.update(dt)*
```lua
hoot = require 'hoot'

function love.update(dt) hoot.update(dt) end
```


## Usage Examples


If the timer's key exists on the object as a function, it'll be called when the timer expires
```lua
function Bullet:destroy()
  -- TODO: Remove object from game
end
hoot(self):set('destroy', 5)
```


When hit, toggle being flipped on our side. If flipped for 2 seconds, automatically jump back up

![](https://raw.github.com/farzher/hoot-lua/master/wakeup.gif)
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


Get stuck on walls for a bit, so we don't need frame perfect timing to wall jump away instead of fall off

![](https://raw.github.com/farzher/hoot-lua/master/wallstick.gif)
```lua
if self.inputs.dir == self.x_normal then
  -- We're trying to leave; start timer to allow us to leave
    hoot(self):set('stuck_on_wall', 1/6, {onlyif='notactive'})
else
  -- Keep us stuck
    hoot(self):set('stuck_on_wall', -1)
end

if not hoot(self):get('stuck_on_wall') then
  -- TODO: Accept inputs to move off the wall
end
```


Double tap right to dash
```lua
if right_pressed then
  if not hoot(self):set('dash_right_timer', 1/10, {onlyif='notexists'}) then
    -- We were unable to set the dash_right_timer because it already existed!
    -- TODO: Dash to the right
  end
end
```


When hitting ceiling, get stuck on it for a bit instead of box2d making us instantly fall down

![](https://raw.github.com/farzher/hoot-lua/master/ceilingstick.gif)
```lua
if hit_ceiling then
  hoot(self):set(function() self.body:setGravityScale(1) end, -self.vy/1000)
  self.body:setGravityScale(0)
  self.vy = 0; self.body:setLinearVelocity(self.vx, self.vy)
end
```


## hoot vs [hump.timer](http://vrld.github.io/hump/# hump.timer)
hump is a great library, and hump.timer is a great timer, but hoot is smarter

Wakeup after 1 second **(hump.timer)**
```lua
self.is_down = false
self.wakeup_timer = nil
function Enemy:knockdown()
  -- We have to cancel the previous wakeup_timer
  -- Otherwise, if knockdown is called while already knocked down
  -- the old knockdown timer will trigger halfway through the new
  -- knockdown and wake it up!
    if self.wakeup_timer then Timer.cancel(self.wakeup_timer) end

  self.is_down = true
  self.wakeup_timer = Timer.add(1, function() self.is_down = false end)
end

function Enemy:update()
  if self.is_down then print('Im down!') end
end
```

Wakeup after 1 second **(hoot)**
```lua
function Enemy:knockdown()
  -- If a previous is_down timer is running, hoot knows about it and replaces it for us by default
    hoot(self):set('is_down', 1)
end

function Enemy:update()
  if hoot(self):get('is_down') then print('Im down!') end
end
```


## Full Documentation (it's not much)

### `hoot(self):set(f, delay, options)`

Set a new timer that will trigger after `delay` seconds.

`f` can be a `function` or `string` of a function name on `self`. If it exists it'll be called with `self` as the first argument when `delay` counts down to `0`.

You can also set `f` to a string that doesn't exist as a function, to use the timer as a boolean variable like in the wall jump example. `stuck_on_wall` isn't a function

`options.onlyif` only set the timer if it currently: `'exists'` `'notexists'` `'active'` `'notactive'`



### `hoot(self):get(key)`
Returns timer info if currently exists, else `nil`

Timer info looks like this `{delay=0.8, f='mycallback'}`. `delay` is the seconds left until it triggers


### `hoot(self):clear(key)`
Clear the timer. It'll never trigger

###### `hoot(self):destroy()`
Cleanup all `hoot` memory associated with `self`

### `hoot.update(dt)`
Don't forget to put this in `love.update`. Otherwise nothing will happen!

###### `hoot.set`
Shortcut for `hoot(hoot):set`

###### `hoot.get`
Shortcut for `hoot(hoot):get`

###### `hoot.clear`
Shortcut for `hoot(hoot):clear`

###### `hoot.new()`
If you can't get away with 1 global hoot object. Use new hoot instances in your gamestates `local hoot = hoot.new()`

###### `hoot.destroy()`
Destroy `hoot.new()` objects when they're no longer needed


## Other Tips
- `hoot` does not store anything on your table, it's left completely untouched.
- Each timer has a `key`, which is set to `f` if it's a string, or `options.key`

  If you call `set` and the `key` already exists, the default behavior is to clear the old timer and replace it.

  You can change this behavior by setting `options.onlyif="notexists"` which will instead leave the old timer alone and not set the new one

  Or you can leave `key` empty, which will always stack more timers. `options.key=false` can be used to clear the key

- Setting a `delay` of `-1` will make the timer exist forever (`get` will return it), but it won't be active (`options.onlyif='active'` won't trigger)
