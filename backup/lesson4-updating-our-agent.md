# Updating Our Agent
At this point, you should have a `%gall` `agent` that can:
* Host a default Earth web page
* Contain a limited data structure
* Print out incoming JSON
You also have a version of TodoMVC that can:
* Authenticate with your Fake Ship
* `poke` your `%gall` `agent` using a new button

In this lesson we're going to work on integrating all of the existing functionality of TodoMVC into our %gall agent and prepare for our next lesson, wherein we'll update TodoMVC to talk to our %gall agent. Let's get started!

## Learning Checklist
* How to upgrade the `state` database of our `%gall` `agent`.
* How to add new `poke` `action`s.

## Goals
* Investigate the expected state of "todos" in our Earth app.
* Upgrade our `%gall` `agent` `state` to accommodate the Earth app state.
* Upgrade our `%gall` `agent` `action`s to accommodate all possible Earth app actions.

## Prerequisites
* A Fake Ship as prepared in [Lesson 3 - The `%gall` of that `agent`](./lesson3-the-gall-of-that-agent.md).
* **NOTE:** We've included a copy of all the files you need for this lesson _in their completed form_ in the folder [src-lesson4](./src-lesson4), but you should try doing this on your own instead of just copying our files in. No cheating!

## The Lesson
Let's start off the lesson by taking a look at how the data in TodoMVC is being stored. First, launch your Urbit (recall that we made the app dependent on our ship being online due to the asynchronous call to authenticate with our ship), then open the app (`yarn run dev` in the `/react-hooks` folder).

Add some todos and mark at least one of them as complete, then open the browser's console (`F12` in most browsers).

In the console, let's examine localStorage, as that's what TodoMVC is currently using to store data:
```
>> localStorage
<- >Storage { todos: "[{\"done\":false,\"id\":\"d160cc1a-02dc-4ea3-f89c-43b482da5fc4\",\"label\":\"two\"},{\"done\":false,\"id\":\"f555c8b9-ca31-b25e-d71e-f473c5de38f6\",\"label\":\"one\"},{\"done\":false,\"id\":\"a8297d73-3359-7829-cdc4-c545642f9a35\",\"label\":\"test\"}]", length: 1 }
```
`localStorage` is storing an object with a key of "todos" whose value is the data from our TodoMVC todo list. We can take a closer look using:
```
>> JSON.parse(localStorage.getItem("todos"))
<- (3) […]
0: Object { done: false, id: "d160cc1a-02dc-4ea3-f89c-43b482da5fc4", label: "two" }
1: Object { done: false, id: "f555c8b9-ca31-b25e-d71e-f473c5de38f6", label: "one" }
2: Object { done: true, id: "a8297d73-3359-7829-cdc4-c545642f9a35", label: "test" }
length: 3
```
Here, we've used the `parse` method of JSON to turn the "todos" item from `localStorage` into its JSON form - an array of objects each with three key-value pairs: (1) "done" - the completion status, (2) "id" - a random ID used to differentiate tasks, (3) "label" - the task text. This structure should inform our Urbit's `state` as we upgrade it - we'll need to acccommodate storing our tasks in a way that includes the same information points provided by the app natively.

We're going to one-up the original design of the Earth app, however, and turn this array into a `map` in our Urbit, because we'll want to be able to index a given task quickly by it's "id" and make changes to it (mark it as complete, edit the "label", etc.).

### Upgrading the `state`
Let's start in the `/sur/tudumvc.hoon` file and define our `state` as a type so that we can reference it easily in our `/app` file. Recall that we import `/sur/tudumvc.hoon` using `/-` in our `/app` file.

#### `/sur/tudumvc.hoon`
Our current file only defines our `action` `type`. We're going to add a new `type` called `tasks` that is structured to accommodate a `map` with a key of a task's "id" and a value for that key of the task's "label" and "done"-ness (completion state). Using this structure will allow us to index a given task by its "id" (a unique key) to modify the "label" or "done"ness (which can be non-unique - we can enter "Call Mom" 100 times and not have an indexing conflict - btw CALL UR MOM).

