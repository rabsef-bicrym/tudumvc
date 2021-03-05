# Hosting Files - TodoMVC on Urbit (sort of)
In this lesson, we'll get the default React.js + Hooks implementation of TodoMVC running on our ship. While this will allow us to directly host the application from Urbit, however it won't have full Urbit integration until a later lesson. Instead, in this inital attempt, we're basically just making the default app available on the web, served from our Urbit.

## Learning Checklist
* Interacting with TodoMVC using `yarn`, including
    * How to use `yarn` to run JavaScript apps in a _dev_ environment.
    * How to use `yarn` to package JavaScript apps for hosting.
    * **NOTE:** We're not really teaching `yarn` here, but you'll know how to use it for this very basic application by the end of this lesson.
* How to host web files from Urbit.
* What does the file-server app do?
* What file types is Urbit capable of serving?
* How would one go about expanding the set of file types that Urbit can serve?
  * **NOTE:** We will not actually implement serving of additional filetypes.
* What is a `poke` and how do I do me one?

## Goals
* Prepare a minified version of TodoMVC from the source code.
* Host the minified version of TodoMVC (or some other web file) from our Urbit.
* Briefly describe the use of `/mar` files in Urbit.
* `poke` an app from the `dojo`.

## Prerequisites
* A development environment as created in Lesson 1.
* The [Lesson 2 files](./src-lesson2) downloaded to your development environment so that you can easily sync them to your development environment.

JAL(2021.3.2) Where do I put them? Where was doing this covered?

