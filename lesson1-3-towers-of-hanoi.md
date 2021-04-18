# Towers of Hanoi
We're going to add a simple generator to our /gen folder, let our shell script copy it into our pier, and then run it. In the process we'll learn about `|commit`-ing our files back into our %clay filesystem when we make changes to them in the Unix filesystem. Assuming you're running your copy shell script as described in the previous subsection, take the following steps:
   * Copy the [hanoi generator](supplemental/hanoi.hoon) to your /gen subdirectory of your development folder (`~/urbit/devops/gen` based on our example above)
     * Make sure your sync function is running, e.g.: `bash dev.sh ~/urbit/nus`
   * This generator solves a Towers of Hanoi game with any number of starting discs on any one of the three pegs. It takes two arguments:
      * See: `|=  [num-of-discs=@ud which-rod=?(%one %two %three)]`
      * Argument 1 - the number of discs in the game
      * Argument 2 - the starting rod
   * We can call this generator using `+hanoi [3 %one]` or similar. Do this in your dojo.
   * You've just received the error:
      ```
      /gen/hanoi/hoon
      %generator-build-fail
      ```
   * Your urbit is not able to find the file yet, even though it's been copied into your pier (take a look for yourself to confirm - if it hasn't, you might have an issue with your shell script)
   * Let's use `|commit %home` to _uptake_ the changes we made in the Unix filesystem into our urbit's `%clay` filesystem. Type that command into the dojo.
   * You've just seen a message somewhat like the below:
      ```
      > |commit %home
      >=
      : /~nus/home/44/gen/hanoi/hoon
      ```
   * Let's try running our generator again, using `+hanoi [3 %one]`.
   * You should see the following:
      ```
     ~[
     [rod-one=~[2 3] rod-two=~ rod-three=~[1]]
     [rod-one=~[3] rod-two=~[2] rod-three=~[1]]
     [rod-one=~[3] rod-two=~[1 2] rod-three=~]
     [rod-one=~ rod-two=~[1 2] rod-three=~[3]]
     [rod-one=~[1] rod-two=~[2] rod-three=~[3]]
     [rod-one=~[1] rod-two=~ rod-three=~[2 3]]
     [rod-one=~ rod-two=~ rod-three=~[1 2 3]]
     ]
     ```
   * And just like that, you've confirmed that your dev environment is set up to house your development files, outside of your pier, with a replication system in place to automatically copy them _into_ your pier.

<hr>
<table>
<tr>
<td>

[< Lesson 1 - The Bosun](./lesson1-the-bosun.md)
</td>
</tr>
</table>