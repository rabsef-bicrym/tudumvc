# Booting Your Ship and Starting an Efficient Development Cycle

We're starting from the very beginning in this lesson.  If you're already familiar with booting a ship on Urbit, you may be able to skip this lesson.  Nonetheless, we suggest you forge ahead with reading it as there may be some good (and hard earned, for this author) pointers on how to efficiently develop on Urbit.  We're going to be using a *fake* ship for our development, which means the ship we use will effectively be "offline" from the perspective of other ships.  This *fake* ship functionality will ensure that we don't break our existing, live ship (should we have one) but will still allow us to develop networked applications (at least, amongst other fake ships running in our same development environment).

## Installing the Urbit binary

The installation process is well covered [here](https://urbit.org/using/install/) but we're going to include the steps required below. Please do note that the `urbit.org` instructions are more likely to stay up-to-date, as those instructions are modified; should you have any issues with our instructions, please take a look at theirs.

### Step 1 - Creating a Suitable Computing Environment
This guide will assume that you have a Linux VPS as your computing environment, but a local MacOS machine or a variety of other configurations will suffice.  If you're looking for a good service to host your urbit, consider [DigitalOcean](https://www.digitalocean.com/) or [SSDNodes](https://www.ssdnodes.com/).  If you'd like to suggest an additional service to be listed here, submit a pull request for us!

#### Setting Up Your Computing Environment
These steps are well covered in other guides that exist online, and that are likely better updated than we could afford to reproduce here.  We'll link to them for you, below.

**DigitalOcean**
1. Create a [DigitalOcean Account and Add a Project and Droplet to your Account](https://www.digitalocean.com/docs/droplets/how-to/create/#:~:text=You%20can%20create%20one%20from,open%20the%20Droplet%20create%20page.)
    * **NOTE:** You likely only need the the $10/mo (2GB RAM, 1 CPU, 50 GB SSD, 2 TB Transfer) and could even possibly get away with the $5/mo option, if you want to fiddle with the swap space.
2. Generate [SSH Keys and Add Them to Your Droplet](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/)
3. Connect to your [Droplet (potentially using Visual Studio Code - that's what I like!)](https://www.digitalocean.com/community/tutorials/how-to-use-visual-studio-code-for-remote-development-via-the-remote-ssh-plugin)

**SSDNodes**
1. Create a [SSDNodes Account and Create a Server](https://www.ssdnodes.com/)
    * **NOTE:** Again, you likely only need the minimal service they provide - choose as you see fit, though
2. Generate [SSH Keys and Connect to Your SSDNode Securely](https://blog.ssdnodes.com/blog/connecting-vps-ssh-security/)

### Step 2 - Installing the Urbit Binary
1. For the love of all that is Holy, please don't do the following steps as `root` (I'm looking at you ~risruc-habteb)
2. Perform the following steps on your VPS to download the Urbit binary
```
mkdir urbit
cd urbit
wget --content-disposition https://urbit.org/install/linux64/latest
tar zxvf ./linux64.tgz --strip=1
```

    * **NOTE:** It is optional to create an `urbit` directory, but note that the current tarball unpacks all of its files directly to the directory into which it is unpacked - if you want to contain those files, we recommend you create a directory to house these files.
    
### Step 3 - Booting a Fake Ship
1. From the directory where you downloaded and unpacked the Urbit binary, boot yourself a fake ship.  I like to use the galaxy `~pen`, but you could use `~zod` or `~rabsef-bicrym` or (quite literally) any other Urbit ID you choose (_but not an invalid Urbit ID_).  To boot a fake ship, use a command like the following (replacing the ship with your preferred ship ID):
```
./urbit -F pen
```

2. You'll need to hang out for a while during your first boot as your fakeship downloads the required data (pill[s]) and boots itself up.  Once you've done that though, you can:
    * Shutdown your ship using `CTRL+D` (normal shutdown) or `CTRL+Z` (crashing shutdown)
    * Switch between the `dojo` and the `chat-cli` using `CTRL+X`
    * Access landscape using the IP address of your ship and the port number to which it has bound
      * **NOTE:** You can bind to port 80, but you may need to allow for [non-root-port-binding](https://cwiki.apache.org/confluence/display/HTTPD/NonRootPortBinding) (**DO NOT RUN ./urbit AS ROOT TO CIRCUMVENT THIS**)
      * Your ship's currently bound port number is noted in the boot sequence:
      <pre><code>
      urbit 1.0
      boot: home is /home/eric/urbit/pen
      loom: mapped 2048MB
      lite: arvo formula 79925cca
      lite: core 59f6958
      lite: final state 59f6958
      loom: mapped 2048MB
      boot: protected loom
      live: loaded: MB/117.293.056
      boot: installed 286 jets
      vere: checking version compatibility
      ames: live on 31346 (localhost only)
      eyre: no channel to cancel ~[//http-server/0v2.o7sqk/12/1]
      eyre: no channel to cancel ~[//http-server/0v2.o7sqk/10/1]
      http: web interface live on http://localhost:<b><i>8080</i></b>
      http: loopback live on http://localhost:12321
      pier (11782): live
      </code></pre>
    * Use your `code` to log in to landscape - enter `+code` into the dojo to get your code

### Step 4 - Prepare a Development Environment
After you've booted your fake ship, you'll want to:
  * Mount your pier (your ship's filesystem) to the Unix filesystem
  * Make a backup copy of your fake ship, so that you can quickly replace your development environment
  * Make a directory for holding your development files
  * Create a shell script to copy your development files into your pier
  * Practice using that shell script against your fake ship, including obliterating your primary fake ship pier and restoring from your backup
  
**Mounting the Pier**
Your urbit's filesystem is called `%clay`.  `%clay` is a `vane` (or [kernel module](https://urbit.org/docs/glossary/vane/)) of `arvo`.  The other `arvo` `vane`s are called `%ames` (networking), `%behn` (pronounced 'bean' or 'been' - timer), `%dill` (terminal driver), `%eyre` (pronounced 'air' or 'ayer', client-side HTTP services), `%ford` (build system), `%gall` (applications), `%iris` (server-side HTTP services), and `%jael` (security).  In this guide, we'll focus mainly on `%clay` and `%gall`.

On first boot, your urbit's filesystem will not be mounted in your Unix filesystem - you can `cd <my-pier>` and nothing will be in there.  And yet, the ship will still work.  You only _need_ to mount your filesystem in Unix if you want to edit files outside of your urbit's operating system.  And, since there isn't a great option for editing files within Urbit (**yet** (TM)), we're going to be editing most of our files from outside Urbit.

From the dojo, key in `|mount %` and hit enter.  If successful, you'll see some output like this:
```
> |mount %
>=
~zod:dojo> 
```

Open another terminal and navigate into your pier directory.  You should now see a folder called `home` for your home desk.  Inside of `home`, you'll find folders entitled `app`, `gen`, `lib`, `mar`, `sur`, `sys`, `ted`, and `tests`.  We're going to spend most of our time working in `app`, `mar` and `sur` with perhaps some work in `gen` and `lib`.
  * The `app` directory contains all of your `gall` applications and their associated content, save for their `structure`s which are in `/sur` and their `mark` handlers in `/mar`.
  * The `gen` directory is for generators, which are simple, stateless, function-like programs that can be run from the dojo or by other applications.
  * The `lib` directory is for library-type `core`s who's functions can be drawn in to other applications using `%ford` runes (specifically `faslus` or `/+`)

Now that we've mounted our pier's filesystem, let's go ahead and copy our pier to a backup file and start considering our development workflow.
  * Shut down your urbit, using `CTRL+D`
  * Copy your pier to a backup file with something like `cp -r <your-pier> <your-pier>-bak`
  * And... That's it.  We're ready to start development.

### Step 5 - Develop!



