/-  todoreact
/+  *server, default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  [%0 tasks=tasks:todoreact]
    ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-zero
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this   .
    def    ~(. (default-agent this %|) bowl)
    hc  ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  ~&  >  '%todoreact app is online'
  =/  todo-react  [%file-server-action !>([%serve-dir /'~todoreact' /app/todoreact %.y %.n])]
  =.  state  [%0 `tasks:todoreact`~]
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke todo-react]
  ==
++  on-save
  ^-  vase 
  !>(state)
++  on-load
  |=  incoming-state=vase
  ^-  (quip card _this)
  ~&  >  '%todoReact has recompiled'
  `this(state !<(versioned-state incoming-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
  ?+  mark  (on-poke:def mark vase)
      %todoreact-action  (poke-actions !<(action:todoreact vase))
    ::
      %json
    ~&  >>  !<(json vase)
    `state
  ==
  [cards this]
  ::
  ++  poke-actions
    |=  =action:todoreact
    ^-  (quip card _state)
    ?-  -.action
      %add-task
    =/  new-id=@ud
    ?~  tasks
      1
    +(-:(sort `(list @ud)`~(tap in ~(key by `(map id=@ud [task=@tU complete=?])`tasks)) gth))
    ~&  >  "Added task {<task.action>} at {<new-id>}"
    =.  state  state(tasks (~(put by tasks) new-id [+.action %.n]))
    :_  state
    ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc tasks)))]]]
    ::
      %remove-task
    ?:  =(id.action 0)
      =.  state  state(tasks ~)
      :_  state
      ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc tasks)))]]]
    ?.  (~(has by tasks) id.action)
      ~&  >>>  "No such task at ID {<id.action>}"
      `state
    =.  state  state(tasks (~(del by tasks) id.action))
    :_  state
    ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc tasks)))]]]
    ::
      %mark-complete
    ?.  (~(has by tasks) id.action)
      ~&  >>>  "No such task at ID {<id.action>}"
      `state
    =/  task-text=@tU  label.+<:(~(get by tasks) id.action)
    =/  done-state=?  ?!  done.+>:(~(get by tasks) id.action)
    ~&  >  "Task {<task-text>} marked {<done-state>}"
    =.  state  state(tasks (~(put by tasks) id.action [task-text done-state]))
    :_  state
    ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc tasks)))]]]
    ::
      %edit-task
    ~&  >  "Receiving facts {<id.action>} and {<label.action>}"
    =/  done-state=?  done.+>:(~(get by tasks) id.action)
    =.  state  state(tasks (~(put by tasks) id.action [label.action done-state]))
    :_  state
    ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc tasks)))]]]
    ::
      %update-tasks
    ~&  >  "Receiving fact {<+.action>}"
    `state(tasks (process-tasks:hc +.action))
    ::
      %send-tasks
    ~&  >  "Sending facts {<tasks>}"
    :_  state
    ~[[%give %fact ~[path.action] [%json !>((json (tasks-json:hc tasks)))]]]
    ==
--
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
    [%mytasks ~]
  :_  this
  ~[[%give %fact ~[path] [%json !>((json (tasks-json:hc tasks)))]]]
  ==
++  on-arvo   on-arvo:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
|_  bol=bowl:gall
++  process-tasks
  |=  from-web=(list [done=? id=@ud label=@tU])
  |^
  ^-  tasks:todoreact
  (roll from-web compare-list)
  ++  compare-list
  |:  [in=`[done=? id=@ud label=@tU]`[%.n 0 ''] out=`tasks:todoreact`tasks]
  (~(put by out) [id=id.in [label=label.in done=done.in]])
  --
++  tasks-json
  |=  stat=tasks:todoreact
  |^
  ^-  json
  =/  tasklist=(list [id=@ud label=@tU done=?])  ~(tap by stat)
  =/  objs=(list json)  (roll tasklist object-maker)
  [%a objs]
  ++  object-maker
  |=  [in=[id=@ud label=@tU done=?] out=(list json)]
  ^-  (list json)
  :-
  %-  pairs:enjs:format
    :~  ['done' [%b done.in]]
        ['id' [%s (scot %ud id.in)]]
        ['label' [%s label.in]]
    ==
  out
  --
--