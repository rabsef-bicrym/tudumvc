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
  ~&  "Your JSON object looks like {<jon>}"
  %-  action:tudumvc
  =<
  action
  |%
  ++  action
    [%add-task 'We did it, reddit!']
  --
  --
--