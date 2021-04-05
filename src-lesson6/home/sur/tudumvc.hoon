::
::  tudumvc sur file
::
|%
:: We've added %remove-task, %mark-complete, %edit-task as new actions
::
+$  action
  $%
  [%add-task task=@tU]
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
      [%task-add id=@ud task=@tU]
      [%task-remove id=@ud]
      [%task-complete id=@ud done=?]
      [%task-edit id=@ud task=@tU]
      [%full-send =tasks]
  ==

:: Creates a structure called tasks that is a (map id=@ud [label=@tU done=?])
:: In other words a map of unique IDs to a cell of `cord` labels and boolean done-ness
::
+$  tasks  (map id=@ud [label=@tU done=?])
+$  shared-tasks  (map owner=ship task-list=tasks)
+$  editors  [requested=(set ship) approved=(set ship) denied=(set ship)]
--