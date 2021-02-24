# The `%gall` of that `agent`
We've figured out how to host Earth web apps from our Urbit and explored some of the limitations of that ability. We now need to prepare Urbit for interaction with that Earth web app. This lesson will focus on the development of a `%gall` `agent` to support `tudumvc`, the fully integrated version of TodoMVC on Urbit.

## Learning Checklist
* What is the basic structure of a `%gall` `agent`?
* How to add `state` to an `agent`.
* How to upgrade an `agent`'s `state`.
* What is `airlock` and how does it work, generally?
* How does incoming JSON look to our Urbit?
* What is `+dbug`?
* What is a `scry`?
* What does `=^` (tisket) do?

## Goals
* Install a `%gall` app.
* Examine the structure of `%gall` apps.
* Link our `%gall` app to an Earth web app.
* Print out, but do not yet interpret, JSON coming from our Earth web app.
* Upgrade the `state` of our `%gall` app.
* Upgrade the app's available `poke`s.
* Scry our `state`
* Use `+dbug` to examine our `tate`

## Prerequisites
* An empty Fake Ship (wipe out the one we made last lesson and start anew)
* The [Lesson 3 files](./src-lesson3) downloaded onto your VPS so that you can easily use them or sync them to your development environment.
  *  **NOTE:** The `/src-lesson3/react-hooks` folder packaged for this lesson has been pre-modified for this lesson. While we will go over these modifications and off-screen changes, you have been pre-warned that the default files will not work for this lesson.

