require 'destructure'
require 'destructure/magic'

class Array
  include Destructure[:matcher_name => :match, :env_name => :m]

  def qsort
    case self
      when match { [] }
        []
      when match { [ pivot, @@rest ]}
        m.rest.select{|x| x < m.pivot}.qsort + [m.pivot] + m.rest.select{|x| x >= m.pivot}.qsort
    end
  end
end