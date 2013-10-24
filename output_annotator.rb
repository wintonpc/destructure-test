require 'tempfile'

class OutputAnnotator

  class << self
    def install
      @old_stdout = $stdout
      @shim = Shim.new($stdout)
      $stdout = @shim
    end

    def uninstall
      $stdout = @old_stdout
    end

    def save(justification)
      @shim.save(justification)
    end
  end

  class Shim
    def initialize(real)
      @real = real
      @log = []
    end

    def write(s)
      m = /(.*\.rb):(\d+)/.match(caller_locations(1, 1)[0].to_s)
      log(s, m[1], m[2]) unless s.strip == ''
      @real.write(s)
    end

    def log(s, file, line)
      @log.push Entry.new(file, line, s)
    end

    def save(justification)
      file_groups = @log.group_by{|x| x.file}
      file_groups.keys.each do |fn|
        entries_by_line = Hash[file_groups[fn].map{|e| [e.line, e]}]
        tmpfn = Tempfile.open('output_annotator') do |op|
          File.readlines(fn).each_with_index do |orig, line|
            annotation = (ent = entries_by_line[(line+1).to_s]) && ent.text
            if annotation
              op.puts("#{orig.chomp.sub(/\s*(#.*)?$/, '').ljust(justification)} # => #{annotation}")
            else
              op.print(orig)
            end
          end
          op.path
        end

        FileUtils.copy(tmpfn, fn)
      end
    end

    def dump
      @log.each do |kv|
        STDOUT.puts "#{kv.first} => #{kv.last}"
      end
    end
  end

  class Entry
    attr_reader :file, :line, :text

    def initialize(file, line, text)
      @file, @line, @text = [file, line, text]
    end
  end

end