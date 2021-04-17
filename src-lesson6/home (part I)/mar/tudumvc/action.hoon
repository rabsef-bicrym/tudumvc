::
::  tudumvc-action mar file
::
/-  tudumvc
=,  dejs:format
|_  act=action:tudumvc
++  grad  %noun
++  grow
  |%
  ++  noun  act
  --
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
      :~  [%add-task so]
          [%remove-task ni]
          [%mark-complete ni]
          [%edit-task (ot :~(['id' ni] ['label' so]))]
          [%sub (se %p)]
      ==
    --
  --
--