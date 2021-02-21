# Launching a Dev Ship with `tudumvc` Installed
We're starting from the very beginning in this lesson. If you're already familiar with booting a ship on Urbit, you may be able to skip this lesson. Nonetheless, we suggest you forge ahead with reading it as there may be some good (and hard earned, for this author) pointers on how to efficiently develop on Urbit. We're going to be using a *fake* ship for our development, which means the ship we use will effectively be "offline" from the perspective of other ships. This *fake* ship functionality will ensure that we don't break our existing, live ship (should we have one) but will still allow us to develop networked applications (at least, amongst other fake ships running in our same development environment).

## Step 1 - Creating a Suitable Computing Environment
This guide will assume that you have a Linux VPS as your computing environment, but a local MacOS machine or a variety of other configurations will suffice. 

### Install the Urbit Binary
1. Do not install as `root`.
2. Do not install as `root`.
3. Perform the following steps on your VPS to download the Urbit binary
```
mkdir urbit
cd urbit
wget --content-disposition https://urbit.org/install/linux64/latest
tar zxvf ./linux64.tgz --strip=1
```
  * **NOTE:** The`urbit` directory is optional, but the current tarball unpacks all of its files directly to its parent directory.

### Booting a Fake Ship
1. I like to use the galaxy `~nus`, but you could use `~zod` or `~rabsef-bicrym` or (quite literally) any other Urbit ID you choose (_but not an invalid Urbit ID_). To boot a `~nus`, enter the following command(replacing `nus` with your preferred ship ID, if you like):
```
./urbit -F nus
```

