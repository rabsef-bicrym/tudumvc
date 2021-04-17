# Establishing Uplink
We're at the finish line of our initial integration of TodoMVC and Urbit. While we'll have a few more lessons hereafter covering upgrades to the system, we're a few short lines of code of completing `tudumvc` in its most basic format.

This is _definitely_ the hardest lesson so far and we don't explain every single change, especially on the JavaScript side - if you're not familiar with React.js at all, this lesson may be difficult. Just remember, there are a lot of resources available online that describe how React.js works.

Let's do it.

## Learning Checklist
* How to use `airlock` to `subscribe` an Earth web app on a `path` to Urbit data.
* How to parse JSON data effectively.

## Goals
* Upgrade our Earth app to send `poke` data for all actions.
* Parse incoming `poke` data into a structure our `%gall` `agent` can understand.
* Subscribe our Earth app to Urbit data for all data changes.
* Make our `%gall` `agent` send updated `state` information to the Earth web.
* Minify our Earth app and host it from our Urbit.

## Prerequisites
* Our Earth web app as modified in [Lesson 4 - Updating Our Agent](./lesson4-updating-our-agent.md).
    * A copy of our current Earth web app can be found in [src-lesson5](./src-lesson5/todomvc-start).
* **NOTE:** We've included a copy of all the files you need for this lesson _in their completed form_ in the folder [src-lesson5](./src-lesson5), but you should try doing this on your own instead of just copying our files in. No cheating!

## The Lesson
We'll start by adding `poke` `action`s for some of the functional feature in our TodoMVC app. Then, we'll take a look at the JSON that we receive and figure out how to parse that. We'll need to add Urbit subscriptions and data passing on `path`s, using `card`s to give our Earth web app a state again after our initial breaking changes and then, finally, we can implement the rest of the functional features.

Begin by launching your Fake Ship and starting the TodoMVC app using `yarn run dev`.

### `poke`s Replete with Parsing
We should start by clearing out all of the "todos" we have in TodoMVC (just mouse over them and click the red x on the right hand side) and clearing all of our tasks out of our `%gall` `agent` (`:tudumvc %tudumvc-action [%remove-task 0]`).

Next, let's add to the Test Button functionality we previously added:
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
  const [todos, { addTodo, deleteTodo, setDone }] = useTodos();

  // Here we're importing the Urbit API from useApi which was passed as a prop
  // to this component/container
  const urb = props.api;

  // Here we're creating a poke action to send some JSON to our ship
  const poker = () => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'add-task': 'from Earth to Mars'}});
  };
```
</td>
<td>

```
  // Note that we've removed "addTodo" and "deleteTodo" from those functions
  // that are lazily defined here, to avoid name conflict
  const [todos, { setDone }] = useTodos();

  // Here we're importing the Urbit API from useApi which was passed as a prop
  // to this component/container
  const urb = props.api;

  // We've added "deleteTodo" and "addTodo"
  const poker = () => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'add-task': 'from Earth to Mars'}});
  };

  const deleteTodo = (num) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'remove-task': num}})
  };

  const addTodo = (task) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'add-task': task}})
  };
