# Hosting Files - TodoMVC on Urbit (sort of)
In this lesson, we'll get the default React.js + Hooks implementation of TodoMVC running on our ship. While this will allow us to directly host the application from Urbit, however it won't have full Urbit integration until a later lesson. Instead, in this inital attempt, we're basically just making the default app available on the Earth web, served from our Urbit.

## Learning Checklist
* How to use `yarn` to run JavaScript apps in a _dev_ environment.
* How to use `yarn` to package JavaScript apps for hosting.
* How to host Earth web files from Urbit.
* What does the file-server app do?
* What file types is Urbit capable of serving?
* How would one go about expanding the set of file types that Urbit can serve?
  * **NOTE:** We will not actually implement serving of additional filetypes.

## Goals
* Prepare a minified version of TodoMVC from the source code.
* Host the minified version of TodoMVC (or some other Earth web file) from our Urbit.
* Briefly describe the use of `/mar` files in Urbit.

## Prerequisites
* A development environment as created in Lesson 1.
* The Lesson 2 files downloaded onto your VPS so that you can easily sync them to your development environment.

## The Lesson
[TodoMVC](https://github.com/tastejs/todomvc) is a basic todo list that has been replicated in a variety of JavaScript frameworks to help teach how those JavaScript frameworks differ. We're going to look at the [React.js + Hooks](https://github.com/tastejs/todomvc/tree/master/examples/react-hooks) implementation of TodoMVC which best compliments Urbit's functionality.

Urbit is sometimes described as an Operating Function rather than an operating system because it is a fully deterministic, `state`ful or `subject`-oriented computing environment that is fully [referentially transparent](https://en.wikipedia.org/wiki/Referential_transparency). This means two things:
* Every input that Urbit receives is processed as an event which changes (or at least can change) the `state`, or currently available data of the Urbit.
* The resulting state of an Urbit post event-processing is indistinguishable from an Urbit that just had that state to start with (generally speaking).

Therefore, given some starting `state` and some expected input, an Urbit will predictably arrive at some resulting `state`, and that resulting `state` is effectively indistinguishable from some other Urbit that simply started with that resulting `state`. The events themselves aren't particularly relevant (generally), only the `state` matters in determining what our Urbit is doing or displaying at any given time.

Similarly, React.js is a Javascript framework that renders a DOM (or, effectively, a webpage) based on the current `state`. Changes are managed by changing the `state` which React automatically interprets into a re-rendered DOM. It doesn't matter to React.js why or how the `state` has changed, only that it has. When the `state` changes, the DOM re-renders.

Urbit and React.js are both similarly `state`ful and, by the end of this guide, we'll see that Urbit is a great candidate for managing a React.js app's `state` and returning a changed `state` for React.js to re-render into a DOM.

Let's start by preparing our TodoMVC app for hosting:

### Preparing TodoMVC
Navigate to the `/todomvc/examples/react-hooks` folder. The files in this folder are all still basic JavaScript files. There are two basic ways we can interact with these files:
* As a dev environment run directly from the files.
  * This method allows us to run the app directly from the files and have changes made to the JavaScript automatically cause the page to rerender.
* As a minified "build" of the files.
  * This method requires that we host the app as a Earth web page and is fairly difficult to modify further.
  * Minifying should be done once you're satisfied with your app and ready to deploy it (but we're going to do it anyway during this exercise - you're not my Dad).

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
We can use `yarn` to run our app without minifying it which allows us, as stated above, to make changes to the underlying JavaScript files while the app is running and watch as the changes magically appear on screen. This is JavaScript Voodoo and is probably sacrilege, but it works.

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
You may also notice that you have a new, `/build` sub-folder in your `./react-hooks`. This is where the minified files live. We're going to copy the **_contents_** of this `/build` sub-folder into a folder that we'll make in the `/app` folder in our `/devops` folder.  Make a folder like `/devops/app/todomvc`, then use your sync routine to allow them to flow to your Fake Ship.  Lastly, run `|commit %home` in your Fake Ship's `dojo`.

Ok - something bad just happened. You received an error message terminating in something like:
```
[%error-validating /app/todomvc/favicon/ico]
[%validate-page-fail /app/todomvc/favicon/ico %from %mime]
[%error-building-cast %mime %ico]
[%no-file %mar %ico]
```
Our Urbit was unable to interpret the file type `.ico` (or the favicon icon for TodoMVC) and it made our ship mad. Note that the error message ends by saying that there is `%no-file %mar %ico`. The `/mar` folder in our Urbit consists of files that help us interpret non-hoon file types into hoon legible files. To date, no one has written an `%ico` interpreting file, but maybe you could be the first! Take a look at `/mar/png.hoon` if you'd like and consider how you might build an `ico.hoon` file.

Rather than dealing with that here, however, let's just do the following:
1. Stop our sync process
2. Delete the `favicon.ico` from the `./devops/app/todomvc` folder
3. Replace our Fake Ship
    * `CTRL+D` to shut down the ship
    * `rm -r nus` to delete the current version
    * `cp -r nus-bak nus` to replace our Fake Ship
    * `./urbit nus` to run it again
4. Restart the sync process
5. `|commit %home` again

Everything should complete this time. Now we need to host these files using our Urbit.

### Hosting Earth Web Files from Urbit
To get started on integrating TodoMVC with Urbit, we need to be able to host web pages from our Urbit. To do this, we'll use the file-server `%gall` `agent`.

We'll start by examining how Urbit communicates with `agents`:

#### `%gall` `agents`
Urbit applications (also known as `agents`) are programs with a rigorously defined structure of a core with 10 arms. This standardization of style is complimented by a standardization of handling by the application management `vane` (or kernel module) of Urbit, called `%gall`. The benefit of these standards is that it effectively makes all `agents` interoperable through a rigorously defined interaction method. These methods take two forms:
* `poke`s
* `quip`s of `card`s

We'll spend more time later talking about `poke`s and `card`s, but for now we can suffice to say that a `poke` is input to a specific `%gall` application and a `card` is cross-communication or instruction to be provided to a `%gall` `agent` or `arvo` `vane` from another `%gall` `agent` or `arvo` `vane`.



####

## Homework

## Exercises

## Summary and Addenda