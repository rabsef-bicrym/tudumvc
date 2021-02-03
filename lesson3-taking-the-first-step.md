# Ground Control to Major Tom - Hailing Mars from Earth

In this lesson, we're going to take our first steps towards developing an "Earth-facing" application.  Perhaps we want some way to take the data/applications of our urbit and make them available to Earth-going plebes or, perhaps we want to funnel some sweet resources away from Earth to support our Martian outpost.  In either event, by default, our urbit (and in fact all urbits, jointly) exist in an impenetrable bathysphere, isolating it from the troubles of the non-deterministic computers of Earth.  In order to establish external communications, we'll have to open our `airlock`.  We'll also investigate `JSON`-to-`hoon` type parsing and some of the elements of a `%gall` application, though further eludication of other elements of our `%gall` app will follow.

## For this lesson, you'll need:
1. The `airlock` demo files
2. Our `%firststep` files including:
    * `/app/firststep.hoon`
    * `/mar/firststep/action.hoon`
    * `/sur/firststep.hoon`
    
### Preparing for the lesson

**`airlock` demo files**

_insert airlock installation instructions using npm_

**`%firststep` `app` files**

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
   A `card` is defined in `lull.hoon` as a `(wind note gift)`.  A [`wind`](https://github.com/urbit/urbit/blob/master/pkg/arvo/sys/arvo.hoon#L122), like a `quip` is a wet gate that takes two molds and produces a structure that is tagged by a head atom (a tuple with either `%pass`, `%slip`, or `%give` as the head, which then further deliniates the tail structure - see the link to `arvo.hoon`).  Basically, `wind`s are used to communicate between vanes, including messages from `%gall` to `%gall` (between agents) and so on.  Vanes that need something from another vane request it by `%pass`ing a `note`.  The produced result is `%give`n as a `gift` back to the requester.  All of this to say that, simply, a `card` is a means of communicating with agents and vanes.  
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
`on-poke` is the most involved portion of our code.  Again, it returns a `(quip card _this)`, but in contrast to other arms we've seen, this arm takes both a `mark` and a `vase`.  The `mark` tells us which `mar` file to use in interpreting the `poke`.  The `mar` file, in turn, tells us how to convert any `poke` we get (in a potential variety of data types) into a `noun` (that will be the hoon-interpretable `vase`).  This handling format is useful for allowing us to poke our application from data external to Urbit (Earth data, like `JSON`), and we'll see how that works when we get to the `mar` file.

The rest of this arm's core is complicated and will take a little bit of explaining.  [`=^`](