```
</td>
</tr>
</table>

Great - we've completely broken things! Save these changes, let the app recompile and attempt adding a task. If you're like me and you've re-freshed your Fake Ship since you last had this working, nothing happens on the Urbit side. This is because we forgot to set the `+cors-registry`. Recall that you set that up like this:
```
> +cors-registry
[ requests={~~http~3a.~2f.~2f.localhost~3a.3000}
  approved={}
  rejected={}
]
> |cors-approve ~~http~3a.~2f.~2f.localhost~3a.3000
>=
```
Now, refresh the page and attempt to add a task. Still broken - nothing shows up in TodoMVC but we should see some output like this in our `dojo`:
```
< ~nus: opening airlock
"Your JSON object looks like [%o p=\{[p='add-task' q=[%s p='test']]}]"
>   "Added task 'We did it, reddit!' at 2"
"Your JSON object looks like [%o p=\{[p='add-task' q=[%s p='test']]}]"
>   "Added task 'We did it, reddit!' at 3"
"Your JSON object looks like [%o p=\{[p='add-task' q=[%s p='test']]}]"
>   "Added task 'We did it, reddit!' at 4"
~nus:dojo> 
```
This is not good - we are not Redditors. We need to parse these incoming `poke`s and make the task that is added reflect the input from the user in TodoMVC, and not just some default value. Recall that we set this in `/mar` way back in [Lesson 3](./lesson3-the-gall-of-that-agent.md). Let's return to `/mar` and correct that:

#### `/mar/tudumvc/action.hoon` and JSON Parsing Introduction
In the prior lesson's homework, we asked that you take a look at the available structures of [JSON in Hoon](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/lull.hoon#L40), found in `lull.hoon`, as well as the JSON parser [`++  dejs`](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/zuse.hoon#L3317) in `zuse.hoon`. We're going to need that information now, so make sure review if you're feeling foggy on it.

##### Available JSON Structures
You might want to have a more in-depth lesson on JSON parsing, which you can find [here](./lesson5-1-more-on-JSON-parsing.md). The main guide will give you just what you need for this purpose.
```
+$  json                                                ::  normal json value
  $@  ~                                                 ::  null
  $%  [%a p=(list json)]                                ::  array
      [%b p=?]                                          ::  boolean
      [%o p=(map @t json)]                              ::  object
      [%n p=@ta]                                        ::  number
      [%s p=@t]                                         ::  string
  ==                                                    ::
