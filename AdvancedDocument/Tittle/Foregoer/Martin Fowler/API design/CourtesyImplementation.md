[CourtesyImplementation](http://martinfowler.com/bliki/CourtesyImplementation.html)



# [CourtesyImplementation](CourtesyImplementation.html)





[API design](/tags/API design.html)

tags:



When you a write a class, you mostly strive to ensure that the
	features of that class make sense for that class. But there are
	occasions when it makes sense to add a feature to allow a class to
	conform to a richer interface that it naturally should.

The most common and obvious example of this is one that comes up
	when you use the composite pattern. Let's consider a simple example
	of containers. You have boxes which can contain other boxes and
	elephants (that's an advantage of virtual elephants.) You want
	to know how many elephants are in a box, considering that you need
	to count the elephants inside boxes inside boxes inside the box. The
  solution, of course, is a simple recursion.

```ruby
class Node
end

class Box < Node
  def initialize 
    @children = []
  end
  def << aNode
    @children << aNode
  end
  def num_elephants
    result = 0
    @children.each do |c|
      if c.kind_of? Elephant
        result += 1
      else
        result += c.num_elephants
      end
    end
    return result
  end
end

class Elephant < Node
end
```

Now the `kind_of?` test in `num_elephants` is a smell, since we
	should be  wary of any conditional that tests the type of an
	object. On the other hand is there an alternative? After all we are
	making the test because elephants can't contain boxes or elephants, so it doesn't
	make sense to ask them how many elephants are inside them. It
	doesn't fit our model of the world to ask elephants how many
	elephants they contain because they can't contain any. We might say
	it doesn't model the real world, but my example feels a touch too
	whimsical for that argument.

However when people use the composite pattern they often do
	provide a method to avoid the conditional - in other words they do
	this.

```ruby
class Node
  #if this is a strongly typed language I define an abstract
  #num_elephants here
end

class Box < Node
  def initialize 
    @children = []
  end
  def << aNode
      @children << aNode
  end
  def num_elephants
    result = 0
    @children.each do |c|
      result += c.num_elephants
    end
    return result
  end
end

class Elephant < Node
  def num_elephants
    return 1
  end
end
```

Many people get very disturbed by this kind of thing, but it does
	a great deal to simplify the logic of code that sweeps through the
	composite structure. I think of it as getting the leaf class
	(elephant) to provide a simple implementation as a courtesy to its
	role as a node in the hierarchy.

The analogy I like to draw is the definition of raising a number
	to the power of 0 in mathematics. The definition is that any number
	raised to the power of 0 is 1. But intuitively I don't think it
	makes sense to say that any number multiplied by itself 0 times is
	1 - why not zero? But the definition makes all the mathematics work
	out nicely - so we suspend our disbelief and follow the definition.

Whenever we build a model we are designing a model to suit how we
	want to perceive the world. Courtesy Implementations are worthwhile
	if they simplify our model.

reposted on 27 Aug 2014












## Find similar articles at the tag

[API design](/tags/API design.html)



