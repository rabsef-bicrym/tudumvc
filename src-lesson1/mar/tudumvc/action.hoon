::
::  tudumvc mar file
::
/-  tudumvc
=,  dejs:format
|_  act=action:tudumvc
++  grab
  |%
  ++  noun  action:tudumvc
  ++  json
    |=  jon=^json
    %-  action:tudumvc
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