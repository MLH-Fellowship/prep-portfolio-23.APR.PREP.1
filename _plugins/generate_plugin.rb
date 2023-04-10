module Jekyll
  class ServeHook < Jekyll::Command
    class << self
      def init_with_program(prog)
        prog.command(:serve) do |c|
          c.action do |args, options|
            puts "Starting Jekyll serve with custom plugin"
            Dir.chdir(Jekyll::Commands::Serve.site_directory(options)) do
              system('ruby generate_fellows.rb')
            end
          end
        end
      end
    end
  end
end
