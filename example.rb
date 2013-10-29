require 'destructure/magic'
require_relative './output_annotator'
require_relative './motivators/static'

class Example
  def run

    OutputAnnotator.install

    # == 'destructuring bind' operation ==
    # you're already familiar with special cases of it..

    # regex
    v = 'madlibs are fun to do'
    v =~ /madlibs are (?<adjective>\w+) to (?<verb>\w+)/
    puts $~[:adjective]                            # => fun
    puts $~[:verb]                                 # => do


    # rails/sinatra routes
    # (syntactic sugar over regexes)
    get '/hello/:name' do
      "Hello #{params[:name]}!"
    end

    # == destructuring bind involves two simultaneous operations ==
    #    * pattern match
    #    * bind values


    # ruby array destructuring is a bastardized form
    v = [1,2,3]
    a, b, c = v
    puts a                                         # => 1
    puts b                                         # => 2
    puts c                                         # => 3

    v = [1,2,3,4,5]
    first, *rest = v
    puts first.inspect                             # => 1
    puts rest.inspect                              # => [2, 3, 4, 5]

    v = [1,2,3,4,5]
    first, *middle, last = v
    puts first.inspect                             # => 1
    puts middle.inspect                            # => [2, 3, 4]
    puts last.inspect                              # => 5

    # that's about the extent of ruby's array destructuring power.
    # nested arrays cannot be destructured in a single step
    v = [1,[2,3],4]
    #a, [b,c], d = v                     # => syntax error

    # but you can do it multiple steps
    a, temp, d = v
    b, c = temp
    puts a                                         # => 1
    puts b                                         # => 2
    puts c                                         # => 3
    puts d                                         # => 4

    # no pattern matching is performed
    a, b, c = [1,2,3,4,5,6,7,8,9]
    puts a                                         # => 1
    puts b                                         # => 2
    puts c                                         # => 3

    # no pattern matching is performed
    a, b, c = [1,2]
    puts a.inspect                                 # => 1
    puts b.inspect                                 # => 2
    puts c.inspect                                 # => nil


    # motivating examples:
    # * method argument matching
    # * java -> ruby code converter
    # * client side of API


    # let's see what we can do within the confines of Ruby's syntax...

    # introducing the 'wobbly rocket' operator: =~->
    # think of it like the =~ regex matching operator
    #
    #          something =~ /pattern/
    #                    vs.
    #         something =~-> {pattern}
    #
    # what else can it do?

    # nested arrays
    v = [5,[6,7],8]
    v =~-> { [a,[b,c],d] }
    puts a                                         # => 5
    puts b                                         # => 6
    puts c                                         # => 7
    puts d                                         # => 8

    # plus, it tells us if the match succeeded
    v = [1,2]
    puts (v =~-> { [a, b] }).inspect               # => #<OpenStruct a=1, b=2>
    puts (v =~-> { [a, b, c] }).inspect            # => nil

    # hashes
    v = { x: 1, y: 2 }
    v =~-> { { x: a, y: b } }
    puts a                                         # => 1
    puts b                                         # => 2

    # order doesn't matter. the pattern specifies a subset that must match
    v = { q: 5, r: 9, p: 42, s: 99 }
    v =~-> { { p: a, r: b } }
    puts a                                         # => 42
    puts b                                         # => 9

    # objects

    # work similarly to a hash
    v = Widget.new('gibble', 8)
    v =~-> { Object[flange: a, sprocket: b] }
    puts a                                         # => gibble
    puts b                                         # => 8

    # bind to the attribute names, for simplicity
    v =~-> { Object[flange, sprocket] }
    puts flange                                    # => gibble
    puts sprocket                                  # => 8

    # lock down the acceptable type
    match_result = v =~-> { OpenStruct[flange, sprocket] }
    puts match_result.inspect                      # => nil

    # pattern fields must be present, else match fails
    match_result = v =~-> { Object[flange, sprocket, whizz] }
    puts match_result.inspect                      # => nil

    # it subsumes built-in functionality:

    # regexes
    v = [1, 2, 'hello, bob']
    v =~-> { [a, b, /hello, (?<name>\w+)/] }
    puts a                                         # => 1
    puts b                                         # => 2
    puts name                                      # => bob

    # splatting
    v = [1,2,3,4,5,6,7,8,9]
    v =~-> { [1, 2, @@stuff, 9] }             # '@@' indicates a splat
    puts stuff.inspect                             # => [3, 4, 5, 6, 7, 8]

    # pattern variables can be pretty much anything that goes on
    # the left hand side of an assignment
    v = [1,4,9]
    v =~-> { [1, @my_var, 9] }
    puts @my_var                                   # => 4

    basket = {}
    v = [1,4,9]
    v =~-> { [1, basket[:thing_i_found], 9] }
    puts basket[:thing_i_found]                    # => 4

    one = OpenStruct.new
    one.two = OpenStruct.new
    v = [17,19,23]
    v =~-> { [17, one.two.three, 23] }
    puts one.two.three                             # => 19

    # use '!' to match the value of an expression rather than bind it
    q = 3
    puts ([1,2,3] =~-> { [1,2,!q] }).inspect       # => #<OpenStruct>
    puts ([1,2,4] =~-> { [1,2,!q] }).inspect       # => nil
    @my_var = 789
    puts (789 =~-> { !@my_var }).inspect           # => #<OpenStruct>
    puts (456 =~-> { !@my_var }).inspect           # => nil

    # specify the same variable multiple times in the pattern
    # to require those parts to match
    puts ([1,2,3] =~-> { [x,2,x] }).inspect        # => nil
    puts ([1,2,1] =~-> { [x,2,x] }).inspect        # => #<OpenStruct x=1>

    # use wildcards (underscore) when you don't care
    puts ([1, 2, 'ack!$&@'] =~-> { [1, 2, _] }).inspect # => #<OpenStruct>
    puts ([1, 2, 'ack!$&@'] =~-> { [1, 2, 3] }).inspect # => nil

    # you can specify alternative patterns, like in regexes
    puts (:foo =~-> { :foo | :bar }).inspect       # => #<OpenStruct>
    puts (:bar =~-> { :foo | :bar }).inspect       # => #<OpenStruct>
    puts (:baz =~-> { :foo | :bar }).inspect       # => nil

    # bind a variable while continuing to match substructure
    v = ['hello', 'starting']
    v =~-> { [ greeting = String, participle = /(?<verb>.*)ing$/ ] }
    puts greeting                                  # => hello
    puts participle                                # => starting
    puts verb                                      # => start

    v = [:not_a_string, 'starting']
    puts (v =~-> { [ greeting = String, participle = /(?<verb>.*)ing$/ ] }).inspect # => nil

    StaticAnalysisExample.new.run

    OutputAnnotator.uninstall
    OutputAnnotator.save(50)

  end

  # fake sinatra route match
  def get(route)
    pattern = route.gsub(/:(\w+)/, '(?<\1>[^\\/]+)')
    puts pattern                                   # => /hello/(?<name>[^\/]+)
  end
end

class Widget
  attr_accessor :flange, :sprocket

  def initialize(flange, sprocket)
    @flange, @sprocket = flange, sprocket
  end
end

Example.new.run