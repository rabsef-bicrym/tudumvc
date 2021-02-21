::
::  testing react-hooks tudumvc
::
|%

+$  action
  $%
  [%add-task task=@tU]
  [%remove-task id=@ud]
  [%mark-complete id=@ud]
  [%edit-task id=@ud label=@tU]
  [%update-tasks =(list [done=? id=@ud label=@tU])]
  [%send-tasks =path]
  ==
+$  tasks  (map id=@ud [label=@tU done=?])
--