```
A JSON in Hoon is defined as either ([$@](https://urbit.org/docs/reference/hoon-expressions/rune/buc/#bucpat) a null atom or a tagged union with a few different options, some of which are recursive (`%a` and `%o`, specifically).

Looking at our incoming `poke` from the web, we can see that `"Your JSON object looks like [%o p=\{[p='add-task' q=[%s p='test']]}]"`, or we're dealing with an `%o` object that contains a `(map @t json)`. Here, our map has one key (`add-task`) and one value (`[%s p='test']`). Let's work our way out from the inside (the value).

Create an object in the dojo that mirrors our incoming value:
```
> =a `json`[%s 'this is a string']
> a
[%s p='this is a string']
~nus:dojo> 
```
Now let's look at the JSON parser [`++  dejs`](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/zuse.hoon#L3317). If you scan through, you can probably guess that [`so:dejs:format`](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/zuse.hoon#L3472) (**NOTE:** `so:dejs:format` is just a long way of referencing the `++  so` arm of `++  dejs` which is, itself in `++  format` found in `zuse.hoon`) is designed to parse `%s` type JSON specifically - let's try this in `dojo`:
```
> (so:dejs:format a)
'this is a string'
~nus:dojo> 
```
Great! But we need to expand it to work with an object (`[%o p=\{[p='add-task' q=[%s p='test']]`). This won't be as obvious, but the function `of:dejs:format` allows us to give a list of parsing functions as, itself, a tagged union that will check the key in an object and apply one specific parser to the value of the incoming object based on a matching of the key from the object to the tag in the tagged union provided to `of`. If this doesn't make sense yet, it will with examples over the course of this lesson.

Let's form something in `dojo` to use `of:dejs:format`:
```
> =a (of:dejs:format :~([%add-task so:dejs:format]))
```
and store our incoming poke as another `face:
```
> =b [%o `(map @t json)`(my :~(['add-task' [%s 'test']]))]
```
and finally let's try parsing it:
```
> (a b)
[%'add-task' 'test']
~nus:dojo> 
```
This looks useful. To spell out what we're doing, let's turn to modifying our `/mar` file.

##### `/mar/tudumvc/action.hoon` First Edit
Modify your `/mar` file as follows:
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
/-  tudumvc
=,  dejs:format
|_  act=action:tudumvc
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
--
```
</td>
<td>

```
/-  tudumvc
=,  dejs:format
|_  act=action:tudumvc
++  grab
  |%
  ++  noun  action:tudumvc
  ++  json
  |=  jon=^json
  ~&  "Your JSON object looks like {<jon>}"
  %-  action:tudumvc
  =<
  (action jon)
  |%
  ++  action
    %-  of
    :~  [%add-task so]
    ==
  --
  --
--
```
</tr>
</table>

Instead of just calling `++  action` like we did in the initial version (which had a hard-coded poke of `[%add-task 'We did it, reddit!']`), we've turned `action` into a call to `of:dejs:format` and given `of` a tagged union of parsers, one of which is for our `%add-task` action, using `so:dejs:format`.

Now, clear your Urbit app's state (`:tudumvc &tudumvc-action [%remove-task 0]`), `|commit %home` our changes to the `/mar` file, and finally try adding a task in TodoMVC again. you should see something like this:
```
"Your JSON object looks like [%o p=\{[p='add-task' q=[%s p='We actually did it, Urbit!']]}]"
>   "Added task 'We actually did it, Urbit!' at 1"
~nus:dojo> 
```
Alright - in order to do any additional testing or confirm our modifications are working on the Earth web side, we're going to need to get our Earth web app to receive our Urbit's `state` as the `state` of our "todos"

### `subscribe` Method of `airlock` and Sending `card`s
We're going to make several changes to `containers/TodoList.js` and `/app/tudumvc.hoon` to implement `state` sharing between Mars and Earth. In very simple terms, what we're doing here is telling TodoMVC to listen on a `path` for information and telling Urbit to send `state` data on that same `path` each time the `state` changes. We'll start with the less involved TodoMVC changes:

#### `subscribe`-ing on a `path`
Not only do we need to have TodoMVC `subscribe` to the `path` but we also will need to use React.js's useState and useEffect to incorporate the incoming data into TodoMVC. Make the following changes:
<table>
<tr>
<td colspan="2">
Change our imports
</td>
</tr>
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
import React, { useCallback, useMemo } from "react";
import { NavLink } from "react-router-dom";
```
</td>
<td>

```
import React, { useCallback, useMemo, useState, useEffect } from "react";
import { NavLink, Route } from "react-router-dom";
```
</td>
</tr>
</table>

<table>
<tr>
<td colspan="2">

Change `state` management and subscribe
</td>
</tr>
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
  const [todos, { setDone }] = useTodos();

  // Here we're importing the Urbit API from useApi which was passed as a prop
  // to this component/container
  const urb = props.api;
```
</td>
<td>

```
  const [todos, setLocalTodos] = useState([]);

  // Here we're importing the Urbit API from useApi which was passed as a prop
  // to this component/container
  const urb = props.api

  // And here we're subscribing to our Urbit app and setting our listening
  // path to '/mytasks'
  useEffect(() => { const sub = urb.subscribe({ app: 'tudumvc', path: '/mytasks', event: data => {
    setLocalTodos(data);
  }}, [todos, setLocalTodos])
  }, []);
```
</td>
</tr>
</table>

<table>
<tr>
<td colspan="2">

Add a setDone `poke` action.

**NOTE:** This doesn't work quite right - you're going to fix it in your homework.
</td>
</tr>
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
  const addTodo = (task) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'add-task': task}})
  };
```
</td>
<td>

```
  const addTodo = (task) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'add-task': task}})
  };

  const setDone = (num) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'mark-complete': num}})
  };
```
</td>
</tr>
</table>

Now, let's send some data back.

#### `/app/tudumvc.hoon`
We're going to need to add a "helper core" (as described briefly in [Lesson 3](./lesson3-the-gall-of-that-agent.md)). Basically, all this does is allow us to offboard some code to beneath the main, 10 `arm`s of our `%gall` `agent`. We need this helper core for two purposes: (1) if you'll recall, the default state of our TodoMVC app is an array of objects, but we're storing everything as a map. We're going to need to convert back to an array. (2) We also need to send our data as JSON to TodoMVC, so we're going to need to use [`++  enjs`](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/zuse.hoon#L3263) from `zuse.hoon` to encode things.

Make the following changes:
<table>
<tr>
<td colspan="2">
Tell Urbit to incorporate a helper core
</td>
</tr>
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
^-  agent:gall
|_  =bowl:gall
+*  this   .
    def    ~(. (default-agent this %|) bowl)
```
</td>
<td>

```
^-  agent:gall
=<
|_  =bowl:gall
+*  this   .
    def    ~(. (default-agent this %|) bowl)
    hc  ~(. +> bowl)
```
</td>
</tr>
</table>

<table>
<tr>
<td>

Add this `door` at the very bottom of the file:
</td>
</tr>
<td>

```
|_  bol=bowl:gall
++  tasks-json
  |=  stat=tasks:tudumvc
  |^
  ^-  json
  =/  tasklist=(list [id=@ud label=@tU done=?])  ~(tap by stat)
  =/  objs=(list json)  (roll tasklist object-maker)
  [%a objs]
  ++  object-maker
  |=  [in=[id=@ud label=@tU done=?] out=(list json)]
  ^-  (list json)
  :-
  %-  pairs:enjs:format
    :~  ['done' [%b done.in]]
        ['id' [%s (scot %ud id.in)]]
        ['label' [%s label.in]]
    ==
  out
  --
--
```
</td>
</tr>
</table>

<table>
<tr>
<td colspan="2">

Pass `card`s on `poke`.

**NOTE:** The use of `card`s is better defined in [Lesson 2-1](./lesson2-1-quip-card-and-poke.md).

**NOTE:** We're also changing where we update the `state` so that the `state` being passed on the `path` is already up-to-date.
</td>
</tr>
<td>
:: initial version
</td>
<td>
:: new version
</td>
</tr>
<tr>
<td colspan="2">

`%add-task`
</td>
</tr>
<tr>
<td>

```
  %add-task
=/  new-id=@ud
?~  tasks
  1
+(-:(sort `(list @ud)`~(tap in ~(key by `(map id=@ud [task=@tU complete=?])`tasks)) gth))
~&  >  "Added task {<task.action>} at {<new-id>}"
`state(tasks (~(put by tasks) new-id [task.action %.n]))
```
</td>
<td>

```
  %add-task
=/  new-id=@ud
?~  tasks
  1
+(-:(sort `(list @ud)`~(tap in ~(key by `(map id=@ud [task=@tU complete=?])`tasks)) gth))
~&  >  "Added task {<task.action>} at {<new-id>}"
=.  state  state(tasks (~(put by tasks) new-id [+.action %.n]))
:_  state
~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc tasks)))]]]
```
</td>
</tr>
<tr>
<td colspan="2">

`%remove-task`
</td>
</tr>
<td>

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
</td>
<td>

```
  %remove-task
?:  =(id.action 0)
  =.  state  state(tasks ~)
  :_  state
  ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc tasks)))]]]
?.  (~(has by tasks) id.action)
  ~&  >>>  "No such task at ID {<id.action>}"
  `state
=.  state  state(tasks (~(del by tasks) id.action))
:_  state
~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc tasks)))]]]
```
</td>
</tr>
<tr>
<td colspan="2">

`%mark-complete`
</td>
</tr>
<tr>
<td>

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
</td>
<td>

```
  %mark-complete