Just as with `action`, we're going to use [`+$`](https://urbit.org/docs/reference/hoon-expressions/rune/lus/#lusbuc):
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version
</td>
</tr>
<tr>
<td>

```
|%

+$  action
  $%
  [%add-task task=@tU]
  ==
--
```
</td>
<td>

```
+$  action
  $%
  [%add-task task=@tU]
  ==

:: Creates a structure called tasks that is a (map id=@ud [label=@tU done=?])
:: In other words a map of unique IDs to a cell of `cord` labels and boolean done-ness
::
+$  tasks  (map id=@ud [label=@tU done=?])
--
```
</td>
</tr>
</table>

Now let's turn our attention to our `/app` file and upgrade our `state` there.

#### `/app/tudumvc.hoon`
We're going to need to change four specific areas of our `/app` file:
* The definition of our `state`
* The `on-init` `arm`
* The `on-load` `arm`
* The `on-poke` `arm` (though we'll actually handle this in a second as we upgrade our `action` definitions)

Our order of operations will be:
* Update the `state` definition to include the `tasks` stype we just created in the `/sur` file.
* Update the `on-init` `arm` (which controls new installs of our `agent`) to start people off with the newest `state` definition, so they don't have to upgrade to our new version.
* Update the `on-load` `arm` to provide an upgrade path for existing users to the new `state`.

Incidentally, don't `commit` any of these changes until we're done - you can have your sync-ing routine off for nearly all of this lesson.

##### `state` definition
Recall that `versioned-state` is a type defined as a [tagged union](https://en.wikipedia.org/wiki/Tagged_union) of our available `state`s and that almost always our `state`s are ennumerated, couting up from a tag of `%0` (to `%1`, `%2` and so on). Let's add our new state:
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  [%0 task=@tU]
    ==
```
</td>
<td>

```
+$  versioned-state
    $%  state-one
        state-zero
    ==
+$  state-zero
    $:  [%0 task=@tU]
    ==
+$  state-one
    $:  [%1 tasks=tasks:tudumvc]
    ==
```
</td>
</tr>
</table>
All we've done here is add a new available `state` definition, but until we update the `door` `sample` and our `on-init` and `on-load` `arm`s, nobody will actually be using this new `state`.

##### The `sample`
Next, we need to change what the door's sample is. This is sort of hard to explain, but basically (if you've read our breakout lesson on [(quip card _this)](./lesson2-1-quip-card-and-poke.md) you may see what's happening here) we need to tell our `app` that the data it should expect (it's `state`) will be the new `state` definition. All of our users (existing by `on-load` and new by `on-init`) will be instantly upgraded to the new `state` when they download our new `app` version, and we want to be able to immediately go in to updating `state` information. To do this, we need to make sure that the expected `sample` of our `agent` is the new `state` version:
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
=|  state-zero
```
</td>
<td>

```
=|  state-one
```
</td>
</tr>
</table>

##### `++  on-init`
New users don't have to worry about upgrading their `state`, but they will need to be immediately set up with the new `state` on first load. To do this, we have to change `on-init`:
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
++  on-init
  ^-  (quip card _this)
  ~&  >  '%tudumvc app is online'
  =/  todo-react  [%file-server-action !>([%serve-dir /'~tudumvc' /app/tudumvc %.n %.n])]
  =.  state  [%0 'example task']
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke todo-react]
  ==
```
</td>
<td>

```
++  on-init
  ^-  (quip card _this)
  ~&  >  '%tudumvc app is online'
  =/  todo-react  [%file-server-action !>([%serve-dir /'~tudumvc' /app/tudumvc %.n %.n])]
  =.  state  [%1 `tasks:tudumvc`(~(put by tasks) 1 ['example task' %.n]]
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke todo-react]
  ==
```
</td>
</tr>
</table>

Note that the only real change here is how we set the `state`. We're using [`++  put:by`](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/hoon.hoon#L1632) (described further [`here`](https://urbit.org/docs/reference/library/2i/#put-by))to add a starting key-value pair to our map of an `id=@ud` key of `1` and a `[label=@tu done=?]` value of `['example task' %.n]`.

This will work for new users, but we're going to need to do a little more work to get our existing users upgraded to this new `state`.

##### `++  on-load`
Existing users will have a `state` of `[%0 task=@tU]`. We need to manipulate that state into something compliant with `[%1 tasks=tasks:tudumvc]` where `tasks`, again, is the map we defined in the `/sur` file we modified above. We're going to use `++  put:by` here, as well, and simply take the existing task and put it in the first `id` position of our map (`id=1`), and mark it as incomplete. We will also need to parse what `state` a user is in when they load so that we don't attempt to apply the upgrades to someone already in the `state-one` configuration:
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
++  on-load
  |=  incoming-state=vase
  ^-  (quip card _this)
  ~&  >  '%tudumvc has recompiled'
  `this(state [%1 (~(put by) 1 [task.incoming-state %.n])])
```
</td>
<td>

```
++  on-load
  |=  incoming-state=vase
  ^-  (quip card _this)
  ~&  >  '%tudumvc has recompiled'
  =/  state-ver  !<(versioned-state incoming-state)
  ?-  -.state-ver
    %1
  `this(state state-ver)
    %0
  `this(state [%1 `tasks:tudumvc`(~(put by tasks) 1 [task.state-ver %.n])])
  ==
```
</td>
</tr>
</table>

We've added a few elements:
* [!<](https://urbit.org/docs/reference/hoon-expressions/rune/zap/#zapgal) dynamically checks a `vase` to make sure it matches a `mold`.
    * In this case, we're checking a `vase` to make sure that it matches our `mold` of `versioned-state` which we already updated to include both `state-zero` and `state-one`.
    * Once confirmed, we set the incoming, typed `vase` as `state-ver` for further use.
* [`?-`](https://urbit.org/docs/reference/hoon-expressions/rune/wut/#wuthep) allows us to switch against a union without a default.
    * We're checking the `head` of the `state-ver` (the tag of the tagged union) to determine if we're in `state` `%0` or `state` `%1`.
    * If we're in `state` `%1` already, we just return the `incoming-state` as is.
    * If we're in version `%0`, we take the current `task` value, which is just a `@tU` and we turn it into a value in our map using [`++  put:by`](https://urbit.org/docs/reference/library/2i/#put-by).

### Upgrading the `action`s
We're going to have to upgrade our `/sur` and `/app` files again to accommodate additional `poke` actions that satisfy for all of our possible TodoMVC events. You can take some time to explore TodoMVC and try and determine what those behaviors are, but we'll tell you they should include (at minimum):
* Adding a Task
* Removing a Task
* Marking a Task as Complete
* Editing a Task

Let's start in the `/sur/tudumvc.hoon` file again and create those `action`s.

#### `/sur/tudumvc.hoon`
Our new map data structure (the `state`'s element `tasks`) allows us to communicate a minimal amount of data between our Earth web app and Urbit to accomplish these tasks:
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
|%

+$  action
  $%
  [%add-task task=@tU]
  ==

:: Creates a structure called tasks that is a (map id=@ud [label=@tU done=?])
:: In other words a map of unique IDs to a cell of `cord` labels and boolean done-ness
::
+$  tasks  (map id=@ud [label=@tU done=?])
--
```
</td>
<td>

```
|%
:: We've added %remove-task, %mark-complete, %edit-task as new actions
::
+$  action
  $%
  [%add-task task=@tU]
  [%remove-task id=@ud]
  [%mark-complete id=@ud]
  [%edit-task id=@ud label=@tU]
  ==

:: Creates a structure called tasks that is a (map id=@ud [label=@tU done=?])
:: In other words a map of unique IDs to a cell of `cord` labels and boolean done-ness
::
+$  tasks  (map id=@ud [label=@tU done=?])
--
```
</td>
</tr>
</table>

Since our tasks are indexed by their unique `id`, we only need to pass the `id` key to mark something as complete or remove it. To edit a task, we have to pass both the `id` and the new `label`. And, as we saw in `on-load` we only need the `label` of a task to add it as a key-value pair to the `tasks` map. We'll see how that works presently:

#### `/app/tudumvc.hoon` - `++  on-poke` Changes
We need to update `on-poke` to accommodate the new `action`s we just added to our `/sur` file. If you're not sure why this is our next step, you might want to look back at [Lesson 2](./lesson2-todomvc-on-urbit-sortof.md) or our breakout lesson on [`poke`s](./lesson2-1-quip-card-and-poke.md). We'll show the changes and then go through each `poke` to discuss how it works.
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
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
</td>
<td>

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
    =/  new-id=@ud
    ?~  tasks
      1
    +(-:(sort `(list @ud)`~(tap in ~(key by `(map id=@ud [task=@tU complete=?])`tasks)) gth))
    ~&  >  "Added task {<task.action>} at {<new-id>}"
    `state(tasks (~(put by tasks) new-id [+.action %.n]))
     ::
      %remove-task
    ?:  =(id.action 0)
      `state(tasks ~)
    ?.  (~(has by tasks) id.action)
      ~&  >>>  "No such task at ID {<id.action>}"
      `state
    `state(tasks (~(del by tasks) id.action))
    ::
      %mark-complete
    ?.  (~(has by tasks) id.action)
      ~&  >>>  "No such task at ID {<id.action>}"
      `state
    =/  task-text=@tU  label.+<:(~(get by tasks) id.action)
    =/  done-state=?  ?!  done.+>:(~(get by tasks) id.action)
    ~&  >  "Task {<task-text>} marked {<done-state>}"
    `state(tasks (~(put by tasks) id.action [task-text done-state]))
    ::
      %edit-task
    ~&  >  "Receiving facts {<id.action>} and {<label.action>}"
    =/  done-state=?  done.+>:(~(get by tasks) id.action)
    `state(tasks (~(put by tasks) id.action [label.action done-state]))
    ==
  --
```
</td>
</tr>
</table>

Before we proceed, we're ready to sync these files and `|commit %home`. Do that, and then check your state using `:tudumvc +dbug %state`. You should have something like this:
```
>   [%1 tasks={[p=id=1 q=[label='example task' done=%.n]]}]
```
Hopefully, you can see how we've updated the existing `state`'s `task` value by turning it into a map of `[id=@ud [label=@tu done=?]]`s where your existing `task` is now the `label` of the first key-value pair in our map. Now, let's look at the `poke-action` changes.

##### `%add-task`
```
  %add-task
=/  new-id=@ud
?~  tasks
  1
+(-:(sort `(list @ud)`~(tap in ~(key by `(map id=@ud [task=@tU complete=?])`tasks)) gth))
~&  >  "Added task {<task.action>} at {<new-id>}"
`state(tasks (~(put by tasks) new-id [task.action %.n]))
```
`%add-task` adds a task to our map. It takes an argument of a `task=@tu` or just a task as a cord.
* First, it creates a face called `new-id` who's value is determined by a conditional statement.
* If the `tasks` face of our `state` is empty, we start at task `id` 1.
* Otherwise we look to find the greatest current `id` value and increment it by one (in other words we always create our new task at the next positive integer `id` position).
    * This ordering function is a little complex, so we've made a [breakout lesson](./lesson4-1-ordering-our-tasks.md) to explain it; if you don't want to read that, just trust me that that's what it does.
* In either event, what we do next is again use [`put:by`](https://urbit.org/docs/reference/library/2i/#put-by) to store our incoming task (`task:action`) at the `key`-position of `new-id`, with an incomplete state (`%.n`).
Try it in dojo by entering `:tudumvc &tudumvc-action [%add-task 'test']`. You should see something like this:
```
>   "Added task 'test' at 2"
> :tudumvc &tudumvc-action [%add-task 'test']
>=
```

##### `%remove-task`
```
  %remove-task
?:  =(id.action 0)
  `state(tasks ~)
?.  (~(has by tasks) id.action)
  ~&  >>>  "No such task at ID {<id.action>}"
  `state
~&  >  "Removed task {<(~(get by tasks) id.action)>}"
`state(tasks (~(del by tasks) id.action))
```
`%remove-task` removes an existing task from our map, with a special all-clear function. It takes an argument of an `id=@ud` which should either be `0` or one of the existing tasks `id`s in our map.
* First, we check to see if the `id` is `0`, using [`?:`](https://urbit.org/docs/reference/hoon-expressions/rune/wut/#wutcol).
    * If it is, we set `tasks` equal to `~`, or null.
* If the `id` is not `0`, then we check (using [`has:by`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L1583), also [here](https://urbit.org/docs/reference/library/2i/#has-by)) if the `id` is a valid key in our map.
    * If it is not a valid `id`, we return the `state` unchanged but mesasge the user in `dojo` indicating that there is `"No such task at ID {<id.action>}`.
    * If it _is_ valid, we use [`del:by`](https://urbit.org/docs/reference/library/2i/#del-by) to remove that key-value pair from `tasks` in our `state`.

Try it in dojo by entering `:tudumvc &tudumvc-action [%remove-task 2]`. You should see something like this:
```
>   "Removed task [~ [label='test' done=%.n]]"
> :tudumvc &tudumvc-action [%remove-task 2]
>=
```

##### `%mark-complete`
```
  %mark-complete
?.  (~(has by tasks) id.action)
  ~&  >>>  "No such task at ID {<id.action>}"
  `state
=/  task-text=@tU  label.+<:(~(get by tasks) id.action)
=/  done-state=?  ?!  done.+>:(~(get by tasks) id.action)
~&  >  "Task {<task-text>} marked {<done-state>}"
`state(tasks (~(put by tasks) id.action [task-text done-state]))
```
`%mark-complete` marks an existing task from our map as complete. It takes an argument of an `id=@ud` which should be one of the existing tasks `id`s in our map.

This works almost identically to `%remove-task`, except that it only changes the `done`ness of a given task using `put:by` to replace the existing `done` value with the _opposite_ of the current `done` value. In the TodoMVC app, you can click the done button to mark an incomplete task as complete, and also click the done button of a _complete_ task to mark it _incomplete_. Allowing our app to automatically alternate between those solves for this functionality.

We complete the alternation by creating a face of `done-state` and set it equal to the _opposite_ of the current `done` state, using [`?!`](https://urbit.org/docs/reference/hoon-expressions/rune/wut/#wutzap) only _after_ we've confirmed that the `id` key actually exists.

Try it in dojo a few times, using something like `:tudumvc &tudumvc-action [%mark-complete 1]`:
```
>   "Task 'example task' marked %.y"
> :tudumvc &tudumvc-action [%mark-complete 1]
>=
>   "Task 'example task' marked %.n"
> :tudumvc &tudumvc-action [%mark-complete 1]
>=
```

##### `%edit-task`
We're not going to tell you how `%edit-task` works - in fact, that's one of your exercises for this week. We can tell you it works rather similarly to the ones above, and that it takes two arguments:
* An `id`.
* An updated `label`.

## Homework
* Examine the available structures of [JSON in Hoon](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/lull.hoon#L40), found in `lull.hoon`.
* Read through [`++  enjs`](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/zuse.hoon#L3263) in `zuse.hoon`.
* Read through [`++  dejs`](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/zuse.hoon#L3317) in `zuse.hoon`.

## Exercises
* Write a description of how `%edit-task` works, referencing the code in the [`src-lesson4`](./src-lesson4/app/tudumvc.hoon#L86) folder.
    * Include a successful `dojo` `poke` command and show your output.
* Attempt to create a few JSON objects in `dojo` and then use [`dejs:format`](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/zuse.hoon#L3317) to parse them into regular Hoon types.

## Summary and Addenda
There we have it - on to Lesson 5. We're just about complete - the next lesson will focus on updating our Earth web app to connect directly to Urbit (and ditch localStorage entirely) and parsing JSON in Urbit.

For now, we hope you are able to:
* Describe how `state` upgrading is managed in `%gall`.
* Add your own `poke` `action`s by defining them in `/sur` and adding handling to `on-poke`.

Also, check out the breakout lesson for this lesson on:
* [Ordering Tasks Using `sort`](./lesson4-1-ordering-our-tasks.md)

<hr>
<table>
<tr>
<td>

[< Lesson 3 - The %gall of that agent](./lesson3-the-gall-of-that-agent.md)
</td>
<td>

[Lesson 5 - Establishing Uplink >](./lesson5-establishing-uplink.md)
</td>
</tr>
</table>