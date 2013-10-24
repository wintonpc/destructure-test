require 'destructure/magic'
require_relative './output_annotator'

class Example
  def run

    OutputAnnotator.install

    # == 'destructuring bind' operation ==
    # you're already familiar with special cases of it..

    # regex
    v = 'madlibs are fun to do'
    v =~ /madlibs are (?<adjective>\w+) to (?<verb>\w+)/
    puts $~[:adjective]                       # => fun
    puts $~[:verb]                            # => do


    # rails/sinatra routes
    # (syntactic sugar over regexes)
    get '/hello/:name' do
      "Hello #{params[:name]}!"
    end

    # == destructuring bind involves two simultaneous operations ==
    #    * pattern match
    #    * bind variables


    # ruby array destructuring is a bastardized form
    v = [1,2,3]
    a, b, c = v
    puts a                                    # => 1
    puts b                                    # => 2
    puts c                                    # => 3

    v = [1,2,3,4,5]
    first, *rest = v
    puts first.inspect                        # => 1
    puts rest.inspect                         # => [2, 3, 4, 5]

    v = [1,2,3,4,5]
    first, *middle, last = v
    puts first.inspect                        # => 1
    puts middle.inspect                       # => [2, 3, 4]
    puts last.inspect                         # => 5

    # that's about the extent of ruby's array destructuring power.
    # nested arrays cannot be destructured in a single step
    v = [1,[2,3],4]
    #a, [b,c], d = v                     # => syntax error

    # but you can do it multiple steps
    a, temp, d = v
    b, c = temp
    puts a                                    # => 1
    puts b                                    # => 2
    puts c                                    # => 3
    puts d                                    # => 4

    # no pattern matching is performed
    a, b, c = [1,2,3,4,5,6,7,8,9]
    puts a                                    # => 1
    puts b                                    # => 2
    puts c                                    # => 3

    # no pattern matching is performed
    a, b, c = [1,2]
    puts a.inspect                            # => 1
    puts b.inspect                            # => 2
    puts c.inspect                            # => nil




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
    puts a                                    # => 5
    puts b                                    # => 6
    puts c                                    # => 7
    puts d                                    # => 8

    # plus, it tells us if the match succeeded
    v = [1,2]
    puts (v =~-> { [a, b] }).inspect          # => #<OpenStruct a=1, b=2>
    puts (v =~-> { [a, b, c] }).inspect       # => nil

    # hashes
    v = { x: 1, y: 2 }
    v =~-> { { x: a, y: b } }
    puts a                                    # => 1
    puts b                                    # => 2

    v = { q: 5, r: 9, p: 42, s: 99 }
    v =~-> { { p: a, r: b } }
    puts a                                    # => 42
    puts b                                    # => 9

    # it subsumes built-in functionality
    # regexes
    v = [1, 2, 'hello, bob']
    v =~-> { [a, b, /hello, (?<name>\w+)/] }
    puts a                                    # => 1
    puts b                                    # => 2
    puts name                                 # => bob
    # splatting
    v = [1,2,3,4,5,6,7,8,9]
    v =~-> { [1,2] }

    OutputAnnotator.uninstall
    OutputAnnotator.save(45)

  end

  # fake sinatra route match
  def get(route)
    pattern = route.gsub(/:(\w+)/, '(?<\1>[^\\/]+)')
    puts pattern                              # => /hello/(?<name>[^\/]+)
  end
end

Example.new.run