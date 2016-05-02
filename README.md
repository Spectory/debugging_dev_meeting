Debugging
---------

Programs are like kids. You're at your home/office playing around, see how your baby grows, does all this nice things you though it to do, and feel so proud when it succeed. It reflects you so well, for the better & the worst.

True, somethings it misbehave and make you regret that late drunken night it all started at, but at the end you're creation is all grown up and needs to go out to the world.

Well all was nice & cozy back home, but its a jungle out there! Bullies will try to hurt it, viruses will try to kill it, and all those damn users just don't understand how to tread it right...

So, when you release your baby out to the world, make sure its damn ready.
And when it comes back home all banged up - patch it up fast all send it out there again, because mammy & daddy are working on a new one now and don't have time for this kind of crap.

## The Debug process
The basic steps in debugging are:
 1. Recognize that a bug exists
 2. Isolate the source of the bug
 3. Identify the cause of the bug
 4. Determine a fix for the bug
 5. Apply the fix and test it

Pretty simple ahh? But we all know its not as easy as it sounds.

The hardest parts are 2 & 3. This is where you bang your head at the table and regret the day you choose to be a programmer.
Luckly, there are ways to soften that processes. At this doc, we'll go over some.

========================================================================================================================

## Tools
The difference between a pro and an amature is that **a pro knows how to use his tools**.

#### Loggers
Loggers allow us to to see what a program is doing just by observing from outside.
When logs are kept & well maintained, it will also allow us to see what the system did in the past.

###### log levels
When something is logged, it is written into the corresponding log, if the log level of the message is equal or higher than the configured log level.

Most common log levels (ordered by severity) are :debug, :info, :warn, :error, :fatal, but most loggers will allow you to add your own levels & tags.

###### Performance Impact
Loggers affect app preformance in two aspects
 - IO - Logs are written to disk. When IO is massive, it can become a bottle next at you OS/Network, which can impact you program performace.
 - CPU/RAM - Strings are written to the log. If we convert complex objects to strings, it takes its toll on the OS.

###### Logging tips
Reading a log should give you a clear indication of what is going on at the system. A log entry should be informative. it should be easy to understand:
 - Where in the code this log entry was created.
 - Which system/module/process generated it.
 - When & in what order the events happen.
 - What exactly happened.

You can achieve most of it by
 - Add the Module & Method name to the log entry
 - Print parameters & variables
 - Use log levels wisely to reduce IO.

In order to minimize the Logger impact on your system:
 - Avoid logs in a loop
 - Avoid logs that require stringfy/parsing of big data structures

###### Example

Lets consider the following code

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

Our program which uses the MyMath module, is misbehaving.
Some users complained that sometimes the program returns the wrong result.
After more questioning, we know the exact input the user entered.
We are able reproduce the bug, but see no errors/execptions raised. All we can to do is start probing around at the code, while running manual tests.

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

Those kind of prints are very helpful while developing/debugging, but pretty annoying for when comes in masses. This is why prints are required to be deleted - in order to keep our system logs clean.

Using loggers `debug` mode allows us to eat our cake and eat it two - use our prints, but only when needed.

```ruby
def add(x, y)
  @logger.debug("MyMath.add(#{x}, #{y})")
  res = (x.to_i + y.to_i)
  @logger.debug("MyMath.add: res = #{res}")
  return res
end
```

Now by simply viewing the log we can pin point the error, loos like someone is misusing the the MyMath.add method and feeding it the wrong input.

```bash
  Apr 24 04:01:20 [debug]: MyMath.add(3, _2)
  Apr 24 04:01:20 [debug]: MyMath.add: res = 0
```

We can even improve that by adding a warn message

```ruby
def add(x, y)
  @logger.debug("MyMath.add(#{x}, #{y})")
  @logger.warn("MyMath.add: invalid input x=#{x}") unless valid_arg(x)
  @logger.warn("MyMath.add: invalid input y=#{y}") unless valid_arg(y)
  res = (x.to_i + y.to_i)
  @logger.debug("MyMath.add: res = #{res}")
  return res
end
```

Now by just viewing the logs, we can see the issue.
```bash
 Apr 24 04:01:20 [warn]: MyMath.add: invalid input y=#{_2}
```
------------------------------------------------------------------------------------------------------------------------

#### Debuggers
Debuggers allows us to see what a programs is doing from the inside.
Different debugger have different capabiltise but usualy you can find the same basic features at each.
 - Break points.
 - Performance measuring.
 - Data Structure viewers.
 - ...

------------------------------------------------------------------------------------------------------------------------

