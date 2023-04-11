module PodLocations
    require 'net/http'
    require 'json'
    class StatsGenerator < Jekyll::Generator
      safe true
  
        def generate(site)
            # initialized an array
            fellows_information = []
            fellows = site.data['fellows']

            fellows.each do |fellow|
                title = fellow['title']
                name = fellow['name']
                
                location = fellow['location']
                university = fellow['university']
                about = fellow['about']
                languages = fellow['languages']
                hobbies = fellow['hobbies']
                img = fellow['img']
                # this creates a dictionary assigning the key value pairs, add description using same format once issue#9 is closed
               
                #fellow_information = {'title' => title, 'name' => name, 'location' => location, 'university' => university, 'about' => about,
                #                    'languages' => languages, 'hobbies' => hobbies, 'img' => img}
                fellow_information = {'title' => title, 'name' => name, 'location' => location, 'about' => about}
                # this creates an array of dictionaries 
                fellows_information.push(fellow_information)
            end

            site.data['fellows_information'] = fellows_information
        end
    end

end

