# The gall of that agent
We've figured out how to host Earth web apps from our Urbit and explored some of the limitations of that ability. We now need to prepare Urbit for interaction with that Earth web app. This lesson will focus on the development of a gall agent to support `tudumvc`, the fully integrated version of TodoMVC on Urbit.

## Learning Checklist
* What is the basic structure of a gall agent?
* How to add state to an agent.
* What is `+dbug`?
* What is a `scry`?
* What does `=^` (tisket) do?
* What is `airlock` and how does it work, generally?
* How does incoming JSON look to our Urbit?

## Goals
* Install a gall app.
* Examine the structure of gall apps.
* Scry our state
* Use `+dbug` to examine our state
* Link our Earth web app with our urbit.
* Print out, but do not yet interpret, JSON coming from our Earth web app.

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
You've just installed your first gall app and it's working! Let's check out some of the features:
* It serves a placeholder site at (modify for your ship's URL) `http://localhost:8080/~tudumvc`.
* It has a state of just some `cord` (or a UTF-8 string), which you can view by `:tudumvc +dbug %state` in dojo.
* It has a poke `action` called `%add-task` that changes the state, which you can test by `:tudumvc &tudumvc-action [%add-task 'new task']`.

Over the course of this lesson, we'll see how this gall app works, update the state to handle the type of data TodoMVC uses, add poke `action`s to mirror those events that TodoMVC can cause and, lastly, examine the JSON data TodoMVC can send us and begin learning about how we can parse that data on the Urbit side.  Let's start with what we know:

### `/sur/tudumvc.hoon`
In the last lesson, we learned that a gall agent's available `action`s are defined in the `/sur` file associated with that app. Taking a look at `/sur/tudumvc.hoon`, we can see one poke action called `%add-task` that takes a `cord` and gives that argument a `face` (variable name) of `task`:
```
+$  action
  $%
    [%add-task task=@tU]
  ==
```
To poke this app, again, we need to:
* Specify the agent:
    * `:tudumvc`
* Specify the appropriate mark:
    * `&tudumvc-action` (which, incidentally [JAL: is it incidental? or is that how it works], specifies `/mar/tudumvc/action.hoon`)
* Specify the appropriate poke, and include that poke's arguments
    * `[%add-task 'an updated task']`

Let's take a look at the `/mar` file next to see how that works in conjunction with this poke:

### `/mar/tudumvc/action.hoon`
Our `mar` file does a few things that we care about:

It imports the `sur` file to make available the `mold` called `action` from that file:
```
/-  tudumvc
```

It imports and reveals `dejs:format` from [`zuse.hoon`](https://github.com/urbit/urbit/blob/a87562c7a546c2fdf4e5c7f2a0a4655fef991763/pkg/arvo/sys/zuse.hoon#L3317) which will allow us to parse incoming JSON data:
```
=,  dejs:format
```

It creates a [*door*](TODO:) that has an implicit [*sample*](TODO) (the input operated upon) of an `action` from `sur`: 
```
|_  act=action:firststep
```
Then, the `mar` file's `door` defines a `grab` arm which helps us cast incoming data into an acceptable type. Any general noun coming in (e.g., what we send through the dojo) will be cast as an `action` as defined in our `sur` file. Incoming JSON, however, will be parsed using the [*gate*](TODO) (like a function) in the `++  json` arm. 
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
  --
```
We'll take a look at how that works (or should work) later, but right now all this is going to do upon receiving JSON is print the JSON in Hoon form in our dojo and then change the state to `'We did it, reddit!'`.

Ok - how about the `/app` file?

### `/app/tudumvc.hoon`
While gall applications can use files from across the filesystem of your urbit (some use `/lib` and `/gen` files, etc), the most basic pattern you'll see is an `/app`, a `/mar` and a `/sur` file.  We've already covered that the `/sur` file defines structures or types for our application and the `/mar` file defines methods for switching between various types of input our application might receive.

The `/app` file is where the meat of the gall agent is, and it has a strict structure you'll see in almost all gall agents:

#### Imports

Agents usually start by importing some `/sur` (`/-`) and `/lib` (`/+`) files:

```
/-  tudumvc
/+  *server, default-agent, dbug
```

#### Agent State

Then they define some state (or several states, if the app has been upgraded - we'll do this later) in a core:

```
|%
+$  state-zero
    $:  [%0 task=@tU]
    ==
+$  versioned-state
    $%  state-zero
    ==
+$  card  card:agent:gall
--
```

JAL(2021.3.4) Why not define `state-zero` as:
```
+$  state-zero  [%0 task=@tU]
```

Remember, a *card* is a data structure for passing information between vanes and agents.

`versioned-state` is a type defined by a series of `tagged unions` where the `head` of a `cell` is a `tag` that identifies the type (sort of like a poke).  In our case, we only have one state (`state-zero`) that is tagged by its `head` `atom` of `%0`.  Other apps will have multiple states, almost always tagged with incrementing integers (e.g. `%0`, `%1`, and so on).

#### They will then always cast the result of the rest of the code as a `agent:gall`, which will always be either a `door` or a `door` and a helper `door` created using [`=<`](https://urbit.org/docs/reference/hoon-expressions/rune/tis/#tisgal) (compose two expressions, inverted - i.e. the main `core` of our gall application will be up top, and the helper `core` underneath, but the helper core will be computed and stored in memory first such that it can be accessed and used by the main `core`). For reference, a `door` is just a `core` with an implicit sample, which, in this case, is always a `bowl:gall`.**

JAL(2021.3.4) This header is way too long. Let's summarize with the header and provide context with body copy.

```
^-  agent:gall
|_  =bowl:gall
```

An `agent:gall` is defined in [`lull.hoon`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1656) also and is, roughly, a `door` ([`form:agent:gall`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1684)) with 10 arms (which we will discuss later) with some other type definitions included (`step`, `card`, `note`, `task`, `gift`, `sign`).

A [`bowl:gall`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1623) is just a bundle of things that will be available to _every_ gall agent, including `our` (the host ship), `now` (the current time), `dap` (the name of our app, in term form - this will be used to start the app), and several other items.

#### Aliases

They will often proceed with a series of aliases using [`+*`](https://urbit.org/docs/reference/hoon-expressions/rune/lus/#lustar):
```
+*  this  .
    def   ~(. (default-agent this %|) bowl)
 ```

`this` is the alias we give to the whole, primary `door`, meaning that if we want to refer to our `app`'s main `door`, we can use use `this`. [JAL: this doesn't really clarify anything for me. why would I want to do this? the paragraph below does a better job of providing this kind of answer.]

The `def` alias, shorthand for *default*, lets us refer to our `app` wrapped in the `default-agent` which gives us the ability to create default behaviors for some of the `arm`s of our `door` that are not currently in use (see `++  on-arvo` in our code, for instance).

#### Interface

All gall agents are _always_ defined as a door with **10 arms**, as defined by the [agent interface](TODO). That said, it's common to abstract logic into other *helper cores*. We'll explore this pattern later. 

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

We're currently only using 5 out of the 10 available arms in `tudumvc`. Let's take a look at what they're doing:

##### `++  on-init`

`on-init` is run _only once_, at first launch of the application (which we did
when we ran `|start %tudumvc` in the dojo). `on-init` produces (`^-`) a `(quip
card _this)`. In this case, we are producing a single `card`s and a mold of the
type of our agent.

```
++  on-init
  ^-  (quip card _this)
  ~&  >  '%tudumvc app is online'
  =/  serve  [%file-server-action !>([%serve-dir /'~tudumvc' /app/tudumvc %.n %.n])]
  =.  state  [%0 'example task']
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke serve]
  ==
```

Our `card` here `%pass`es a `%poke` to the `file-server` app (which should
resemble the poke we made in dojo in the last lesson) to serve files. The
only real difference here is that (1) it's a `card` being passed instead of a
direct poke and (2) we assigned part of the poke the [*face*](TODO) (kind of
like a variable name) `serve` which is just a way of making the actual `card`
less long:

```
=/  serve  [%file-server-action !>([%serve-dir /'~tudumvc' /app/tudumvc %.n %.n])]
<...>
:~  [%pass /srv %agent [our.bowl %file-server] %poke serve]
==
```

Compare this to `:file-server &file-server-action [%serve-dir /'~tudumvc'
/app/tudumvc %.n %.n]` which would have been the dojo poke.

We should also note that the line `=. state [%0 'example task']` sets the
starting state of the app, on first load, to a cell of `[%0 task='example
task']`.

Most arms of an agent produce a `(quip card this)`, which can be read as "a list
of cards and a new agent," where the "new agent" is the current agent with a
potentially modified state. Remember: each `card` is data that represents an
instruction to another part of the system (agent/vane). That means that for an
agent to *produce effects*, like change its state or interact with the rest of
the system, it produces *data*. This is the "deterministic computer" in action.

##### `++  on-save`

`on-save` is run every time the agent shuts down or is upgraded. It produces a
[*vase*](https://urbit.org/docs/reference/library/4o/#vase) which is a noun
wrapped in its type (as a cell). For instance `[#t/@ud q=1]` would be the vase
produced by `!>(1)`. The head, `#t/@ud`, is the type (unsigned decimal), and the tail, `q=1`, is the noun.

As an aside, you can use what's called a *type spear* to identify the type of
some noun: `-:!>(my-noun)` (it's called a type spear because it looks like a
spear). In our example, `on-save` produces the current state of the application
wrapped in the type of the state (version).

```
++  on-save
  ^-  vase 
  !>(state)
```

JAL(2021.3.4): What does our `+on-save` arm do precisely? I think nothing, but
we should explain that.

##### `++  on-load`

`on-load` is run on startup of our agent (on re-load). As with `on-init`, this
arm produces a `(quip card _this)` - a list of `card`s to be sent to the vanes
of our urbit and a new version of our agent. 

```
++  on-load
  |=  incoming-state=vase
  ^-  (quip card _this)
  ~&  >  '%tudumvc has recompiled'
  `this(state !<(versioned-state incoming-state))
```

Our `+on-load` arm does essentially nothing, but later we'll see how it can be
used to allow our agent to upgrade its state to a new version.

##### `++  on-poke`

Like other arms, `+on-poke` returns a `(quip card _this)`, but in contrast to
`+on-load`, this arm takes both a `mark` and a `vase`. The `mark` `vase`
argument combo, called a [*cask*](TODO), should be mildly familiar, as we've
taken advantage of this already to poke our app. 

In the dojo, we communicate a poke using the following format: 

```
:agent-name &agent-mark [%sur-action noun]
```

In our case this will be `:tudumvc &tudumvc-action [%add-task 'new value']`. Our
`cask`, then, is `[%tudumvc-action [%add-task 'new value']]`.

```
++  on-poke
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

`on-poke` is the most involved portion of our code. [JAL(2021.3.4): Please
fact-check me here Eric] It utilizes a helper core, created with [`|^`
(barket)](TODO), to define the `+poke-actions` arm for applying the appropriate
state updates depending on which action is encountered.

The role of [`=^` (tisket)](TODO:) is critical, but also complicated. All you
really need to know is that it is a terse way of producing `card` and state
changes from non-inline hoons (it uses other arms so the code doesn't get too
"wide", a hoon antipattern). If you want to know more about how `=^` works, you
can check out this [breakout lesson](./lesson3-1-tisket.md).

##### `++  on-peek`

`+on-peek` is the arm used for handling reads, which are called *scries* (or
*scry* in the singular case).

All programs in Urbit can be treated as data, as can all, uh, data. The effect
of this is that everything, including the internal state of a program or agent,
can be seen as part of the filesystem. scrying, then, allows us to read the
state of our program from a path, as if we were looking up a file on the
filesystem.

Now, you can:

* Take the red pill and [learn how to `scry`](./lesson1-1-%25clay-breakout.md#scrying)
* Take the blue pill and skip to seeing it in action.

```
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  (on-peek:def path)
    [%x %task ~]  ``noun+!>(task)
  ==
```

`+on-peek` is responsible for exposing paths that can be scried from. To try it
out, enter the following into the dojo, one at a time:

```
:: read the current state
.^(@tU %gx /=tudumvc=/task/noun)
:: update the state
:tudumvc &tudumvc-action [%add-task 'newer task']
:: read it again
.^(@tU %gx /=tudumvc=/task/noun)

```

This should make sense if you read the breakout above, otherwise just nod
knowingly.

This isn't the only way to read the state of our agent. You can also make use of
`+dbug`. `+dbug` relies on the use of the `dbug` library that is imported at the
beginning of the `/app/tudumvc.hoon` file (`/+ *server, default-agent, dbug`),
and can be completed in dojo like this - `:tudumvc +dbug %state`.

That's about it then for the `/app`, `/mar`, and `/sur` files, and the `tudumvc`
app generally, at least for this lesson. Let's finish with a discussion of the
changes made to the TodoMVC Earth web app.

### TodoMVC Earth App

There's a modified copy of the TodoMVC for you in the [`src-lesson3`
folder](./src-lesson3/react-hooks). We're not quite ready to minify this file,
as we still have more work to do, which is why we have a placeholder
`index.html` file in the `/app/tudumvc` folder. Nonetheless, remember that we
can run the non-minified version using `yarn run dev`.

This version of the TodoMVC app has been updated to communicate with your Urbit.
You may need to do some additional customization, but we'll point this out to
you when we get there.

#### Preliminary Setup

The following steps were taken to prepare the base `react-hooks` project for
Urbit integration:

* Upgrade node.js
    * `yarn add n`
    * `n stable`
* Add the Urbit API package
    * `yarn add @urbit/http-api`

From the `src-lesson3/react-hooks` directory, you'll want to start by running
`yarn install`.

#### Airlock

A library for communicating with Urbit's HTTP server, `eyre`, already exists on
`npm`. We tend to refer to libraries that bridge the gap from Urbit to other
languages, like JavaScript, as *airlock* libraries. You can see a full list of
them [here](https://github.com/urbit/awesome-urbit#http-apis-airlock).

The methods we need from this library are `authenticate`, `poke` and
`subscribe`.

* `authenticate` uses the same login functionality as we've seen with Landscape
  (`+code`).
* `poke` sends a poke in JSON to a specified app, of a specified `mark` and
  `vase`.
* `subscribe` opens up a path over which our Urbit and the browser can
  communicate.

#### Setup

In `hooks/useApi.js` we're basically just grabbing an API token using
`authenticate` and exporting the resulting token (`urb`) that will inform our
use of the other two methods, later.

JAL(2021.3.4): On my box, ~nus starts up on port 80, not 8080, meaning that the
below `url` needs to be different. If the reader isn't using `~nus`, they'll
need a different code and ship defined here as well. It's probably important to
call this out to account for varying setups.

```
import Urbit from "@urbit/http-api";
import { memoize } from 'lodash';

const useApi = memoize(async () => {
    const urb = await Urbit.authenticate({ ship: 'nus', url: 'localhost:8080', code: 'bortem-pinwyl-macnyx-topdeg', verbose: true});
    return urb;
});

export default useApi;

```

#### Initialize the API

In `index.js`, we import `useApi` and pass the `api` to `App.js`.

```
// We're adding airlock's useApi functionality here:
import useApi from "./hooks/useApi";

const root = document.getElementById("root");

(async () => {
    const api = await useApi();
    ReactDOM.render(<App api={api} />, root);
})();
```

We need to make our render asynchronous so that we await the completion of the
promise generated by `useApi`. This ensures that our app is authenticated with
our Urbit.

#### Propagate the API

In `App.js`, we modify the default function to accept the `props` passed by
`index.js`. We unpack the `props` into the `{api}` object and return
`TodoList.js` as a function of having passed `props` to it. This, again, passes
those ever-so-useful `poke` and `subscribe` methods over to our basic container.
And remember, it's already authenticated as a result of making `index.js`
asynchronous.

```
export default function App(props) {
  const {api} = props;
  return (
    <HashRouter>
      <React.Fragment>
        <div className="todoapp">
        <Route key="my-route" path="/:filter?" render={(props) => {
            return <TodoList api={api} {...props} />
        ...
```

#### Handling Pokes

Here's where we're doing some real work. `TodoList.js` is now modified to take
the `props` passed to it, and `urb` is defined as the `api` attribute of
`props`. We can then create a function called `poker` that forms a poke that
should be familiar to us. 

```
export default function TodoList(props) {
  const router = useRouter();

  const [todos, { addTodo, deleteTodo, setDone }] = useTodos();

  const urb = props.api;

  const poker = () => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'add-task': 'from Earth to Mars'}});
  };

<... following line is line 121>
          <li>
            <button className="clear-completed" onClick={poker}>
              Test Button
            </button>
          </li>
```

The function `poker`, seen here:

```
  const poker = () => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'add-task': 'from Earth to Mars'}});
  };
```

Should remind us of the dojo poke we've used earlier (`:tudumvc &tudumvc-action
[%add-task 'from Earth to Mars']`, or similar). And that's because it is - the
only difference here is that our vase (the `action` or `[%add-task 'task']`
part) is a JSON object now.

We've also added a button on the taskbar of the app that allows us to trigger
the `poker` function.

Go ahead and start the modified web app using `yarn run dev`. Open the console
once it's loaded in the browser. You're almost certainly seeing the following
error:

```
Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource at http://localhost:8080/~/channel/1614149322-3066e9. (Reason: CORS header ‘Access-Control-Allow-Origin’ missing).
```

#### CORS

Whoops, we've got [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
issues. Fortunately Urbit has tooling for handling this. 

In your dojo, punch in `+cors-registry`. You'll see something like this:

JAL(2021.3.4): NOTE: For there to be a request you'll have to ensure that you've
logged into Landscape first.

```
> +cors-registry
[ requests={~~http~3a.~2f.~2f.localhost~3a.8080}
  approved={}
  rejected={}
]
```

You're going to have to approve the CORS registration for your Earth app. You
can do this with `|cors-approve ~~http~3a.~2f.~2f.localhost~3a.8080` (replace
the address with what ever request you see in your dojo on the prior step).
Refresh the page.

Now you'll see some new messages in the console, importantly:

```
Received authentication response 
Response { type: "cors", url: "http://localhost:8080/~/login", redirected: false, status: 204, ok: true, statusText: "ok", headers: Headers, body: ReadableStream, bodyUsed: false }
index.js:165
```

You'll also see `< ~nus: opening airlock` in the dojo.

We're logged in - our web app is connected to our urbit. Push the "Test Button"
and let's take a look at what can be sent from Earth to Mars.

#### The JSON poke

```
"Your JSON object looks like [%o p=\{[p='add-task' q=[%s p='from Earth to Mars']]}]"
```

This printout highlights the JSON that we received from our "Test Button". If we
check the state now (using `scry`ing or `+dbug`, like `:tudumvc +dbug %state`),
we'll see that our `task` is now `[%0 task='We did it, reddit!']`.

JAL(2021.3.4): It seems weird that we sent `'from Earth to Mars'` but the state
changed to `We did it, reddit!`. We should probably call out this weirdness
explicitly.

In the next lesson, we'll finish the conversion of TodoMVC into `tudumvc` and
take a look at how we can start interpreting JSON into pokes our urbit can
actually understand. We'll also update our agent's state and range of pokes. For
now, we've done good work and it's time for some rest (for me at least, you have
homework to do).

## Homework

* Read this [`airlock` reference doc](https://urbit.org/docs/reference/vane-apis/airlock/).
* Check out the state of `picky` defined [here](https://github.com/timlucmiptev/gall-guide/blob/c95140b2c3c62e45c346a25efe027d55dfdd5bd6/example-code/app/picky-backend.hoon#L7), as well as the [`on-load`](https://github.com/timlucmiptev/gall-guide/blob/master/example-code/app/picky-backend.hoon#L40) arm.

## Exercises

* Attempt to upgrade our gall agent's state to a `(map id=@ud [label=@tU
  done=?])`.
    * You'll need to change (1) the state definition, (2) `on-init`, (3)
      `on-load`
* Attempt to add a different poke `action` to our gall app that modifies the
  state (either the existing state or the one you produced in the above
  exercise, if you were successful).

**NOTE:** Do not worry about failing at either of these exercises - we will go
through these activities in the next lesson, but it would be good for you to
try, first. You can even cheat and look at [`src-lesson4`](./src-lesson4)'s
code - so long as you can comment it [JAL: huh?] and explain what it does as you
do the upgrade.

## Summary and Addenda

And that does it for Lesson 3. We're almost done with basic integration and,
hopefully, you've found the experience so far relatively painless. You might
want to take the time now to review `=^` and how it works, in our breakout
lesson [JAL: should you review both breakouts?]:

* [`=^`](./lesson3-1-tisket.md)

That's generally optional, though if you go on to develop your own apps, you'll
probably want a firmer understanding. Nonetheless, at this point you should:

* Know the basic, 10 arm structure of a gall agent.
* Know where state is defined in an agent.
* Be able to query the current state of an agent, either through `+dbug` or a
  `scry`.
* Generally describe the use of `=^`.
* Know what `airlock` is a bit about how to use it.
* Know what JSON looks like when displayed in Urbit.

<hr>
<table>
<tr>
<td>

[< Lesson 2 - TodoMVC on Urbit (sort of)](./lesson2-todomvc-on-urbit-sortof.md)
</td>
<td>

[Lesson 4 - Updating Our Agent >](./lesson4-updating-our-agent.md)
</td>
</tr>
</table>