## The Lesson
Start by syncing the files in the `/app`, `/mar` and `/sur` to your ship. We'll examine these files in detail below, but we need them there to start. Additionally, once they've sync'd and you've `|commit %home`-ed, use `|start %tudumvc` to start the app we've just added. You should see:
```
gall: loading %tudumvc
>   '%tudumvc app is online'
> |start %tudumvc
>=
activated app home/tudumvc
[unlinked from [p=~nus q=%tudumvc]]
```
You've just installed your first `%gall` app and it's working! Let's check out some of the features:
* It serves a placeholder site at (modify for your ship's URL) `http://localhost:8080/~tudumvc`.
* It has a state of just some `cord` (or a UTF-8 string), which you can view by `:tudumvc +dbug %state` in `dojo`.
* It has a `poke` `action` called `%add-task` that changes the `state`, which you can test by `:tudumvc &tudumvc-action [%add-task 'new task']`.

Over the course of this lesson, we'll see how this `%gall` app works, update the `state` to handle the type of data TodoMVC uses, add `poke` `action`s to mirror those events that TodoMVC can cause and, lastly, examine the JSON data TodoMVC can send us and begin learning about how we can parse that data on the Urbit side.  Let's start with what we know:

### `/sur/tudumvc.hoon`
In the last lesson, we learned that a `%gall` `agent`'s available `action`s are defined in the `/sur` file associated with that app. Taking a look at `/sur/tudumvc.hoon`, we can see one poke action called `%add-task` that takes a `cord` and gives that argument a `face` (variable name) of `task`:
```
+$  action
  $%
  [%add-task task=@tU]
  ==
```
To poke this app, again, we need to:
* Specify the `%gall` app:
    * `:todomvc`
* Specify the appropraite `/mar` file:
    * `&tudumvc-action` (which, incidentally, specifies `/mar/tudumvc/action.hoon`)
* Specify the appropriate `poke`, and include that `poke`'s arguments
    * `[%add-task 'an updated task']`

Let's take a look at the `/mar` file next to see how that works in conjunction with this poke:

### `/mar/tudumvc/action.hoon`
Our `mar` file does a few things of import:

It imports the `sur` file to make available the `mold` called `action` from that file:
```
/-  tudumvc
```

It imports and reveals `dejs:format` from [`zuse.hoon`](https://github.com/urbit/urbit/blob/a87562c7a546c2fdf4e5c7f2a0a4655fef991763/pkg/arvo/sys/zuse.hoon#L3317) which will help us "de-`JSON`ify" incoming `JSON` data:
```
=,  dejs:format
```

It creates a `door` that has an implicit `sample` of an `action` from `sur`: 
```
|_  act=action:firststep
```
Then, the `mar` file's `door` then has a `grab` arm which helps us shove incoming data into an acceptable type. Any general `noun` coming in (like, what we send through the `dojo`) will be cast as an `action` as defined in our `sur` file. An incoming JSON, however, will be parsed using the `gate` in the `++  json` `arm`. 
```
++  grab
  |%
  ++  noun  action:tudumvc
  ++  json
  |=  jon=^json
  ~&  "Your JSON object looks like {<jon>}"
  %-  action:tudumvc
  =<
  action
  |%
  ++  action
    [%add-task 'We did it, reddit!']
  --
```
We'll take a look at how that works (or should work) later, but right now all this is going to do on receiving JSON is print the JSON in Hoon form in our dojo and then change the state to `'We did it, reddit!'`.

Ok - how about the `/app` file?

### `/app/tudumvc.hoon`
While `%gall` applications can use files from across the filesystem of your urbit (some use `/lib` and `/gen` files, etc), the most basic pattern you'll see is an `/app`, a `/mar` and a `/sur` file.  We've already covered that the `/sur` file defines structures or types for our application and the `/mar` file defines methods for switching between various types of input our application might receive.

The `/app` file is the meat of the `%gall` `agent`, and it has a strict structure you'll see in almost all `%gall` apps:

#### They almost always start with importing some `/sur` (`/-`) and `/lib` (`/+`) files:
```
/-  tudumvc
/+  *server, default-agent, dbug
```
#### They then always define some `app` `state` (or several states, if the app has been upgraded - we'll do this later) in a `core`:
```
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  [%0 task=@tU]
    ==
+$  card  card:agent:gall
--
```
   * **NOTE:** In plainest English, `card`s are actions that we request of some `vane` - think of these as the bag at a Which 'Wich sandwich shop, where you pick your ingredients and give them to an employee who then executes the instructions.
   * **NOTE:** `versioned-state` is a type defined by a series of `tagged unions` where the `head` of a `cell` is a `tag` that identifies the type (sort of like a `poke`).  In our case, we only have one state (`state-zero`) that is tagged by its `head` `atom` of `%0`.  Other apps will have multiple states, almost always tagged with incrementing integers (e.g. `%0`, `%1`, and so on).
#### They will then always cast the result of the rest of the code as a `agent:gall`, which will always be either a `door` or a `door` and a helper `door` created using [`=<`](https://urbit.org/docs/reference/hoon-expressions/rune/tis/#tisgal) (compose two expressions, inverted - i.e. the main `core` of our `%gall` application will be up top, and the helper `core` underneath, but the helper core will be computed and stored in memory first such that it can be accessed and used by the main `core`). For reference, a `door` is just a `core` with an implicit sample, which, in this case, is always a `bowl:gall`.**
```
^-  agent:gall
|_  =bowl:gall
```
   * **NOTE:** an `agent:gall` is defined in [`lull.hoon`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1656) also and is, roughly, a `door` ([`form:agent:gall`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1684)) with 10 arms (which we will discuss later) with some other type definitions included (`step`, `card`, `note`, `task`, `gift`, `sign`).
   * **NOTE:** a [`bowl:gall`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1623) is just a series of things that will be available to _every_ `%gall` agent, including `our` (the host ship), `now` (the current time), `dap` (the name of our app, in term form - this will be used to start the app), and several other items.

#### They will often proceed with a series of aliases using [`+*`](https://urbit.org/docs/reference/hoon-expressions/rune/lus/#lustar):
```
+*  this  .
    def   ~(. (default-agent this %|) bowl)
 ```
   * **NOTE:** `this` refers to the whole, primary `door`, meaning that if we want to refer to our `app`'s main `door`, we can use use `this`.  The `def` shorthand just lets us refer to our `app` wrapped in the `default-agent` which basically just gives us the ability to create default behaviors for some of the `arm`s of our `door` that are not currently in use (see `++  on-arvo` in our code, for instance).

#### Internal to an agent's main `door`, there will _always_ be **10 `arm`s** (and never any more or less - although some arms may be defined as cores with sub-`arm`s to do additional work, and some may reach out to our helper `core`'s `arm`s to do additional work). The 10 `arm`s of `%gall` are exquisitely covered in [~timluc-miptev's Gall Guide](https://github.com/timlucmiptev/gall-guide/blob/master/arms.md), but we'll review a few of them below:
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

We're currently only using 5 out of the _10_ available `arm`s in `tudumvc`. Let's take a look at those:

##### `++  on-init`
```
^-  (quip card _this)
~&  >  '%tudumvc app is online'
=/  tudumvc-serve  [%file-server-action !>([%serve-dir /'~tudumvc' /app/tudumvc %.n %.n])]
=.  state  [%0 'example task']
:_  this
:~  [%pass /srv %agent [our.bowl %file-server] %poke todomvc-serve]
==
```
`on-init` is run _only once_, at first launch of the application (which we did when we ran `|start %tudumvc` in the dojo). `on-init` produces a `(quip card _this)`. In this case, we are producing a single `card`s and a mold of the type of our agent.

Our `card` here `%pass`es a `%poke` to the `file-server` app which strongly resembles the `poke` we made in `dojo` in the last lesson to serve files. The only real difference here is that (1) it's a `card` being passed instead of a direct `poke` and (2) we assigned part of the `poke` a face (`tudumvc-serve`) which is just a convention used to make the actual `card` less long:
```
=/  tudumvc-serve  [%file-server-action !>([%serve-dir /'~tudumvc' /app/tudumvc %.n %.n])]
<...>
:~  [%pass /srv %agent [our.bowl %file-server] %poke todomvc-serve]
==
```
Compare this to `:file-server &file-server-action [%serve-dir /'~tudumvc' /app/tudumvc %.n %.n]` which would have been the `dojo` `poke`.

We should also note that the line `=.  state  [%0 'example task']` sets the starting `state` of the app, on first load, to a cell of `[%0 task='example task']`.

Each `arm` of an agent that produces a `(quip card this)` (most of them) will return a list actions (`card`s) to perform/request, and a version of the agent, potentially with a changed `state`.  This is really useful for a deterministic computer.  We can use the arms of our `app`s to say "on this event, request these actions of other vanes (or other agents by requesting an action through `%gall`) and also update our state to indicate these changes.  Further, we can use the `++  on-arvo` arm to say "in the event of receiving these `card`s from other agents/vanes, take these actions and update the `state` in these ways.  It makes interaction really, really easy and unified throughout the `vane`/`agent` complex of our urbit!

##### `++  on-save`
```
^-  vase 
!>(state)
```
`on-save` is run every time the `app` shuts down or is upgraded.  It produces a [`vase`](https://urbit.org/docs/reference/library/4o/#vase) which is a noun wrapped in its type (as a cell).  For instance `[#t/@ud q=1]` would be the vase produced by `!>(1)`.  As implied, `!>` wraps a `noun` in its type; as an aside, you can use what's called a type spear to identify the type of some noun `-:!>(my-noun)` like that (it's called a type spear because it looks like a cute lil' spear).  In our express example, `on-save` produces the current `state` of the application wrapped in the type of the `state` (version).

##### `++  on-load`
```
|=  incoming-state=vase
^-  (quip card _this)
~&  >  '%tudumvc has recompiled'
`this(state !<(versioned-state incoming-state))
```
`on-load` is run on startup of our `app` (on re-load).  It, as with `on-init`, produces a `(quip card _this)` - a list of `card`s to be sent to the vanes of our urbit and an `app` in the structure of our current `app` (potentially with changed state).  This `on-load` section of our current app basically does nothing, but what we will see it do in the future is _upgrade the `state` between versions of the `app`'s development_; more on that later.

##### `++  on-poke`
```
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
  ?+  mark  (on-poke:def mark vase)
      %tudumvc-action  (poke-actions !<(action:tudumvc vase))
  ==
  [cards this]
  ::
  ++  poke-actions
    |=  =action:tudumvc
    ^-  (quip card _state)
    ?-  -.action
      %add-task
    `state(task task:action)
    ==
  --
```
`on-poke` is the most involved portion of our code. Again, it returns a `(quip card _this)`, but in contrast to `++  on-load`, this arm takes both a `mark` and a `vase`. The `mark` `vase` argument combo should be mildly familiar, as we've taken advantage of this already to poke our app. In the `dojo`, we communicate a poke using the following format: `:app-name &app-mark-file [%sur-action noun]` - in our case this will be `:tudumvc &tudumvc-action [%add-task 'new value']`. Our `cask` (`mark` `vase` combo), then, is `[%tudumvc-action [%add-task 'new value']]`.

The role of `=^` (tisket) is critical but also complicated. All you really need to know is that it is a terse way of producting `card` and `state` changes from non-in-line hoons (it uses other arms so the code doesn't get wide). If you want to know more about how `=^` works, you can check out this [breakout lesson](./lesson3-1-tisket.md).

##### `++  on-peek`
```
|=  =path
^-  (unit (unit cage))
?+  path  (on-peek:def path)
  [%x %task ~]  ``noun+!>(task)
==
```
`on-peek` is where `scry`ing is managed. All programs in Urbit can be treated as data, as can all, uh, data. The effect of this is that everything, including the internal state of a program or app, can be seen as part of the file system. `scry`ing is just the method of using the filesystem to tell us about the state of a program. And here, you must make a choice:
* Take the red pill and [learn how `scry`ing works](./lesson1-1-%25clay-breakout.md#scrying)
* Take the blue pill and only learn `+dbug`

Both of these functions allow us to see in to the `state` of our app. 
* `scry`ing relies on the `on-peek` functionality to tell it how to return data, and our specific scry can be completed in dojo like this - `.^(@tU %gx /=tudumvc=/task/noun)` (if you didn't read the breakout above, just try it and nod knowingly).
* `+dbug` relies on the use of 







These have been done off screen:
yarn add n
n stable
yarn add @urbit/http-api
yarn-install
modifications to JS files




## Homework

## Exercises

## Summary and Addenda