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
 There are several types of `JSON` that Urbit can recognize.  They are defined in [`lull.hoon`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/lull.hoon#L40(.  Let's take a look at them:
 ```
 +$  json                                                ::  normal json value
  $@  ~                                                 ::  null     `json`[%o p={[p='test-action' q=[%s 'test']}]
  $%  [%a p=(list json)]                                ::  array    `json`[%a `(list json)`~[[%s 'this is an array'] [%n '123'] [%b %.y]]]
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

**`%o` parsing**
Let's look at [`of:dejs:format`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3392).  we're not going to plumb the depths of how this `wet` `gate` actually works, but we can speak to what it's going to do for us.  An `of:dejs:format` parse will look something like this:
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





