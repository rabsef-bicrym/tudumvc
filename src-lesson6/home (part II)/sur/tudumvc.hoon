::
::  tudumvc sur file
::
|%
:: We've added %remove-task, %mark-complete, %edit-task as new actions
::
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

:: Creates a structure for front end usage that will specify the ship to poke on 
:: each action, allowing our host ship to then send cards to each recipient ship
:: 
+$  frontend
  $%
    [%add-task =ship label=@tU]
    [%remove-task =ship id=@ud]
    [%mark-complete =ship id=@ud]
    [%edit-task =ship id=@ud label=@tU]
  ==
:: Creates a structure called tasks that is a (map id=@ud [label=@tU done=?])
:: In other words a map of unique IDs to a cell of `cord` labels and boolean done-ness
::
+$  tasks  (map id=@ud [label=@tU done=?])
+$  shared-tasks  (map owner=ship task-list=tasks)
+$  editors  [requested=(set ship) approved=(set ship) denied=(set ship)]
--