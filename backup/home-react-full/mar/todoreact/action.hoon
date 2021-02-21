::
::  todoMVC mar file
::
/-  todoreact
=,  dejs:format
|_  act=action:todoreact
++  grab
  |%
  ++  noun  action:todoreact
  ++  json
    |=  jon=^json
    %-  action:todoreact
    =<
    (action jon)
    |%
    ++  action
      %-  of
      :~  [%update-tasks task-update]
          [%add-task so]
          [%remove-task ni]
          [%mark-complete ni]
          [%edit-task (ot :~(['id' ni] ['label' so]))]
      ==
    ++  task-update
      %-  ar
      %-  ot
      :~  :-  %done   bo
          :-  %id     ni
          :-  %label  so
      ==
    --
  --
--