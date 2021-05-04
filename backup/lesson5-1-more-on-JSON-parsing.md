# More on JSON Parsing
 There are several types of `JSON` that Urbit can recognize. They are defined in [`lull.hoon`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/lull.hoon#L40). Let's take a look at them:
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
For our convenience, I've added examples of how to produce the various different types of `JSON` Urbit can understand to the right of the description of their structure - this is not actually in the `lull.hoon` file, but you should try some of these in the `dojo` and attempt to make your own as well. Understanding these types and their related parsing functions in [`dejs:format`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3317) is helpful in order to imagine how we might proceed from here. Let's try a few in the `dojo`, starting with the easy ones:

## Easy `JSON` Parsing
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

## Challenging `JSON` Parsing
In contrast to the above `arm`s of `dejs:format` which all just take a `JSON` as an argument and then do something with it, the parsers for `%o` and `%a` type `JSON` take a `(pole [cord fist])` and a `fist` respectively.

### [`fist`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3319)
A `fist` is a structure that normalizes to an example gate ([`$-`](https://urbit.org/docs/reference/hoon-expressions/rune/buc/#buchep)). In this case, it's basically saying that we're going to take in a `JSON` and return a [`grub`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3319), which is just any `noun`.

### `(pole [cord fist])`
A `pole` is just a `face`less list. In this case, it would be a list of `[cord fist]`.

### `%o` parsing
Let's look at [`of:dejs:format`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3392).  We're not going to plumb the depths of how this `wet` `gate` actually works, but we can speak to what it's going to do for us. An `of:dejs:format` parse will look something like this:
```
%-  of
:~  [%s-string so]
    [%n-number ni]
    [%b-boolean bo]
==
```
`of` is being called with a `pole` of `[cord fist]`s, except we're representing the `cord`s as `term`s (which is not necessary). Here, we're basically saying "OK Object, you're going to come in with a map of `[cord JSON]` k-v pairs, and we're going to use this translation guide to check the `key` and determine what `fist` (parsing rule) to use against the value of that pair." Importantly, the incoming `%o` `JSON` object need not actually include all possible translative kv pairs in each incoming object - we're just giving an exhaustive list of translations so that any possible case could be handled.

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
[%'number-action' 123]
```
         
</td>
</tr>
</table>

### `%a` parsing
Let's look at [`ar:dejs:format`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/zuse.hoon#L3323).Again, here we won't trouble ourselves with learning `wet` `gate`s to determine exactly what's happening, but we can speak to what it does. An `ar:dejs:format` parse will look something like this:
```
(ar so)
```
Importantly, `ar:dejs:format` works differently from `of:dejs:format` in that it doesn't take multiple cases (a `(pole [cord first])`) but, instead, it takes a single `fist` (some arm that will result in the conversion of our incoming `json` to a `grub`). Also note that the product of `ar` being called with a `fist` is a gate that  accepts a sample of an array of `JSON` and parses that array using the first argument of the `ar` call. This limits our ability to handle arrays of `JSON` that are of disparate types, unless we have some tricks up our sleves (hint: we do). First, let's try doing this in `dojo`:

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