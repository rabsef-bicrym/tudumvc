|=  [num-of-discs=@ud which-rod=?(%one %two %three)]
::  Special thanks to ~winduc-dozser
|^  ^-  (list hanoi-board)
=|  working-board=hanoi-board
?-  which-rod
    %one
  =.  rod-one.working-board    (rod-maker num-of-discs)
  (method working-board)
    %two
  =.  rod-two.working-board    (rod-maker num-of-discs)
  (method working-board)
    %three
  =.  rod-three.working-board  (rod-maker num-of-discs)
  (method working-board)
==
+$  hanoi-board  $:(rod-one=(list @) rod-two=(list @) rod-three=(list @))
++  method
  |=  working-state=hanoi-board
  =|  moves-output=(list hanoi-board)
  |-  ^-  (list hanoi-board)
  ?:  (solution-checker (solver working-state))
    (flop [(solver working-state) moves-output])
  =.  working-state  (solver working-state)
  %=  $
    working-state  (move-second working-state)
    moves-output   [(move-second working-state) [working-state moves-output]]
  ==
++  rod-maker
  |=  num-disc=@ud
  =|  output=(list @)
  |-  ^+  output
  ?:  =(num-disc 0)
    output
  $(num-disc (dec num-disc), output [num-disc output])
++  solution-checker
  |=  checked-board=hanoi-board
  ?-  which-rod
      %one
    ?|  =(rod-two:checked-board (rod-maker num-of-discs))
        =(rod-three:checked-board (rod-maker num-of-discs))
    ==
      %two
    ?|  =(rod-one:checked-board (rod-maker num-of-discs))
        =(rod-three:checked-board (rod-maker num-of-discs))
    ==
      %three
    ?|  =(rod-one:checked-board (rod-maker num-of-discs))
        =(rod-two:checked-board (rod-maker num-of-discs))
    ==
  ==
++  solver
  |=  current-state=hanoi-board
  =,  current-state
  ::  Alternate movements between smallest piece and next smallest piece
  ::  If EVEN discs, move right, if  ODD discs, move left
  ::  For SMALLEST:
  ::    If no tower in chosen direction, move to opposite end, continuing in chosen direction
  ::  For NEXT SMALLEST:
  ::    Only one valid operation
  ?:  =(0 (mod num-of-discs 2))
    ::  move right
    (move-one-right current-state)
  ::  move left
  (move-one-left current-state)
++  move-one-right
  |=  current-state=hanoi-board
  ^-  hanoi-board
  ?~  (find [1]~ rod-one:current-state)
  ?~  (find [1]~ rod-two:current-state)
  ?~  rod-three.current-state  ~_(leaf+"What happon?" !!)
    :: rod-three has 1
    %=  current-state
      rod-one    [1 rod-one:current-state]
      rod-three  t.rod-three:current-state
    ==
  :: rod-two has 1
  ?~  rod-two.current-state  !!
  %=  current-state
    rod-three  [1 rod-three:current-state]
    rod-two    t.rod-two:current-state
  ==
  :: rod-one has 1
  ?~  rod-one.current-state  !!
  %=  current-state
    rod-two  [1 rod-two:current-state]
    rod-one  t.rod-one:current-state
  ==
++  move-one-left
  |=  current-state=hanoi-board
  ^-  hanoi-board
  ?~  (find [1]~ rod-one:current-state)
  ?~  (find [1]~ rod-two:current-state)
  ?~  rod-three.current-state  ~_(leaf+"What happon?" !!)
    :: rod-three has 1
    ?~  rod-three.current-state  !!
    %=  current-state
      rod-two    [1 rod-two:current-state]
      rod-three  t.rod-three:current-state
    ==
  :: rod-two has 1
  ?~  rod-two.current-state  !!
  %=  current-state
    rod-one  [1 rod-one:current-state]
    rod-two  t.rod-two:current-state
  ==
  :: rod-one has 1
  ?~  rod-one.current-state  !!
  %=  current-state
    rod-three  [1 rod-three:current-state]
    rod-one    t.rod-one:current-state
  ==
++  move-second
  |=  current-state=hanoi-board
  ^-  hanoi-board
  ?~  rod-one.current-state
    :: This doesn't work -> ?<  &(=(~ rod-two) =(~ rod-three))
    ?~  rod-two.current-state  !!
    ?~  rod-three.current-state  !!
    ?:  (gth i.rod-two:current-state i.rod-three:current-state)
      current-state(rod-one [i.rod-two:current-state rod-one:current-state], rod-two t.rod-two:current-state)
    current-state(rod-one [i.rod-three:current-state rod-one:current-state], rod-three t.rod-three:current-state)
  ?~  rod-two.current-state
    ::?<  &(=(~ rod-one) =(~ rod-three))
    ?~  rod-three.current-state  !!
    ?:  (gth i.rod-one:current-state i.rod-three:current-state)
      current-state(rod-two [i.rod-one:current-state rod-two:current-state], rod-one t.rod-one:current-state)
    current-state(rod-two [i.rod-three:current-state rod-two:current-state], rod-three t.rod-three:current-state)
  ?~  rod-three.current-state
    ::?<  &(=(~ rod-one) =(~ rod-two))
    ?:  (gth i.rod-one:current-state i.rod-two:current-state)
      current-state(rod-three [i.rod-one:current-state rod-three:current-state], rod-one t.rod-one:current-state)
    current-state(rod-three [i.rod-two:current-state rod-three:current-state], rod-two t.rod-two:current-state)
  ?~  (find [1]~ rod-one:current-state)
  ?~  (find [1]~ rod-two:current-state)
  ?:  (gth i.rod-one:current-state i.rod-two:current-state)
    current-state(rod-one [i.rod-two:current-state rod-one:current-state], rod-two t.rod-two:current-state)
  current-state(rod-two [i.rod-one:current-state rod-two:current-state], rod-one t.rod-one:current-state)
  ?:  (gth i.rod-one:current-state i.rod-three:current-state)
    current-state(rod-one [i.rod-three:current-state rod-one:current-state], rod-three t.rod-three:current-state)
  current-state(rod-three [i.rod-one:current-state rod-three:current-state], rod-one t.rod-one:current-state)
  ?:  (gth i.rod-two:current-state i.rod-three:current-state)
    current-state(rod-two [i.rod-three:current-state rod-two:current-state], rod-three t.rod-three:current-state)
  current-state(rod-three [i.rod-two:current-state rod-three:current-state], rod-two t.rod-two:current-state)
--