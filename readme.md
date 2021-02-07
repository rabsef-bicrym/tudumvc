# TuduMVC - a Vanilla.js Implementation of TodoMVC with Urbit Integration

TuduMVC is an implementation of the Vanilla.js version of TodoMVC using an Urbit backbone to support data storage, todo-list modifications (mark as complete, add items, list items, etc.), and serving of the front end page itself.  This guide consists of two parts, each sub-divided into several sub-guides:
1. The **first part** will cover the process from setting up a ship (a unit of the Urbit identity space), hosting the *vanilla* Vanilla.js implementation of TodoMVC, creating a data structure in our application that will house the todo list we're generating from hosting TodoMVC and modifying the Vanilla.js implementation of TodoMVC to communicate with our Urbit as a back-end for that todo list data.  Completing this part of the guide will help you gain confidence in your ability to:
    * [Install the Urbit binary and boot a ship](lesson1-development-cycle.md#step-1---creating-a-suitable-computing-environment)
    * [Create an efficient and replicable development cycle](lesson1-development-cycle.md#step-4---prepare-a-development-environment)
    * [Use and modify the files within an operating Urbit ship](lesson1-development-cycle.md#step-5---develop)
    * Set up a repository for your code on git
    * [Use and understand Gall agents within Urbit](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson3-taking-the-first-step.md#firststep-app-file)
    * Create a data structure within a Gall agent
    * Create "structures" and "marks" ([`/sur`](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson3-taking-the-first-step.md#firststep-sur-file) and [`/mar`](https://github.com/rabsef-bicrym/tudumvc/blob/main/lesson3-taking-the-first-step.md#firststep-mar-file) files) to accompany your Gall agents
    * Serve content from your urbit, using both `file-server` and a Gall agent
    * Update and recompile a Gall agent to accommodate new data structures
    * Understand the basics of the type system within Urbit
2. The **second part** will improve our initial implementation by adding in collaborative features to TodoMVC <to be written>.  Completing this second part of the guide will improve your confidence with Gall agents by introducting teh following abilities:

Let's get started!

**Part 1 Lessons**

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
