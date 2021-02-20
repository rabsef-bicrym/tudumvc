# If an App is Worth Todo-ing, it's Worth `tudu`-ing Well
In this lesson, we're going to take a look at the basic _React.js with Hooks_ version of TodoMVC provided by the [TodoMVC project](https://todomvc.com/). We'll learn about the following items:
1. How TodoMVC React-Hooks can be installed locally for some testing and modification
2. How TodoMVC React-Hooks stores its data
3. How we might emulate and perhaps improve on the data structure of TodoMVC React-Hooks in Hoon

## Goals
* Install TodoMVC React-Hooks example on our server
* Launch the dev instance of TodoMVC React-Hooks and 
* Examine the data structure of TodoMVC React-Hooks
* Build a very simple version of a Todo `app` for our urbit that mirrors the functionality of the TodoMVC React-Hooks example

## Installing TodoMVC React-Hooks
Let's get this running locally.  Clone the repository for TodoMVC from [here](https://github.com/tastejs/todomvc) - that'll go something like this:
```
$ git clone https://github.com/tastejs/todomvc.git
Cloning into 'todomvc'...
```

That'll take a minute to download everything from that repository (all sorts of different versions of the app), but when we're done, we're ready to start installing. Move into the React-Hooks folder using `cd todomvc/examples/react-hooks` (replacing the beginning with whever you cloned the repository.

To install the app from there, I'll be using `yarn` to do most of my work for me, but you could use `npm` if you prefer it (weirdo).  Let's get installing:
```
$ yarn install
yarn install v1.22.10
info No lockfile found.
...
[4/4] Building fresh packages...
success Saved lockfile.
Done in 52.65s.
```

## Launch the Dev Instance of TodoMVC React-Hooks
Once the installation is done, you'll be back at your shell.  Let's boot the app:
```
$ yarn run dev
yarn run v1.22.10
$ react-scripts start
```
`yarn run dev` will start up the app on `localhost` (or wherever your server is) at port 3000.  Once it's ready, you'll see this:
```
Compiled successfully!

You can now view hooks-todo in the browser.

  http://localhost:3000/

Note that the development build is not optimized.
To create a production build, use yarn build.
```

Now we're ready to experiment!

## Examine the Data Structure of TodoMVC React-Hooks
Navigate to the site you've just launched (probably at [http://localhost:3000](http://localhost:3000)). You should take some time to play around in the app here and see what it can do.  Add some tasks, mark some as complete, delete some, add some more. Once you've got a nice `state` built up from adding tasks, let's take a look at the data structure.
* Open the console in your browser and key in `localStorage`.  You'll see something like this:
```
>> localStorage
<- > Storage { todos: "[{\"done\":true,\"id\":\"a7859d5f-a05b-fcb4-f63f-347d50b10c27\",\"label\":\"done-task\"},{\"done\":false,\"id\":\"fc8db1df-cd84-600f-9b50-ed21fd4b5c95\",\"label\":\"test-task\"}]", length: 1 }
```
This tells us that we have an object in localStorage called "todos" that contains an array of objects of our tasks. We can get at this object, however, and see it a little more closely.  Let's take a peek at that object:
* Store the localStorage object as a variable
```
>> var test = localStorage.getItem("todos");
<- undefined
>> test
<- "[{\"done\":true,\"id\":\"a7859d5f-a05b-fcb4-f63f-347d50b10c27\",\"label\":\"done-task\"},{\"done\":false,\"id\":\"fc8db1df-cd84-600f-9b50-ed21fd4b5c95\",\"label\":\"test-task\"}]"
>> JSON.parse(test);
<- (2) […]
> 0: Object { done: true, id: "a7859d5f-a05b-fcb4-f63f-347d50b10c27", label: "done-task" }
> 1: Object { done: false, id: "fc8db1df-cd84-600f-9b50-ed21fd4b5c95", label: "test-task" }
length: 2
<prototype>: []
```
Ok - so we have an array of _n_ objects (depending on how many tasks you made). Each object has three attributes: done, id and label. Done is a `boolean`, ID is just a random string or unique identifier and Label is the task string (the title of the task).

We basically have what we need to get started building the app here:
* A `task` object with a `label`, `id`, and `done`-ness state
* Ability to:
  * Add tasks
  * Delete tasks
  * Mark tasks as complete
  * Edit the `label` of a task

Let's build this thing.

## Building the App
You're in luck, because I've already built this app for you.  We'll examine this app just like we did `%firststep` and walk through all of the important and different bits.




