# On Quips of Cards and Pokes
This brief breakout lesson covers what `card`s and `poke`s are. This material will be more generally covered in other lessons but if you just can't wait for that, let's proceed:

## [`card`s](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/lull.hoon#L1660)
A `card` is defined in `lull.hoon` as a `(wind note gift)`.  A [`wind`](https://github.com/urbit/urbit/blob/master/pkg/arvo/sys/arvo.hoon#L122) is a wet gate that takes two molds and produces a structure that is tagged by a `head` `atom` (a tuple with either `%pass`, `%slip`, or `%give` as the head, which then further deliniates the tail structure - see the link to `arvo.hoon`).

Basically, `wind`s are used to communicate between vanes, including messages from `%gall` to `%gall` (between agents) and so on. Vanes that need something from another vane request it by `%pass`ing a `note`. The produced result is `%give`n as a `gift` back to the requester.  All of this to say that, simply, a `card` is a means of intercommunication between `agents` and `vane`s.

A [`quip`](https://urbit.org/docs/reference/library/1c/#quip) is `mold` that takes two `mold`s as arguments and produces a tuple of a `list` of the first `mold` argument and the `mold` of the second argument.  In this case, we are producing a list of `card`s and a mold of the type of our agent (`this` is defined in the alias section of all `%gall` `agents` as the whole core to which it refers - `+*  this  .`, and as a note `_noun` produces "the type of the noun", which is in our case `this`).

In other words, whenever you see an arm that has its output typed as a `(quip card _this)` (denoted by `^-  (quip card _this)`), that arm will result in the production of a `list` of `card`s (or instructions to `agents` or `vane`s) and a new version of `this` (or the `agent` itself) with a changed `state`. In the `++  on-poke` arm, `poke`s do the work of creating the `state` change and initiating the `list` of `card`s, so let's take a look at `poke`s.

## `poke`s
A `poke` is just a one-time input to some `%gall` app. `poke`s are handled by the `++  on-poke` arm of a `%gall` application. `++  on-poke`returns a `(quip card _this)` and takes both a `mark` and a `vase`.

This `mark` `vase` cell is also called a [`cage`](https://github.com/urbit/urbit/blob/0f069a08e83dd0bcb2eea2e91ed611f0074ecbf8/pkg/arvo/sys/arvo.hoon#L45) which is, itself, defined as a `(cask vase)`.  `cask` (defined one line below `cage`, linked above) is a `wet gate` that takes a vase and creates a `pair` of a `mark` and the argument it receives (in this case, a `vase`).  In the `dojo`, we communicate a poke using the following format: `:app-name &app-mark-file [%sur-action noun]`.

The handling of a `noun` `poke` entered through `dojo` is defined in the `++  on-poke` arm, as described, but the `vase` being passed must match one of the structures defined in the `action` mold of the `/sur` file for that app.  The `/mar` file for the app is  used to conform incoming `poke`s to the `/sur` file specification and handles converting non-`noun` pokes into interpretable `type`s (that is, incoming `JSON` pokes, for instance, must be converted to `noun`s for the `/app` file to handle them).

Generally, the effect generated by an incoming `poke` is the production of a `quip` of some (or no) `card`s and a changed `state`. In other words, a `(quip card _this)`!