?.  (~(has by tasks) id.action)
  ~&  >>>  "No such task at ID {<id.action>}"
  `state
=/  task-text=@tU  label.+<:(~(get by tasks) id.action)
=/  done-state=?  ?!  done.+>:(~(get by tasks) id.action)
~&  >  "Task {<task-text>} marked {<done-state>}"
=.  state  state(tasks (~(put by tasks) id.action [task-text done-state]))
:_  state
~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc tasks)))]]]
```
</td>
</tr>
<tr>
<td colspan="2">

`%edit-task`
</td>
</tr>
<tr>
<td>

```
  %edit-task
~&  >  "Receiving facts {<id.action>} and {<label.action>}"
=/  done-state=?  done.+>:(~(get by tasks) id.action)
`state(tasks (~(put by tasks) id.action [label.action done-state]))
==
```
</td>
<td>

```
  %edit-task
~&  >  "Receiving facts {<id.action>} and {<label.action>}"
=/  done-state=?  done.+>:(~(get by tasks) id.action)
=.  state  state(tasks (~(put by tasks) id.action [label.action done-state]))
:_  state
~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc tasks)))]]]
```
</td>
</tr>
</table>

<table>
<tr>
<td colspan="2">

Lastly, we need to add an `on-watch` action. `on-watch` is extremely simple - it activates when something subscribes on a `path` and it tells our app what to do on that occasion.

Here, all we're doing is sending our current tasks back along the `path`.
</td>
</tr>
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
++  on-watch  on-watch:def
```
</td>
<td>

```
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
    [%mytasks ~]
  :_  this
  ~[[%give %fact ~[path] [%json !>((json (tasks-json:hc tasks)))]]]
  ==
```
</td>
</tr>
</table>

All we need to do now is `|commit %home` our changes and save the changes to TodoList.js. If you add a task thereafter, you should see it automatically appear in the Earth web version!

### `poke` Everything Like it's Facebook in 2007
Unfortunately, none of our other actions (when sent by JSON, at least) will work yet because we haven't added parsing functions for their data types yet.

