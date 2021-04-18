# Getting Started - Urbit Bosunry
This guide will walk you through implementing `%tudumvc`, an Urbit-centric port of TodoMVC, on a test urbit. Urbit is an Operating System or Operating Function (more on that later) that has cryptographically owned address space. Each node of the address space can be booted (or "launched"), or used as a personal server, and the nodes are commonly referred to as a Ship.

Each lesson of this guide, including this one, will follow a standard format. In each lesson, you'll have the following sections which should help you check for understanding as you progress through them:
* Learning Checklist
  * _A list of things you should know or understand by the time you complete the lesson._
* Goals
  * _A list of things you will be able to do on your own by the end of the lesson._
* Prerequisites
  * _What you'll need to complete the lesson._
* The Lesson
  * _The actual contents of the specific lesson._
* Homework
  * _Things to read or do, in addition to the lesson itself, for enrichment._
* Exercises
  * _Tests for understanding of the material covered - the difficulty of these exercises will vary._
  * _When the difficulty is really high, I'll include a breakout lesson that will walk you through the exercise, but you should try it on your own first!_
* _Optional_ Breakout Lessons
  * _Some of the lessons will include optional breakouts of complex subjects into sub-lessons._
  * _It is not necessary to complete these optional lessons to progress through the guide, but if you want to learn more, these will be there for you. Enter if you dare._

While it's possible to develop on a live Ship, it's highly discouraged for a variety of reasons (trust me on this, I have the highest _breach count_ in all of Urbit-dom). Instead we'll want to do our development on a test instance of an urbit, also known as a Fake Ship. In this lesson, you'll learn how to set up a Fake Ship for development purposes, and how to set up an efficient workflow using this Fake Ship. If you're already familiar with Urbit, you might be able to skim this lesson, but you should at least give it a once over before proceeding.

Let's get started!

## Learning Checklist
* How to boot an Urbit ship.
* How to create an efficient workflow for developing on Urbit.
* What additional materials are needed for completing this guide?
* What does the end product we're intending to design look like?

## Goals
* Create an Urbit development environment
* Restart your development environment using a fresh **Fake Ship** at any time
* Access the guide's materials quickly and efficiently from your local development environment
* Use your **Fake Ship** for simple things like logging into Landscape

## Prerequisites
* In this lesson, we expect you to start at 0 and have absolutely nothing Urbit related or prepared, in advance.
* You will, however, need some things _from_ this lesson to continue forward, but we're going to tell you how to get those things.
* We will assume you have minimal knowledge of using Linux or can use a search engine to self-help where some Linux terminology may be confusing or not fully explained.

