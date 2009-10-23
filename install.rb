require 'fileutils'

dir_base = "#{Dir.getwd}"
origin = '/vendor/plugins/mail_fetcher/files/'

files = []
files << {:name => 'Mail Fetcher YAML', :destination => "#{dir_base}/config/mail_fetcher.yml", :origin => "#{dir_base}#{origin}mail_fetcher.yml"}
files << {:name => 'Mail Fetcher DAEMON', :destination => "#{dir_base}/script/mail_fetcher", :origin => "#{dir_base}#{origin}mail_fetcher"}
files << {:name => 'Mail Fetcher ComentarioReceiver', :destination => "#{dir_base}/app/models/comentario_receiver.rb", :origin => "#{dir_base}#{origin}comentario_receiver.rb"}
files << {:name => 'Mail Fetcher TmailExtensions', :destination => "#{dir_base}/lib/tmail_extensions.rb", :origin => "#{dir_base}#{origin}tmail_extensions.rb"}

files.each do |f|
  unless File.exist?(f[:destination])
    FileUtils.cp(f[:origin], f[:destination])
    puts "=> Copied #{f[:name]}."
    if f[:destination].include?('/script/')
      FileUtils.chmod 0755, f[:destination]
      puts "=> chmod 0755 #{f[:destination]}."      
    end    
  else
    puts "=> #{f[:name]} file already exists."
  end

end


