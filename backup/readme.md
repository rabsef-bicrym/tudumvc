# TuduMVC - a React.js + Hooks Implementation of TodoMVC with Urbit Integration

TuduMVC is an implementation of the React.js + Hooks version of TodoMVC using an Urbit backbone to support data storage, todo-list modifications (mark as complete, add items, list items, etc.), and serving of the front end page itself.  This guide consists of three parts, each sub-divided into several sub-guides:
1. The **first part** will cover the process from setting up a ship (a unit of the Urbit identity space), learning about our ship generally and how it works, creating a `%gall` app, parsing `JSON` objects in hoon and, finally, upgrading the state of our initial `%gall` app to improve its capabilities. Completing this part of the guide will help you gain confidence in your ability to:
    * [Install the Urbit binary and boot a ship](lesson1-development-cycle.md#step-1---creating-a-suitable-computing-environment)
    * [Create an efficient and replicable development cycle](lesson1-development-cycle.md#step-4---prepare-a-development-environment)
    * [Use and modify the files within an operating Urbit ship](lesson1-development-cycle.md#step-5---develop)
    * [Learn more about the file system and accessing that file system](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson2-the-filesystem.md#ls)
    * [Writing a simple generator that interacts with the file system](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson2-the-filesystem.md#writing-a-generator-to-perform-a-scry)
    * [Use and understand `%gall` agents within Urbit that communicate with Earth](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson3-taking-the-first-step.md)
    * Create "structures" and "marks" ([`/sur`](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson3-taking-the-first-step.md#firststep-sur-file) and [`/mar`](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson3-taking-the-first-step.md#firststep-mar-file) files) to accompany your `%gall` agents
    * [Parsing JSON in Hoon](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson4-state-upgrading-and-json-parsing.md#json-parsing-part-i)
    * [Upgrading the `state` of our `app` file](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson4-state-upgrading-and-json-parsing.md#our-new-app-file)

2. The **second part** will cover initial inspection of an Earth app and the creation of an Urbit app to accommodate interactions with that app, creating a data structure in the Urbit app that houses the Earth app information and `poke`s that allow the Earth app to interact with our data structure, and, finally, hosting the Earth app directly from our Urbit. Completing this part of the guide will help you gain confidence in your ability to:
    * Projecting an Earth app data structure onto structures convenient for use in Urbit
    * Creating Urbit `poke` actions to mirror the required functionality of an Earth app
    * Serve content from your urbit, using both `file-server` and a Gall agent

3. The **third part** will improve our initial implementation by adding in collaborative features to our `tudureact` `%gall` app <to be written>.  Completing this third part of the guide will improve your confidence with Gall agents by introducting the following abilities:

Let's get started!

## Part 1 Lessons

* [Lesson 1 - Booting Your Ship and Starting an Efficient Development Cycle](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson1-development-cycle.md)
* [Lesson 2 - The Urbit Filesystem `%clay`](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson2-the-filesystem.md)
* [Lesson 3 - Ground Control to Major Tom - Hailing Mars from Earth](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson3-taking-the-first-step.md)
* [Lesson 4 - State Upgrading & JSON Parsing](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson4-state-upgrading-and-json-parsing.md)




# Special Thanks
* `~radbur-sivmus`
* `~timluc-miptev`
* `~sarpen-laplux`
* `~tinnus-napbus`
* `~mister-todteg`

and, as always, `~risruc-habteb`
