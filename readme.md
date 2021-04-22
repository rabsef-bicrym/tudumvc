# TuduMVC - a React.js + Hooks Implementation of TodoMVC with Urbit Integration

[![awesome urbit badge](https://img.shields.io/badge/~-awesome%20urbit-lightgrey)](https://github.com/urbit/awesome-urbit)

<span style="color:#F5DF4D">tudumvc</span> is an implementation of the React.js + Hooks version of [TodoMVC](https://jacob-ebey.js.org/hooks-todo/#/) that uses Urbit as a back-end. The Urbit backend supports all of the open-web functionality _including_ serving the front-end without any need for client-side storage. With minimal changes to the existing source code and less than 200 lines of back-end code, **tudumvc** is responsive, lightweight, and expandable. The pervasiveness of React.js as a framework for front-end development informs our choice of implementations of TodoMVC to incorporate with urbit.

Additionally, `tudumvc` is an excellent example of the advantages of incorporating Urbit in your stack. The React.js + Hooks implementation of TodoMVC is a stateful application that updates its presentation layer on state change. Urbit is a deterministic operating system, sometimes called an operating function, and it functions off of a basic pattern of state -> event -> effects -> new state. `tudumvc` compliments this basic pattern by using the React.js front end to produce events, using Urbit to interpret those events and produce effects and a new state and returning the state to React.js to be displayed.

The back-end development required to host an app like `tudumvc` is minimal and straightfoward, as are the changes we have to make to the React.js + Hooks TodoMVC implementation. Further, Urbit's `%gall` applications are inherently capable of cross-integration, so it would be a relatively straightforward task to integrate the functionality of `tudumvc` into other Urbit apps, like "groups", or even just allow the app to network with other self-hosted instances of `tudumvc` on other ships in the Urbit universe.

If you want to know more about the advantages of building applications on Urbit, check out this [interview I've done w/ `~radbur-sivmus` and `~timluc-miptev`](#).

Over the course of this guide, we'll get `tudumvc` running on a test ship then investigate the code and learn how we might apply this to other existing applications, or build something from the ground up, on Urbit.

Let's start with creating a ship:

**Lesson 1**

[Preparing a Development Environment](./lesson1-the-bosun.md)

**NOTE:** If you're familiar with developing on Urbit generally, you can scan the above document and make sure you're all set up, then proceed to Lesson 2.

# Other Lessons:

**Lesson 2**

[TodoMVC on Urbit (sort of)](./lesson2-todomvc-on-urbit-sortof.md)

**Lesson 3**

[The `%gall` of that `agent`](./lesson3-the-gall-of-that-agent.md)

**Lesson 4**

[Updating Our Agent](./lesson4-updating-our-agent.md)

**Lesson 5**

[Establishing Uplink](./lesson5-establishing-uplink.md)

**Lesson 6**

[Things Tudu and People TuSee](./lesson6-things-tudu.md)

# Special Thanks
* `~radbur-sivmus`
* `~timluc-miptev`
* `~sarpen-laplux`
* `~tinnus-napbus`
* `~mister-todteg`

and, as always, `~risruc-habteb`
