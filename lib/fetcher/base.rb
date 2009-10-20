require 'eventmachine'
module Fetcher
  class Base
    # Options:
    # * <tt>:server</tt> - Server to connect to.
    # * <tt>:username</tt> - Username to use when connecting to server.
    # * <tt>:password</tt> - Password to use when connecting to server.
    # * <tt>:receiver</tt> - Receiver object to pass messages to. Assumes the
    # receiver object has a receive method that takes a message as it's argument
    #
    # Additional protocol-specific options implimented by sub-classes
    #
    # Example: 
    #   Fetcher::Base.new(:server => 'mail.example.com',
    #                     :username => 'pam',
    #                     :password => 'test',
    #                     :receiver => IncomingMailHandler)

    cattr_accessor :logger
    attr_accessor :sleep_time    
    
    @@logger ||= ::RAILS_DEFAULT_LOGGER
    
    
    def initialize(options={})
      %w(server username password receiver).each do |opt|
        raise ArgumentError, "#{opt} is required" unless options[opt.to_sym]
        # convert receiver to a Class if it isn't already.
        if opt == "receiver" && options[:receiver].is_a?(String)
          options[:receiver] = Kernel.const_get(options[:receiver])
        end
          
        instance_eval("@#{opt} = options[:#{opt}]")
      end
      instance_eval("@sleep_time = 60")
    end


    def listen
      cambiar_usuario(1)
           
      EM.run do
        while(!@shutdown) do
          puts "-- Running Fetcher at #{Time.now}"
          cambiar_usuario(1)
          begin
            self.fetch
          rescue => e
            puts "#{e}"
          end
          sleep self.sleep_time
        end        
      end    
    end
    
    def stop      
      @shutdown = true
      EM.stop if EM.reactor_running?      
    end
    
    # Run the fetching process
    def fetch
      establish_connection
      get_messages
      close_connection
    end
    
    protected
    
    # Stub. Should be overridden by subclass.
    def establish_connection #:nodoc:
      raise NotImplementedError, "This method should be overridden by subclass"
    end
    
    # Stub. Should be overridden by subclass.
    def get_messages #:nodoc:
      raise NotImplementedError, "This method should be overridden by subclass"
    end
    
    # Stub. Should be overridden by subclass.
    def close_connection #:nodoc:
      raise NotImplementedError, "This method should be overridden by subclass"
    end
    
    # Send message to receiver object
    def process_message(message)
      raise NotImplementedError, "This method should be overridden by subclass"
    end
    
    # Stub. Should be overridden by subclass.
    def handle_bogus_message(message) #:nodoc:
      raise NotImplementedError, "This method should be overridden by subclass"
    end
  end
end

