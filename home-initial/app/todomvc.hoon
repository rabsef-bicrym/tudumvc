
::  todoMVC
::  starting state
::
::  Import todoMVC from sur
::
/-  todomvc
::  Import server, default-agent and dbug from lib
::
/+  *server, default-agent, dbug
::  Form a core
::
|%
::  Here we're preparing to have multiple states in the future
::  This gives us the ability to expand our application's functionality
::
+$  versioned-state
    $%  state-zero
    ==
::
::  Here we're defining the first state - this state is arbitrary and will
::  hold our poke action's message, just for fun.  Later we'll upgrade this
::  state to do more!
::
+$  state-zero
    $:  [%0 message=tape]
    ==
::  This is a default type that is used to pass information between gall agents
::  Card is defined in lull.hoon here:
::  https://github.com/urbit/urbit/blob/1eae4c09b991539ec61eb97f28bae84d7a385351/pkg/arvo/sys/lull.hoon#L1660
::
+$  card  card:agent:gall
::
--
::  This calls the gate of the debugging library that will be used to help us
::  troubleshoot our application.  It's basically a wrapper for the gall app we make
::
%-  agent:dbug
::  Following here, we initiate the state (as a blank version of the versioned state type)
::  Then we declare the result of all of the rest of the code as an agent of gall (kethep)
::  Lastly, we form a door with a default type of a bowl from gall.  The bowl contains lots
::  of fun things - our ships name, entropy bits, the current date time and MORE!!
::
=|  state-zero
=*  state  -
^-  agent:gall
|_  =bowl:gall
::  Lustar is used here to create aliases for this, the default action and the helper core
::  We could alias more materials, if we wanted to, and we would do it here
::  Lustar, as an arm marker, is unique in that it must come before all other lus runes
::  Most chapters are defined by luslus (see on-init, beneath, for example)
::  Additionally, lustar must come first in a "tome", which is effectively a series of
::  arms in a core.
::
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
::  In on-init, we establish what should happen on the first load of the application
::  Note that gall applications only use on-init ONCE - the first time they are loaded
::  Any subsequent upgrades for an already running application must be handled through
::  on-save and on-load interactions.  Nonetheless, as we version todoMVC, we must also
::  set up on-init to get new users up to the most recent version immediately, rather than
::  leaving it at setting them up at the base version.  We will modify this as we improve our app
::
++  on-init
  ^-  (quip card _this)
  ::  CLI notification that things are verking - IT VERKS!
  ::
  ~&  >  '%todoMVC app is online'
  ::  Establish todomvc-basic as a face.  This "face" (basically variable) is a cell of 
  ::  a mark (here a file-server-action, defined in mar\file-server\action.hoon) and a vase
  ::  which is, itself a cell of a noun and its type (specific vases for our application
  ::  are added/documented in sur\file-server.hoon).
  ::  This could really all be written into the card produced below it, where the face is used, but
  ::  out of convention, when a card is super long, we will offboard the action portion of the card
  ::  to a face, and insert it into the cart as the face (see below)
  ::
  =/  todomvc-basic  [%file-server-action !>([%serve-dir /'~todomvc-basic' /app/todomvc/basic %.y %.n])]
  ::  This line uses tisdot to modify an existing face (the bunt value of our state) to a valid extant
  ::  state value - here our version number (%0) and a "message" ("starting")
  ::
   =.  state  [%0 "starting"]
  ::  The type returned by this arm, as declared on line 65 is a quip card _this.  A quip is a duple of a 
  ::  list and a noun of a given type.  Here we're saying this arm will return a list of cards (actions) and a
  ::  core of the type of the core we're currently in - that is, some actions and possibly a changed state
  ::  We use colcab (:_) to form this duple in reverse order to make the heavier code towards the bottom
  ::
  :_  this
  ::  This is the list of cards we are passing to gall - currently it's only the one.  This one card says to
  ::  pass on the path "srv" to an agent, specifically our ship's %file-server app, a poke (how apps talk to
  ::  each other) that contains the contents of the face todomvc-basic (described above)
  ::
  :~  [%pass /srv %agent [our.bowl %file-server] %poke todomvc-basic]
  ==
::  on-save is where the state of our application is saved over upgrades, allowing us to maintain existing data
::  The data is saved as a vase (a duple of the mark of a noun and that noun) - this vase must necessarily fit one of 
::  our type defintions (lines 17-26)
::
++  on-save
  ^-  vase 
  !>(state)
::  In contrast, on-load is used to reset the application to the stored persistent state after re-loading the application
::  for instance, on upgrade.  Note ln 110 where we cast the type of the output of this arm as a (quip card _this) which
::  we know is a list of actions and a core of the type of this application.  Note ln 112, then, where we're returning an
::  empty list (`this = [~ this]) of cards and the state as derrived from extracting a typed noun from a vase.  Try this in
::  dojo -> "!<  @  !>  ~zod".  ~zod is our fearless leader galaxy with a numeric value of 0; this code snippet proves it!
::  We will later modify this code, as we modify our state in sequential versions of todoMVC, to upgrade the state over time
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%todoMVC has recompiled'
  `this(state !<(versioned-state old-state))
::  on-poke handles pokes from the cli or other agents, as the name implies.  on-poke expects to receive a mark and a vase
::  The only poke action we have presently is our %test-action, defined in our sur file.  Note that this arm has a gate
::  and a subsequent core created by barket (|^); this allows us to embed functional arms within this arm's core (poke-action)
::  We could, however, handle this differently, and put poke-action in a helper core outside of the entire parent core of this
::  gall app.  We might do that in later iterations to keep things clean and legible.
::
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
::  The rest of the arms, as of right now, use the boilerplate definitions from the default-agent library we've pulled in
::
++  on-arvo   on-arvo:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--