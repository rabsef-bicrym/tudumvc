# The Urbit Filesystem `%clay`

In the last lesson, we learned how to christen an urbit and set up a fake ship for Hoon development.  In this lesson, we're going to take a slightly closer look at `%clay` and write a simple hoon to work with it.  This lesson will also lead us to a discussion of the `/mar` mark system.  The `/mar` system allows our urbit to change nouns from one `type` to another `type`.  We're not going to plumb the depths of this system, so there will be some times where you'll just have to trust me on what we're doing - I'll try to denote such times.

## `+ls`

As with beloved Unix, we can list the files of any directory in an urbit from within our dojo shell.  `+ls` is a generator stored in your `/gen` folder, by default.  A generator is a simple function-like program that:
1. Takes an argument called a `sample`.
2. Runs some hoons to produce an output (printed or operational or what have you).
3. Returns the result of its operation to your urbit to be handled.
Let's try using it.  In the dojo, try this: `+ls %/`, which should output the following):
```
app/ gen/ lib/ mar/ sur/ sys/ ted/ tests/`
```

Great - we've just learned a few things:
* We're operating in our `home` directory, by default, in our urbit as told by the presence of the folders seen above (though, technically, without any base modifications, your `home` and `kids` desks will be identical.
* `%/` is apparently a reference to this home directory.
* Each folder is denoted as just its name followed by `/` (pronounced `fas`).

Now let's try `+ls /===`.  Same result!  `%/` and `/===` must be equivalent statements.  The `sample`, or argument, that we're passing `+ls` is a `path`, which is just a way of denoting a certain area of the `%clay` filesystem. `path`s consist of a [`beak`](https://github.com/urbit/urbit/blob/79f461f5c9ecfb7bf45ee55061332beec2775f98/pkg/arvo/sys/arvo.hoon#L33) (or a `ship` `desk` `case` (version)) and no or some additional filepath identification.  `%/` is a shorthand way of denoting the current relative path, which in our case is the `home` `desk` (a workspace containing directories) on your urbit, in the current version, or `case`.  When we give the sample `/===` we're saying "use the default `desk` of our `ship` in the current version (`case`)" - so in most cases that will be the same as `%/`.

We could substitute other values, however, and get (potentially) different results.  As a trivial example of this, try `+ls /<~sampel-palnet>/kids/=` - you'll see you get effectively the same information but from your `kids` `desk`, rather than your `home` `desk` (we've substituted `/<~sampel-palnet>/kids/=` in place of `/===` which also means `/<~sampel-palnet/home/now`).

### Try this:
Browse a few other directories and look at their files:
* `+ls /===/app`
* `+ls %/gen`
* Try the following in sequence:
    * `=dir %/app`
    * `+ls %/`
    * `+ls /===`
    * `+ls /===/app`
    * Interesting results, no?  Consider what this means about how `=dir <path>` works.
    * Use just `=dir` to return to your default path.

### Add a file:
Create a file in Unix called test.txt within the home directory of your test urbit.  Put a few lines of text into it and then proceed as follows:
* `+ls %/`
    * **NOTE:** Nothing new has happened here.  Again, making a file in the Unix side of things doesn't affect your urbit until you `|commit %home` (or whatever other desk you're working in).
* `|commit %home`
* `+ls %/`
    * **NOTE:** Now you'll see the file you just made - let's take a look at a few ways to work with that file, from here.
 
 ## `%cat`
 
 As with Unix, everything in Urbit is a file.  `%cat`, as with its Unix counterpart, concatenates the files in a given directory to produce their output.  You can do  this with the file you just added to your urbit
 * `%cat %/test/txt`
 
 ## `scry`ing
 
`scry`ing is just a way of examining the 'namespace' or file system of `Arvo`.  It uses [`.^` (`dotket`)](https://urbit.org/docs/reference/hoon-expressions/rune/dot/#dotket), the 'fake' Nock instruction (`12`) to load a noun from `arvo` - a valid `scry` has the form of `.^(<type> <vane><care> <path>)`.

In other words, `.^` takes a `type` to `mold` the returned noun into, a `vane``care` combo that tells the `scry` what `vane` to ask, and what [`care`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/lull.hoon#L799) (or `clay` 'submode') to use and the `path` where the noun lives.  Let's check these out in order:
 
 ### `type`
 
The `type` is that of the `noun` which will be returned from a `scry`.  You can often put `*` (or "any noun") in the `type` position, but it will return untyped, raw urbit data; a cell of numbers, if you get results back.  We want to read the `.txt` file we just created - so let's take a look at the `/mar/txt/hoon` to help us determine what `type` we should expect from that noun (this is a "trust me" moment).

You'll note that ln 12 of that file is an `arm` called `++  grab` that, according to the comment next to it, is used to `::  convert from`.  as we've said, a `.^` `scry` returns a `noun`.  Looking at ln 15, we can see what `type` to expect from `scry`ing the `noun` of a `.txt` file:
 `  ++  noun  wain                                        ::  clam from %noun`
 
The `noun` form of a `.txt` file will be a `wain`.  A `wain` happens to be a list of `cord`s, which are just `atom`s uf UTF-8 text.  Makes sense for a `.txt` file.  We'll want to remember `wain` for later

 ### `vane`
Urbit's vanes include, and will be signified by their first letter, in our `scry`s.
`%a`mes `%b`ehn `%c`lay `%d`ill `%e`yre `%f`ord `%g`all `%i`ris `%j`ael
We're going to use `%c`lay today, but you'll learn to use others, including `%g` later.
 
 ### `care`
 
`care`s are instructions on what type of information to try and pull from a path.  While there are others, the most common `care`s you'll see are `x` and `y`.  

#### `y`
A care of `y` will _always_ return a [`cage`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/arvo.hoon#L45) (a `mark` and a `vase`) with a [`mark`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/arvo.hoon#L50) of [`%arch`](https://github.com/urbit/urbit/blob/c888af3a30b5da38a93094c0e9f5a4b0e35b9a6d/pkg/arvo/sys/arvo.hoon#L25) and a `vase` of an `arch`.  An `arch` is just a filesystem node that looks something like this:
 ```
 > .^(arch %cy %/)
