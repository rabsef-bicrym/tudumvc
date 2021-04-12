# Things Tudu and People TuSee
In this lesson, we're going to add networking to our app. You'll be able to subscribe to your friends or coworkers task lists and even, if they permit you, edit those lists (with the same level of control you have over your own lists). As a proprietor of a task list, you'll also be able to select, of those people who subscribe to your task list, who can edit and who is precluded from editing but may still look. You can even kick them from their subscription, if you're really annoyed.

This lesson includes a lot of changes but few of them are structural and most of them are just iterations on themes of prior lessons - we hope you find it fairly easy to follow.

Let's get after it then.

## Learning Checklist
* How to use wires and paths to send and receive data.
* How to add new mark files to your program for various purposes.

## Goals
* Upgrade our Earth app to handle multiple todo lists, including selecting between various lists and subscribing to additional lists.
* Add new pokes to our agent that allow for specification of the ship to which those pokes should apply.
    * This is how we'll handle pokes to remote ships from our Earth app.
    * We'll also see how you can use the same pokes you've already written to poke remote ships through the dojo.
* Add new pokes to handle receipt of new tasks data from ships you subscribe to when they make changes.

## Prerequisites
* Our Earth web app as modified in [Lesson 5 - Establishing Uplink](./lesson5-establishing-uplink.md).
    * A copy of our current Earth web app can be foudn in [src-lesson6](./src-lesson6/todomvc-start).
* A new Fake Ship (probably ~zod) with whom we can share task!
* **NOTE:** We've included a copy of all the files you need for this lesson _in their completed form_ in the folder [src-lesson6](./src-lesson6), but you should try doing this on your own instead of just copying our files in. No cheating!

## The Lesson
We're going to start by updating our state for shared todo lists and adding to the state a tuple of sets of editors; requested-editors, approved-editors and denied-editors.

