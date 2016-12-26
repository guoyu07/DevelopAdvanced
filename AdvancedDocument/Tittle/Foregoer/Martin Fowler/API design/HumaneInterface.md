[HumaneInterface](http://martinfowler.com/bliki/HumaneInterface.html)



# [HumaneInterface](HumaneInterface.html)


[API design](/tags/API design.html)

tags:



Hanging around the ruby crowd for a while, I've come across the
	term 'Humane Interface' quite a bit. It describes part of the
	rubyist attitude to writing class interfaces, I think it also sets
	up an interesting contrast between two schools of thought in
	designing APIs (the other is the [MinimalInterface](MinimalInterface.html)).

The essence of the humane interface is to find out what people
	want to do and design the interface so that it's really easy to do
	the common case.

The obvious contrast to a minimal interface is that humane
interfaces tend to be much larger, and indeed humane interface
designers don't worry too much about the interface being big. This
isn't to say that classes with humane interfaces need be larger in
terms of implementation. The fundamental functionality of the two is
often quite similar. 

A good way of looking at the difference between humane and
minimal interfaces is to compare the list components in Java and Ruby.
Java has an interface ([java.util.List](http://java.sun.com/j2se/1.5.0/docs/api/java/util/List.html))

which declares 25 instance methods. Ruby has an [Array](http://www.ruby-doc.org/core/classes/Array.html) class
(which is a list not an array) that has 78 methods. That difference in
size is something of a clue of that there's a different style here
(although there's more reasons for that difference).
Both components offer the basic same service, but Ruby's array
includes a lot of additional functionality. This functionality is all
relatively small things that can be built on Java's minimal
interface.

Let's take a small example to help show the difference: getting
the last item on the list. To do this in Java you do:

<pre>aList.get(aList.size -1)</pre>

in Ruby you do

<pre>anArray.last</pre>

In fact it's even more startling than that: Ruby's Array has a
`first` method too, so rather than going
`anArray[0]` you can go `anArray.first`.

There's larger elements of functionality as well. Ruby's Array
	has a flatten method that takes nested arrays and turns them into a
	single level.

<pre>irb&gt; [1,2,[3,4,[5,6],7],8].flatten
=&gt; [1, 2, 3, 4, 5, 6, 7, 8]
</pre>

The point here is all of this functionality, whether as simple as
`last` or as complex as `flatten`, can be
written by clients themselves without increasing the size of the list
class. Minimalists tend to focus on the minimal set of necessary
methods to support these behaviors, humane designers try to add
methods that are needed. Often these extra methods are referred to as
convenience methods, a term that minimalists do not consider to be a
complement.

This begs the question: "what's the basis for deciding what
	should be added to a humane interface?" If you put in everything
	anyone might want you'll get a very complex class. Humane interface
	designers try to identify what are the most common uses of a class,
	and design the interface to make these uses easy. 

Not just does this principle inspire the methods you add, it
also affects how you name them. At RubyConf, Tanaka Akira pointed out
the value of preferring short names for common methods. Since these
are used more often you get familiar with them - it's easy to remember
brief names if you use them a lot, also it's more useful since it
saves typing and reading. An example of this is the `parse`
method on `DateTime` that does a default parse of common
date formats and the more flexible `strptime` that can take
any format, but you use less often.

This principle of naming isn't in conflict with the minimalist
approach. Indeed when Java's List interface appeared it changed
the legacy Vector's `elementAt` method to
`get`.

Another interesting consequence of ruby's humane interface
philosophy is the aliasing method names. When you want the length of a
list, should you use `length` or `size`? Some
libraries use one, some the other, Ruby's Array has both, marked as
aliases so that either name calls the same code. The rubyist view
being that it's easier for the library to have both than to ask the
users of a library to remember which one it is.

You can get long and tiresome threads about which style of
	interface design is
	best. Here I'll try to summarize the arguments in favor of the
	humane interface (see [MinimalInterface](MinimalInterface.html) for the other side).

Much of an object's strength lies in its behavior, not its data.
If you only try to provide the minimum, you end up with multiple
clients duplicating code for common cases. In cases like
`flatten` you end up with a bunch of people writing their
own recursive functions. It's not hard, but why should they bother when
it's not that rare a case?

Even for simple cases like `last`, readers have to learn an
	idiom. Why should they have to see something indirect, when a simple
	method reads directly? Good software thinks of the users first and
	makes life easy for them. Humane interfaces follow that principle.

Humane interfaces do more work so that clients don't have to. In
	particular the human users of the API need things so that their
	common tasks are easy to do - both for reading and writing.

There are good arguments on both sides. Personally I lean to
the Humane Interface approach, although I do think it's harder.



* * *

## Follow Ups

This one caused a bit of stir, which has led to some
interesting and useful discussion. At some point I might put some
		narrative over the links to help you read them, until then I'll
		just list them. The debate was mostly triggerred by [Elliotte

Harold's](http://www.cafeaulait.org/oldnews/news2005December6.html) short but robust
criticism of the humane approach and [James

Robertson's ](http://www.cincomsmalltalk.com/blog/blogView?showComments=true&amp;entry=3311314085) reply (make sure you check the comments on Robertson's
posts). Then came the deluge | [Cees

de Groot](http://www.cdegroot.com/blog/2005/12/06/simplicity-rules-in-the-right-place/) | [Antonio Vieiro](http://blogs.sun.com/roller/page/swinger?entry=harold_martin_and_kisses) | [David

Hoefler](http://davidhoefler.com/blog/index.php?title=humane_interface_and_ruby_and_some_java&amp;more=1&amp;c=1&amp;tb=1&amp;pb=1 "humane_interface_and_ruby_and_some_java&amp;more=1&amp;c=1&amp;tb=1&amp;pb=1") | [James Higgs](http://staff.interesource.com/james/PermaLink.aspx?guid=ac626a46-1728-4488-bbda-6c05254656ec) | [Peter
Williams](http://pezra.barelyenough.org/blog/2005/12/humane-interfaces/) | [Cedric Beust](http://beust.com/weblog/archives/000346.html) | [John D. Mitchell](http://weblogs.java.net/blog/johnm/archive/2005/12/humane_interfac.html) | [Stuart

Roebuck](http://www.typingahead.com/management/2005/12/humane_interfac.html) | [Elliotte
Harold (2)](http://www.cafeaulait.org/oldnews/news2005December7.html) | [Jon
Tirsen](http://jutopia.tirsen.com/articles/2005/12/07/is-yagni-in-conflict-with-humane-interfaces) | [Hitesh
Jasani](http://www.jasani.org/articles/2005/12/08/when-not-to-be-a-minimalist) | [Blaine
Buxton](http://www.blainebuxton.com/weblog/2005/12/humane-interface-debate.html) | [Ramnivas Laddad](http://ramnivas.com/blog/index.php?p=20) |
[Anders
Noras](http://www.dotnetjunkies.com/WebLog/anoras/archive/2005/12/07/134193.aspx) | [James
Robertson (2)](http://www.cincomsmalltalk.com/blog/blogView?showComments=true&amp;entry=3311482201) | [Kieth
Ray](http://homepage.mac.com/keithray/blog/2005/12/07/) | [James
Robertson (3)](http://www.cincomsmalltalk.com/blog/blogView?showComments=true&amp;entry=3311432437) | [Elliotte
Harold (3)](http://www.cafeaulait.org/oldnews/news2005December8.html) | [Charles
Miller](http://fishbowl.pastiche.org/2005/12/09/humane_interfaces) | [Rob
Lally](http://robertlally.com/index.php?p=64) | [Bernard
Notarianni](http://www.notarianni.org/index.php/2005/12/08/humane_interface_debat) | [David Crow](http://davidcrow.ca/article/786/simplicity-rules)
| [Jim
Weirich](http://onestepback.org/index.cgi/Tech/Ruby/ArrayApi.red) | [Jim
Weirich (2) ](http://onestepback.org/index.cgi/Tech/Ruby/OpenClassMindset.red)| [Ian
Bicking](http://blog.ianbicking.org/the-unbridled-humanity-of-apis.html) | [Brian
Foote](http://www.laputan.org/catfish/archives/000127.html) | [Justin
Gehtland](http://www.relevancellc.com/blogs/?p=89) | [Tom
Moertel](http://blog.moertel.com/articles/2005/12/08/cost-reducing-interfaces-should-be-the-focus) | [Antonio
Vieiro (2)](http://blogs.sun.com/roller/page/swinger?entry=simple_kisses_and_surprises) | [Kris
Wehner](http://www.burnthacker.com/articles/2005/12/06/how-do-you-make-an-interface-truly-humane) | [The Server Side](http://www.theserverside.com/news/thread.tss?thread_id=37990) | [Ravi
Mohan](http://ravimohan.blogspot.com/2005/12/what-mr-fowler-really-said.html) | [Danny
Lagrouw](http://www.blog.dannynet.net/archives/26) | [Piers
Cawley](http://www.bofh.org.uk/articles/2005/12/10/java-people-are-funny) | [Peter
Williams](http://pezra.barelyenough.org/blog/2005/12/synonyms-need-love-too/) | [Florian Frank](http://rubylution.ping.de/articles/2005/12/21/rubys-rich-array-api) | [Chris Siebenmann](http://utcc.utoronto.ca/~cks/space/blog/python/OnInterfaceStyles) . 

There's more too, I haven't spotted them all and I've only gone
for those that I think add something interesting to the debate and
avoid invective. There's been a tendency to over-focus on the Ruby
Array vs Java List example rather than the underlying principles, but
that's natural. There have been a number of good directions the
discussion is going, if I get chance I'll try to develop one or two of
them.

Or you could just read [Joey deVilla](http://farm.tucows.com/blog/_archives/2005/12/9/1443435.html) - who includes excerpts from
most of the above.




<span class="label">Share:</span>[![](/t_mini-a.png)](https://twitter.com/intent/tweet?url=http://martinfowler.com/bliki/HumaneInterface.html&amp;text=Bliki: HumaneInterface ➙  "Share on Twitter")[![](/fb-icon-20.png)](https://facebook.com/sharer.php?u=http://martinfowler.com/bliki/HumaneInterface.html "Share on Facebook")[![](/gplus-16.png)](https://plus.google.com/share?url=http://martinfowler.com/bliki/HumaneInterface.html "Share on Google Plus")

if you found this article useful, please share it. I appreciate the feedback and encouragement







## Find similar articles at the tag

[API design](/tags/API design.html)



