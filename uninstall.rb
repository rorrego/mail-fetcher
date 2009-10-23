require 'fileutils'

dir_base = "#{Dir.getwd}"
origin = '/vendor/plugins/mail-fetcher/files/'

files = []
files << {:name => 'Mail Fetcher YAML', :destination => "#{dir_base}/config/mail-fetcher.yml", :origin => "#{dir_base}#{origin}mail-fetcher.yml"}
files << {:name => 'Mail Fetcher DAEMON', :destination => "#{dir_base}/script/mail-fetcher", :origin => "#{dir_base}#{origin}mail-fetcher"}
files << {:name => 'Mail Fetcher ComentarioReceiver', :destination => "#{dir_base}/app/models/comentario_receiver.rb", :origin => "#{dir_base}#{origin}comentario_receiver.rb"}
files << {:name => 'Mail Fetcher TmailExtensions', :destination => "#{dir_base}/lib/tmail_extensions.rb", :origin => "#{dir_base}#{origin}tmail_extensions.rb"}


files.each do |f|
  FileUtils.rm(f[:destination])
    puts "=> Borrado #{f[:name]}"
end


puts "Ahora rm -rf vendor/plugins/mail-fetcher"
