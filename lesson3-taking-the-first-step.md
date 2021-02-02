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
`on-init` is run _only once_, at first launch of the application (which we will do by running `|start %<app-name>` in the dojo).  In our case, `on-init` produces a `(quip card this)`.  A `quip` is 
