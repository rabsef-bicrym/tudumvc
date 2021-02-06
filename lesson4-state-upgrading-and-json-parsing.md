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
  $@  ~                                                 ::  null
  $%  [%a p=(list json)]                                ::  array
      [%b p=?]                                          ::  boolean
      [%o p=(map @t json)]                              ::  object
      [%n p=@ta]                                        ::  number
      [%s p=@t]                                         ::  string
  ==                                                    ::
  ```
