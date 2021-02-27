# Ordering Our Tasks

Let's work with a task list in `dojo` to better understand - enter the following:
```
>=a `(map id=@ud [label=@tU done=?])`(my :~([1 ['first task' %.n]] [2 ['second task' %.n]] [3 ['third task' %.n]]))
```
Then enter just `a` and you should see something like this:
```
>a
{[p=id=1 q=[label='first task' done=%.n]] [p=id=2 q=[label='second task' done=%.n]] [p=id=3 q=[label='third task' done=%.n]]}
```

Now we have a face of `a` stored in the `dojo` with a `map` just like our `type` `tasks` in our `/sur` file.  Let's take a peek at what [`key:by`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L1751) does - try:
```
> ~(key by a)
{id=1 id=2 id=3}
```

Ok, so we can get a [`set`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L1915) of all of the `key`s in the `map` we previously created. Next, we need to establish what [`tap:in`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L1410) does - try:
```
> =b ~(key by a)
```
First, to pin our last step to a face, making things cleaner, then:
```
> `(list @ud)`~(tap in b)
~[3 2 1]
```

Alright, we're making progress - we've now got a list of our `id`s, and we've moved the `id` `face` which will allow us to do further manipulation to find our greatest value.  Let's finish with taking a look at [`sort`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L739) - try:
```
=c `(list @ud)`~(tap in b)
```
Again, first, to store our prior work, then:
```
> +(-:(sort c gth))
4
```

And there we have it, we sort `c` by [`gth`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L2691) (greater than) as the criteria for sorting, then we increment it using the shorthand `+(<value to increment>)`.  We get 4, the next available `id`.  After that, all we do is use that as the value of `new-id` and then use [`put:by`](https://github.com/urbit/urbit/blob/fab9a47a925f73f026c39f124e543e009d211978/pkg/arvo/sys/hoon.hoon#L1632) to add the new `label` with a `done`-ness state of `%.n` at the appropriate `id` `key` position in our `tasks` `map`.