#!/usr/bin/env ruby

require 'readline'
require 'open3'

def input(prompt="", newline=false)
  prompt += "\n" if newline
  Readline.readline(prompt, true).squeeze(" ").strip
end

def run(*args)
  stdin, stdout, stderr, wait_thread = Open3.popen3(*args)

  output = stdout.readlines

  if !wait_thread.value.success?
    puts "Failed to execute #{args} with #{wait_thread.value}"
    puts "out: #{output.join ">> "}"
    puts "err: #{stderr.readlines.join ">> "}"
    exit 1
  end

  stdin.close
  stdout.close
  stderr.close

  return output
end

output = run "git", "status", "--porcelain"

def commit_state(message, when_)
  diff = run "git", "diff", "--color"
  puts "diff:"
  puts ">> #{diff.join ">> "}"
  status = run "git", "status"
  puts "status:"
  puts ">> #{status.join ">> "}"

  work_done = input(message)
  commit_message = "#{when_}: #{work_done}"
  sure = input("Are you sure? [y/N]: ")

  exit(1) if sure.downcase != "y"

  run "git", "commit", "-a", "-m", commit_message
  system "git", "push"
end

if !output.empty?
  commit_state("What have you done: ", "start")
end
