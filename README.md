Debugging
---------
### Intro
Programs are like kids. You're at your home/office playing around, see how your baby grows, does all this nice things you though it to do, and feel so proud when it succeed. It reflects you so well, for the better & the worst.
True, somethings it misbehave and make you regret that late drunken night it all started at, but at the end you're creation is all grown up and needs to go out to the world.

Well all was nice & cozy back home, but its a jungle out there! bullies will try to hurt it, viruses will try to kill it, all those damn users just don't understand how to tread it right...

So, when you release your baby out to the world, make sure its damn ready.
And when it comes back home all banged up - patch it up fast all send it out there again, because mammy & daddy are working on a new one now and don't have time for this kind of crap.

###Debug process
The basic steps in debugging are:
 1. Recognize that a bug exists
 2. Isolate the source of the bug
 3. Identify the cause of the bug
 4. Determine a fix for the bug
 5. Apply the fix and test it

Pretty simple ahh? We all know its not as easy as it sounds. The hardest parts are 2 & 3. This is the part when you bang your head at the table and regret the day you choose to be a programmer.

========================================================================================================================

### Tools
The difference between a pro and an amature is that a pro knows how to use his tool.

#### Loggers
Loggers allow us to to see what a program is doing just by observing from outside.
When logs are kept & well maintained, it will also allow us to see what the system did in the past.

###### log levels

When something is logged, it is printed into the corresponding log if the log level of the message is equal or higher than the configured log level.
Most common log levels (ordered by severity) are :debug, :info, :warn, :error, :fatal.

##### Performance Impact
Loggers affect app preformance in two aspects
 - IO - Logs are written to disk.
 - CPU/RAM - convertsion complex objects to string.

##### Logging tips
Reading a log should give you a clear indication of what is going on at the system. A log entry should be informative:
 - where - where in the code this log entry was created.
 - who - which system/module/process created it
 - when - when & in what order the events happen
 - what - what exactly happened

You can achieve most of it by
 - Add the Module & Method name to the log entry
 - Print parameters & variables
 - Avoid logs in a loop
 - Avoid logs that require stringfy of big data structures / parsing
 - Use log levels wisely to reduce IO.

##### Example

for example Lets consider the following code

```ruby
module MyMath
  def add(x, y)
    return (x.to_i + y.to_i)
  end
end

module MyCalc
  def awesome_calc(args)
    ...
    MyMath.add(x, y)
    ...
  end
end
```

Our program which (uses the MyMath module), and misbehaving.
Some users complained that sometimes the program returns the wrong result.
After more questioning, we know the exact input the user entered.
we can reproduce the bug, but see no errors at the logs, all we can & need to do is start probing around at the code.

How can we prevent or at least reduce the debug cycle of such scenarios?

Methods have input, and output. If we know what goes in & out of them, we can tell if they work properly.
This is why often while coding & debugging we find ourselves adding prints to the code like so:

```ruby
# coverts 2 strings to integers and performs addition.
def add(x, y)
  puts "x=#{x}"
  puts "y=#{y}"
  puts "x+y=#{(x.to_i + y.to_i)}"
  return (x.to_i + y.to_i)
end
```

Those kind of prints are very helpful while developing/debugging, pretty annoying for when comes in masses. This is why prints are required to be deleted - in order to keep our system logs clean.

Using loggers `debug` mode allows us to eat our cake and eat it two - use our prints, but only when needed

```ruby
def add(x, y)
  @logger.debug("MyMath.add(#{x}, #{y})")
  res = (x.to_i + y.to_i)
  @logger.debug("MyMath.add: res = #{res}")
  return res
end
```

Now by simply viewing the log we can pin point the error, loos like someone is missusing the the MyMath.add method and feeding it the wrong input.

```bash
  Apr 24 04:01:20 [debug]: MyMath.add(3, _2)
  Apr 24 04:01:20 [debug]: MyMath.add: res = 0
```

------------------------------------------------------------------------------------------------------------------------

##### Debuggers
Debuggers allows use to see what a programs is doing from the inside.
Different debugger have different capabiltise but usualy you can find the same features at each.
 - Break points.
 - Performance measuring
 - Data Structure viewers
 - ...

------------------------------------------------------------------------------------------------------------------------

##### Linters
Linters are programs that analyze code for potential errors, both logic & style. Simply put, a parser parses your code and looks for mistakes.
It’s save time & maintain code quality/safety. Most editor will allow us to integrate linters as plugins, but we can use them as stand alone to automate scripts of our own.

Linters have a wide range of abilaties:
 - Detect logical errors (such as missing a comma or misspell a variable name)
 - Detect code anti-patterns.
 - Detect syntax error.
 - Detect deprecated code usage.
 - Suggest code optimizartions.
 - Some Linters (rubocop for example) will even do those fixes for you.

For example, a linter will prevent the classic mistake of global variables at JS
```js
function (){
  i=0;
  ...
}
```
or useless assignments at ruby
```ruby
 obj = do_some_heavy_calc()
 ...
 obj = []
```

------------------------------------------------------------------------------------------------------------------------

##### Version Control
Bugs are 99% human error. someone wrote a code that is missbehaving.
Version Control keeps our code changes history.
By reviewing the history we can tell who chagnged what & when.

