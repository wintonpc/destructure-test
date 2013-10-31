# usage:
#  write_to_log(s) - where s is string to log to STDOUT
#  write_to_log(fn, s) - where fn is filename to log to, s is string to write
#  write_to_log(file, s) - where file is a File object, s is string to write
def write_to_log(*args)
  if args.size == 1
    s = args[0]
    # log to STDOUT
  elsif args.size == 2
    if args[0].is_a?(File)
      file, s = args
      # log to File object
    else
      fn, s = args
      # log to file path
    end
  else
    raise "invalid arguments: #{args}"
  end
end

write_to_log(my_file, "I've just picked up a fault in the AE35 unit.")



def write_to_log(s, fn_or_file=nil)
  if fn_or_file.nil?
    # log to STDOUT
  elsif fn_or_file.is_a?(File)
    file = fn_or_file
    # log to File object
  else
    fn = fn_or_file
    # log to file path
  end
else
  raise "invalid arguments: #{args}"
end

write_to_log("I've just picked up a fault in the AE35 unit.", my_file)



def write_to_log(opts)
  file = opts[:file]
  fn = opts[:fn]
  s = opts[:s]
  if s && file
    # log to File object
  elsif s && fn
    # log to file path
  elsif s
    # log to STDOUT
  else
    raise "invalid option set: #{opts}"
  end
end

write_to_log(file: my_file, s: "I've just picked up a fault in the AE35 unit.")



def write_to_log(*args)
  case
    when args =~ [s]
      # log to STDOUT
    when args =~ [file = File, s]
      # log to File object
    when args =~ [fn, s]
      # log to file path
    else
      raise "invalid arguments: #{args}"
  end
end

write_to_log(my_file, "I've just picked up a fault in the AE35 unit.")