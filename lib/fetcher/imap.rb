require File.dirname(__FILE__) + '/../vendor/plain_imap'
module Fetcher
  class Imap < Base
    
    PORT = 143
    
    protected    
    # Additional Options:
    # * <tt>:authentication</tt> - authentication type to use, defaults to PLAIN
    # * <tt>:port</tt> - port to use (defaults to 143)
    # * <tt>:ssl</tt> - use SSL to connect
    # * <tt>:use_login</tt> - use LOGIN instead of AUTHENTICATE to connect (some IMAP servers, like GMail, do not support AUTHENTICATE)
    # * <tt>:processed_folder</tt> - if set to the name of a mailbox, messages will be moved to that mailbox instead of deleted after processing. The mailbox will be created if it does not exist.
    # * <tt>:error_folder:</tt> - the name of a mailbox where messages that cannot be processed (i.e., your receiver throws an exception) will be moved. Defaults to "bogus". The mailbox will be created if it does not exist.

    def initialize(options={})
      @authentication = options.delete(:authentication) || 'PLAIN'
      @port = options.delete(:port) || PORT
      @ssl = options.delete(:ssl)
      @use_login = options.delete(:use_login)
      @processed_folder = options.delete(:processed_folder)
      @error_folder = options.delete(:error_folder) || 'bogus'
      super(options)
    end
    
    # Open connection and login to server
    def establish_connection
      tries = 1
      begin
        @connection = Net::IMAP.new(@server, @port, @ssl)
        #some IMAP servers, like GMail, do not support AUTHENTICATE
        @connection.login(@username, @password)
      rescue => e
        puts "Fetcher::Imap.establish_connection Error at #{Time.now} (attempt: #{tries}): #{e} \n #{e.message}"            
        tries +=1
        retry        
      end
    end
    
    # Retrieve messages from server
    def get_messages
      @connection.select('INBOX')
      @connection.uid_search(['ALL']).each do |uid|
        msg = @connection.uid_fetch(uid,'RFC822').first.attr['RFC822']
        tries = 1
        begin
          puts "Fetcher::Imap.get_messages Parseando Mensaje #{uid}"
          ComentarioReceiver.receive(msg)
          add_to_processed_folder(uid) if @processed_folder
        rescue => e
          #Rescatar Exception "Mysql::Error: MySQL server has gone away"          
          if e.to_s =~ /away/ && tries < 5
            puts "Fetcher::Imap.get_messages (Mysql away) Error at #{Time.now} (attempt: #{tries}): #{e} \n #{e.message}"            
            tries +=1
            ActiveRecord::Base.connection.reconnect!
            retry
          else
            puts "Fetcher::Imap.get_messages Error at #{Time.now} (attempt: #{tries}): #{e} \n #{e.message} \n #{e.backtrace.join("\n")}"
            handle_bogus_message(msg, e)
          end          
        end
        # Mark message as deleted 
        @connection.uid_store(uid, "+FLAGS", [:Seen, :Deleted])
      end
    end
    
    # Store the message for inspection if the receiver errors
    def handle_bogus_message(message, e)
      create_mailbox(@error_folder)
      @connection.append(@error_folder, message)
      HoptoadNotifier.notify(
            :error_class => "ComentarioReceiver #{e.class} Error", 
            :error_message => "#{e.class}: #{e.message}", 
            :request => { :params => {:message => message} }
          )      
    end
    
    # Delete messages and log out
    def close_connection
      @connection.expunge
      @connection.logout
      @connection.disconnect
    rescue  => e
      puts "Error closing connection at #{Time.now}: #{e} \n #{e.message}"      
    end
    
    def add_to_processed_folder(uid)
      create_mailbox(@processed_folder)
      @connection.uid_copy(uid, @processed_folder)
    end
    
    def create_mailbox(mailbox)
      unless @connection.list("", mailbox)
        @connection.create(mailbox)
      end
    end
    
  end
end