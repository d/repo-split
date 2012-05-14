#!/usr/bin/env ruby

args = readline.split

revisions = args.values_at(* args.each_index.select(&:odd?)).uniq

if revisions.length == 2
  # fast-forward-able
  if %x(git rev-list #{revisions[0]}^..#{revisions[1]}).include? revisions[0]
    revisions.shift
  elsif %x(git rev-list #{revisions[1]}^..#{revisions[0]}).include? revisions[1]
    revisions.pop
  end
end

puts ['-p'].product(revisions).join(' ')