## The Lesson
[Urbit](https://urbit.org/understanding-urbit/) is a virtual personal server that runs on *nix (Unix based platforms, like MacOS, Linux or the Windows Linux Subsystem). The binary, or program, that makes Urbit work has to have an appropriate *nix environment on which to run, so we'll start with getting you such a platform. If you already have a *nix system you plan on using, you should be able to skip this first part.

There are many options for hosting your Urbit including doing so on your local MacOS or Linux computer, using a  adding the Linux subsystem to your Windows box or even running your Urbit on a [Raspberry Pi](http://dasfeb.industries/). If you want to run on a cloud server, check out this brief [breakout lesson](./lesson1-4-hosting-options.md) describing your options.

### Installing the Urbit Binary
The best way of getting always-up-to-date instructions is by referencing urbit.org's guide [here](https://urbit.org/using/install/). This guide will assume you've installed your urbit binary at `~/urbit` on your chosen system.

**NOTE:** The urbit directory creation is optional, but the current tarball unpaks all of its files directly to its parent directory, so this is helpful for containing your files.

Now you have the Urbit binary installed and ready to use. Let's look at how you can start a ship with them:

### Booting a Fake Ship
You can boot literally any ship as a fake ship. In this guide, I'll be using the ship ~nus but you could use ~zod or ~rabsef-bicrym or (quite literally) any of the thousands of other valid Urbit ID. Assuming we're going with ~nus, enter the following command in the folder where you unpacked the Urbit binary:
```
./urbit -F nus
```

Your ship will start to boot, and you'll need to wait a few minutes while the ship downloads additional data (pill[s]) and bootstraps itself.  You'll see something like this:
```
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
```

From here, you should be able to:
* Shutdown this ship using `CTRL+D` (normal shutdown) or `CTRL+Z` (crashing shutdown).
* Restart the ship thereafter using just `./urbit nus` (note we no longer need to use the `-F` switch).
* Switch between the `dojo` (which is like the command prompt for Urbit) and  the `chat-cli` (or the terminal chat client for Urbit) using `CTRL+X`.
* Access landcape using the IP address of your ship's server and the port number to which it has bound:
  * Your ship's currently bound port number is noted in the boot sequence.
  * In the above sequence, port 8080 is bound, see:

    `http: web interface live on http://localhost:8080`

This is a good start - we have our fake ship running and we can access it through Landscape, but we need to do a little additional work to make this setup more convenient for development:

### Prepare for Development
We're going to make mistakes along the way here, and as you've likely noticed from the last step, it takes some time to boot a ship from the ground up. On a live ship, any time you make a breaking mistake, you have to breach your ship (which costs Ethereum) and boot from the ground up (barring some of the new export/import functionality that's being worked on). Luckily, with a fake ship, we can make a backup of the freshly booted state that we can simply restore after our mistakes. Let's make a backup:

#### Mount the Filesystem
The filesystem of Urbit is not natively visible from our *nix platform. We need to make them available as we edit/change them during develop. First, shut down your ship using `CTRL+D` and then navigate into the pier (or the directory that running an urbit creates) using `cd nus` from your shell, assuming you booted a fake ~nus like I did. You should see that that folder is empty.  Let's `cd ..` and `./urbit nus` to boot our ship back up and then enter `|mount %` in the dojo. You should see the following:
```
> |mount %
>=
~nus:dojo> 
```

If you shut down your ship again and navigate to the folder, you'll now see a sub-folder called home that contains its own sub folders; /app, /gen, /lib, /mar, /sur, /sys, /ted, and /tests. You could also see these sub-folders by entering `+ls /===` in dojo:
```
> +ls /===
app/ gen/ lib/ mar/ sur/ sys/ ted/ tests/
~nus:dojo> 
```

If you'd like to know more about what's going on with the filesystem from the Urbit side, take a look at this [breakout lesson on Urbit's filesystem, `%clay`](./lesson1-1-%25clay-breakout.md). This breakout is relatively deep for a beginner, and you don't need to know all of this to proceed.

**NOTE:** Changes to the filesystem made on the *nix side will not immediately be reflected in our urbit. We will have to use `|commit %home` to "re-uptake" those changed *nix side files into the %clay filesystem when we make changes - we'll see that later.

#### Create a Backup
Shut down the ship you've just mounted and then make a backup from your *nix shell using `cp -r nus nus-bak`. This creates a pristine copy of the existing ~nus ship that we can restore at any point. If we break our running version of ~nus, we can simply erase it (`rm -r nus`) and replace it (`cp -r nus-bak nus`) and be back where we started.

You might wonder "but what about all the changes I made?" We're going to use a bash script to sync our development files from a separate folder, so that we can break our ship with impugnity, copy our backup into place and re-send our development files to our fresh copy.

Let's get that development folder set up:

#### Add a Development Folder
We're going to use one specific folder for all of our new files, and write a bash script to copy them into our urbit's pier. Doing our development in this way affords us free reign to blow up our pier directory, replace it with a backup and restart our copy routine.
   * Create a folder with a name of your choosing (`mkdir <folder-name>`). I'll use `~/urbit/devops` and we'll pretend my pier is `~/urbit/nus`
      * Within that new folder, create an /app, /sur, /mar, /gen and /lib folder, to mirror those folders from our pier's home directory
   * Create a shell script file and use [this script](supplemental/dev.sh) that takestake a directory as an argument and `rsync`s the contents of our /devops folder to our home directory
   * Open two terminal sessions simultaneously, boot your urbit in one and start up your shell script in the other. Assuming the above configuration, we would start our shell script with something like `bash dev.sh ~/urbit/nus/home`.  You should have something like this going on:
   
      ![Image of Dev Environment](supplemental/devops.png)

You can test your functionality by trying to install a simple Towers of Hanoi generator - check out this [breakout lesson](./lesson1-3-towers-of-hanoi). 

You're now ready to start developing. We should get our development files local to our environment, just for convenience (not technically necessary):

### Downloading this Repository
In some folder of your development environment (not your pier), run `git clone https://github.com/rabsef-bicrym/tudumvc.git` in the shell to make a copy of the repository. This will make it very easy to copy files into our /devops folder as we move forward with the lessons.

## Homework
* Read about [how cores work](https://urbit.org/docs/hoon/hoon-school/arms-and-cores/).
* Read about [generators and how to install files to your Urbit](https://urbit.org/docs/hoon/hoon-school/setup/#generators).
* Make sure your syncing functionality is working by adding a file or [generator](./lesson1-3-towers-of-hanoi.md) to the /devops sub-folders and syncing it over to your ship. Make sure you can see the file copied over into your home directory.

## Exercises
* Write the generator as described in the Homework reading and sync it to your ship using our sync method.

## Summary and Addenda
You are now ready to begin development work on Urbit. There are several things you might want to know or do from here (in addition to continuing to the next lesson), such as:
* [Booting a ship that has data from the live network, also known as an `-L` ship](./lesson1-2-the-L-ship.md).
* [Test your /devops sync functionality](./lesson1-3-towers-of-hanoi.md).
* [How %clay works generally](./lesson1-1-%clay-breakout.md).

These optional addenda aren't necessary to continue. The only thing that is necessary to continue is that you:
* Know how to boot an Urbit ship.
* Know how to use our development workflow, including:
  * Using the sync function to move files from our development folder to our ship.
  * Erasing the existing dev ship and replacing it with the backup, clean dev ship.
* Have access to the guide's materials (either locally or just on GitHub).

<hr>
<table>
<tr>
<td>

[< Back to Summary](./readme.md)
</td>
<td>

[Lesson 2 - TodoMVC on Urbit (sort of) >](./lesson2-todomvc-on-urbit-sortof.md)
</td>
</tr>
</table>