## The Lesson
[TodoMVC](https://github.com/tastejs/todomvc) is a basic todo list that has been replicated in a variety of JavaScript frameworks to help teach how those JavaScript frameworks differ. We're going to look at the [React.js + Hooks](https://github.com/tastejs/todomvc/tree/master/examples/react-hooks) implementation of TodoMVC for two main reasons:

The first is the ubiquity of React.js for web app development. TodoMVC's React.js + Hooks implementation also incorporates the most modern usage of React.js (Hooks) which is, in our opinion, the best way of building modern front ends, regardless of its dominance in the market.

The second is slightly more involved. Urbit is sometimes described as an Operating Function rather than an operating system because it is a fully deterministic, stateful or `subject`-oriented computing environment that is fully [referentially transparent](https://en.wikipedia.org/wiki/Referential_transparency). This means two things:
* Every input that Urbit receives is processed as an event which changes (or at least can change) the state, or currently available data of the Urbit.
* The resulting state of an Urbit post event-processing is indistinguishable from an Urbit that just had that state to start with (generally speaking).

Therefore, given some starting state and some expected input, an Urbit will predictably arrive at some resulting state, and that resulting state is effectively indistinguishable from some other Urbit that simply started with that resulting state. The events themselves aren't particularly relevant (generally), only the state matters in determining what our Urbit is doing or displaying at any given time.

Similarly, React.js is a Javascript framework that renders a DOM (or, effectively, a webpage) based on the current state. Changes are managed by changing the state which React automatically interprets into a re-rendered DOM. It doesn't matter to React.js why or how the state has changed, only that it has. When the state changes, the DOM re-renders.

Urbit and React.js are both similarly stateful and, by the end of this guide, we'll see that Urbit is a great candidate for managing a React.js app's state and returning a changed state for React.js to re-render into a DOM.

Let's start by preparing our TodoMVC app for hosting:

### Preparing TodoMVC
Navigate to the `/todomvc/examples/react-hooks` folder. The files in this folder are all still basic JavaScript files. There are two basic ways we can interact with these files:
* As a dev environment run directly from the files.
  * This method allows us to run the app directly from the files and have changes made to the JavaScript automatically cause the page to rerender.
* As a minified "build" of the files.
  * This method requires that we host the app as a web page and is fairly difficult to modify further.
  * Minifying should be done once you're satisfied with your app and ready to deploy it (but we're going to do it anyway during this exercise).
  
JAL(2021.3.2) We haven't gone over how to get the `react-hooks` files onto our system yet. Do we use what's in `src-lesson2` or do we clone `tastejs/todomvc`?

We'll work through both methods here, as we're going to need both going forward.

#### `yarn install`
Start by running `yarn install` in the `./react-hooks` folder. `yarn install` looks at all the dependencies required to run TodoMVC and downloads the relevant packages. This is all JavaScript-y stuff that is well covered elsewhere on the internet and is otherwise fairly boring, but if you want to know more about how this works, you might take a look [here](https://classic.yarnpkg.com/en/docs/cli/install/). In either event, it should complete with some output that looks like this:
```
[4/4] Building fresh packages...
success Saved lockfile.
Done in 40.09s.
```
We're now ready to pick between one of two ways of interacting with the app. We can either:

#### Run a Dev Version of the App
We can use `yarn` to run our app without minifying it which allows us, as stated above, to make changes to the underlying JavaScript files while the app is running and watch as the changes magically appear on screen.

From your `./react-hooks` folder where you just ran `yarn install`, go ahead and run `yarn run dev`. Your app will load in browser (if you're using VS Code and it's port forwarding) or will otherwise be available at the location stated in the completion text:
```
Compiled successfully!

You can now view hooks-todo in the browser.

  http://localhost:3000/

Note that the development build is not optimized.
To create a production build, use yarn build.
```
Nice - we're running TodoMVC.  Let's make a change to a file and see how that displays. Open the `./react-hooks/containers/TodoList.js` file and edit line 66:
<table>
<tr>
<td>
Base File
</td>
<td>
Modified File
</td>
</tr>
<tr>
<td>

```
<h1>todos</h1>
```
</td>
<td>

```
<h1>tudus on Urbit</h1>
```
</td>
</tr>
</table>

Save your changes and watch as your app in your browser magically reloads with the new header text. We're going to use this method later to make changes to this file and test them as we integrate TodoMVC with Urbit.

But, for now, we just want to host this default version on Urbit. Which we can do using the next method. Go ahead and shut down this dev build by doing `CTRL+C` in the terminal window that's currently running the `yarn` dev server.

#### Compiling a Minified Version of an App
Within the `./react-hooks` folder again, enter the command `yarn build`. You'll get some output like this:
```
yarn run v1.22.10
$ react-scripts build
Creating an optimized production build...
Compiled successfully.

File sizes after gzip:

  56.32 KB  build/static/js/2.1ff61cb7.chunk.js
  2.5 KB    build/static/js/main.fd6ebb66.chunk.js
  1.74 KB   build/static/css/2.8e2a78c7.chunk.css
  771 B     build/static/js/runtime~main.60127afb.js
  72 B      build/static/css/main.be9cd952.chunk.css

The project was built assuming it is hosted at /hooks-todo/.
You can control this with the homepage field in your package.json.

The build folder is ready to be deployed.
```
You may also notice that you have a new, `/build` sub-folder in your `./react-hooks`. This is where the minified files live. We're going to copy the **_contents_** of this `/build` sub-folder into a folder that we'll make in the `/app` folder in our `/devops` folder.  Make a folder like `/devops/app/todomvc`, then use your sync routine to allow them to flow to your ship.  Lastly, run `|commit %home` in your ship's `dojo`.

Ok - something bad just happened. You received an error message terminating in something like:
```
[%error-validating /app/todomvc/favicon/ico]
[%validate-page-fail /app/todomvc/favicon/ico %from %mime]
[%error-building-cast %mime %ico]
[%no-file %mar %ico]
```
Our Urbit was unable to interpret the file type `.ico` (or the favicon icon for TodoMVC) and it made our ship mad. Note that the error message ends by saying that there is `%no-file %mar %ico`. The `/mar` folder in our Urbit consists of files that help us interpret non-hoon file types into hoon-legible files. To date, no one has written an `%ico` interpreting file, but maybe you could be the first! Take a look at `/mar/png.hoon` if you'd like and consider how you might build an `ico.hoon` file.

JAL(2021.3.3) Making Urbit aware of the `.ico` type would probably be a valuable exercise.

Rather than dealing with that here, however, let's just do the following:
1. Stop our sync process
2. Delete the `favicon.ico` from the `./devops/app/todomvc` folder
3. Replace our ship
    * `CTRL+D` to shut down the ship
    * `rm -r nus` to delete the current version
    * `cp -r nus-bak nus` to replace our ship
    * `./urbit nus` to run it again
4. Restart the sync process
5. `|commit %home` again

Everything should complete this time. Now we need to host these files using our Urbit.

### Hosting Files from Urbit
To get started on integrating TodoMVC with Urbit, we need to be able to host web pages from our Urbit. To do this, we'll use the [`file-server`](TODO) *agent*.

Let's explain what that is.

#### Gall agents 

A primary building block in Urbit backends is called an [*agent*](TODO). You can think of an agent as a back-end service with a built-in database.

Each agent conforms to a specific well-defined interface. That interface is implemented as a [*core*](TODO) (kind of like a class) with ten [*arms*](TODO) (kind of like a method). Another way to think of a gall agent is as a [microservice](https://en.wikipedia.org/wiki/Microservices), but without the painful devops.

Agents are managed by a kernel [*vane*](TODO) called [*gall*](TODO). Gall is responsible for defining both agent interface and the protocol for inter-agent communication. Agents communicate using [*pokes*](TODO) and [`card`](TODO)s.

We'll spend more time later talking about `poke`s and `card`s, but for now it suffices to say that a *poke* is an input to a specific agent and a `card` is data used to convey instructions across vanes or agents. 

We're going to perform a `poke` from the `dojo` to tell `file-server` to start serving our TodoMVC web app, so let's take a look at how that agent expects us to communicate with it.

#### The `/sur` file
The logic of an agent and the data structures that it defines for public use are typically separated. Agents are defined in the `/app` folder, while their data structures are defined in the `/sur` file (the two files typically have the same name). You can think of what's in the `/sur` file as an agent's public API. 

It's common practice to define an `action` type in the `/sur` file. The `action` type effectively tells us what kind of `poke`s, or what kind of input, we can provide that agent. 

Open the file `/sur/file-server.hoon` and take a look at the definition of `action`:
```
+$  action
  $%  [%serve-dir url-base=path clay-base=path public=? spa=?]
      [%serve-glob url-base=path =glob:glob public=?]
      [%unserve-dir url-base=path]
      [%toggle-permission url-base=path]
      [%set-landscape-homepage-prefix prefix=(unit term)]
  ==
```
The rune [`+$`](https://urbit.org/docs/reference/hoon-expressions/rune/lus/#lusbuc) (pronounced lus-buc; find more rune use information [here](https://storage.googleapis.com/media.urbit.org/docs/hoon-cheat-sheet-2020-07-24.pdf)) defines a type. The first argument following `+$` is the name of the type and the second argument is the specification of the type. Here, the specification of the type is actually, itself, defined by a rune, [`$%`](https://urbit.org/docs/reference/hoon-expressions/rune/buc/#buccen).

`$%` is a [tagged union](https://en.wikipedia.org/wiki/Tagged_union), or list of types with different expected structure that our Urbit recognizes by the *head* value (first element). We can see this above - note that `%serve-dir` (the head of that sub-structure) creates an expectation of four other arguments in that `cell`: 

1. An `url-base` that is a `path`, 
2. A `clay-base` that is also a `path`, 
3. A `public` switch that is a `boolean` and 
4. An `spa` switch that is also a `boolean`.

If your ship is like mine (at the time of this writing), your `/sur/file-server.hoon` file isn't commented, but the [version on the Urbit GitHub](https://github.com/urbit/urbit/blob/50d45b0703eb08a5b46a8ff31818b3a6f170b9f8/pkg/arvo/sur/file-server.hoon#L6) is - let's take a look:
```
::    url-base   site path to route from
::    clay-base  clay path to route to
::    public     if false, require login
::    spa        if true, `404` becomes `clay-base/index.html`
```
Here we can see what each of those arguments does - simply put, `url-base` will set where we're going to serve the page, `clay-base` will tell `file-server` what files to serve at that URL, `public` will switch whether user login is required to access the page (this will use the same login `+code` that you used in the first lesson to log in to Landscape), and lastly `spa` sets the 404 Error page.

In our case, we want to serve our files from `/app/todomvc` (`clay-base` - recall that `%clay` is the filesystem of Urbit) to `http://localhost:8080/~todomvc` (`url-base`) and make them `public` (`%.y`). We will keep the 404 Error page as the default 404 Error page (`%.n`). So, our `action` we'll be `poke`ing `file-server` with will look like this:
```
[%serve-dir /'~todomvc' /app/todomvc %.y %.n]
```

#### `poke`ing `file-server`
To send that `poke` to `file-server` from the dojo we're going to use a command like the following:
```
:<gall agent> &<mark> <poke action>
```
Three things are going on here:
* Specify the agent to `poke` (`:file-server`, for instance)
* Specify the `mark` of the `poke` (`&file-server-action`), so Urbit knows how to interpret it (see the [Breakout Lesson](./lesson2-1-quip-card-and-poke.md) for more information on this)
* Specify the `poke` type and the arguments we're sending as part of that `poke`

Let's try that - in `dojo`, enter:
```
:file-server &file-server-action [%serve-dir /'~todomvc' /app/todomvc %.y %.n]
```

Now, navigate to your ship's URL + `/~todomvc`, like `https://localhost:8080/~todomvc`.

...something is still wrong. You should be seeing a blank page there.

#### Examining Internal References in our Minified File

JAL(2021.3.3) This section doesn't seem that valuable. We're not learning anything about Urbit, just fixing a piece of incidental complexity because we've chosen to host our files at a different URI than the one that the single-page application expects. Why not just serve the directory at `/hooks-todo` instead of `/~todomvc`?

JAL(2021.3.3) I'm getting the following error, albeit things appear to work, whenever the page (on either of the above routes) is hit: why?
```
%nets-failed
%nets-need
@
%nets-have
?(
  %~
  [%a p=it(#2)]
  [%b p=?(%.y %.n)]
  [%n p=@ta]
  [%o p=#1]
  [%s p=@t]
  ?(
    %~
    [%a p=it(#2)]
    [%b p=?(%.y %.n)]
    [%n p=@ta]
    [ %o
        p
        ^#1
      nlr(
        [ p=@t
            q
          ^#2.?(%~ [%a p=it(#2)] [%b p=?(%.y %.n)] [%n p=@ta] [%o p=#1] [%s p=@t])
        ]
      )
    ]
    [%s p=@t]
  )
)
arvo: scry-lost
```


Minified files are hard to edit, but so is tracking down every file reference in an existing application that we're trying to port to Urbit in its non-minified form.  If you look in the console (`F12` key) of your browser that's currently showing a blank page, you'll probably see some errors like the following:
```
The script from “http://138.197.192.56:8080/~/login?redirect=/hooks-todo/static/js/2.1ff61cb7.chunk.js” was loaded even though its MIME type (“text/html”) is not a valid JavaScript MIME type.
```

Note the referent `hooks-todo`. We didn't make our base directory `hooks-todo` so this redirect isn't going to work for us. Make a mental note of the steps we go through next as we're going to need to do them again, later.

In the folder `/app/todomvc` run a find and replace for:
<table>
<tr>
<td>
Find
</td>
<td>
Replace With
</td>
</tr>
<tr>
<td>
hooks-todo
</td>
<td>
~todomvc
</td>
</tr>
</table>
And then `|commit %home`.  Then refresh the page.

Holy shit we did it.

## Homework
* Read through the rest of the commented version of [`/sur/file-server.hoon`](https://github.com/urbit/urbit/blob/master/pkg/arvo/sur/file-server.hoon).
* Read the [`++  on-poke` arm](https://github.com/urbit/urbit/blob/50d45b0703eb08a5b46a8ff31818b3a6f170b9f8/pkg/arvo/app/file-server.hoon#L105) of `/app/file-server.hoon` and try and figure out what's going on there - how is our `poke` being handled?
* Read _just_ the introduction/overview of [`~timluc-miptev`'s Gall Guide](https://github.com/timlucmiptev/gall-guide/blob/master/overview.md#what-is-gall)

## Exercises
* Identify how you might switch our current TodoMVC hosting to `private`, requiring a login.
* Host a static HTML file from your test ship that says "Hello World!" or something else, if you're feeling daring.

## Summary and Addenda
Well, you can host web files from Mars - and there's way less latency than you might imagine (eat your heart out, NASA)! While we'll discuss it later in more detail, you might want to have a better understanding of:
* [`card`s and `poke`s](./lesson2-1-quip-card-and-poke.md)

That breakout is optional, and not necessary to continue. However, by now you should generally:
* Know how to use `yarn` to run a _dev_ version of TodoMVC straight from the non-minified files
* Know how to use `yarn` to package a production build of TodoMVC when we're ready.
* Know how to `poke` `file-server` to ask it to host web content for you
* Know what a `/mar` file does, very generally.
* Know what a `/sur` file does, very generally.
* Know at least one limitation of file types Urbit is immediately able to serve.

<hr>
<table>
<tr>
<td>

[< Lesson 1 - The Bosun](./lesson1-the-bosun.md)
</td>
<td>

[Lesson 3 - The %gall of that agent >](./lesson3-the-gall-of-that-agent.md)
</td>
</tr>
</table>
