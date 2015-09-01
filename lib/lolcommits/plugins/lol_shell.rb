# -*- encoding : utf-8 -*-
require 'yaml'
require 'oauth'

# twitter gem currently spams stdout when activated, surpress warnings just during the inital require
original_verbose, $VERBOSE = $VERBOSE, nil # Supress warning messages.
$VERBOSE = original_verbose # activate warning messages again.

module Lolcommits
  class LolShell < Plugin

    def run_postcapture
      return unless valid_configuration?
      # Run the shell script defined in configuration['post_script']
      script = configuration['post_script'] + " '" + runner.main_image + "'"
      debug "Running: " + script
      system (script)
    end

    def configure_options!
      options = super
      # ask user to configure tokens if enabling
      if options['enabled']
        config = configure!

        if config
          options = options.merge(config)
        else
          return # return nil if configure_auth failed
        end
      end
      options
    end

    def configure!
      puts "Script to execute postcommit: "
      post_script = STDIN.gets.strip.downcase.to_s
      {
        'post_script' => post_script
      }
    end

    def configured?
      !configuration['enabled'].nil? &&
        configuration['post_script']
    end

    def self.name
      'shell'
    end

    def self.runner_order
      :postcapture
    end
  end
end
