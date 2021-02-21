::
::  Working on Data Model/Transmission Version - ToDos below:
::  ?. Make all actions cause a send on the path (instead, send on load of page, or if page is being watched)
::     (is this really the best way to handle this?)
::  2. Diagnose why path subscription sometimes errors, sometimes works
::  X. Work with javascript magic to get incoming data into replacement format for expected data
::  X. Make all FE actions send down path (javascript side)
::  5. Write /mar file integration to dejs incoming actions (next)
::  >. Rather than deduplicating on the java side, determine if there is a 
::     completed version of the task - if so, keep only the complete version (see below)
::  >. Deduplication is not working on java side (still needs some looking at)
::
/-  todomvc
/+  *server, default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
        state-one
    ==
+$  state-one  [%1 =tasks:todomvc message=tape]
+$  state-zero
    $:  [%0 message=tape]
    ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-one
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this   .
    def    ~(. (default-agent this %|) bowl)
    hc  ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  ~&  >  '%todoMVC app is online'
  =/  todomvc-basic  [%file-server-action !>([%serve-dir /'~todomvc-basic' /app/todomvc/basic %.y %.n])]
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
  =/  state-ver  !<(versioned-state incoming-state)
  ?-  -.state-ver
      %1
    `this(state state-ver)
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
    ::
      %json
    ~&  >>  !<(json vase)
    `state
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
     
      %send-tasks
    ?~  +.action
      ~&  >  "Include path in poke"
      `state
    ~&  >  "Sending fact {<(tasks-to-json:hc tasks.state)>}"
    :_  state
    ~[[%give %fact ~[path.action] [%json !>((json (tasks-to-json:hc tasks.state)))]]]
      %update-tasks
    ~&  >  "Receiving fact {<+.action>}"
    `state(tasks (process-tasks:hc +.action))
    ==
--
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
    [%mytasks ~]
  ~&  >  "Browser Subscribed to Path %mytasks"
  :_  this
  ~[[%give %fact ~[path] [%json !>((json (tasks-to-json:hc tasks.state)))]]]
  ==
++  on-arvo   on-arvo:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
|_  bol=bowl:gall
++  comp-lst
  |=  [in=[di=@ud [tsk=@tU stat=?]] out=(list @tU)]
  ^-  (list @tU)
  ?:  stat.in
    [tsk.in out]
    out
++  inc-lst
  |=  [in=[di=@ud [tsk=@tU stat=?]] out=(list @tU)]
  ^-  (list @tU)
  ?.  stat.in
    [tsk.in out]
    out
::  This next arm has been added to allow us to "JSON-ify" our state data
::  Further description of what's going on here will be in the lesson
:: 
++  tasks-to-json
  |=  stat=tasks:todomvc
  |^
  ^-  json
  =/  tasklist=(list [id=@ud task=@tu complete=?])  ~(tap by stat)
  =/  objs=(set [p=@tU q=json])  (my (roll tasklist object-maker))
  [%o objs]
  ++  object-maker
    |=  [in=[di=@ud [tsk=@tu stat=?]] out=(list [p=@tU q=json])]
    :-
    :-  (scot %ud di.in)
    %-  pairs:enjs:format
    :~  ['title' [%s tsk.in]]
        ['completed' [%b stat.in]]
        ['id' [%s (scot %ud di.in)]]
    ==
    out
  --
++  process-tasks
  |=  from-web=(list [task=@tU complete=? id=@ud])
  |^
  ^-  tasks:todomvc
  (roll from-web compare-list)
  ++  compare-list
  |:  [in=`[task=@tU complete=? id=@ud]`['' %.n 0] out=`tasks:todomvc`tasks]
  ?~  (~(get by out) id.in)
    (~(put by out) [id=id.in [task=task.in complete=complete.in]])
  =/  current-task=[id=@ud [task=@tU complete=?]]  [id.in (~(got by out) id.in)]
  ?:  &(=(complete.current-task %.n) =(complete.in %.y))
    (~(put by out) [id=id.in [task=task.in complete=complete.in]])
  out
  --
  :: 
--