/-  tudumvc
/+  *server, default-agent, dbug
|%
+$  versioned-state
    $%  state-two
        state-one
        state-zero
    ==
+$  state-zero  [%0 task=@tU]
+$  state-one   [%1 tasks=tasks:tudumvc]
+$  state-two   [%2 shared=shared-tasks:tudumvc editors=editors:tudumvc]
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-two
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this   .
    def    ~(. (default-agent this %|) bowl)
    hc  ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  ~&  >  '%tudumvc app is online'
  =/  todo-react  [%file-server-action !>([%serve-dir /'~tudumvc' /app/tudumvc %.n %.n])]
  =.  state  [%2 `shared-tasks:tudumvc`(~(put by shared) our.bowl (my :~([1 ['example task' %.n]]))) [~ ~ ~]]
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke todo-react]
  ==
++  on-save
  ^-  vase 
  !>(state)
++  on-load
  |=  incoming-state=vase
  ^-  (quip card _this)
  ~&  >  '%tudumvc has recompiled'
  =/  state-ver  !<(versioned-state incoming-state)
  ?-  -.state-ver
    %2
  `this(state state-ver)
    %1
  `this(state [%2 `shared-tasks:tudumvc`(~(put by shared) our.bowl tasks.state-ver) [~ ~ ~]])
    %0
  `this(state [%2 `shared-tasks:tudumvc`(~(put by shared) our.bowl (my :~([1 [task.state-ver %.n]]))) [~ ~ ~]])
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
  ?+  mark  (on-poke:def mark vase)
      %tudumvc-action    (poke-actions !<(action:tudumvc vase))
      %tudumvc-frontend  (frontend-actions !<(frontend:tudumvc vase))
  ==
  [cards this]
  ::
  ++  poke-actions
    |=  =action:tudumvc
    ^-  (quip card _state)
    =^  cards  state
    ?-  -.action
        %add-task
      ?>  |((team:title our.bowl src.bowl) (~(has in approved.editors) src.bowl))
      (add-task:hc our.bowl label.action)
        %remove-task
      ?>  |((team:title our.bowl src.bowl) (~(has in approved.editors) src.bowl))
      (remove-task:hc our.bowl id.action)
        %mark-complete
      ?>  |((team:title our.bowl src.bowl) (~(has in approved.editors) src.bowl))
      (mark-complete:hc our.bowl id.action)
        %edit-task
      ?>  |((team:title our.bowl src.bowl) (~(has in approved.editors) src.bowl))
      (edit-task:hc our.bowl id.action label.action)
        %sub
      (sub:hc partner.action)
        %unsub
      (unsub:hc partner.action)
        %force-remove
      ?>  (team:title our.bowl src.bowl)
      (force-remove:hc ~ partner.action)
        %edit
      ?>  (team:title our.bowl src.bowl)
      (edit:hc partners.action status.action)
    ==
    [cards state]
  ++  frontend-actions
    |=  =frontend:tudumvc
    ^-  (quip card _state)
    =^  cards  state
    ?-  -.frontend
        %add-task
      ?>  (team:title our.bowl src.bowl)
      (add-task:hc ship.frontend label.frontend)
        %remove-task
      ?>  (team:title our.bowl src.bowl)
      (remove-task:hc ship.frontend id.frontend)
        %mark-complete
      ?>  (team:title our.bowl src.bowl)
      (mark-complete:hc ship.frontend id.frontend)
        %edit-task
      ?>  (team:title our.bowl src.bowl)
      (edit-task:hc ship.frontend id.frontend label.frontend)
    ==
    [cards state]
  --
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  (on-peek:def path)
    [%x %task ~]  ``noun+!>(task)
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  =/  my-tasks=tasks:tudumvc  (~(got by shared) our.bowl)
  ?+  -.path  (on-watch:def path)
      %mytasks
    :_  this
    ~[[%give %fact ~ [%json !>((json (tasks-json:hc shared)))]]]
      %sub-tasks
    =.  requested.editors  (~(gas in requested.editors) ~[src.bowl])
    :_  this
    ~[[%give %fact ~ [%tudumvc-update !>((updates:tudumvc %full-send my-tasks))]]]
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  |^
  ?+  -.sign  (on-agent:def wire sign)
      %fact
    =/  update-action=updates:tudumvc  !<(updates:tudumvc q.cage.sign)
    =^  cards  this
    ?-  -.update-action
        %full-send
      ~&  >  "Receiving {<src.bowl>}'s task list"
      =.  shared  (~(put by shared) src.bowl tasks.update-action)
      :_  this
      ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc shared)))]]]
        %task-add
      ~&  >  "Receiving task {<label.update-action>} from {<src.bowl>}'s list"
      (partner-add id.update-action label.update-action src.bowl)
        %task-remove
      ~&  >  "Removing task {<id.update-action>} from {<src.bowl>}'s list"
      (partner-remove id.update-action src.bowl)
        %task-complete
      ~&  >  "Marking {<src.bowl>}'s task {<id.update-action>} as done: {<done.update-action>}"
      (partner-complete id.update-action done.update-action src.bowl)
        %task-edit
      ~&  >  "Editing {<src.bowl>}'s task {<id.update-action>} to read {<label.update-action>}"
      (partner-edit id.update-action label.update-action src.bowl)
    ==
    [cards this]
      %kick
    ~&  >  "{<src.bowl>} gave %kick - removing shared list"
    =.  shared  (~(del by shared) src.bowl)
    `this
  ==
  ++  partner-add
    |=  [id=@ud task=@tU =ship]
    =/  partner-list=tasks:tudumvc  (~(got by shared) ship)
    =.  shared  (~(put by shared) ship (~(put by partner-list) id [task %.n]))
    :_  this
    ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc shared)))]]]
  ++  partner-remove
    |=  [id=@ud =ship]
    =/  partner-list=tasks:tudumvc  (~(got by shared) ship)
    =.  shared  (~(put by shared) ship (~(del by partner-list) id))
    :_  this
    ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc shared)))]]]
  ++  partner-complete
    |=  [id=@ud done=? =ship]
    =/  partner-list=tasks:tudumvc  (~(got by shared) ship)
    =/  task=@tU  label:(~(got by partner-list) id)
    =.  shared  (~(put by shared) ship (~(put by partner-list) id [task done]))
    :_  this
    ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc shared)))]]]
  ++  partner-edit
    |=  [id=@ud task=@tU =ship]
    =/  partner-list=tasks:tudumvc  (~(got by shared) ship)
    =/  done=?  done:(~(got by partner-list) id)
    =.  shared  (~(put by shared) ship (~(put by partner-list) id [task done]))
    :_  this
    ~[[%give %fact ~[/mytasks] [%json !>((json (tasks-json:hc shared)))]]]
  --
