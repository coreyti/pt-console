require "rubygems"
require "highline/import"
require 'singleton'

module PivotalTracker
  class Console
    include Singleton
    
    attr_reader :configuration
    
    def initialize
      @configuration = load_configuration

      color_scheme = HighLine::ColorScheme.new do |scheme|
        scheme[:banner]  = [ :green ]
        scheme[:section] = [ :green ]
      end
      HighLine.color_scheme = color_scheme
    end

    def run
      Signal.trap(:INT, "EXIT")
      dashboard
    end

    protected

    def dashboard
      loop do
        banner('Welcome to the Pivotal Tracker console')

        valid_commands = ['quit', 'configure (required)']
        if configured?
          valid_commands = ['quit', 'configure', 'create', 'read', 'update', 'destroy']
        end

        command = choose(*valid_commands) do |config|
          config.header  = "what would you like to do?"
          config.readline = true
        end

        break if command == 'quit'
        send(command.sub(/ .*/, ''))
      end
    end
    
    def configure
      valid_commands = [
        'main menu',
        'set token',
        'set project',
        'save'
      ]

      loop do
        section("configuration", ['current settings...', configuration])

        command = choose(*valid_commands) do |config|
          config.header   = "select an option'"
          config.readline = true
        end

        return if command == 'main menu'

        case command
          when 'set token'
            configuration[:token]   = ask('enter new value') { |config| config.default = configuration[:token] }
          when 'set project'
            configuration[:project] = ask('enter new value') { |config| config.default = configuration[:project] }
          when 'save'
            say 'saving!'
        end
      end

      # command = ask("configuration: enter your API token") do |config|
      #   config.readline = true
      #   config.default  = configuration[:token]
      # end
    end

    def create
      
    end

    def read
      
    end

    def update
      
    end

    def destroy
      
    end

    private

    def banner(message)
      pad = ' ' * ((80 - message.length) / 2)
      say "<%= color('\n#{"-" * 80}\n#{pad}#{message}\n#{"-" * 80}', :banner) %>"
    end
    
    def section(title, info)
      say "<%= color('\n#{title}', :section) %>"

      case info.class.name
        when 'Array'
          message = ""
          info.each do |entry|
            if(entry.is_a? Hash)
              entry.each { |key, value| message << "  #{key}:\t#{value}\n" }
            else
              message << "  #{entry}\n"
            end
          end
          say "<%= color('#{message}', :section) %>"
        when 'String'
          say "<%= color('  #{info}', :section) %>"
      end
    end

    def load_configuration
      config = {
        :token   => nil,
        :project => nil
      }

      env = ENV.select { |key, value| key =~ /^PIVOTALTRACKER/ }
      env.each do |entry|
        config[entry[0].downcase.sub(/^pivotaltracker_/, '').intern] = entry[1]
      end

      if File.exist?(".pivotal_tracker")
        yaml = YAML::load(IO.read(".pivotal_tracker"))
        if yaml
          yaml.inject(config) do |config, entry|
            config[entry[0].to_sym] = entry[1]
          end
        end
      end

      config
    end

    def configured?
      configuration.all? { |key, value| ! (value.nil? || value.empty?) }
    end
  end
end
