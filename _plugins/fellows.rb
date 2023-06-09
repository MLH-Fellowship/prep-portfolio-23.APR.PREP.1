module FellowsPlugin
  class FellowsGenerator < Jekyll::Generator
    safe true
    
    def generate(site)
      fellows = site.data['fellows']
      fellows.each do |fellow|
        fellow['url'] = fellow['name'].downcase.gsub(' ', '-').tr('.', '')
                          .to_s
        site.pages << FellowPage.new(site, fellow)
      end
      site.data['fellows'] = fellows
    end
  end

  class FellowPage < Jekyll::Page
    def initialize(site, fellow)
      @site = site

      # Path to the source directory.
      @base = site.source

      # Directory the page will reside in.
      @dir = 'fellows'

      # All pages have the same filename.
      @basename = fellow['url']
      @ext = '.md'
      @name = "#{@basename}.md"

      # Define any custom data you want.
      @data = {
        'layout' => 'profile',
        'title' => fellow['title'],
        'location' => fellow['location'],
        'university' => fellow['university'],
        'about' => fellow['about'],
        'languages' => fellow['languages'],
        'hobbies' => fellow['hobbies'],
        'img' => fellow['img']
      }
    end
  end
end
