/-  todomvc
/+  *server, default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  [%0 message=tape]
    ==
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
  ~&  >  '%todoMVC app is online'
  =/  todomvc-basic  [%file-server-action !>([%serve-dir /'~todomvc-basic' /app/todomvc/basic %.y %.n])]
   =.  state  [%0 "starting"]
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke todomvc-basic]
  ==
++  on-save
  ^-  vase 
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%todoMVC has recompiled'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
  ?+  mark  (on-poke:def mark vase)
      %todomvc-action  (poke-action !<(action:todomvc vase))
  ==
  [cards this]
  ::
  ++  poke-action
    |=  =action:todomvc
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