#### `/mar/tudumvc/action.hoon` Again
You can review our [breakout lesson on JSON parsing](./lesson5-1-more-on-JSON-parsing.md) if you want to better understand what's going on here. If not, just make the following changes:
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
  ++  json
    |=  jon=^json
    ~&  "Your JSON object looks like {<jon>}"
    %-  action:tudumvc
    =<
    (action jon)
    |%
    ++  action
      %-  of
      :~  [%add-task so]
      ==
    --
  --
```
</td>
<td>

```
  ++  json
    |=  jon=^json
    %-  action:tudumvc
    =<
    (action jon)
    |%
    ++  action
      %-  of
      :~  [%add-task so]
          [%remove-task ni]
          [%mark-complete ni]
          [%edit-task (ot :~(['id' ni] ['label' so]))]
      ==
    --
  --
```
</td>
</tr>
</table>

#### Final changes to TodoMVC
We need to make changes to TodoList.js and TodoItem.js. Incidentally, we've avoided doing this but you could also remove reference to useTodos.js anywhere you find it in either file.
<table>
<tr>
<td colspan="2">
Update TodoList.js
</td>
</tr>
<tr>
<td colspan="2">
Incorporate the Urbit API to make it available to TodoItem.js
</td>
</tr>
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
  return (
    <React.Fragment>
```
</td>
<td>

```
  const {api} = props;
  return (
    <React.Fragment>
```
</td>
</tr>
<tr>
<td colspan="2">
Pass the api to TodoItem.js
</td>
</tr>
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
          {visibleTodos.map(todo => (
            <TodoItem key={todo.id} todo={todo} />
          ))}
```
</td>
<td>

```
          {visibleTodos && visibleTodos.map(todo => (
            // Each item is an instance of Route and wants
            // a key
            <Route key={`todoItem-${todo.id}`} render={(props) => {
              console.log(`todoItem-${todo.id}`);
              return <TodoItem todo={todo} api={api} {...props}/>
            }} />
          ))}
```
</td>
</tr>
</table>

<table>
<tr>
<td colspan="2">
Update TodoItem.js
</td>
</tr>
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
export default function TodoItem({ todo }) {
  const [, { deleteTodo, setLabel, toggleDone }] = useTodos(() => null);

  const [editing, setEditing] = useState(false);
```
</td>
<td>

```
export default function TodoItem(props) {
  const [label, setLabel] = useState(props.todo.label);

  const [id, setID] = useState(props.todo.id);
  
  const [editing, setEditing] = useState(false);

  const urb = props.api;

  const deleteTodo = (num) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'remove-task': parseInt(num)}})
  };

  const toggleDone = (num) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'mark-complete': parseInt(num)}})
  };

  const onBlur = () => {
    console.log(`setting urbit state to ${label} for task ${id}`);
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'edit-task': {'id': parseInt(id), 'label': label}}})
  };
```
</td>
</tr>
<tr>
<td>

```
  const onDelete = useCallback(() => deleteTodo(todo.id), [todo.id]);
  const onDone = useCallback(() => toggleDone(todo.id), [todo.id]);
  const onChange = useCallback(event => setLabel(todo.id, event.target.value), [
    todo.id
  ]);
```
</td>
<td>

```
  const onDelete = useCallback(() => deleteTodo(id), [id]);
  const onDone = useCallback(() => toggleDone(id), [id]);
  const onChange = event => {
    setLabel(event.target.value);
  }
```
</td>
</tr>
<tr>
<td>

```
  const handleViewClick = useDoubleClick(null, () => setEditing(true));
  const finishedCallback = useCallback(
    () => {
      setEditing(false);
      setLabel(todo.id, todo.label.trim());
    },
    [todo]
  );

  const onEnter = useOnEnter(finishedCallback, [todo]);
  const ref = useRef();
  useOnClickOutside(ref, finishedCallback);
```
</td>
<td>

```
  const handleViewClick = useDoubleClick(null, () => setEditing(true));
  const finishedCallback = useCallback(
    () => {
      onBlur();
      setEditing(false);
    },
    [label]
  );

  const onEnter = useOnEnter(finishedCallback, [label]);
  const ref = useRef();
  useOnClickOutside(ref, finishedCallback);
```
</td>
</tr>
<tr>
<td>

