# If an App is Worth `Todo`-ing, it's Worth `tudu`-ing Well
In this lesson, we're going to take a look at the basic _React.js with Hooks_ version of TodoMVC provided by the [TodoMVC project](https://todomvc.com/). We'll learn about the following items:
1. How TodoMVC React-Hooks can be installed locally for some testing and modification
2. How TodoMVC React-Hooks stores its data
3. How we might emulate and perhaps improve on the data structure of TodoMVC React-Hooks in Hoon

## Goals
* Install TodoMVC React-Hooks example on our server
* Launch the dev instance of TodoMVC React-Hooks and 
* Examine the data structure of TodoMVC React-Hooks
* Build a very simple version of a Todo `app` for our urbit that mirrors the functionality of the TodoMVC React-Hooks example

## Installing TodoMVC React-Hooks
Let's get this running locally.  Clone the repository for TodoMVC from [here](https://github.com/tastejs/todomvc) - that'll go something like this:
```
$ git clone https://github.com/tastejs/todomvc.git
Cloning into 'todomvc'...
```

That'll take a minute to download everything from that repository (all sorts of different versions of the app), but when we're done, we're ready to start installing. Move into the React-Hooks folder using `cd todomvc/examples/react-hooks` (replacing the beginning with whever you cloned the repository.

To install the app from there, I'll be using `yarn` to do most of my work for me, but you could use `npm` if you prefer it (weirdo).  Let's get installing:
```
$ yarn install
yarn install v1.22.10
info No lockfile found.
...
[4/4] Building fresh packages...
success Saved lockfile.
Done in 52.65s.
```

## Launch the Dev Instance of TodoMVC React-Hooks
Once the installation is done, you'll be back at your shell.  Let's boot the app:
```
$ yarn run dev
yarn run v1.22.10
$ react-scripts start
```
`yarn run dev` will start up the app on `localhost` (or wherever your server is) at port 3000.  Once it's ready, you'll see this:
```
Compiled successfully!

You can now view hooks-todo in the browser.

  http://localhost:3000/

Note that the development build is not optimized.
To create a production build, use yarn build.
```

Now we're ready to experiment!

## Examine the Data Structure of TodoMVC React-Hooks
Navigate to the site you've just launched (probably at [http://localhost:3000](http://localhost:3000)). You should take some time to play around in the app here and see what it can do.  Add some tasks, mark some as complete, delete some, add some more. Once you've got a nice `state` built up from adding tasks, let's take a look at the data structure.
* Open the console in your browser and key in `localStorage`.  You'll see something like this:
```
>> localStorage
<- > Storage { todos: "[{\"done\":true,\"id\":\"a7859d5f-a05b-fcb4-f63f-347d50b10c27\",\"label\":\"done-task\"},{\"done\":false,\"id\":\"fc8db1df-cd84-600f-9b50-ed21fd4b5c95\",\"label\":\"test-task\"}]", length: 1 }
```
This tells us that we have an object in localStorage called "todos" that contains an array of objects of our tasks. We can get at this object, however, and see it a little more closely.  Let's take a peek at that object:
* Store the localStorage object as a variable
```
>> var test = localStorage.getItem("todos");
<- undefined
>> test
<- "[{\"done\":true,\"id\":\"a7859d5f-a05b-fcb4-f63f-347d50b10c27\",\"label\":\"done-task\"},{\"done\":false,\"id\":\"fc8db1df-cd84-600f-9b50-ed21fd4b5c95\",\"label\":\"test-task\"}]"
>> JSON.parse(test);
<- (2) […]
> 0: Object { done: true, id: "a7859d5f-a05b-fcb4-f63f-347d50b10c27", label: "done-task" }
> 1: Object { done: false, id: "fc8db1df-cd84-600f-9b50-ed21fd4b5c95", label: "test-task" }
length: 2
<prototype>: []
```
Ok - so we have an array of _n_ objects (depending on how many tasks you made). Each object has three attributes: done, id and label. Done is a `boolean`, ID is just a random string or unique identifier and Label is the task string (the title of the task).

We basically have what we need to get started building the app here:
* A `task` object with a `label`, `id`, and `done`-ness state
* Ability to:
  * Add tasks
  * Delete tasks
  * Mark tasks as complete
  * Edit the `label` of a task

Let's build this thing.

## Building the App
You're in luck, because I've already built this app for you. We'll examine this app just like we did `%firststep` and walk through all of the important and different bits. I'm going to pass over some content that has been [previously elucidated in a prior lesson](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson3-taking-the-first-step.md), so you should probably look that over if you haven't already, or review it if you have.

### For this part of the lesson, you'll need:
1. Our `%todoreact` files including
      * /app/todoreact.hoon
      * /mar/todoreact/action.hoon
      * /sur/todoreact.hoon

Let's start by looking at the `/sur` file, which will mirror some of what we saw in the Earth app explored above:

### `%todoreact` `sur` file
Our `/sur` file is fairly straightforward:
```
|%
+$  action
  $%
  [%add-task task=@tU]
  [%remove-task id=@ud]
  [%mark-complete id=@ud]
  [%edit-task id=@ud label=@tU]
  ==
+$  tasks  (map id=@ud [label=@tU done=?])
--
```
In the action `mold`, we've created an action for each of the `poke` actions that we suggested above. We have a way to add, delete, toggle completenesss and edit our tasks. Then, and simply, we create a `type` for our data structure for `tasks`. The `tasks` type is a `(map id=@ud [label=@tU done?])` or a map of `id`s to `label`s and `done`-ness states. We're using a map instead of a simple array because we don't want to have to trawl through the array to make changes when they're being sent from the Earth app. Instead, we can always use the `id` of a given item to address that particular item and make changes. This simple structural change will help us on the urbit side of things, but it also creates some technical debt that we'll have to fill later - that of getting the array from the site into `map` form, and vice-versa.

Now, let's see how our `/app` file will handle the `action` and `tasks` structures to make the app work:

### `%todoreact` `app` file
Our `/app` file, like all `/app` files, will have 10 `arm`s.  As with our `%firststep` program, however, we're only really using 4 `arm`s: `++  on-init`, `++  on-save`, `++  on-load` and `++  on-poke`.  We'll go through these in order:

#### `++  on-init`
```
  ^-  (quip card _this)
  ~&  >  '%todoreact app is online'
  =.  state  [%0 `tasks:todoreact`~]
  `this
```
Our `on-init` `arm` does very little different from our last agent's `on-init` `arm`. The only real difference here is what our default `state` will be in the line ``[%0 `tasks:todoreact`~]``.  The `state` of our app is defined above, in the lines:
```
+$  state-zero
    $:  [%0 tasks=tasks:todoreact]
    ==
```
This `state` only stores one data structure. The structure has a `face` (or variable name) of `tasks` and a `type` of `tasks:todoreact`, or the `tasks` map we made in our `sur` file.

#### `++  on-save` and `++  on-load`
Our `on-save` and `on-load` arms differ very little from what we saw in `%firststep`.  Basically we're just packing and un-packing our `state` for reloading the app.  Since we only have one `state`, there's nothing very interesting happening here.

#### `++  on-poke`
Our `on-poke` arm is doing the vast majority of new work in our app.  Nonetheless, the structure is very similar to what we saw in `%firststep`:
<table>
<tr>
<td colspan="2">
Comparison of %firststep to %todoreact
</td>
</tr>
<tr>
<td>

`%firststep`
</td>
<td>

`%todoreact`
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
</td>
<td>
  
```
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
  ?+  mark  (on-poke:def mark vase)
      %todo-action  (poke-actions !<(action:todo vase))
  ==
  [cards this]
  ::
  ++  poke-actions
    |=  =action:todo
    ^-  (quip card _state)
    ?-  -.action
      %add-task
    =/  new-id=@ud
    ?~  tasks
      1
    +(-:(sort `(list @ud)`~(tap in ~(key by `(map id=@ud [task=@tU complete=?])`tasks)) gth))
    ~&  >  "Added task {<task.action>} at {<new-id>}"
    =.  state  state(tasks (~(put by tasks) new-id [+.action %.n]))
    `state
    ::
      %remove-task
    ?:  =(id.action 0)
      =.  state  state(tasks ~)
      `state
    ?.  (~(has by tasks) id.action)
      ~&  >>>  "No such task at ID {<id.action>}"
      `state
    =.  state  state(tasks (~(del by tasks) id.action))
    `state
    ::
      %mark-complete
    ?.  (~(has by tasks) id.action)
      ~&  >>>  "No such task at ID {<id.action>}"
      `state
    =/  task-text=@tU  label.+<:(~(get by tasks) id.action)
    =/  done-state=?  ?!  done.+>:(~(get by tasks) id.action)
    ~&  >  "Task {<task-text>} marked {<done-state>}"
    =.  state  state(tasks (~(put by tasks) id.action [task-text done-state]))
    `state
    ::
      %edit-task
    ~&  >  "Receiving facts {<id.action>} and {<label.action>}"
    =/  done-state=?  done.+>:(~(get by tasks) id.action)
    =.  state  state(tasks (~(put by tasks) id.action [label.action done-state]))
    `state
    ==
  --
```
</td>
</tr>
</table>

As we can see, things begin exactly the same for the two apps - we're taking in some `poke`, checking the `mark` to confirm it's of a type our app understands, and then passing the `vase` of the `poke` to an out-rigger `arm` (`++  poke-actions`) to be handled. Looking at `poke-action` you may notice that there's a strange disparity between this app and the prior in terms of how `poke` changes to `state` are handled.

<table>
  <tr>
    <td colspan="2">
      Spot the difference:
    </td>
  </tr>
  <tr>
    <td>
      %firststep
    </td>
    <td>
      %todoreact
    </td>
  </tr>
  <tr>
    <td>
      
