# Ground Control to Major Tom - Hailing Mars from Earth

In this lesson, we're going to take our first steps towards developing an "Earth-facing" application.  Perhaps we want some way to take the data/applications of our urbit and make them available to Earth-going plebes or, perhaps we want to funnel some sweet resources away from Earth to support our Martian outpost.  In either event, by default, our urbit (and in fact all urbits, jointly) exist in an impenetrable bathysphere, isolating it from the troubles of the non-deterministic computers of Earth.  In order to establish external communications, we'll have to open our `airlock`.  We'll also investigate `JSON`-to-`hoon` type parsing and some of the elements of a `%gall` application, though further eludication of other elements of our `%gall` app will follow.

## For this lesson, you'll need:
1. The `airlock` demo files
2. Our `%firststep` files including:
    * `/app/firststep.hoon`
    * `/mar/firststep/action.hoon`
    * `/sur/firststep.hoon`
    
### Preparing for the lesson

**`airlock` demo files**

_insert airlock installation instructions using npm_

**`%firststep` app files**

Copy the files for `%firststep` into the appropriate folders in your development folder, turn on the syncing function and `|commit %home`.

