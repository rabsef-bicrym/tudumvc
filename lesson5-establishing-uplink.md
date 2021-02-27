# Establishing Uplink
We're at the finish line of our initial integration of TodoMVC and Urbit. While we'll have a few more lessons hereafter covering upgrades to the system, we're a few short lines of code of completing `tudumvc` in its most basic format. Let's do it.

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
* A copy of our current Earth web app (found in [src-lesson5](./src-lesson5/todomvc-start)).
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
Changing our imports
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
```
</td>
<td>

```
import React, { useCallback, useMemo, useState, useEffect } from "react";
```
</td>
</tr>
</table>

<table>
<tr>
<td colspan="2">

Changing `state` management and subscribe
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
  useEffect(() => { const sub = urb.subscribe({ app: 'todoreact', path: '/mytasks', event: data => {
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

Add setDone `poke` action

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

### `poke` Everything Like it's Facebook in 2007

## Homework

## Exercises

## Summary and Addenda