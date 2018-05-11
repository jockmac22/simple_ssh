#! /usr/local/bin/ruby
require 'digest'



def files_hash(files)
  files_hash = ""
  files.each do |file|
    files_hash += Digest::SHA1.hexdigest(File.read(file))
  end
  Digest::SHA1.hexdigest(files_hash)
end

def spinner_message(msg)
  states = ['/','-','\\','|']
  state_idx = (Time.now.to_f*10.0).to_i % 4
  state  = states[state_idx]
  print "\r#{msg}...#{state}"
end


def show_wait_spinner(msg, fps=10)
  chars = %w[| / - \\]
  char_idx = 0
  delay = 1.0/fps
  iter = 0
  spinner = Thread.new do
    while iter do  # Keep spinning until told otherwise
      char_idx = (Time.now.to_f*10).to_i % 4
      print "#{msg}...#{chars[char_idx]}"
      sleep delay
      print "\r"
    end
  end
  yield.tap{       # After yielding to the block, save the return value
    iter = false   # Tell the thread to exit, cleaning up after itself…
    spinner.join   # …and wait for it to do so.
  }                # Use the block's return value as the method's
end

previous_hash = ""
current_hash = ""
while(true)
  if current_hash != previous_hash
    puts "\e[H\e[2J"
    puts "\n\n"
    puts "-"*80
    puts "Spec Scan"
    puts "Files changed, running RSpec @ #{Time.now.to_s}"
    puts "-"*80
    system("time cd .. && rspec #{ARGV[0]}")
    previous_hash = current_hash
  end
  show_wait_spinner("Scanning directories for changes") do
    files = Dir[File.join("..","lib","**","*.rb")] + Dir[File.join("..","spec","**","*.rb")]
    current_hash = files_hash(files)
    sleep(2)
  end
end
