::
::  todoMVC mar file
::
/-  todomvc
=,  dejs:format
|_  act=action:todomvc
++  grab
  |%
  ++  noun  action:todomvc
  ++  json
    |=  jon=^json
    %-  action:todomvc
    =<  
    (action jon)
    |%
    ++  action
      %-  of
      :~  [%update-tasks task-update]
      ==
    ++  task-update
      %-  ar
      %-  ot
      :~  [%title so]
          [%completed bo]
          [%id ni]
      ==
    --
  --
--