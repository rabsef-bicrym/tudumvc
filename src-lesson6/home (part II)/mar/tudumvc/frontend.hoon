::
::  tudumvc-frontend mar file
::
/-  tudumvc
=,  dejs:format
|_  front=frontend:tudumvc
++  grad  %noun
++  grow
  |%
  ++  noun  front
  --
++  grab
  |%
  ++  noun  frontend:tudumvc
  ++  json
    |=  jon=^json
    %-  frontend:tudumvc
    =<
    (front-end jon)
    |%
    ++  front-end
      %-  of
      :~  [%add-task (ot :~(['ship' (se %p)] ['label' so]))]
          [%remove-task (ot :~(['ship' (se %p)] ['id' ni]))]
          [%mark-complete (ot :~(['ship' (se %p)] ['id' ni]))]
          [%edit-task (ot :~(['ship' (se %p)] ['id' ni] ['label' so]))]
      ==
    --
  --
--