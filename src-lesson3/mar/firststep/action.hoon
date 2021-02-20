::
::  firstsep mar file
::
/-  firststep
=,  dejs:format
|_  act=action:firststep
++  grab
  |%
  ++  noun  action:firststep
  ++  json
    |=  jon=^json
    ;;  action:firststep
    ~&  >  (so jon)
    [%test-action (so jon)]
  --
--