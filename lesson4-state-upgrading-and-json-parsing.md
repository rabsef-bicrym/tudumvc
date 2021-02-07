# State Upgrading & JSON Parsing
In this lesson we'll update the state of our `%firststep` app that we previously created.  In doing so we'll learn about the following items:
1. Updating an app while maintaining/converting our existing `state` to a new `state` model
2. `JSON` parsing (and, in particular, using recursive `JSON` parsing)
3. Rolling your own `roll` function to help with a recursive process (see [`roll`](https://urbit.org/docs/reference/library/2b/#roll) in the Standard Library)

## Goals
* Update the app to have a new `state` value of a `@ud` with a face of `number`
* Allow the following `poke` types:
    * `[%test-action msg=@t]`        :: Allows changing the `@t` called `message` in our `state`
    * `[%increment num=@ud]`         :: Allows incrementing the `@ud` called `number` in our `state`
    * `[%mor poks=(list action)]`    :: Allows sending a list of actions that will each be processed (this can be recursive)
* Identify how we can send each one of these pokes from the `dojo` and the web
* Identify the differences in how we will be sending `JSON` `poke`s to accommodate this more complex typing structure

## `JSON` parsing (Part I)
In the prior lesson, we used only one `JSON` parsing function from [`dejs:format` found in `zuse.hoon`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3472).  Let's take a look at what that function actually does:
```
++  so                                              ::  string as cord
  |=(jon=json ?>(?=([%s *] jon) p.jon))
```
1. From the comment, we can see that it takes a string (Urbit `JSON` type would look like `[%s p=@t]`.  The `JSON` comes in as the `gate`'s `sample` and is assigned the face of `jon`.
2. We then make an assertion ([`?>`](https://urbit.org/docs/reference/hoon-expressions/rune/wut/#wutgar)) that the `jon` will be equal to `[%s *]`, or that it will be a `cell` with a head of the tag `%s` and a tail of some `noun`.
3. Lastly, assuming that is the case (a positive assertion that is untrue crashes), we simply return the face `p` interior to the face `jon` which would be the `@t` of `[%s p=@t]`.
Overall, this is a very simple way of parsing `JSON` for our first example, but it affords us no ability to send _anything_ but a string from the web to our ship.  All other data types would crash at the assertion that the structure of the incoming `JSON` is equivalent to `[%s *]`.

In this lesson, we're going to need to be able to send at least 2 data types, a number and a string, and also a list of `poke`s of those data types, allowing us to send, for instance, both a string and a number (to update both our `state`'s `message` and `number` values.

## As the `JSON` changes
Previously, our poke line in our `airlock` code looked like this: `const test = await pokeFirstStep("test");`.  This is all fine and good if we're only sending one type of poke - we don't need to even consider other types so we don't have to send over the tagged `head` that was expected in our `sur` file which, again, looked like this: `[%test-action msg=cord]`.  Instead, we handled it in the following way in our `mar` file:
```
++  json
  |=  jon=^json
  ;;  action:firststep
  ~&  >  (so jon)
  [%test-action (so jon)]
```
   * NOTE: The important thing to see above is that our expected `JSON` coming from the web is simply a `cord` or, in the Urbit `JSON` type, a `[%s p='@t']`.  As such, we use the line `[%test-action (so jon)]` to parse _just the string_ and then add the expected `head` of the tagged-union type we created in our `sur` file (`[%test-action msg=@t]`)
    
 In this lesson, we need to allow our web component to specify multiple, disparate `poke`s and their associated data types.  Let's take a look at the types of `JSON` Urbit can handle:
 
 ## `JSON` parsing (Part II)
 There are several types of `JSON` that Urbit can recognize.  They are defined in [`lull.hoon`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/lull.hoon#L40).  Let's take a look at them:
 ```
 +$  json                                                ::  normal json value
  $@  ~                                                 ::  null     `json`[%o p={[p='test-action' q=[%s 'test']}]
  $%  [%a p=(list json)]                                ::  array    `json`[%a `(list json)`~[[%s 'this is an'] [%s 'array'] [%s 'of json']]]
      [%b p=?]                                          ::  boolean  `json`[%b %.y]
      [%o p=(map @t json)]                              ::  object   `json`[%o `(map @t json)`(my :~(['test-action' [%s 'test']]))]
      [%n p=@ta]                                        ::  number   `json`[%n ~.123]
      [%s p=@t]                                         ::  string   `json`[%s 'test']
  ==                                                    ::
  ```
For our convenience, I've added examples of how to produce the various different types of `JSON` Urbit can understand to the right of the description of their structure - this is not actually in the `lull.hoon` file, but you should try some of these in the `dojo` and attempt to make your own as well.  Understanding these types and their related parsing functions in [`dejs:format`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3317) is helpful in order to imagine how we might proceed from here.  Let's try a few in the `dojo`, starting with the easy ones:

**Easy `JSON` Parsing**
### `so:dejs:format`
Try `` (so:dejs:format `json`[%s 'test']) `` in the `dojo`
You should see:
```
> (so:dejs:format `json`[%s 'test'])
'test'
```

###  `ni:dejs:format`
Try `` (ni:dejs:format `json`[%n ~.123]) `` in the `dojo`
You should see:
```
> (ni:dejs:format `json`[%n ~.123])
123
```

### `bo:dejs:format`
Try `` (bo:dejs:format `json[%b %.y]) `` in the `dojo`
You should see:
```
> (bo:dejs:format `json`[%b %.y])
%.y
```

**Challenging `JSON` Parsing**
In contrast to the above `arm`s of `dejs:format` which all just take a `JSON` as an argument and then do something with it, the parsers for `%o` and `%a` type `JSON` take a `(pole [cord fist])` and a `fist` respectively.

**[`fist`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3319)**
A `fist` is a structure that normalizes to an example gate ([`$-`](https://urbit.org/docs/reference/hoon-expressions/rune/buc/#buchep)).  In this case, it's basically saying that we're going to take in a `JSON` and return a [`grub`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3319), which is just any `noun`.

**`(pole [cord fist])`**
A `pole` is just a `face`less list.  In this case, it would be a list of `[cord fist]`.

### `%o` parsing
Let's look at [`of:dejs:format`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3392).  We're not going to plumb the depths of how this `wet` `gate` actually works, but we can speak to what it's going to do for us.  An `of:dejs:format` parse will look something like this:
```
%-  of
:~  [%s-string so]
    [%n-number ni]
    [%b-boolean bo]
==
```
`of` is being called with a `pole` of `[cord fist]`s, except we're representing the `cord`s as `term`s (which is not necessary).  Here, we're basically saying "OK Object, you're going to come in with a map of `[cord JSON]` k-v pairs, and we're going to use this translation guide to check the `key` and determine what `fist` (parsing rule) to use against the value of that pair."  Importantly, the incoming `%o` `JSON` object need not actually include all possible translative kv pairs in each incoming object - we're just giving an exhaustive list of translations so that any possible case could be handled.

We could form something like this, in `dojo`:
`=a (of:dejs:format :~([%test-action so:dejs:format] [%number-action ni:dejs:format]))`
And, we could make our object look like the example we had above, plus add another:
`` =b [%o `(map @t json)`(my :~(['test-action' [%s 'test']]))] ``
`` =c [%o `(map @t json)`(my :~(['number-action' [%n ~.123]]))] ``
And lastly, we could run both examples:
<table>
<tr>
<td colspan="2">
Using object parsing dejs:format functionality
</td>
</tr>
<tr>
<td>
         
```
> (a b)
[%'test-action' 'test']
```
         
</td>
<td>
   
```
> (a c)
[%'nubmer-action' 123]
```
         
</td>
</tr>
</table>

### `%a` parsing
Let's look at [`ar:dejs:format`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3323). Again, here we won't trouble ourselves with learning `wet` `gate`s to determine exactly what's happening, but we can speak to what it does.  An `ar:dejs:format` parse will look something like this:
```
(ar so)
```
Importantly, `ar:dejs:format` works differently from `of:dejs:format` in that it doesn't take multiple cases (a `(pole [cord first])`) but, instead, it takes a single `fist` (some arm that will result in the conversion of our incoming `json` to a `grub`).  Also note that the product of `ar` being called with a `fist` is a gate that  accepts a sample of an array of `JSON` and parses that array using the first argument of the `ar` call.  This limits our ability to handle arrays of `JSON` that are of disparate types, unless we have some tricks up our sleves (hint: we do).  First, let's try doing this in `dojo`:

Perhaps our array is an array of strings, allowing us to construct something like this:
```
=a (ar:dejs:format so:dejs:format)
```
And, we could make our object look like:
```
=c `json`[%a ~[[%s 'a'] [%s 'b'] [%s 'c']]]
```
And, lastly, we could run that example:
```
> (a c)
<|a b c|>
```

## Our New `sur` File
As a note, over the next few subsections, we'll be making changes to the files we previously created for our `app`, but we shouldn't worry about `|commit %home`ing, until we've made all of the changes - don't worry, I'll tell you when.

The changes we're going to make to the `sur` file will look like this:
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
|%
+$  action
  $%
  [%test-action msg=cord]
  ==
--
```

</td>
<td>

```
|%
+$  action
  $~  [%mor ~]
  $%
  [%test-action msg=cord]
  [%increment num=@ud]
  [%mor poks=(list action)]
  ==
--
```

</td>
</tr>
</table>

We should immediately be able to see 2 main differences.
1. We've added 2 new `action`s, `[%increment num=@ud]` and `[%mor poks=(list action)]` - NOTE: The second new `action` is recursive definition - the `poks` face of `%mor` will be a list of other possible `action`s.
2. We've added a default case using [`$~`](https://urbit.org/docs/reference/hoon-expressions/rune/buc/#bucsig) of an empty-list version of `%mor`

We're going to use these two changes to allow us to pass mutliple different types of `action`s (or `poke`s) from our Earth webapp, including, should we so choose, an array of `actions`s.

## Our New `mar` File
This one is going to take a little more explaining than the first; make the following changes:
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
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
```

</td>
<td>

```
/-  firststep
=,  dejs:format
|_  act=action:firststep
++  grab
  |%
  ++  noun  action:firststep
  ++  json
    |=  jon=^json
    ?>  ?=([%o *] jon)
    ?:  (~(has by p.jon) %mor)
      :-  %mor  ((ar json) (~(got by p.jon) %mor))
    %.  jon
    %-  of
    :~  [%test-action so]
        [%increment ni]
    ==
  --
--
```

</td>
</tr>
</table>

Let's work through each change:

**`?>  ?=([%o *] jon)`**
This change allows us to confirm that any `JSON` coming in will be an `%o` object.  This means we're not going to be able to pass just `'test'` anymore, but something like `{'test-action': 'test'}` to do even the simple, non-recursive versions of our action.

**`?:  (~(has by p.jon) %mor)`**
Let's review the structure of an `%o` object `JSON` in hoon: `[%o p=(map @t json)]`.  An `%o` object of `JSON` in hoon is a cell with a head of `%o` and a tail of `p=(map @t json)`.  [`has:by`](https://urbit.org/docs/reference/library/2i/#has-by) is a `map` logic function built into the standard library.  It checks if there is specific `key` in the kv pair list of the `map` and produces a `%.y` if there is, and a `%.n` if there isn't.  Here, we're just checking to see if `%mor` is one of the keys, because we're going to have to handle it differently than other cases.  [`?:`](https://urbit.org/docs/reference/hoon-expressions/rune/wut/#wutcol) is simplying creating a switching behavior based on the test performed by `has:by`.  
* If the `key` `%mor` exists in the object, then we perform the line `:-  %mor  ((ar json) (~(got by p.jon) %mor)`, which we'll discuss in a second.
* If there is no key `%mor`, then we move on to the following section:
```
%.  jon
%-  of
:~  [%test-action so]
    [%increment ni]
==
```

[`%.`](https://urbit.org/docs/reference/hoon-expressions/rune/cen/#cendot) calls a `gate` with a sample, inverted; the sample is `jon`, or our `JSON`.  That is, it has the sample listed first and the `gate` second.  We should be familiar with the patter onf the next 4 lines:
* [`%-`](https://urbit.org/docs/reference/hoon-expressions/rune/cen/#cenhep) calls `of` as a `gate` that takes a sample
* The sample is a `(pole [cord fist])`, just like what we used when we were experimenting with our `%o` parsing, above
* The `gate` `of`, when called with a `(pole [cord fist])`, returns a `gate` that takes a sample of a `(map cord json)`, and it parses that map by determining which `dejs:format` rule to use, based on the `key` value, where that `key` must match one of the `cord` in the `(pole [cord fist])` it was passed.
If the `JSON` `{'test-action':'test'}` was sent to this parser, it would pass the assertion created by `?>`, it would not have `%mor` in it, so it would skip to the `%.` line, that `JSON` would then be parsed by checking the `(pole [cord fist])` that was passed to `of` and, based on `'test-action'` as a key, it would parse `test` (which would come in as the `JSON` object `[%s 'test']` using the `so:dejs:format` method, which we've seen previously.

**`:-  %mor  ((ar json) (~(got by p.jon) %mor))`**
For this section, let's imagine that we're working with the `JSON` object: `` `json`[%o (my ~[['mor' [%a ~[[%o (my ~[['test-action' [%s 'test']] ['increment' [%n ~.2]]])]]]]])]` `` - breaking that down:
* The most exterior object is a `%o` object with a `(map cord json)` of `(my ~[['mor' [%a ~[[%o (my ~[['test-action' [%s 'test']] ['increment' [%n ~.2]]])`
* The object-value of the kv pair with a `key` of `'mor'` is an `%a` type array of a `(list json)`
* The `(list json)` is a list of one `%o` object - namely `~[[%o (my ~[['test-action' [%s 'test']] ['increment' [%n ~.2]]`
* The `(map cord json)` of the above `%o` object contains two kv pairs: `['test-action' [%s 'test']]` and `['increment [%n ~.2]]`, and we know how these would be parsed in `JSON` from when we looked at the final `of` portion of the `gate` we're in

Here's how this section is going to work:
* If we receive a `JSON` object like we described at the top of this section, we first check if it's an `%o` object, which it is.
* Then we check if it has the `key` `'mor'`, which we do.
* In that case, we parse the value of the kv pair with the `key` `'mor'` (which is an array) using the `JSON` parsing function created by `(ar json)`.  `(ar json)` creates an array parsing function using the `arm` we're in **_right now_** (`++  json` - and, incidentally, we have to use `^json`, which skips the first `json` face it finds, to cast something in this case to avoid name conflict between the immediate arm and the type).
* For the single item in the array that we have (namely, `~[[%o (my ~[['test-action' [%s 'test']] ['increment' [%n ~.2]]`), we run it through `++  json`
   * We check if it's an `%o` object, which it is
   * Then we check if it has the `key` `'mor'`, which we _do not_.
   * In that case, we move straight on to the `%.  jon  %-  of  :~  [%test-action so]  [%increment ni]  ==` section and determine how to parse each kv pair in the map.
   
You _might_ notice, from this discussion, that you can do this indefinitely (stacking `'mor'` keys inside of `'mor'` keys, inside of `'mor'` keys, and so on.  In any event, what we'll get back is a `action:firststep` of `[%mor poks=(list json)]`.  We should now look at the changes to `app` to see how this sort of `poke` (and the others), will be handled.


## Our New `app` File
There are a few significant changes in our `app` file.  We'll handle them one by one, based on the section in which they appear

**The `state` Definition `core`**
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero  [%0 message=cord]
::
+$  card  card:agent:gall
--
```

</td>
<td>

```
|%
+$  versioned-state
  $%  state-zero
      state-one
  ==
+$  state-one   [%1 message=cord number=@ud]
+$  state-zero  [%0 message=cord]
::
+$  card  card:agent:gall
--
```

</td>
</tr>
</table>
There are two big changes here.  First, we've defined `state-one` as `[%1 message=cord number=@ud]`, or a tagged-head cell with an expected tail.  Second, we've added to `versioned-state` the `state-one` that we're defining

**The Opened Door**
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
=|  state-zero
```

</td>
<td>

```
=|  state-one
```
</td>
</tr>
</table>
All we're doing here is making sure that a _new_ installer of this `app` will start with a bunted `state-one`, rather than a `state-zero`.

**`++  on-init`**
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
++  on-init
  ^-  (quip card _this)
  ~&  >  '%firststep achieved'
  =.  state  [%0 'starting']
  `this
```

</td>
<td>

```
++  on-init
  ^-  (quip card _this)
  ~&  >  '%firststep achieved'
  =.  state  [%1 'starting' 0]
  `this
```
</td>
</tr>
</table>
All this does is upgrade the `on-init` behavior to start users with a `state-one` of `[%1 'starting' 0]`.  Recall that `on-init` is only run once, and so this would only affect _new_ `app` installs - people ugrading will go on to use `on-load`, which we'll see next.

**`++  on-load`**
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%firststep has recompiled'
  `this(state !<(versioned-state old-state))
```

</td>
<td>

```
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%secondstep has recompiled'
  =/  state-ver  !<(versioned-state old-state)
  ?-  -.state-ver
    %1
  `this(state state-ver)
    %0
  `this(state [%1 message.state-ver 0])
  ==
```
</td>
</tr>
</table>
In contrast to our first implementation, where we simply indicate compilation has succeeded and return a `(quip card _this)` (empty `(list card)` set) with the `state` set as the `vase` that the `on-load` arm was passed (a/k/a the old state), we have to make handling provisions for upgrading from the old `state `( `%0`) to the new `state`.

[`?-`](https://urbit.org/docs/reference/hoon-expressions/rune/wut/#wuthep) is going to be doing this work for us by doing something like a case-when statement with no default.
* If the `state` has a head of `%1` (i.e. it's `state-one` already), we just return a `(quip card _this)` (empty `(list card)` set) with the `state` set as the `vase` that the `on-load` arm was passed.
* If the `state` has a head of `%0` (i.e. it's the _old_ `state` version)

**`++  on-poke`**
<table>
<tr>
<td>
:: initial version
</td>
<td>
:: new version 
</td>
</tr>
<tr>
<td>
   
```
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
```

</td>
<td>

```
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
    ?-  -.action
        %test-action  
      ~&  >  "Replacing state value {<message:state>} with {<+.action>}"
      `state(message msg.action)
    ::
        %increment
      ~&  >  "Incrementing {<number>} by {<+.action>}"
      `state(number (add number num.action))
    ::
        %mor
      =|  dracs=(list card)
      |-
      ?~  +.action
        [dracs this]
      =^  caz  state
        (poke-action i.poks.action)
      $(poks.action t.poks.action, dracs (weld caz dracs))
    ==
  --
```
</td>
</tr>
</table>
Really, all that's changed here is the `++  poke-action` arm, and there only to accommodate multiple different `action:firststep` `poke`s.  Let's take them in order.

1. We've replaced our `?>  =(-.action %test-action)` with a `?-` test, which as we saw above is a case-when type statement with no default.
   * We're testing the head of our incoming `action:firststep` for being either `%test-action`, `%increment` or `%mor`
2. `%test-action` works the same as it did previously, only now the `action:firststep` model for `%test-action` has a `face` for the `cord` value message - `[%test-action msg=cord]`.
3. `%increment` works much in the same way as `%test-action` except it adds its `@ud` value to the current `number:state` value of our `app` using `` `state(number (add number num.action)) ``
4. `%mor` is where things get interesting:
   * First, it bunts a `(list card)` called `dracs`
   * Next, it forms a [`trap`](https://urbit.org/docs/tutorials/hoon/hoon-school/recursion) (or a sample-less core with one arm that is computed immediately, called `$`)
   * Next, it checks whether the `poks` face of our `action:firststep` is empty - effectively checking to see if a list is empty, so as to allow us to either address easily the head and tail of the list (where non-null) or identify when we're done with recursion (where null)
   * Assuming the list is **not empty**, we use [`=^`](https://urbit.org/docs/reference/hoon-expressions/rune/tis/#tisket) which, as we described previously, does the following things:
      * Creates a new face (here `caz`)
      * Identifies a face from the existing subject (here `state`)
      * Has some hoon that creates a cell of values, who's values map onto the prior two faces (head to `caz`, tail to `state`)
      * Has some more hoon that is evaluated with the benefit of the new face and the change to the existing face (`caz` and `state` respectively)
   * `=^` allows us to run `poke-action` against the head of the list, `i.poks.action`, which will return a `(quip card _state)`.
   * When it returns that `(list card)` and new `state`, those are mapped on to the `caz` and `state` values from `=^`
   * In our last line, we reprocess the arm `$` of the `trap`, but with `poks.action` equal to just the tail (we've already processed the head) of `poks.action`, and we `weld` the list of cards (`caz`) to the overarching list of cards we bunted just before we entered the `trap`.
   * We simply repeat this over and over until the list is empty, whereupon we return `[dracs this]`, a `(list card)` that we've been building up in recursion.

Well - that's really it.  Let's try `|commit %home`-ing and launch our webpage and try a few different pokes.  Try the following pokes by replacing the `JSON` being passed:
1. `{'test-action': 'It's VERKING. It VERKS!'}`

Expected output:
```
< ~nus: opening airlock
>   "Replacing state value 'starting' with msg='It's VERKING. It VERKS!'"
```
2. `{'increment': 100}`

Expected output:
```
< ~nus: opening airlock
>   "Incrementing 0 by num=100"
```
3. `{"mor": [{"test-action": "test"},{"increment": 2}]}`

Expected output:
```
< ~nus: opening airlock
>   "Replacing state value 'It's VERKING. It VERKS!' with msg='test'"
>   "Incrementing 100 by num=2"
```
