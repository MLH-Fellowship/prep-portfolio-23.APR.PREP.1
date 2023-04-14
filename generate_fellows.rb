require 'yaml'

require 'fileutils'



FileUtils.mkdir_p '_fellows'

fellows = YAML.load_file('_data/fellows.yml')

fellows.each do |fellow|
  File.open("_fellows/#{fellow['name'].downcase.gsub(' ', '-')}.md", 'w') do |file|
    file.puts "---"
    file.puts "layout: profile"
    file.puts "name: #{fellow['name']}"
    file.puts "title: #{fellow['title']}"
    file.puts "location: #{fellow['location']}"
    file.puts "university: #{fellow['university']}"
    file.puts "about: #{fellow['about']}"
    file.puts "languages: #{fellow['languages']}"
    file.puts "hobbies: #{fellow['hobbies']}"
    file.puts "img: #{fellow['img']}"
    file.puts "---"
  end
end