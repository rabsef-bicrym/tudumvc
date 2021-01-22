# The Urbit Filesystem `%clay`

In the last lesson, we learned how to christen an urbit and set up a fake ship for Hoon development.  In this lesson, we're going to take a slightly closer look at `%clay` and write a simple hoon to work with it.  This lesson will also lead us to a discussion of the `/mar` mark system.

## `+ls`

As with beloved Unix, we can list the files of any directory in an urbit from within our dojo shell.  `+ls` is a generator stored in your `/gen` folder, by default.  A generator is a simple function-like program that:
1. Takes an argument called a `sample`.
2. Runs some hoons to produce an output (printed or operational or what have you).
3. Returns the result of its operation to your urbit to be handled.
Let's try using it.  In the dojo, try this: `+ls %/`:
`app/ gen/ lib/ mar/ sur/ sys/ ted/ tests/`

Great - we've just learned a few things:
* We're operating in our `home` directory, by default, in our urbit as told by the presence of the folders seen above.
* `%/` is apparently a reference to this home directory.
* Each folder is denoted as just its name followed by `/` (pronounced `fas`).

Now let's try `+ls /===`.  Same result!  `%/` and `/===` must be equivalent statements.  The `sample`, or argument, that we're passing `+ls` is a `path`, which is just a way of denoting a certain area of the `%clay` filesystem. `path`s consist of a `beak` and no or some additional filepath identification.  `%/` is a shorthand way of denoting the current relative path, which in our case is the `home` `desk` (a workspace containing directories) on your urbit, in the current version, or `case`.  When we give the sample `/===` we're saying "use the default `desk` of our `ship` in the curreent version - so in most cases that will be the same as `%/`.  We could substitute other values, however, and get (potentially) different results.  As a trivial example of this, try `/<~sampel-palnet>/kids/=` - you'll see you get effectively the same information but from your `kids` `desk`, rather than your `home` `desk`.

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
Create a file in Unix called test.txt within the home directory of your test urbit.  Put a few lines of text into it and the proceed:
* `+ls %/`
    * **NOTE:** Nothing new has happened here.  Again, making a file in the Unix side of things doesn't affect your urbit until you `|commit %home` (or whatever other desk you're working in).
* `|commit %home`
* `+ls %/`
    * **NOTE:** Now you'll see the file you just made - let's take a look at a few ways to work with that file, from here.
 
 
