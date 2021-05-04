## Overall Lesson Structure
  * Introduction - What we'll learn
  * Goal of lesson - What we'll do
  * Prerequisites - What you'll need
  * Lesson Content - provide "what we'll learn" and accomplish "what we'll do"
    * Links to in-depth elements of Lesson Content if needed/where applicable
  * Homework - Readings to supplement learning
    * Could include in-depth elements presented in Lesson Content

## Introduction
`tudumvc` is an implementation of the React.js + Hooks version of [TodoMVC](https://jacob-ebey.js.org/hooks-todo/#/) that uses Urbit as a back-end. The Urbit backend supports all of the open-web functionality _including_ serving the front-end without any need for client-side storage. With minimal changes to the existing source code and less than 200 lines of back-end code, `tudumvc` is responsive, lightweight, and expandable.

`tudumvc` is an excellent example of the advantages of incorporating Urbit in your stack. The React.js + Hooks implementation of TodoMVC is a stateful application that updates its presentation layer on state change (when the underlying data about tasks changes). Urbit is a deterministic operating system, sometimes called an operating function, and it functions off of a basic pattern of state -> event -> effects -> new state. `tudumvc` compliments this basic pattern by using the React.js front end to produce events, using Urbit to interpret those events and produce effects and a new state and returning the state to React.js to be displayed.

The back-end development required to host an app like `tudumvc` is minimal and straightfoward, as are the changes we have to make to the React.js + Hooks TodoMVC implementation. Further, Urbit's `%gall` applications are inherently capable of cross-integration, so it would be a relatively straightforward task to integrate the functionality of `tudumvc` into other Urbit apps, like "groups", or even just allow the app to network with other self-hosted instances of `tudumvc` on other ships in the Urbit universe.

If you want to know more about the advantages of building applications on Urbit, check out this [interview I've done w/ `~radbur-sivmus` and `~timluc-miptev`](#).

## How-To Dev Ship
  * Introduction
    * How are we going to do the dev for the rest of the lessons?

      _We're going to create a stable clean-slate development ship and then clone it repeatedly as we make changes to the application. We'll do this so we don't have to worry about breaking our ship; so that we can try things, make mistakes and keep moving._
    * What do we need to get started

      _We need a dev ship, we need a development environment and we need a syncing process to connect our development environment with our (current) dev ship. We also need a clean copy of our dev ship as a backup, so that we can swap that in easily._
    * Clone the repository local so you can do your work easily without having to copy pate
    
      _We want a copy of the repository local to our development environment so that we can swap in files quickly and without copy-pasting them from the repository._

  * Goals
    * Be able to restart your dev environment fresh at any time

      _We'll show you how to create a dev ship, back up a working/clean version of it, and set up an external-to-ship coding environment wherein you can write your files and copy them to your current dev ship.  If you mess something up, you just revert your changes, blow up your existing dev ship, copy in your backup and start again._
    * Have the materials for the rest of the lessons available

      _This is really just cloning a git repository into your local development environment. Even if not specifically required for this exercise, it does help introduce some git functionality which, if you're not already familiar, will give you some skills that will help you continue application development beyond this guide._
    * Have a working Dev ship

      _We do want to be certain that our environment is reasonably set up.  We'll check it using a few of the in-built functionalities of Urbit, like logging into landscape and creating a group._
    * Be logged in to landscape

      _We're just logging into the primary Earth web interface of our Urbit here.  This confirms that it's working as well as introducing us to the Earth web login experience using +code_
  * Prerequisites
    * Urbit Binary
    * *nix based system
  * Lesson Content
    * Get a hosting platform

      _I'll introduce you to a few hosting options if you're utterly unfamiliar with VPS services and suggest some that might work for your Urbiting adventures._
    * Get the Urbit Binary

      _Urbit is a program that runs in *nix systems. The Urbit Binary is the program and we'll need a copy of it to do anything in Urbit. If you already have a ship, you likely already have the binary._
    * Launch a Fake Ship

      _A fake ship is an unnetworked, un-registered Urbit that can be used for development. It can't communicate with any external nodes of the Urbit network, but it can communicate with other, local fake ships.  We'll do this later when we add network integration to our application_
    * Log in to Landscape (learn +code)

      _Landscape is the basic Earth web interface for Urbit and where most Urbiteers spend their time. While we're not creating an extension of Landscape with this project, we are using the same authentication functionality to secure our instance of `tudumvc` from other Earth web users (or, at least, we could do so). Logging into landscape shows us how this might work._
  * Homework
    * Read about cores from Hooniversity

      _Cores are the basic function-structures in Urbit. Cores are something like functions and can contain subroutines.  We'll want to be familiar (generally) with the terminology of cores so we can better understand what's going on in our Urbit back-end._
  * Exercises
    * Boot a moon for your real ship and merge the fully functioning end-state application from my moon

      _I'll help you get a fully functional instance of `tudumvc` running on a Moon so you can immediately start using it, perhaps even to track where you are in the lessons here.  You can also tear this apart, if you want, and learn by deconstruction._

  * Transition: _Alright, we have a development environment.  Let's get to work implementing TodoMVC on our development ship_

## Host the Existing App
  * Introduction
    * How to host files using file-server

      _`file-server` is a built in `gall` application in its own right, and it helps us serve files to Earth web using `eyre`. We'll take a look at how we're hosting the basic TodoMVC application using `file-server` and a very simple `gall` application. After this, you should be able to host your own (at minimum) static HTML content using your Urbit_
    * What file-server does
      
      _`file-server` takes a file path in your Urbit and makes it available to the Earth web. As it is a `gall` app, we communicate to it using `card`s and `poke`s, which we'll investigate in an upcoming lesson_
    * What file-types are allowed by Urbit and what are not (presently, this is extensable though)

      _There are **some** limitations on what kinds of files Urbit can serve to Earth web presently, but the central Tlon development team is constantly adding to this and there are many community efforts to extend allowed file types to new media types.  Further, this is something you can do entirely on your own on your own ship and still have it available on the clear web.  We won't get into adding new file type support to Urbit in these lessons, but we'll touch on where you might begin_
  * Goal
    * Have TodoMVC running on your ship

      _This is just the BASIC implementation of TodoMVC React.js + Hooks and does not actually talk to our Urbit ... yet! We'll take a look at it to get used to the required features/functionality/data structure so that we can build our Urbit app to integrate with it._
    * Examine `%clay` briefly

      _`%clay` is Urbit's file system. We need to know some basics about `%clay` in order to do most of the work in the rest of this guide. We'll get used to working at it in this section so we can better understand what we're doing later on. Since data and applications are basically the same thing in Urbit, we will take a look at how we can read data from our `tudumvc` application using `%clay` in a later lesson, so it's good for us to have a basic understanding here._
  * Prerequisites
    * Fresh Dev Ship
    * Lesson 1 Files Synced to Fresh Dev Ship
  * Lessson Content
    * Get TodoMVC on ship

      _Again, this is just the basic application we're hosting, but we're getting familiar with the file hosting process so we'll be ready to do it in future as we build `tudumvc` (the fully interactive, Urbit centric version)_
    * Review some of the files using `%clay`

      _We're just going to learn how to examine our Urbit's filesystem from within Urbit.  We will already be familiar with examining the file sytem from our *nix environment.  _
    * Access TodoMVC on our ship from Earth web

      _We'll need our understanding of how to log in to an Earth web app hosted by our Urbit that we learned from accessisng Landscape.  We'll also investigate the functionality of TodoMVC so we can begin to formulate ideas about how we might implement the features in Urbit._
  * Homework
    * Read ~timluc-miptev's Gall Guide introduction for additional information
  * Exercises
    * Create another app using the app framework from Lesson 1 and host a static html page that says "Hello World!"

      _I will write a breakout where I actually walk through this with the user, but allow them to try it on their own, should they so choose_
  * Transition:   _We have the basic app running on our ship and we know how to host Earth web.  But, if we want our Earth app and our Urbit to interact we're going to need several things: (1) An input integration between the Earth app and the Urbit app (2) a data storage element in our Urbit app to maintain the data being produced by our Earth app (3) a way of examining our Urbit's data storage from the Urbit side, in case we want to inspect it or see how it's working (4) a way of interacting with state, or creating events that change the state (e.g. adding tasks)_

## Start from the beginning
  * Introduction
    * Apps as both services and data managers

      _From ~timluc-miptev's Gall Guide which you read last lesson: "Gall's capabilities go well beyond what you normally think of as "standalone applications." Because of Urbit's design, Gall apps/modules can cleanly interact with other apps/modules on the local ship or remote ones. They also can call the operating system in ways that are much more manageable than you may be used to in Unix programming (if you have that background)._

      _Gall modules can, for example:_
      * _run background chron jobs that periodically check your data_
      * _coordinate data sources from other Gall apps_
      * _provide full-blown user experiences with frontend_
      * _run database resources that back multiple services_

      _This is why I asked the user to read this in the last lesson_

    * State as the data management function of our apps
      
      _Urbit `%gall` applications are `state`ful.  In fact, all programs in Urbit are evaluated in relation to some `subject` or data context.  Our `%gall` applications will, at each input, perform some computation with the `state` in mind and return a versions of themselves with the calculated changes to the `state` based on the input given.  In the introduction, we explained that urbit is something like an Operating Function that has a basic pattern of state -> event -> effects -> new state.  In this lesson we'll learn how to set the `state` of a `%gall` application and how to update the `state` of that `%gall` application to accommodate changes to our app's functionality; this is a common need in application development and we'll want to be ready for it as it._
    * Pokes as input to our app that can come from basically any source: our own keystrokes in dojo, other apps, or the Earth web

      _Pokes are just a way of inputting data to our app. They differ from what you may imagine as traditional input in that they can come from basically any source without significant modification to the underlying application.  It's like we have a built in API for our application in the way `%gall` manages all applications - this is one of the greatest advantages of developing on Urbit_
    * Scrys as ways to read into our app from `dojo`

      _Everything in Urbit is data, including programs.  In contrast to most development environments, we have the ability in Urbit to treat our program as data and access the `state` of the program conveniently.  In this lesson we'll examine one **really easy** way of accessing the data (this way might not always be available) and one slightly less easy way that is slightly more powerful.  These two ways are `+dbug` and `scry`ing, respectively. Being able to access a program as data is highly efficient and also promotes application cross-integration, and it is important that you learn about it as you move forward with developing Urbit applications_
  * Goals
    * Have an app with some state `(list [id=@ud label=@tU done=?])`

      _This is the way that data is stored in TodoMVC by default, a list of objects.  We'll start this way to show that we can but then change to a map which is easier to access, generally, and frankly a better way of storing the same data.  We don't need to change TodoMVC to allow us to store data in Urbit in the better storage method, so don't worry too much about that.  Instead, we'll handle all that in the communication between Earth web app and Urbit._
    * Upgrade that state `(map id=@ud [label=@tU done=?])`

      _This is the correct way of storing the data from TodoMVC in Urbit because it makes it easier to index, access, and change specific tasks in the apps.  We'll also learn how to upgrade state by starting on a list and ending on a map.  As stated above, over an apps lifecycle it's all but inevitable that you'll need to modify how data is stored.  Starting with this easy example of `state` upgrading will allow you to get a grasp on the upgrade process while we're still dealing with an easy example. You'll be ready for more challenging state upgrades when you start developing on your own._
    * Examine the Types used in state (breakout)

      _Though I will explain the type of a list and the type of a map in the lesson proper, we'll go into some discussion of Urbit types in greater detail in a breakout lesson_
    * Create a poke action to influence the state

      _In other words, take input, produce effects, receive an updated state_
    * Examine tisket functionality and cards (breakout in part)

      _This is complicated and also necessary to understand if you want to read existing applications effectively.  Tisket is a shorthand that allows us to break out state updating and card production to other arms and return that to a more terse arm that produces effects.  It will be an extension/breakout lesson that covers cards **and** tisket_
    * Find our state using +dbug

      _dbug is a generator that wraps an application and allows us to easily see the state of a program.  That being said, it may not always be available to us and so we'll also need to know how to use scrys_
    * Find our state using a scry

      _scrying is a more universally available but slightly more difficult way of seeing the state of a given `%gall` app.  We'll examine how this works and why we would want to know about it.  We'll also learn how to use it against existing applications, which we would want to know if we intend on integrating our apps with other apps.  In order to integrate apps, we need to know how they store data and plan how we'll interact with that data store.  Using a scry we can quickly and effectively query data from the other app for our own purposes in planning that integration_
    * Examine scrys (breakout)

      _further investigation of the above_
  * Prerequisite
    * Fresh Dev Ship
    * Lesson 2 Files Synced to Fresh Dev Ship
  * Lesson Content
    * Install a stateful app
    * Poke the app and change the state
    * Examine the state using +dbug
    * Examine the state using a scry
    * Upgrade the state and repeat
    * Examine how tisket allows us to influence state

    _these are all covered in the above explanations_
  * Homework
    * Read ~timluc-miptev's section on scrys
    * Read the scry section of `chat-store.hoon`
  * Exercise
    * Write an additional scry for our app that returns only completed tasks
    * Scry chat-store

  * Transition: _We've made a data structure, we've written inputs to allow us to change that data structure.  Next, we have the (actually) simple task of getting TodoMVC to interact with our data structure.  This is the last real step before we have a working `tudumvc` of our own, and it will be less painful than you might think!_

## Earth to Mars Connection
  * Introduction
    * How to communicate with the outside world
      
      _The web uses JSON to store and communicate data (in many contexts, at least). Urbit just uses Hoon.  We're going to need to learn how to translate JSON into Hoon and back in order for this system to work_
    * How JSON looks in Hoon

      _Hoon has built-in typing for JSON objects and we'll learn about how that looks and how we can work with it in this lesson_
    * How Hoon handles JSON

      _We will also learn how we can convert Hoon-native types to JSON and back in this lesson.  With this ability, we're basically ready to get TodoMVC to talk with our app._
  * Goals
    * Connect TodoMVC to our ship, trivially (airlock, arbitrary button that pokes)

      _Airlock is a pre-built integration using JavaScript that will allow our ship to communicate with our Earth web app and vice-versa.  It's basically plug and play, but we'll talk about how to configure it here_
    * printf our JSON from TodoMVC so we can see how it looks

      _Basically, we want to see how the JSON coming in from our Earth web app looks and then design a parser to turn it into a Hoon type.  This lesson will focus on that specific data but we'll also have a breakout lesson where you can learn more_
    * Write a parsing function for our JSON poke so we can make it actually do something

      _We'll write a function that takes our incoming simplictic poke function and turns it into a fully-Hoon poke_
  * Prerequisites
    * Complete prior lesson _OR_
    * Start a fresh dev ship and sync the lessosn files
  * Lesson Content
    * Set up airlock and run TodoMVC from its own folder (we'll replace the minified content in what our urbit is hosting later)
    * Add a poke button to the TodoMVC app
    * Printf JSON
    * Parse JSON
  * Homework
    * Read through the JSON parsing functions available
  * Exercises
    * Parse these JSON (need examples)
    * Upgrade the poke to pass a more complicated JSON and update the app to handle that
    * Add a subscription action using airlock and an on-watch section 

## Updating the App for Mars
  * Introduction
    * How to fully upgrade app to run _only_ on urbit for data
    * How to use on-watch
    * How to add all required pokes
    * How cards work
  * Goals
    * Add required pokes
    * Upgrade app
    * Add subscription and cards
    * Package our finished content, minified, and start hosting this on the urbit
  * Lesson Content
    * Add pokes
    * Add on-watch functionality
    * minify our app and host it
  * Homework
    * TBD - something on app subscriptions
  * Exercises
    * TBC - something on app subscriptions