++  on-leave
  |=  =path
  ^-  (quip card _this)
  ~&  >>  "{<src.bowl>} has left the chat"
  =.  editors  [(~(dif in requested.editors) (sy ~[src.bowl])) (~(dif in approved.editors) (sy ~[src.bowl])) (~(dif in denied.editors) (sy ~[src.bowl]))]
  `this
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::
|_  bol=bowl:gall
++  tasks-json
  |=  stat=shared-tasks:tudumvc
  |^
  ^-  json
  =/  shared-tasks=(list [partner=ship tasks=tasks:tudumvc])  ~(tap by stat)
  =/  objs=(list json)  (roll shared-tasks partner-handler)
  [%a objs]
  ++  partner-handler
    |=  [in=[partner=ship tasks=tasks:tudumvc] out=(list json)]
    ^-  (list json)
    =/  partners-tasks=(list [id=@ud label=@tU done=?])  ~(tap by tasks.in)
    =/  objs=(list json)  (roll partners-tasks object-maker)
    :-
    %-  pairs:enjs:format
      :~  [`@tU`(scot %p partner.in) [%a objs]]  ==
    out
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
++  add-task
  |=  [=ship label=@tu]
  ?.  (team:title our.bol ship)
    :_  state
    ~[[%pass /send-poke %agent [ship %tudumvc] %poke %tudumvc-action !>([%add-task label])]]
  =/  task-map=tasks:tudumvc  (~(got by shared) our.bol)
  =/  new-id=@ud
  ?~  task-map
    1
  +(-:`(list @ud)`(sort ~(tap in `(set id=@ud)`~(key by `tasks:tudumvc`task-map)) gth))
  ~&  >  "Added task {<label>} at id {<new-id>}"
  =.  state  state(shared (~(put by shared) our.bol (~(put by task-map) new-id [label %.n])))
  :_  state
  :~  [%give %fact ~[/sub-tasks] [%tudumvc-update !>((updates:tudumvc %task-add new-id label))]]
      [%give %fact ~[/mytasks] [%json !>((json (tasks-json shared)))]]
  ==
++  remove-task
  |=  [=ship id=@ud]
  ?.  (team:title our.bol ship)
    :_  state
    ~[[%pass /send-poke %agent [ship %tudumvc] %poke %tudumvc-action !>([%remove-task id])]]
  ?:  =(id 0)
    =.  state  state(shared (~(put by shared) our.bol ~))
    ~&  >  "I'm here"
    :_  state
    :~  [%give %fact ~[/sub-tasks] [%tudumvc-update !>((updates:tudumvc %full-send ~))]]
        [%give %fact ~[/mytasks] [%json !>((json (tasks-json shared)))]]
    ==
  =/  task-map=tasks:tudumvc  (~(got by shared) our.bol)
  ?.  (~(has by task-map) id)
    ~&  >>>  "No task at id {<id>}"
    `state
  ~&  >  "Removing task at id {<id>} from your tasks"
  =.  state  state(shared (~(put by shared) our.bol (~(del by task-map) id)))
  :_  state
  :~  [%give %fact ~[/sub-tasks] [%tudumvc-update !>((updates:tudumvc %task-remove id))]]
      [%give %fact ~[/mytasks] [%json !>((json (tasks-json shared)))]]
  ==