###### git commit
In order to make the best of it, we should be descriptive at our commits messages.
Commiting changes like `git commit -am 'fix'` is pretty useless...
messages should be informative:
 - what task did you work on?
 - is there a task id that we use to mannage our work? include that too.
 - reflect in general what chagnes this commit bring to the project.
 - make sure your username & email are set correctly `git config -l`

 Now that our commits contains some actual useful data, but how can we find the relavant commit.

#######git log
displays latest commits to the repo.

#######git blame
Show you how was the last to make changes to the viewed code, and at which commit.

#######git bisect
Does a binary search on the commits.
 - `git bisect start` - start the bisect
 - `git bisect bad` - marks the current commit as bad, meaning the bug exists.
 - `git bisect good <COMMIT_ID>` - makes the commit as bug free, (for example the last stable version that was marked with the `git tag` cmd)
 - `git bisect` check out to the middle commit.

keep marking commits as good/bad till you find the commit that produecd the bug.
 - remmber to use `git bisect reset` to go back to the starting point, or you'll leave the repo in a weird state.

###### git diff
Displays the diffrance between 2 commits / branches / files
Use the `--name-only` option to list affected files.

###### git show <COMMIT_ID>
When a lot of changes where done between the two targets, diff can be too overwalming`git show` can display only changes from the given commit.
`--name-only` works here too.

========================================================================================================================

### Culture
A single developer can work very fast sometimes, but there is a limit. at some point the project is simply too big/complicated for a single developer to manage & support.

Working as a team requires good communucation folowing guidelines.

##### Issue Tracking
As our software gets bigger & bigger. the code base increases, vendors code is integrated & open source code is added. as the code evolves, it accumulate more and more bugs.
 - when a bug is found, minor or major, make sure it is tracked.
   - minor bugs can be ignored for a while, but can also mutate into a more sirouse issue.
   - Open a task. Write everything you found relavent during your investigations for future usage.
 - keep vendor/open source code updated.
   - upgrades can contain bug fixes.
   - upgrades can contain new bugs too, run sanity tests before committing code upgrades.
   - view the change log of new releases.
   - review the external projects open/close issues.

------------------------------------------------------------------------------------------------------------------------

##### Research
Ok, so now we know where the bug is generated, time to find a solution.

###### Remain effective
Debugging is hard. We need to keep our mind sharp.
 - take brakes
 - find a quite place to work.
 - ask not to be disturbed.

###### Rubber Duck Debuging
In order to find a solution, we first need to define the problem.
We all had that experince when a solution amerges while you try to explain the problem to someone else, you don't need their input, just someone to talk to aloud while you gatther your thougths, so why not a rubber duck or a teddy bear?

###### Use Co-workers
Well even you duck is not very much helpful... time to leverage other people knowlage & experince.
 - Diside for how long you're going to perssue a lead on your own.
 - keep in mind, others are busy too. I find the 'try everthing from the first google page' rule pretty useful.
 - once you got someone attention, let them find their own way.
 - explain what is wrong, not what you did.
 - be patiant, no body likes helping a jackass.


------------------------------------------------------------------------------------------------------------------------

##### Clean Code
Code is almost never written just once. Most of the time, someone (maybe even you) will need to work on that piece of code at some point.

As Robert C. Martin stated in his book Clean Code: A Handbook of Agile Software Craftsmanship, “Clean code is code that has been taken care of. Someone has taken the time to keep it simple and orderly. They have paid appropriate attention to details. They have cared.” But why should you care? What’s wrong with code that just works?

'Clean code' contains less bugs, easier to understand & debug.
'Dirty code' is hard to handle & maintain, and in time will 'rot' due to abandment.

 - The five-minute rule - if you find an ugly piece of code that can be fixed very fast, do it.
 - allways improve yourself. if you are not happy with your current work, improve it, or at least understand what is wrong. next time, do it better.


###### Design & Archtecture
This is the basic 'think before you do' idea. Before racing ahead and writing hundreds of lines of code, take some time an ponder about your task.
  - What are the feature requierments exactly?
  - Do I have sufficient knowlage in order to complete the task, or need more time for research.
  - What are the feature components and how they interact with each other.

Some tasks can be quite complex, and won't be completed in one coding session. you want to make sure that if& when you drop the task for awhile, it will be easy to pick it up again.
  - draw a sketch.
  - define subtasks
  - break the tasks into a road-map. Define were are the main break points. When you reach a break point, ask your self if you have the time to reach the next one or not.

######code review
Code review is systematic examination of the source code.
Its main goals are find developers mistakes before the code is deplyed and mutate into a full grown bug.

There are a few type of code reviews
 - Over-the-shoulder – one developer looks over the author's shoulder as the latter walks through the code.
 - Email pass-around – source code management system emails code to reviewers automatically after checkin is made.
 - Pair programming – two authors develop code together at the same workstation, as it is common in Extreme Programming.
 - Tool-assisted code review – authors and reviewers use software tools, informal ones such as pastebins and IRC, or specialized tools designed for peer code review.

Studies show that lightweight reviews uncovered as many bugs as formal reviews, but were faster and more cost-effective.

 - use tools / version control to see code chagnes.
 - review the code while its fresh.
 - sessions should be briff, no more than an hour.
 - cover 200-400 line per session.
 - cover everything. configs, unit tests are code too.

######Automated tests
There are lots of reasons why we should autamate tests.
the main argument you hear against it is 'it takes too much time'.
Well, let me asure you - debuging takes much more time.

you can read more about it at a previuse post here

------------------------------------------------------------------------------------------------------------------------