[ fil=~
    dir
    [p=~.app q=~]
    [p=~.web q=~]
    [p=~.sur q=~]
    [p=~.gen q=~]
    [p=~.lib q=~]
    [p=~.mar q=~]
    [p=~.ted q=~]
    [p=~.sys q=~]
    [p=~.tests q=~]
  }
]
```
or
```
 > .^(arch %cy %/test/txt)
[   fil
  [ ~
    0vo.8i775.kcfg3.si8pu.6frk3.hbepi.4k07t.4o72l.9uqq3.k8php.ckr5i
  ]
  dir={}
]
```
`arch`es are `(axil @uvI)`s - an [`axil`](https://github.com/urbit/urbit/blob/b1eed3a0e053309960bf9c00579780973f562717/pkg/arvo/sys/arvo.hoon#L29) is a `wet` `gate` (or `type` preserving `gate` that conforms to what was passed to it rather than specifying an incoming `type`) that takes a `@uvI` (unsigned base32) and conforms it to a structure of `[fil=(unit item) dir=(map @ta ~)]`.  As we saw above, if we give the scry a path to a folder (`%/`), we get back an empty `fil` item and a `dir` that is a map of directories to `~` (thus `dir=(map @ta ~)`).  In contrast, as also seen above, if we give the `scry` a path to a file, we get back a `fil` that is the file represented in unsigned base32 format (this is definitely magic).

#### `x`
A `care` of `x` will return the noun of the file at the end of the path (and if you type it right, it will return in the right format), like this:

```
> .^(wain %cx %/test/txt)
<|This is a test Test line 2|>
```

To review - what we're getting back here is a `cage` of `[%noun <vase>]` (or a `noun` `mark` and a `noun` wrapped in its `type`) of a `(list cord)`.  Try this in `dojo`:

```
> !>(.^(wain %cx %/test/txt))
[ #t/*''
    q
  [ 2.361.902.151.087.028.599.105.262.277.191.764
    60.599.277.785.343.835.422.025.044
    0
  ]
]
```

Remember that a `wain` is a `(list cord)`.  By casting the `noun` at the end of the path as a `wain`, we get back `[%noun [wain <the-noun>]]`.  The return of `#t/*''` shows us that, where `*` is `noun` and `''` is `cord`.

### `path`

A path, as we've described above, is a list of knots that points to somewhere in the filesystem, you've probably derived that from the examples above.

## Writing a Generator to Perform a Scry

Let's save this [file](/supplemental/readmytang.hoon) into the `/gen` folder.  Taking a look at it line by line:
```
:: Bartis forms a gate that takes a sample and performs some action
:: The sample is called pax, and it's a path
::
|=  pax=path
:: Tisfas forms a face (optionally of a type) for the evaluation of some further hoon
:: wain-file is a wain derived from the scry of a path called pax
::
=/  wain-file  .^(wain %cx pax)
:: The next line simply casts the wain as a tang, a pretty-printing text format
::
`tang`wain-file
```
And now, let's try using it (don't forget to `|commit %home`)
```
> +readmytang %/test/txt
~['This is a test' 'Test line 2']
```

