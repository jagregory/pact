require 'ostruct'
require 'logger'

module Pact

  class Configuration
    attr_accessor :pact_dir
    attr_accessor :log_dir
    attr_accessor :logger
    attr_accessor :tmp_dir
    attr_accessor :reports_dir
    attr_writer :pactfile_write_mode

    def log_path
      log_dir + "/pact.log"
    end

    def pactfile_write_mode
      if @pactfile_write_mode == :smart
        is_rake_running? ? :overwrite : :update
      else
        @pactfile_write_mode
      end
    end

    private

    #Would love a better way of determining this! It sure won't work on windows.
    def is_rake_running?
      `ps -ef | grep rake | grep #{Process.ppid} | grep -v 'grep'`.size > 0
    end
  end

  def self.configuration
    @configuration ||= default_configuration
  end

  def self.configure
    yield configuration
    FileUtils::mkdir_p configuration.tmp_dir
  end

  def self.clear_configuration
    @configuration = default_configuration
  end

  private

  def self.default_configuration
    c = Configuration.new
    c.pact_dir = File.expand_path('./spec/pacts')
    c.tmp_dir = File.expand_path('./tmp/pacts')
    c.log_dir = default_log_dir
    c.logger = default_logger c.log_path
    c.pactfile_write_mode = :overwrite
    c.reports_dir = File.expand_path('./reports/pacts')
    c
  end

  def self.default_log_dir
    File.expand_path("./log")
  end

  def self.default_logger path
    FileUtils::mkdir_p File.dirname(path)
    logger = Logger.new(path)
    logger.level = Logger::INFO
    logger
  end

end