++  mark-complete
  |=  [=ship id=@ud]
  ?.  (team:title our.bol ship)
    :_  state
    ~[[%pass /send-poke %agent [ship %tudumvc] %poke %tudumvc-action !>([%mark-complete id])]]
  =/  task-map=tasks:tudumvc  (~(got by shared) our.bol)
  ?.  (~(has by task-map) id)
    ~&  >>>  "No task at id {<id>}"
    `state
  =/  task-text=@tU  label.+<:(~(get by task-map) id)
  =/  done-state=?  ?!  done.+>:(~(get by task-map) id)
  =.  state  state(shared (~(put by shared) our.bol (~(put by task-map) id [task-text done-state])))
  ~&  >  "Task {<task-text>} marked {<done-state>}"
  :_  state
  :~  [%give %fact ~[/sub-tasks] [%tudumvc-update !>((updates:tudumvc %task-complete id done-state))]]
      [%give %fact ~[/mytasks] [%json !>((json (tasks-json shared)))]]
  ==
++  edit-task
  |=  [=ship id=@ud label=@tU]
  ?.  (team:title our.bol ship)
    :_  state
    ~[[%pass /send-poke %agent [ship %tudumvc] %poke %tudumvc-action !>([%edit-task id label])]]
  =/  task-map=tasks:tudumvc  (~(got by shared) our.bol)
  ?.  (~(has by task-map) id)
    ~&  >>>  "No such task at id {<id>}"
    `state
  ~&  >  "Task id {<id>} text changed to {<label>}"
  =/  done-state=?  done.+>:(~(get by task-map) id)
  =.  state  state(shared (~(put by shared) our.bol (~(put by task-map) id [label done-state])))
  :_  state
  :~  [%give %fact ~[/sub-tasks] [%tudumvc-update !>((updates:tudumvc %task-edit id label))]]
      [%give %fact ~[/mytasks] [%json !>((json (tasks-json shared)))]]
  ==
++  sub
  |=  partner=ship
  ~&  >  "Subscribing to {<partner>}'s tasks"
  :_  state
  ~[[%pass /sub-tasks/(scot %p our.bol) %agent [partner %tudumvc] %watch /sub-tasks]]
++  unsub
  |=  partner=ship
  ~&  >  "Unsubscribing from {<partner>}'s tasks"
  =.  shared  (~(del by shared) partner)
  :_  state
  :~  [%pass /sub-tasks/(scot %p our.bol) %agent [partner %tudumvc] %leave ~]
      [%give %fact ~[/mytasks] [%json !>((json (tasks-json shared)))]]
  ==
++  force-remove
  |=  [paths=(list path) partner=ship]
  =.  editors  [(~(dif in requested.editors) (sy ~[partner])) (~(dif in approved.editors) (sy ~[partner])) (~(dif in denied.editors) (sy ~[partner]))]
  :_  state
  ~[[%give %kick paths `partner]]
++  edit
  |=  [partners=(list ship) status=?(%approve %deny)]
  ?-  status
      %approve
    =.  editors  [(~(dif in requested.editors) (sy partners)) (~(gas in approved.editors) partners) (~(dif in denied.editors) (sy partners))]
    `state
      %deny
    =.  editors  [(~(dif in requested.editors) (sy partners)) (~(dif in approved.editors) (sy partners)) (~(gas in denied.editors) partners)]
    `state
  ==
--