##### Linters
Linters are programs that analyze code for potential errors.
Simply put, a parser parses your code and looks for mistakes.
It saves time & maintain code quality/safety.

Most editors will allow us to integrate linters as plugins, but we can use them as stand alone to automate scripts of our own.

Linters have a wide range of abilaties:
 - Detect logical errors (such as missing a comma or misspell a variable name)
 - Detect code anti-patterns.
 - Detect syntax error.
 - Detect deprecated code usage.
 - Suggest code optimiztions.
 - Some Linters will even do those fixes for you.

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

###### Validators
A validator is a program that can checks your web pages against the web standards.
It is easy to miss a closing tag or misspell attribute, but very hard to find once its there.
Most of the time leads to visual bugs. Visual bugs can be hurt UX so badly that it will affect you app drastically. (For example, a user that can't click a submit button of a form).


HTML will work, somethings even look pretty good, when there are some major issues with the page structure.
To make things even more challenging, different browsers deal with such invalid structure differently, so you page can look great on one, by totally deformed on other.

Plus, Visual bugs are the ones makes you look bad & unprofessional just because there very easy to spot by the end user. The user doesn't thinks 'boy, I shouldn't view this site with Opera 9, maybe I'll switch to chrome 47'. He will probably think 'Man those guys are idiots over there' and move on to our competitors.

###### Formatters
Formatters are programs that analyze code, and fix them automatically according to style conventions.
Formatters will remove all the annoying 'ugly code' for you. don't spend time on fixing indentations, white spaces, and match brackets.
Focus on what you write, not who it looks.

Since Linters warn about style issues, formatters help reduce lint errors too.
------------------------------------------------------------------------------------------------------------------------

#### Version Control
Bugs are 99.99999% human error. someone wrote a piece of code that is missbehaving.
Version Control keeps our code changes history.
By reviewing the history we can tell who chagnged what & when.

###### git commit
In order to make the best of it, first we should be descriptive at our commits messages.
Commit messges like `git commit -am 'fix'` are pretty useless...

Messages should be informative:
 - What feature does this commit relate to?
 - Is there a task id that we use to mannage our work? include that too.
 - Describe what chagnes does this commit bring to the project.
 - Make sure your username & email are set correctly `git config -l`
 - Keep commits small. commits that includes many code changes are hard to follow/describe.

 Now that our commits contains some actual useful data, but how can we find the relavant commit.

###### git log
Displays latest commits to the repo.

###### git blame
Shows how was the last to make changes to the viewed code, and at which commit.

###### git bisect
Does a binary search on the commits.
 - `git bisect start` - start the bisect
 - `git bisect bad` - marks the current commit as bad, meaning the bug exists.
 - `git bisect good <COMMIT_ID>` - makes the commit as bug free, (for example the last stable version that was marked with the `git tag` cmd)
 - `git bisect` check out to the middle commit.

Keep marking commits as good/bad till you find the commit that produecd the bug.
 - remmber to use `git bisect reset` to go back to the starting point, or you'll leave the repo in a weird state.

###### git diff
Displays the diffrance between 2 commits / branches / files
Use the `--name-only` option to list affected files instead of files content.

###### git show <COMMIT_ID>
When a lot of changes where done between the two targets, diff can be too overwalming. `git show` displays only changes from the given commit.
`--name-only` works here too.

========================================================================================================================

## Culture
A single developer can work very fast & efficiently, but there is a limit. At some point the project is simply too big/complicated for a single developer to manage & support.

Working as a team requires good communication following agreed guidelines.

#### Issue Tracking
As our software gets bigger & bigger, the code base increases.
Vendors code is integrated & open source code is added.
As the code evolves, it accumulate more and more bugs.
 - When a bug is found, minor or major, make sure it is tracked.
   - Minor bugs can be ignored for a while, but can also mutate into a more serious issue.
   - Open a task. Write everything you found relevant during your investigations for future usage.
 - Keep vendor/open source code updated.
   - Keep track on your vendors blogs / press releases.
   - View the change log of new releases.
   - Review the external projects open/close issues.
   - Upgrades can contain bug fixes.
   - Upgrades can introduce new bugs too, run sanity tests before committing code upgrades.

------------------------------------------------------------------------------------------------------------------------

#### Research
Ok, we use all those awesome tools now know where the bug is generated. Time to pin point the issue and find a solution.

###### Remain effective
Debugging is hard. We need to keep our mind sharp.
 - Take brakes
 - Find a quite place to work.
 - Ask not to be disturbed.

###### Rubber Duck Debugging
In order to find a solution, we first need to define the problem.
We all had that experience when a solution emerges while you try to explain the problem to someone else. You don't need their input, just someone to talk to aloud while you gather your thoughts. Studies shows that objects can be as effective as a humans for that purpose, So... why not a rubber duck or a teddy bear?

###### Use Co-workers
Well, even you duck is not very much helpful... Time to leverage other people knowledge & experience.
 - Decide for how long you're going to pursue a lead on your own.
 - Keep in mind that others are busy too. I find the 'Try everything from the first Google page' rule pretty useful.
 - Once you got someone attention, let them find their own way.
 - Explain what is wrong, not what you did. Let others find their own way. don't trap them in your mind set.
 - Be patient, no body likes helping a jackass.

------------------------------------------------------------------------------------------------------------------------

### Automation
Bugs appear when the programs is in some state. Every time that state applies, the bug will appear.
Sometimes it requrie a few simple steps to put the system in the buggy state, a click of a button, or a flag change.
In other cases, getting there can be quite a juerny. you'll need to repeat multiple changes every time inorder to see & test the bug. this us just white noise for the debgging process. Plus, when we have multiple actions to complete each run, it is easy to miss one, and get to a totaly diffrent state.

Automation helps us to remain focued on the stuff that matter. We'll repreduce/test our bug fast.
 - Write a script that will change your programs state.
 - Write an automated test for that bug.
 - Automate casual dev tasks such as db resets, cleanups, backups.
 - Automate devOps tasks such as deployment, e2e/smoke tests.  

------------------------------------------------------------------------------------------------------------------------

#### Clean Code
Code is almost never written just once. Most of the time, someone (maybe even you) will need to work on that piece of code at some point.

As Robert C. Martin stated in his book 'Clean Code: A Handbook of Agile Software Craftsmanship':

“Clean code is code that has been taken care of. Someone has taken the time to keep it simple and orderly. They have paid appropriate attention to details. They have cared.”

But why should you care? What’s wrong with code that just works?
 - 'Clean code' contains less bugs, easier to understand & debug.
 - 'Dirty code' is hard to handle & maintain, and in time will 'rot' due to abandonment.

More tips:
 - The five-minute rule - if you find an ugly piece of code that can be fixed very fast, do it.
 - always improve yourself. if you are not happy with your current work, improve it, or at least understand what is wrong. next time, do it better.

#### Design & Architecture
Programs a divided into modules. Every module has its role and purpose. It helps you keep DRY principles and code quality.

Some tasks can be quite complex, and won't be completed in one coding session. you want to make sure that if & when you drop or hand over the task to someone els, it will be easy to pickup.

Overall, sound architecture also prevents bugs.
When program parts are not well defined we start seeing mutant modules that does many things, code duplication, and spaghetti code.

Before racing ahead and writing hundreds of lines of code, take some time an ponder about your task.
  - How does it fit the big picture.
  - What are the feature requirements exactly?
  - Do I have sufficient knowledge in order to complete the task, or need more time for research.
  - What are the feature components and how they interact with each other.
  - Can I reuse/expand any other modules?
  - break the tasks into a road-map. Define were are the main break points. When you reach a break point, ask your self if you have the time to reach the next one or not.

#### Code review
Code review is systematic examination of the source code.
Its main goals are find developers mistakes before the code is deployed and mutate into a full grown bug.

There are a few type of code reviews
 - Over-the-shoulder – one developer looks over the author's shoulder as the latter walks through the code.
 - Email pass-around – source code management system emails code to reviewers automatically after commits is made.
 - Pair programming – two authors develop code together at the same workstation, as it is common in Extreme Programming.
 - Tool-assisted code review – authors and reviewers use software tools specialized for peer code review.

Studies show that lightweight reviews uncovered as many bugs as formal reviews, but were faster and more cost-effective.
 - Use tools / version control to see code changes.
 - Review the code while its fresh.
 - Sessions should be brief, no more than an hour.
 - Cover 200-400 line per session.
 - Cover everything. configs, unit tests are code too.

###### Automated tests
There are lots of reasons why we should automate tests.
The main argument you hear against it is 'it takes too much time'.
Well, let me assure you - debugging takes much more time.

You can read more about it at a previous post [here](https://github.com/Spectory/unit_tests_dev_meeting)

------------------------------------------------------------------------------------------------------------------------
## Resources
https://en.wikibooks.org/wiki/Computer_Programming_Principles/Maintaining/Debugging#Basic_debugging_steps
http://cvuorinen.net/2014/04/what-is-clean-code-and-why-should-you-care/
http://dev.splunk.com/view/logging-best-practices/SP-CAAADP6
http://guides.rubyonrails.org/debugging_rails_applications.html
