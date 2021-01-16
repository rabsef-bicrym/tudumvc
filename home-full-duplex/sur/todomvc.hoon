::
::  todoMVC sur file
::
|%
::  Available poke actions follow
::
+$  action
  $%
  ::  This is just a test action to show the functionality.
  ::  It lets us change the message stored in our app's state, by providing a new message (msg).
  ::
  [%test-action msg=tape]
  [%list-tasks completed=?]
  [%pull-task id=@ud]
  [%add-task task=@tU]
  [%remove-task id=@ud]
  [%mark-complete id=@ud]
  [%send-tasks =path]
  [%update-tasks =(list [task=@tU complete=? id=@ud])]
  ==
::
::  We're adding a type here to handle a map of tasks
::
+$  tasks  (map id=@ud [task=@tU complete=?])
--