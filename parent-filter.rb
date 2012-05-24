#!/usr/bin/env ruby

def execute(cmd)
  stdout = `#{cmd}`
  if $?.success?
    return stdout
  end
  raise "execution of command \"#{cmd}\" failed. Status: #{$?}"
end
args = readline.split

revisions = args.values_at(* args.each_index.select(&:odd?)).uniq

if revisions.length == 2
  # fast-forward-able
  if execute("git merge-base #{revisions[0]} #{revisions[1]}").include? revisions[0]
    revisions.shift
  elsif execute("git merge-base #{revisions[1]} #{revisions[0]}").include? revisions[1]
    revisions.pop
  end
end

puts ['-p'].product(revisions).join(' ')
