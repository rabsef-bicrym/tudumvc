# Ground Control to Major Tom - Hailing Mars from Earth

In this lesson, we're going to take our first steps towards developing an "Earth-facing" application.  Perhaps we want some way to take the data/applications of our urbit and make them available to Earth-going plebes or, perhaps we want to funnel some sweet resources away from Earth to support our Martian outpost.  In either event, by default, our urbit (and in fact all urbits, jointly) exist in an impenetrable bathysphere, isolating it from the troubles of the non-deterministic computers of Earth.  In order to establish external communications, we'll have to open our `airlock`.  We'll also investigate `JSON`-to-`hoon` type parsing and some of the elements of a `%gall` application, though further eludication of other elements of our `%gall` app will follow.

## For this lesson, you'll need:
1. The `airlock` demo files
2. Our `%firststep` files including:
    * [`/app/firststep.hoon`](/src/app/firststep.hoon)
    * [`/mar/firststep/action.hoon`](/src/mar/firststep/action.hoon)
    * [`/sur/firststep.hoon`](/src/sur/firststep.hoon)
    
### Preparing for the lesson

#### **`airlock` demo files**

_Preliminary instructions_
1. In some directory, do `git clone https://github.com/tylershuster/rab-test.git`
2. Modify `rab-test/src/index.ts` to have your fake ship's ship-name, url, code
3. In the `rab-test` directory, do `npm install`
4. In the `rab-test` directory still, do `npm start`


_insert airlock installation instructions using npm_

#### **`%firststep` `app` file**

Copy the files for `%firststep` into the appropriate folders in your development folder, turn on the syncing function and `|commit %home`.

While `%gall` applications can use files from across the filesystem of your urbit (some use `/lib` and `/gen` files, etc), the most basic pattern you'll see is an `/app`, a `/mar` and a `/sur` file.  The `/sur` file defines structures or types for our application, the `/mar` file defines methods for switching between various types of input our application might receive.

Take a look  at some of the other `%gall` `app`s found in your `/app` directory.  You should start to notice some patterns that coincide with our `app` file:

**They almost always start with importing some `/sur` (`/-`) and `/lib` (`/+`) files:**
```
/-  firststep
/+  *server, default-agent, dbug
```

