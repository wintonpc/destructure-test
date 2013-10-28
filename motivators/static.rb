class StaticAnalysisExample
  def run
    puts(sexp { 42 })                              # => [:lit, 42]
    puts(sexp { true })                            # => [:true]
    puts(sexp { 'hello' })                         # => [:str, "hello"]
    puts(sexp { a = :foo })                        # => [:lasgn, :a, [:lit, :foo]]
    puts(sexp { @b = :bar })                       # => [:iasgn, :@b, [:lit, :bar]]
    puts(sexp { 1 + 2 })                           # => [:call, [:lit, 1], :+, [:arglist, [:lit, 2]]]
    puts(sexp { @babel.translate('hola', :en) })   # => [:call, [:ivar, :@babel], :translate, [:arglist, [:str, "hola"], [:lit, :en]]]
    puts(sexp { String.new('fun') })               # => [:call, [:const, :String], :new, [:arglist, [:str, "fun"]]]
    puts(sexp { h[:three] = 3 })                   # => [:attrasgn, [:call, nil, :h, [:arglist]], :[]=, [:arglist, [:lit, :three], [:lit, 3]]]

    puts(sexp { puts 'go ahead' if is_valid })     # => [:if, [:call, nil, :is_valid, [:arglist]], [:call, nil, :puts, [:arglist, [:str, "go ahead"]]], nil]

    puts(sexp {                                    # => [:if, [:call, nil, :is_valid, [:arglist]], [:call, nil, :puts, [:arglist, [:str, "go ahead"]]], [:call, nil, :raise, [:arglist, [:str, "you suck"]]]]
      if is_valid
        puts 'go ahead'
      else
        raise 'you suck'
      end
    })
  end

  def analyze(exp)
    case
      when exp =~ [:lit, value]
        analyze_literal(value)
      when exp =~ [:lasgn, lhs, rhs]
        analyze_local_assignment(lhs, rhs)
      when exp =~ [:call, [:const, class_name], :new, [:arglist, *args]]
        analyze_construction(class_name, args)
      when exp =~ [:call, receiver, method_name, [:arglist, *args]]
        analyze_method_call(receiver, method_name, args)
      # ...
    end
  end

  def sexp(&block)
    block.to_sexp(strip_enclosure: true, ignore_nested: true).to_a.inspect
  end
end