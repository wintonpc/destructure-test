require 'destructure/magic'
require_relative './output_annotator'

class Example
  def run

    OutputAnnotator.install

    a = 1 + 2
    puts a                               # => 3

    foo = 5 * 10
    puts foo                             # => 50

    OutputAnnotator.uninstall
    OutputAnnotator.save(40)

  end
end

Example.new.run