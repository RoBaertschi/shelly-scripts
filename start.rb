#!/usr/bin/env ruby

require 'readline'
require 'open3'

def input(prompt="", newline=false)
  prompt += "\n" if newline
  Readline.readline(prompt, true).squeeze(" ").strip
end

output = `git status --porcelain`

def run(*args)
  stdin, stdout, stderr, wait_thread = Open3.popen3(*args)

  if !wait_thread.value.success?
    puts "Failed to execute #{args} with #{wait_thread.value}"
    puts "out: #{stdout.readlines.join ">> "}"
    puts "err: #{stderr.readlines.join ">> "}"
    exit 1
  end

  stdin.close
  stdout.close
  stderr.close
end

def commit_state(message, when_)
  work_done = input(message)
  commit_message = "#{when_}: #{work_done}"

  run("git", "add", ".")
  run("git", "commit", "-m", commit_message)
end

if !output.empty?
  commit_state("What have you done: ", "Start")
end