```
  return (
    <li
      onClick={handleViewClick}
      className={`${editing ? "editing" : ""} ${todo.done ? "completed" : ""}`}
    >
      <div className="view">
        <input
          type="checkbox"
          className="toggle"
          checked={todo.done}
          onChange={onDone}
          autoFocus={true}
        />
        <label>{todo.label}</label>
        <button className="destroy" onClick={onDelete} />
      </div>
      {editing && (
        <input
          ref={ref}
          className="edit"
          value={todo.label}
          onChange={onChange}
          onKeyPress={onEnter}
        />
      )}
    </li>
  );
```
</td>
<td>

```
  return (
    <li
      onClick={handleViewClick}
      className={`${editing ? "editing" : ""} ${props.todo.done ? "completed" : ""}`}
    >
      <div className="view">
        <input
          type="checkbox"
          className="toggle"
          checked={props.todo.done}
          onChange={onDone}
          autoFocus={true}
        />
        <label>{label}</label>
        <button className="destroy" onClick={onDelete} />
      </div>
      {editing && (
        <input
          ref={ref}
          className="edit"
          value={label}
          id={id}
          // On change needs to happen component local
          // on blur needs to send to urbit
          onChange={onChange}
          onKeyPress={onEnter}
        />
      )}
    </li>
  );
```
</td>
</tr>
</table>

### Wrapping Up
You should be able to save all these changes, reload the app and start using it at this point. We still need to minify the JavaScript and store it in the `/app/tudumvc` folder to serve it _from_ our Urbit rather than running it on a dev server. Once you're done playing with your success, go ahead and shut down the dev server using `CTRL+C`

#### Minifying
1. Minify the app (by producing a `build` folder) using `yarn build`.
2. Delete our old `index.html` file from `/app/tudumvc`.
3. Copy and paste the contents of `build` to `/app/tudumvc`.
4. Delete `favicon.ico`.
5. Do a find and replace:
        <table>
        <tr>
        <td>
        Find
        </td>
        <td>
        Replace With
        </td>
        </tr>
        <tr>
        <td>
        hooks-todo
        </td>
        <td>
        ~tudumvc
        </td>
        </tr>
        </table>
6. `|commit %home`

And there you have it. `tudumvc` works. It's going to live at http://localhost:8080/~tudumvc. Try it out!

## Homework
* {Information about social element - to be added}

## Exercises
* Describe what's going on in our Helper Core - you'll need the following information:
    * [=<](https://urbit.org/docs/reference/hoon-expressions/rune/tis/#tisgal)
    * [pairs:enjs:format](https://github.com/urbit/urbit/blob/6bcbbf8f1a4756c195a324efcf9515b6f288f700/pkg/arvo/sys/zuse.hoon#L3271)
    * [tap:by](https://urbit.org/docs/reference/library/2i/#tap-by)
    * [roll](https://urbit.org/docs/reference/library/2b/#roll)
    * [scot](https://urbit.org/docs/reference/library/4m/#scot)
* Fix setDone in `/containers/TodoList.js` to work properly - you'll need to:
    * Add a secret function to `%mark-complete` (perhaps at `id=0` like we did with `%remove-task`) that automatically marks all tasks as complete, regardless of their current state.
    * Change `/containers/TodoList.js` to send just the secret function identifier rather than cycling through all available `id`s
    * Change our "Test Button" to be the "Mark All as Complete" button.

## Summary and Addenda
That was a lot of lesson. We hope you picked up on the big beats and we encourage you to pore through the changes we made in the JavaScript to better understand what we did. It's a shame we couldn't cover every line change here, but I'm no JavaScript expert and we expect that's better covered in other forums.

By now, you should:
* Generally understand JSON parsing.
    * Additional information [here](./lesson5-1-more-on-JSON-parsing.md).
* Generally understand `airlock` subscriptions and how data is passed using a `card` along a `path`.

In our next lesson we're going to add features to `tudumvc` to allow networked task-management between urbits, now that our data is stored in Urbit.

<hr>
<table>
<tr>
<td>

[< Lesson 4 - Updating Our Agent](./lesson4-updating-our-agent.md)
</td>
<td>

[Lesson 6 - Things Tudu and People TuSee >](./lesson6-things-tudu.md)
</td>
</tr>
</table>