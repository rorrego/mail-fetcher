require 'tmail_extensions'
require 'mms2r'
class ComentarioReceiver < ActionMailer::Base

  def receive(email)
      message = MMS2R::Media.new(email)
      #Process the message here
            
      message.media.keys.each do |m|
        next if (m == 'text/html' || m == 'text/plain')
        message.media[m].each do |a|
          #do something with the attachments
        end
      end
  end


end