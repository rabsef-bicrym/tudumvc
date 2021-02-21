/-  firststep
/+  *server, default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero  [%0 message=cord]
::
+$  card  card:agent:gall
--
::
%-  agent:dbug
::
=|  state-zero
=*  state  -
^-  agent:gall
|_  =bowl:gall
::
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%firststep achieved'
  =.  state  [%0 'starting']
  `this
++  on-save
  ^-  vase 
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%firststep has recompiled'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
  ?+  mark  (on-poke:def mark vase)
      %firststep-action  (poke-action !<(action:firststep vase))
  ==
  [cards this]
  ::
  ++  poke-action
    |=  =action:firststep
    ^-  (quip card _state)
    ?>  =(-.action %test-action)
      ~&  >  "Replacing state value {<message:state>} with {<+.action>}"
      `state(message +.action)
  --
++  on-arvo   on-arvo:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--