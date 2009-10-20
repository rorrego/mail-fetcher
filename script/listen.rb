puts '=> Loading Rails...'

require File.dirname(__FILE__) + '/../../../../config/environment'
require File.dirname(__FILE__) + '/../../../../app/overrides/action_mailer'

config = YAML.load_file("#{RAILS_ROOT}/config/mailer_daemon.yml")[RAILS_ENV.to_sym].to_options
invoker = Fetcher
poller = invoker.create(config.merge({:type => :imap, :receiver => ComentarioReceiver}))
puts '** Rails loaded.'
puts "** Starting #{ invoker }..."
puts '** Use CTRL-C to stop.'

ActiveRecord::Base.logger = Fetcher::Base.logger
ActionController::Base.logger = Fetcher::Base.logger

trap(:INT) { poller.stop; exit }

begin
  poller.listen
ensure
  puts '** No Fetchers found.'
  puts "** Exiting at #{Time.now}"
end

def tail(log_file)
  cursor = File.size(log_file)
  last_checked = Time.now
  tail_thread = Thread.new do
    File.open(log_file, 'r') do |f|
      loop do
        f.seek cursor
        if f.mtime > last_checked
          last_checked = f.mtime
          contents = f.read
          cursor += contents.length
          print contents
        end
        sleep 1
      end
    end
  end
  tail_thread
end