2. Wait as your fakeship downloads the required data (pill[s]) and boots itself up. Once it's settled, you can:
   * Shutdown your ship using `CTRL+D` (normal shutdown) or `CTRL+Z` (crashing shutdown).
   * Switch between the `dojo` and the `chat-cli` using `CTRL+X`, though you'll have no one to talk to on this un-networked ship.
   * Access landscape using the IP address of your ship and the port number to which it has bound
      * **NOTE:** You can bind to port 80, but you may need to allow for [non-root-port-binding](https://cwiki.apache.org/confluence/display/HTTPD/NonRootPortBinding) (**DO NOT RUN ./urbit AS ROOT TO CIRCUMVENT THIS**)
      * Your ship's currently bound port number is noted in the boot sequence:
    <pre><code>
    ~
    urbit 1.0
    boot: home is /home/rabsef-bicrym/urbit/nus
    loom: mapped 2048MB
    lite: arvo formula 79925cca
    lite: core 59f6958
    lite: final state 59f6958
    loom: mapped 2048MB
    boot: protected loom
    live: loaded: MB/110.182.400
    boot: installed 286 jets
    vere: checking version compatibility
    ames: live on 31499 (localhost only)
    http: web interface live on http://localhost:8080
    http: loopback live on http://localhost:12321
    pier (48): live
    ~nus:dojo> 
    </code></pre>
    * Use your `code` to log in to landscape (at the `web interface` URL listed in the boot sequence) - enter `+code` into the dojo to get your code

## Step 2 - Preparing a Development Environment
After you've booted your Fake Ship, you'll want to:

### Mount the Pier
The Urbit filesystem is called `%clay` which is a `vane` (or [kernel module](https://urbit.org/docs/glossary/vane/)) of [`arvo`](https://urbit.org/docs/glossary/arvo/), the operating system.  We'll learn about more of the `vane`s of `arvo` later, particularly [`%eyre`](https://urbit.org/docs/glossary/eyre/) (pronounced 'air', the web server vane) and [`%gall`](https://urbit.org/docs/glossary/gall/) (stateful application management).

On first boot, the Urbit filesystem iss not 'mounted' to the underlying Unix filesystem.  If you `cd nus` into your pier, you won't see anything, yet the ship will continue to work.  But, we're going to need to work with some of these files, so we'll make them visible in the Unix side using `|mount`.

In `dojo`, enter `|mount %` and hit Enter.  If successful, you'll see some output like this:
```
> |mount %
>=
~zod:dojo> 
```

Now, you should see a folder called `home` in your pier.  This directory contains your `home` `desk`.  Inside of `home`, you'll find `app`, `gen`, `lib`, `mar`, `sur`, `sys`, `ted`, and `tests`.
  * The `app` directory contains all of your `gall` applications and their associated content, save for their `structure`s which are in `/sur` and their `mark` handlers in `/mar`.
  * The `gen` directory is for generators, which are simple, stateless, function-like programs that can be run from the dojo or by other applications.
  * The `lib` directory is for library-type `core`s who's functions can be drawn in to other applications using `%ford` runes (specifically `faslus` or `/+`)

Now that we've mounted our pier's filesystem, let's go ahead and copy our pier to a backup file (so we can rapidly delete our working ship and replace it with a blank slate) and start considering our development workflow.
  * Shut down your urbit, using `CTRL+D`
  * Copy your pier to a backup file with something like `cp -r nus nus-bak`

### Create a Development Routine
We're going to use one specific folder for all of our new files, and write a bash script to copy them into our urbit's pier.  Doing our development in this way affords us free reign to blow up our pier directory, replace it with a backup and restart our copy routine.
   * Create a folder with a name of your choosing (`mkdir <folder-name>`).  I'll use `~/urbit/devops` and we'll pretend my pier is `~/urbit/nus`
      * Within that new folder, create an `app`, `sur`, `mar`, `gen` and `lib` folder, to mirror those folders from our pier's `home` directory
   * Create a shell script file and use [this script](supplemental/dev.sh) that takestake a directory as an argument and `rsync`s the contents of our `/devops` folder to our `home` directory
   * Open two terminal sessions simultaneously, boot your urbit in one and start up your shell script in the other.  Assuming the above configuration, we would start our shell script with something like `bash dev.sh ~/urbit/nus/home`.  You should have something like this going on:
   
      ![Image of Dev Environment](supplemental/devops.png)

## Step 3 - Install `tudumvc` to Your Ship
**Note:** The pre-built version of `tudumvc` in this lesson's `src` folder _requires_ that you use nus as your dev ship. The files have been minified and modification of the ship's identity in the Earth app, at this stage, is difficult.
1. Copy the contents of [src-lesson1](./src-lesson1) into the appropriate sub-folders of your `/devops` folder and let them sync to your ship.
2. Run `|commit %home` in `dojo` to uptake the files into your ship
<pre><code>
> |commit %home
>=
+ /~nus/home/2/app/tudumvc/hoon
+ /~nus/home/2/app/tudumvc/static/css/2.5ec1470f.chunk.css/map
+ /~nus/home/2/app/tudumvc/asset-manifest/json
+ /~nus/home/2/app/tudumvc/index/html
+ /~nus/home/2/app/tudumvc/static/css/main.be9cd952.chunk/css
+ /~nus/home/2/app/tudumvc/static/js/main.22949569.chunk.js/map
+ /~nus/home/2/app/tudumvc/logo-icon/png
+ /~nus/home/2/app/tudumvc/static/css/2.5ec1470f.chunk/css
+ /~nus/home/2/app/tudumvc/static/js/main.22949569.chunk/js
+ /~nus/home/2/app/tudumvc/static/js/runtime~main.1dc9c6f5/js
+ /~nus/home/2/app/tudumvc/static/js/2.f6a93fda.chunk.js/map
+ /~nus/home/2/app/tudumvc/static/css/main.be9cd952.chunk.css/map
+ /~nus/home/2/sur/tudumvc/hoon
+ /~nus/home/2/app/tudumvc/precache-manifest.d8879c74fc1a4a422c8d09e25f321cf3/js
+ /~nus/home/2/app/tudumvc/static/js/runtime~main.1dc9c6f5.js/map
+ /~nus/home/2/mar/tudumvc/action/hoon
+ /~nus/home/2/app/tudumvc/service-worker/js
+ /~nus/home/2/app/tudumvc/static/js/2.f6a93fda.chunk/js
+ /~nus/home/2/app/tudumvc/manifest/json
~nus:dojo> 
</code></pre>
3. Start the `app` by running `|start %tudumvc`

## Step 4 - Investigate the App
* Open the console in your browser running `tudumvc`'s front-end.  Keep your ship open in another visible window.
* Add and remove a few tasks - try marking one a complete.
* Observe the outputs in `dojo` and the printing of the JavaScript actions in the browser console.
* Turn off your ship (`CTRL-D`) while the app is running and try taking some actions in the front-end

In the next lesson, we'll start rebuilding this app from the ground up, showing how we were able to take the default implementation of React-Hooks and, with minimal modifications to the existing codebase and fewer than 200 lines of Hoon, convert the app to run entirely off of our Urbit app's `state`.

Homework:
1. Read ~timluc-miptev's [Gall Guide - Overview](https://github.com/timlucmiptev/gall-guide/blob/master/overview.md)
2. Identify a feature you'd like to add to the functionality of `tudumvc` for your Final Project.

Exercises:
1. Examine `/devops/app/tudumvc.hoon` and see if you can determine the following:
    * Where are the messages in `dojo` that correlate to front-end actions being generated.
    * The `path` being used to communicate with the front-end is `/mytasks` - find all of the instances where that's specified in the app.
2. Change some of the mesages formed in `dojo` that result from front-end actions.
    * **BONUS POINTS:** Add additional metadata, like the `label` and `done`-ness of items that are deleted to the `dojo` logging.

