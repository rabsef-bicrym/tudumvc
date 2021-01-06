/-  todomvc
/+  *server, default-agent, dbug
|%
::  Here we need to add the new state version (state-one)
::
+$  versioned-state
    $%  state-zero
        state-one
    ==
::  Here, we define the state-one content - note that tasks is defined in our sur file
::
+$  state-one  [%1 =tasks:todomvc message=tape]
+$  state-zero
    $:  [%0 message=tape]
    ==
::
+$  card  card:agent:gall
--
::
%-  agent:dbug
::
=|  state-one
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
::  Add a helper core and its alias (hc)
+*  this   .
    def    ~(. (default-agent this %|) bowl)
    hc  ~(. +> bowl)
::
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%todoMVC app is online'
  =/  todomvc-basic  [%file-server-action !>([%serve-dir /'~todomvc-basic' /app/todomvc/basic %.y %.n])]
  ::  Changing this to start new users with state-one and a blank list of tasks
   =.  state  [%1 ~ "starting"]
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke todomvc-basic]
  ==
++  on-save
  ^-  vase 
  !>(state)
++  on-load
  |=  incoming-state=vase
  ^-  (quip card _this)
  ~&  >  '%todoMVC has recompiled'
  ::  Creating a face to give us our incoming state in our versioned-state type
  :: 
  =/  state-ver  !<(versioned-state incoming-state)
  ::  Checking the head of our versioned state cell to determine what # it is
  ?-  -.state-ver
      ::  If our state head is %1, we're good to go - return the state as it was saved
      ::
      %1
    `this(state state-ver)
      ::  If we are still in the old state, however (%0), then bunt our map (clear all existing tasks)
      ::  and preserve the message from the prior state version
      ::
      %0
    `this(state [%1 ~ message.state-ver])
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
  ?+  mark  (on-poke:def mark vase)
      %todomvc-action  (poke-actions !<(action:todomvc vase))
  ==
  [cards this]
  ::
  ++  poke-actions
    |=  =action:todomvc
    ^-  (quip card _state)
    ?-  -.action
      %test-action
    ~&  >  "Replacing state value {<message:state>} with {<+.action>}"
    `state(message +.action)
      %add-task
    =/  new-id=@ud
    ?~  tasks
      1
    +(-:(sort `(list @ud)`~(tap in ~(key by `(map id=@ud [task=@tU complete=?])`tasks)) gth))
    ~&  >  "Added task {<+.action>} at {<new-id>}"
    `state(tasks (~(put by tasks) new-id [+.action %.n]))
      %remove-task
    ?.  (~(has by tasks) +.action)
      ~&  >>>  "No such task at ID {<+.action>}"
      `state
    ~&  >>  "Removing task {<(~(get by tasks) +.action)>}"
    `state(tasks (~(del by tasks) +.action))
      %pull-task
    ?.  (~(has by tasks) +.action)
      ~&  >>>  "No such task at ID {<+.action>}"
      `state
    ~&  >  "Task: {<(~(get by tasks) +.action)>}"
    `state
      %list-tasks
    =/  task-list=(list [id=@ud [task=@tU complete=?]])  ~(tap by tasks)
    ?:  +.action
      ~&  >  "Completed tasks: {<(roll task-list comp-lst.hc)>}"
      `state
    ~&  >  "Incomplete tasks: {<(roll task-list inc-lst.hc)>}"
    `state
      %mark-complete
    ?.  (~(has by tasks) +.action)
      ~&  >>>  "No such task at ID {<+.action>}"
      `state
    ~&  >  "Task {<task:+<:(~(get by tasks) +.action)>} marked complete"
    =/  task-text=@tU  task.+<:(~(get by tasks) +.action)
    `state(tasks (~(put by tasks) +.action [task-text %.y]))
    ==
--
++  on-arvo   on-arvo:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
|_  bol=bowl:gall
::  This arm will handle all of our todomvc cli actions as described in our sur file
::
++  comp-lst
  |=  [in=[di=@ud [task=@tU stat=?]] out=(list @tU)]
  ^-  (list @tU)
  ?:  stat.in
    [task.in out]
    out
++  inc-lst
  |=  [in=[di=@ud [task=@tU stat=?]] out=(list @tU)]
  ^-  (list @tU)
  ?.  stat.in
    [task.in out]
    out
--