```
++  poke-action
  |=  =action:firststep
  ^-  (quip card _state)
  ?>  =(-.action %test-action)
    ~&  >  "Replacing state value {<message:state>} with {<+.action>}"
  `state(message +.action)
```
  </td>
  <td>
  
  ```
++  poke-actions
  |=  =action:todo
  ^-  (quip card _state)
  ?-  -.action
    %add-task
  =/  new-id=@ud
  ?~  tasks
    1
  +(-:(sort `(list @ud)`~(tap in ~(key by `(map id=@ud [task=@tU complete=?])`tasks)) gth))
  ~&  >  "Added task {<task.action>} at {<new-id>}"
  =.  state  state(tasks (~(put by tasks) new-id [+.action %.n]))
  `state
```
  </td>
  </tr>
  </table>
      
In the `%firststep` file, we handle the `state` change using `` `state(<face> <changed value>) `` but in `%todoreact` we're using `=.  state  state(<face> <changed value>)` (we'll talk about how those values are being set momentarily, for each `poke`, but let's clear up this inconsistency first).  The reason we're doing this is we will eventually add a `quip card`s in addition to the `state` change which will send our updated `state` to our Earth app.  In order to do this, we need the `state` changed _before_ we create the `card`s we send to the Earth app.  This is just an eccentricity of how we're handling this - it could probably be handled differently, too, but all we're really doing is using the `=.` function (which changes a value for the evaluation of subsequent hoon) to change our `state` before creating our `(quip card _state)`.

Let's work through each action and see how those work:

##### `%add-task`
`%add-task` will be used to, as the name implies, add tasks.
```
  %add-task
=/  new-id=@ud
?~  tasks
  1
+(-:(sort `(list @ud)`~(tap in ~(key by `(map id=@ud [task=@tU complete=?])`tasks)) gth))
~&  >  "Added task {<task.action>} at {<new-id>}"
=.  state  state(tasks (~(put by tasks) new-id [+.action %.n]))
`state
```
It first creates a face called `new-id` who's value is determined by a conditional statement.  If the `tasks` face of our `state` is empty, we start at task `id` 1, otherwise we look to find the greatest current `id` value and increment it by one (in other words we always create our new task at the next positive integer `id` position).  The line that does this function is seemingly complex.  Let's work with it in `dojo` to better understand - enter the following:
```
>=a `(map id=@ud [label=@tU done=?])`(my :~([1 ['first task' %.n]] [2 ['second task' %.n]] [3 ['third task' %.n]]))
>a
{[p=id=1 q=[label='first task' done=%.n]] [p=id=2 q=[label='second task' done=%.n]] [p=id=3 q=[label='third task' done=%.n]]}
```

Now we have a face of `a` with a `map` just like our `type` `tasks` in our `/sur` file.  Let's take a peek at what [`key:by`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L1751) does - try:
```
> ~(key by a)
{id=1 id=2 id=3}
```

Ok, so we can get a [`set`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L1915) of all of the `key`s in the `map` we previously created. Next, we need to establish what [`tap:in`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L1410) does - try:
```
> =b ~(key by a)
```
First, to pin our last step to a face, making things cleaner, then:
```
> `(list @ud)`~(tap in b)
~[3 2 1]
```

Alright, we're making progress - we've now got a list of our `id`s, and we've moved the `id` `face` which will allow us to do further manipulation to find our greatest value.  Let's finish with taking a look at [`sort`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L739) - try:
```
=c `(list @ud)`~(tap in b)
```
Again, first, to store our prior work, then:
```
> +(-:(sort c gth))
4
```

And there we have it, we sort `c` by [`gth`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L2691) (greater than) as the criteria for sorting, then we increment it using the shorthand `+(<value to increment>)`.  We get 4, the next available `id`.  After that, all we do is use that as the value of `new-id` and then use [`put:by`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L1632) to add the new `label` with a `done`-ness state of `%.n` at the appropriate `id` `key` position in our `tasks` `map`.

##### `%remove-task`
`%remove-task` also does what it says on the tin, but with a special function to completely clear our state if the `id` of 0 is given as the task to remove.
```
%remove-task
  ?:  =(id.action 0)
    =.  state  state(tasks ~)
    `state
  ?.  (~(has by tasks) id.action)
    ~&  >>>  "No such task at ID {<id.action>}"
    `state
  =.  state  state(tasks (~(del by tasks) id.action))
  `state
```
This works by first checking to see if the `id` given in the `poke` is 0. If it is, then it sets the `tasks` face of the `state` to `~`, or null. 

If the `id` is not 0, then it checks to see (using [`has:by`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L1583) if the `id` given is a valid `key` in the current `tasks` `map`. If the `id` is not valid, we return the `state` unchanged but message the user in `dojo` indicating that there is `"No such task at ID {<id.action>}"`.  If the `id` _is_ valid, we use `del:by` to remove that item from `tasks` and update the `state`.
