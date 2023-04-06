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
                location = fellow['location']
                name = fellow['name']
                # add a description when Issue #9 is closed
                # this creates a dictionary assigning the key value pairs, add description using same format once issue#9 is closed
                fellow_information = {'name' => name, 'location' => location}
                # this creates an array of dictionaries 
                fellows_information.push(fellow_information)
            end

            site.data['fellows_information'] = fellows_information
        end
    end
    
    # Output the JSON string to the HTML file
    #File.open('_data/location_list.json', 'w') do |file|
    #    file.write(json_location_list)
end