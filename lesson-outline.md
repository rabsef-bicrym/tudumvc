## Overall Lesson Structure
  * Introduction - What we'll learn
  * Goal of lesson - What we'll do
  * Prerequisites - What you'll need
  * Lesson Content - provide "what we'll learn" and accomplish "what we'll do"
    * Links to in-depth elements of Lesson Content if needed/where applicable
  * Homework - Readings to supplement learning
    * Could include in-depth elements presented in Lesson Content

## How-To Dev Ship
  * Introduction
    * How are we going to do the dev for the rest of the lessons?
    * What do we need to get started
    * Clone the repository local so you can do your work easily without having to copy pate
  * Goals
    * Be able to restart your dev environment fresh at any time
    * Have the materials for the rest of the lessons available
    * Have a working Dev ship
    * Be logged in to landscape
  * Prerequisites
    * Urbit Binary
    * *nix based system
  * Lesson Content
    * Get a hosting platform
    * Get the Urbit Binary
    * Launch a Fake Ship
    * Log in to Landscape (learn +code)
  * Homework
    * Read about cores from Hooniversity
  * Exercises
    * Boot a moon for your real ship and merge the fully functioning end-state application from my moon

## Host the Existing App
  * Introduction
    * How to host files using file-server
    * What file-server does
    * What file-types are allowed by Urbit and what are not (presently, this is extensable though)
  * Goal
    * Have TodoMVC running on your ship
    * Examine `%clay` briefly
  * Prerequisites
    * Fresh Dev Ship
    * Lesson 1 Files Synced to Fresh Dev Ship
  * Lessson Content
    * Get TodoMVC on ship
    * Review some of the files using `%clay`
    * Access TodoMVC on our ship from Earth web
  * Homework
    * Read ~timluc-miptev's Gall Guide introduction for additional information
  * Exercises
    * Create another app using the app framework from Lesson 1 and host a static html page that says "Hello World!"

## Start from the beginning
  * Introduction
    * Apps as both services and data managers
    * Pokes as actions to our app that can come from basically any source
    * Scrys as ways to read into our app from `dojo`
  * Goals
    * Have an app with some state `(list [id=@ud label=@tU done=?])`
    * Upgrade that state `(map id=@ud [label=@tU done=?])`
    * Examine the Types used in state (breakout)
    * Create a poke action to influence the state
    * Examine tisket functionality and cards
    * Find our state using +dbug
    * Find our state using a scry
    * Examine scrys (breakout)
  * Prerequisite
    * Fresh Dev Ship
    * Lesson 2 Files Synced to Fresh Dev Ship
  * Lesson Content
    * Install a new app
    * Poke the app and change the state
    * Examine the state using +dbug
    * Examine the state using a scry
    * Upgrade the state and repeat
    * Examine how tisket allows us to influence state
  * Homework
    * Read ~timluc-miptev's section on scrys
    * Read the scry section of `chat-store.hoon`
  * Exercise
    * Write an additional scry for our app that returns only completed tasks
    * Scry chat-store
    * Attempt to host the files w/o reference to file-server

## Earth to Mars Connection
  * Introduction
    * How to communicate with the outside world
    * How JSON looks in Hoon
    * How Hoon handles JSON
  * Goals
    * Connect TodoMVC to our ship, trivially (airlock, arbitrary button that pokes)
    * printf our JSON from TodoMVC so we can see how it looks
    * Write a parsing function for our JSON poke so we can make it actually do something
    * Update our scry functionality
  * Prerequisites
    * Complete prior lesson _OR_
    * Start a fresh dev ship and sync the lessosn files
  * Lesson Content
    * Set up airlock and run TodoMVC from its own folder (we'll replace the minified content in what our urbit is hosting later)
    * Add a poke button to the TodoMVC app
    * Printf JSON
    * Parse JSON
    * Update Scrying
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