Begin by launching your Fake Ship and a new Fake Ship (of your choice, we'll assume ~zod) with the Lesson 5 version of tudumvc installed and started. These two ships should be running on the same machine so they can discover eachother (fake ships are not networked _outside_ a given machine, but on the same machine they are inter-discoverable!)

You'll also want to have two terminals running to copy files from a central editing folder to _both_ of your fake ships simultaneously, to allow you to update both of them quickly.

### Updating the State
First, we're going to update the sur file to have two new types - `shared-tasks` and `editors`:

#### Adding Types
The changes we're going to make to the type system are fairly straightforward:
<table>
<tr>
<td>
:: initial sur file version
</td>
<td>
:: new sur file version
</td>
</tr>
<tr>
<td>

```
+$  tasks  (map id=@ud [label=@tU done=?])
```
</td>
<td>

```
+$  tasks  (map id=@ud [label=@tU done=?])
+$  shared-tasks  (map owner=ship task-list=tasks)
+$  editors  [requested=(set ship) approved=(set ship) denied=(set ship)]
```
</td>
</tr>
</table>

As you can see, `shared-tasks` is simply a map of ships to our prior type (`tasks`).

Editors is slightly more complex, but it works exactly like `+cors-registry` works. We're making a tuple of `requested` `approved` and `denied` editors (the names are descriptive of their capacities - only `approved` editors can edit your task lists), each of which are `(set ship)`s. A [set](https://urbit.org/docs/hoon/reference/stdlib/2o/#set) is just a mold that creates a list-like structure that _only_ allows for unique items to be added. By using `(set ship)` instead of `(list ship)` or some other structure, we can: (1) more easily work on our `(set ship)`s using [set logic](https://urbit.org/docs/hoon/reference/stdlib/2h/) and (2) ensure that nobody gets listed twice in any one category. We'll also, later, build logic to make sure that any action taken on an editor removes them from their current category and places them in another category to make sure if you `%kick` someone from their subscription, they can't just re-subscribe and start editing your tasks.

Next, let's add some pokes to our action type in the same sur file to accommodate subscription actions:

#### Adding to Our action Type
Thinking through what we'll need here, we should prepare for the following actions:
* Subscribing to a ship's todo list.
    * Will need to specify a ship to which we will subscribe.
* Unsubscribing to a ship's todo list.
    * Will need to specify a ship to which we will subscribe.
* `%kick`ing a subscriber (or, forcefully removing someone who subscribes to you).
    * Will need to specify a ship to which we will subscribe.
    * Will also need to specify a path to kick them from - we'll talk about paths more later, but these are basically the data feed on which they're receiving your todo list. Theoretically, since we only have one data feed, [we could simply remove them from all possible paths](https://github.com/timlucmiptev/gall-guide/blob/master/poke.md#example-4-kicking-a-subscriber-from-the-host), but we'll still allow our poke to specify one or more paths, as a best practice.
* Allowing or denying a request from a subscriber to edit your todo list.
    * Will need to specify a `(list ship)`s that you want to edit.
    * Will need to specify a status for those ships (`%approve` or `%deny`)

<table>
<tr>
<td>
:: initial sur file version
</td>
<td>
:: new sur file version
</td>
</tr>
<tr>
<td>

```
+$  action
  $%
  [%add-task task=@tU]
  [%remove-task id=@ud]
  [%mark-complete id=@ud]
  [%edit-task id=@ud label=@tU]
  ==
```
</td>
<td>

```
+$  action
  $%
    [%add-task label=@tU]
    [%remove-task id=@ud]
    [%mark-complete id=@ud]
    [%edit-task id=@ud label=@tU]
    :: New action types for handling subscriptions on urbit side
    ::
    [%sub partner=ship]
    [%unsub partner=ship]
    [%force-remove paths=(list path) partner=ship]
    [%edit partners=(list ship) status=?(%approve %deny)]
  ==
```
</td>
</tr>
</table>

These should all make relative sense at this point. If, for instance, you want to subscribe to a partner, you could just key into dojo `:tudumvc &tudumvc-action [%sub ~zod]`. Similarly, you might `:tudumvc &tudumvc-action [%unsub ~zod]` to cancel that subscription later. We'll later write handlers in the main agent file to handle all this, so don't try it just yet. Nonetheless, its use should be fairly clear.

Having subscribed to someone, we are going to need some way of: (1) receiving their full list of tasks when we first subscribe and (2) receiving incremental updates as their todo list changes over time. It would be fairly inconvenient and expensive to receive the whole list each time, so we'll take each one of those updates almost exactly like we take updates to our own list:

#### Creating an updates Type
We're going to add a type called `updates` to our sur file. It's going to fairly closely mirror our original `action` type with the addition of one tagged union called `%full-send` which will send _all_ tasks to a subscriber when they first subscribe. The primary difference here is all of our incremental updates will come with an `id=@ud` identifier, just to make sure that we are updating our partner's todo list exactly as they are (to avoid `id` dis-union):

<table>
<tr>
<td>
:: adding update type to our sur file (wherever)
</td>
</tr>
<td>

```
:: Here we're creating a structure arm called updates and we're re-creating the
:: task actions that might come in as updates from the ships to which we subscribe
::
+$  updates
  $%
    [%task-add id=@ud label=@tU]
    [%task-remove id=@ud]
    [%task-complete id=@ud done=?]
    [%task-edit id=@ud label=@tU]
    [%full-send =tasks]
  ==
```
</td>
</tr>
</table>

You might also note that we're not sending the source of the update (the ship name). This is because %gall actually handles that for us. Each incoming poke to our ship will be identified by a `src.bowl` which will be a ship - we can use that to easily pinpoint who's list is being updated by what updates. Only the owner of a given list will ever send us these updates - this further ensures parity amongst all subscribers/editors/the original host in terms of the status of the tasks and their individual `id`s.

**NOTE:** These poke structures could probably be added to `action` just as easily as separated out into their own type, but we're going to use separate types for clarity. When we get to the Earth web updates, we're going to do the same thing, again, for clarity.



## Homework

## Exercises
* Beautify the display of tuduMVC in browser by cleaning up my pitiable implementation of the drop-down menu and the input box.
    * See if you can add ship name validation to the subscription box
* Add to the data being sent to the site a list of people requesting edit access to your task list, and a method whereby you can provide them edit access or deny their request
* Add an approval list for people requesting access to your todo list so not just anyone can subscribe.

## Summary and Addenda