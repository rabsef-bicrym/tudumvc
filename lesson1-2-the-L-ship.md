# Creating `-L` Ships
[_Courtesy of ~timluc-miptev's Gall Guide_](https://github.com/timlucmiptev/gall-guide/blob/master/workflow.md#-l-ships)

Sometimes you want your development ships to have large datasets, such as the data in a real ship of yours. In these cases, the best option is to run a real ship with the `-L` command line flag, which turns off its networking so that you can do dangerous operations and then delete the ship when you're done.

Be careful with `-L` ships!. If you don't follow the steps below (particulary copying the "real" directory or starting with the `-L` flag), you could have to breach.

To run an `-L` ship, do the following steps:

* Copy your existing ship's folder to a new folder, e.g.: `cp -r rabsef-bicrym fake-rabsef`
* Run like so: `./urbit -L fake-rabsef`

<hr>
<table>
<tr>
<td>

[< Lesson 1 - The Bosun](./lesson1-the-bosun.md)
</td>
</tr>
</table>