require "rubygems"
require "highline/import"
require 'singleton'

module PivotalTracker
  class Console
    include Singleton
    
    def initialize
      color_scheme = HighLine::ColorScheme.new do |scheme|
        scheme[:headline] = [ :green ]
      end
      HighLine.color_scheme = color_scheme
    end

    def run
      Signal.trap(:INT, "EXIT")
      
      loop do
        puts "run..."
        cmd = ask("<%= color('Enter command: ', :headline) %>", %w{save load reset quit}) do |q|
          # q.first_answer = ENV['BLAH']
          # q.confirm = true
          q.default = 'quit'
          q.readline = true
        end
        break if cmd == "quit"
        send(cmd)
      end
    end
    
    def save
      cmd = choose('save as one', 'save as two') do |c|
        c.header = 'please choose...'
      end
      puts cmd
    end
    
    def load
      say('loading')
    end
    
    def reset
      say('resetting')
    end
  end
end