**They then always define some `app` `state` (or several states, if the app has been upgraded - we'll do this later) in a `core`:**
```
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  [%0 message=cord]
    ==
::
+$  card  card:agent:gall
--
```
   * NOTE: a `card` is a `(wind note gift)` as defined in [`lull.hoon`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1660), where a [`wind`](https://urbit.org/docs/tutorials/hoon/hoon-school/behn/) is a `wet gate` (a type polymorphic gate) that accepts two [`mold`](https://urbit.org/docs/tutorials/hoon/hoon-school/molds/)s or type structuring cores ([idempotent](https://en.wikipedia.org/wiki/Idempotence) function that coerces a noun to be of a specific type).  [`wind`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/arvo.hoon#L122)s basically help us communicate across `vane`s, including `vane`-to-`vane` communication, and commonly come as either `%pass`es of `note`s (instructions to another `vane`) or `%give`ing of `gift`s (information produced as a result of some action to be given to some `vane`).  In plainest English, `card`s are actions that we request of some `vane` - think of these as the bag at a Which 'Wich sandwich shop, where you pick your ingredients and give them to an employee who then executes the instructions.
   * NOTE: `versioned-state` is a type defined by a series of `tagged unions` where the `head` of a `cell` is a `tag` that identifies the type.  In our case, we only have one state (`state-zero`) that is tagged by its `head` `atom` of `%0`.  Other apps will have multiple states, almost always tagged with incrementing integers (e.g. `%0`, `%1`, and so on).
   
**They will always bunt a `state` type (the most recent version) and then often alias that `state` type as just `state` for ease of use thereafter:**
```
=|  state-zero
=*  state  -
```

**They will then always cast the result of the rest of the code as a `agent:gall`, which will always be either a `door` or a `door` and a helper `door` created using `=<` (compose two expressions, inverted - i.e. the main `core` of our `%gall` application will be up top, and the helper `core` underneath, but the helper core will be computed and stored in memory first such that it can be accessed and used by the main `core`).  For reference, a `door` is just a `core` with an implicit sample, which, in this case is always a `bowl:gall`.**
```
^-  agent:gall
|_  =bowl:gall
```
   * NOTE: an `agent:gall` is defined in [`lull.hoon`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1656) also and is, roughly, a `door` ([`form:agent:gall`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1684)) with 10 arms (which we will discuss later) with some other type definitions included (`step`, `card`, `note`, `task`, `gift`, `sign`).
   * NOTE: a [`bowl:gall`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1623) is just a series of things that will be available to _every_ `%gall` agent, including `our` (the host ship), `now` (the current time), `dap` (the name of our app, in term form - this will be used to start the app), and several other items.
   
**They will often proceed with a series of aliases using `+*`:**
```
+*  this  .
    def   ~(. (default-agent this %|) bowl)
 ```
   * NOTE: `this` refers to the whole, primary `door`, meaning that if we want to refer to our `app`'s main `door`, we can use use `this`.  The `def` shorthand just lets us refer to our `app` wrapped in the `default-agent` which basically just gives us the ability to create default behaviors for some of the `arm`s of our `door` that are not currently in use (see `++  on-arvo` in our code, for instance).

**Internal to an agent's main `door`, there will _always_ be **10 `arm`s** (and never any more or less - although some arms may be defined as cores with sub-`arm`s to do additional work, and some may reach out to our helper `core`'s `arm`s to do additional work).  The 10 `arm`s of `%gall` are exquisitely covered in [~timluc-miptev's Gall Guide](https://github.com/timlucmiptev/gall-guide/blob/master/arms.md), but we'll review a few of them below:**
```
++  on-init
++  on-save
++  on-load
++  on-poke
++  on-arvo
++  on-watch
++  on-leave
++  on-peek
++  on-agent
++  on-fail
```

In the current application, we're only using 4 out of the _10_ available `arm`s.  Let's take a look at those:

**`++  on-init`**
```
^-  (quip card _this)
~&  >  '%firststep achieved'
=.  state  [%1 'starting' 0]
`this
```
`on-init` is run _only once_, at first launch of the application (which we will do by running `|start %<app-name>` in the dojo).  `on-init` produces a `(quip card _this)`.  A [`quip`](https://urbit.org/docs/reference/library/1c/#quip) is `mold` that takes two `mold`s as arguments and produces a tuple of a `list` of the first `mold` argument and the `mold` of the second argument.  In this case, we are producing a list of `card`s and a mold of the type of our agent (recall that `this` is defined in the alias section above as the whole core to which it refers - `+*  this  .`, and as a note `_noun` produces "the type of the noun", which is in our case `this`).
   **[`card`s](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1660)**
   A `card` is defined in `lull.hoon` as a `(wind note gift)`.  A [`wind`](https://github.com/urbit/urbit/blob/master/pkg/arvo/sys/arvo.hoon#L122), like a `quip` is a wet gate that takes two molds and produces a structure that is tagged by a `head` `atom` (a tuple with either `%pass`, `%slip`, or `%give` as the head, which then further deliniates the tail structure - see the link to `arvo.hoon`).  Basically, `wind`s are used to communicate between vanes, including messages from `%gall` to `%gall` (between agents) and so on.  Vanes that need something from another vane request it by `%pass`ing a `note`.  The produced result is `%give`n as a `gift` back to the requester.  All of this to say that, simply, a `card` is a means of communicating with agents and vanes.  
   **`this`**
   `this` is an alias to our agent's core, and will include the `bowl`, the `app` as structured, and the `state` as a type (meaning two `this`es could exist w/ different `state`s and still fit the mold of `this` - an **important detail**).

   Each `arm` of an agent that produces a `(quip card this)` will return a list of these types of actions to perform/request, and a version of the agent, potentially with a changed `state`.  This is really useful, as you might imagine, for a deterministic computer.  We can use the arms of our `app`s to say "on this event, request these actions of other vanes (or other agents by requesting an action through `%gall`) and also update our state to indicate these changes.  Further, we can use the `++  on-arvo` arm to say "in the event of receiving these `card`s from other agents/vanes, take these actions and update the `state` in these ways.  It makes interaction really really easy and unified throughout the vane/agent complex of our urbit!
 
 In our app, our `on-init` section:
 1. Casts our result as a `(quip card this)`
 2. Prints "%firststep achieved" in the dojo (using [`~&`](https://urbit.org/docs/reference/hoon-expressions/rune/sig/#sigpam))
 3. Sets the `state` (using [`=.`](https://urbit.org/docs/reference/hoon-expressions/rune/tis/#tisdot)) to `[%0 'starting']` which fits the type defined in `state-zero`
 4. Returns an empty `(list card)` and the `app` (using ``\this`` tets

**`++  on-save`**
```
^-  vase 
!>(state)
```
`on-save` is run every time the `app` shuts down or is upgraded.  It produces a [`vase`](https://urbit.org/docs/reference/library/4o/#vase) which is a noun wrapped in its type (as a cell).  For instance `[#t/@ud q=1]` would be the vase produced by `!>(1)`.  As implied, `!>` wraps a `noun` in its type; as an aside, you can use what's called a type spear to identify the type of some noun `-:!>(my-noun)` like that (it's called a type spear because it looks like a cute lil' spear).  In our express example, `on-save` produces the current `state` of the application wrapped in the type of the `state` (version).

**`++  on-load`**
```
|=  old-state=vase
^-  (quip card _this)
~&  >  '%firststep has recompiled'
`this(state !<(versioned-state old-state))
```
`on-load` is run on startup of our `app` (on re-load).  It, as with `on-init`, produces a `(quip card _this)` - a list of `card`s to be sent to the vanes of our urbit and an `app` in the structure of our current `app` (potentially with changed state).  This `on-load` section of our current app basically does nothing, but what we will see it do in the future is _upgrade the `state` between versions of the `app`'s development_; more on that later.

**`++  on-poke`**
```
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
  ?+  mark  (on-poke:def mark vase)
      %firststep-action  (poke-action !<(action:firststep vase))
  ==
  [cards this]
  ::
  ++  poke-action
    |=  =action:firststep
    ^-  (quip card _state)
    ?>  =(-.action %test-action)
      ~&  >  "Replacing state value {<message:state>} with {<+.action>}"
      `state(message +.action)
  --
```
`on-poke` is the most involved portion of our code.  Again, it returns a `(quip card _this)`, but in contrast to other arms we've seen, this arm takes both a `mark` and a `vase`.  This `mark` `vase` cell is also called a [`cage`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/arvo.hoon#L45) which is, itself, defined as a `(cask vase)`.  `cask` (defined one line below `cage`, linked above) is a `wet gate` that takes a vase and creates a `pair` of a `mark` and the argument it receives (in this case, a `vase`).  In the `dojo`, we communicate a poke using the following format: `:app-name &app-mark-file [%sur-action noun]` - in our case this will be `:firststep &firststep-action [%test-action 'new value']`.  Our `cask`, then, is `[%firststep-action [%test-action 'new value']]`.

The `mark` tells us which `mar` file to use in interpreting the `poke`.  `mar` files will always have (some of) three `arm`s, `++  grab`, `++  grow` and `++  grad`.  Focuing on  `++  grab`, we use this `arm` to convert some _other_ `mark` to the `mark` of the file we're in.  For instance, the `++  grab` `arm` of `/mar/txt.hoon` has a sub-`arm` called `++  noun` that uses `wain` (a `(list cord)`) to convert an incoming `noun` into a `%txt` filetype which is, see [line 10](https://github.com/urbit/urbit/blob/a87562c7a546c2fdf4e5c7f2a0a4655fef991763/pkg/arvo/mar/txt.hoon#L10), a `wain`.

Our `mar` file, as we will see later, is used to convert the data from an Earth `poke` (aka `JSON` data) into valid hoon types (for just the value) when `poke`d from Earth.
      * NOTE: The entire `poke` coming from Earth will be in `JSON` but will be converted using `poke-as` (which is out of scope for this lesson) in [`%eyre`](https://github.com/urbit/urbit/blob/a87562c7a546c2fdf4e5c7f2a0a4655fef991763/pkg/arvo/sys/vane/eyre.hoon#L1358) to our expected `mark` for our `app` but, nonetheless, our `action.hoon` file (`/mar/firststep/action/hoon`) has to convert the values in the `vase` to the expected type for our `app` to handle (in this case, simply updating the `cord` part of our `state`, called `message`, of our app, but other more complicated `poke`s can and do exist).
      
The rest of this arm's core is complicated and will take a little bit of explaining.  [`=^`](https://urbit.org/docs/reference/hoon-expressions/rune/tis/#tisket) performs a very important role that is documented well, again, in [~timluc-miptev's Gall Guide](https://github.com/timlucmiptev/gall-guide/blob/master/poke.md#the--idiom).  Basically, what it does is it creates a new `face` (here, `cards`) that can take some value, a `wing` of the subject (here, `state`) that has some value (which will be replaced), then some hoon (which will create a `cell` of two values - we'll call this the 'producing hoon'), then some more hoon (the 'recipient hoon').  The 'producing hoon' produces a `cell` of two values.  The two values map onto the new `face` (the `head` to `cards`) and the `wing` (the `tail` to `state`).  If our producing hoon is written correctly, it will produce a `(quip card _state)` which maps perfectly onto `cards` `state`.  Our receiving hoon then does some action based on these changes (in this case, produces a `(quip card _this)` from `[cards this]` where `this` in the `tail` there has been updated with the new `state`).  It's really just a terse way of producing the `card`s and `state` changes we want and then returning them to the `app`!

Focusing even further on:
```
=^  cards  state
?+  mark  (on-poke:def mark vase)
    %firststep-action  (poke-action !<(action:firststep vase))
==
[cards this]
```
We see that we test the `mark` coming in using [`?+`](https://urbit.org/docs/reference/hoon-expressions/rune/wut/#wutlus) to do something like a case-when statement with a default (NOTE: this default uses `default-agent` which we've aliased above as `def`).  We only have _one_ case in our initial example here - so, solong as the mark is `&firststep-action`, we will call `(poke-action !<(action:firststep vase))` (NOTE: [`!<`](https://urbit.org/docs/reference/hoon-expressions/rune/zap/#zapgal) automatically checks to ensure that our vase matches our mold of the `action` defined in our `sur` file).  `poke-action` must, with our argument, necessarily return a `(quip card _state)`, or a list of `card`s and a version of our `state` (potentially with updated values).

To finish examining this section, we should look at `poke-action`:
```
++  poke-action
  |=  =action:firststep
  ^-  (quip card _state)
  ?>  =(-.action %test-action)
    ~&  >  "Replacing state value {<message:state>} with {<+.action>}"
    `state(message +.action)
--
```
We know that `poke-action` will receive an `action:firststep` as defined in our `sur` file, because we've dynamically type checked it above (`(poke-action !<(action:firststep vase))`).  From there, we simply _assert_ using [`?>`](https://urbit.org/docs/reference/hoon-expressions/rune/wut/#wutgar) that the `head` of our `action` (or `vase`) will be `%test-action` (our only `poke` `action` available in our `sur` file).  That being true, we `~&` a message for the user in `dojo` that indicates what we're doing (replacing `message:state` with the `tail` of our incoming `vase`, e.g. the new message), then we do it (`` `state(message +.action)`` is the equivalent of `:-(~  %=(state message +.action))` which just means "return an (empty) list of `card`s and the `state` with the `message` face of the `state` replaced with whatever the `tail` of our `action` or `vase` is).

If you haven't followed any of the above, once you've `|commit %home`ed, just do `:firststep &firststep-action [%test-action 'New Message']` in the `dojo` and see what happens.  After that, do `:firststep +dbug %state` and take a look at your state.  Basically all the above was to explain that we have the capacity to change that `state` element.  In either case (understanding or absolute flummoxed-ness), let's take a look at our `mar` and `sur` files, next.

#### **`%firststep` `mar` file**
Our `mar` file does a few things of import:

It imports the `sur` file to make available the `mold` called `action` from that file:
```
/-  firststep
```

It imports and reveals `dejs:format` from [`zuse.hoon`](https://github.com/urbit/urbit/blob/a87562c7a546c2fdf4e5c7f2a0a4655fef991763/pkg/arvo/sys/zuse.hoon#L3317) which will help us "de-`JSON`ify" incoming `JSON` data:
```
=,  dejs:format
```

It creates a `door` that has an implicit `sample` of an `action` from `sur` and then 
```
|_  act=action:firststep
++  grab
  |%
  ++  noun  action:firststep
  ++  json
    |=  jon=^json
    ;;  action:firststep
    ~&  >  (so jon)
    [%test-action (so jon)]
  --
--
```
Our `mar` file's door then has a `grab` arm which helps us shove incoming data into an acceptable type.  Any general `noun` coming in will be cast as an `action` as defined in our `sur` file.  A `JSON` incoming will be parsed using the `gate` under that sub-`arm`.  Let's take a closer look at that gate:
```
|=  jon=^json
;;  action:firststep
~&  >  (so jon)
[%test-action (so jon)]
```
The gate takes a `JSON` (the type, not the `arm`, which is why we use `^` to skip the first closest reference, the `arm`).  It normalizes its output to a mold using [`;;`](https://urbit.org/docs/reference/hoon-expressions/rune/mic/#micmic).  It `dojo` prints the `dejs`ified version (`~&  >  (so jon)`) and then it produces the cell `[%test-action (so jon)]`.  [`so`](https://github.com/urbit/urbit/blob/a87562c7a546c2fdf4e5c7f2a0a4655fef991763/pkg/arvo/sys/zuse.hoon#L3472) is a gate that takes a json and then checks to confirm it's of the `%s` variety (a string); if it is, it produces the string.  This is a very simple `JSON` conversion and we'll look at more complex ones in a coming lesson, but this should be good for us, for now.


#### **`%firststep` `sur` file**
We're on the home stretch here - stick with me.  Our `sur` file defines types for our `app`:
```
|%
::  Available poke actions follow
::
+$  action
  $%
  ::  This is just a test action to show the functionality.
  ::  It lets us change the message stored in our app's state, by providing a new message (msg).
  ::
  [%test-action msg=cord]
  ==
--
```
Very simply, the above uses `+$` to define a type called `action` which is then a union of types, differentiated by their `head` `atom` `tag`.  In this case, the only `tag` is `%test-action` which takes a `cord` called msg.

Working backwards now, we can say that, receiving either a `dojo` induced noun or an Earth induced `JSON`, our `mar` file will make sure that we receive an interpretable `poke`, as defined by our `sur` file, and, lastly, our `app` file will take that poke and update our `state` to reflect the change in the `message` face of the `state` based on the `cord` received in our `poke`.

### Try it using both the web and the `dojo` interface:

#### Web Interface Instructions
Reload the page that was launched when you set up the demonstrative airlock implementation
You should see:
```
< ~nus: opening airlock
>   'test'
>   "Replacing state value 'starting' with msg='test'"
eyre: canceling ~[//http-server/0v6.8ehbm/28/3]
~nus:dojo>
```
   
#### `dojo` Interface Instructions
Simply enter `:firststep &firststep-action [%test-action 'my cord here']`

You should see:
```
>   "Replacing state value 'test' with msg='test'"
> :firststep &firststep-action [%test-action 'test']
>=
~nus:dojo> 
```
