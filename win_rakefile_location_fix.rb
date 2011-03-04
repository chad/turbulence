class Rake::Application
  def rakefile_location
      bt = caller
      bt.map { |t| t[/([^:]+):/,1] }
      bt.find {|str| str =~ /^#{@rakefile}$/ } || ""
  end
end

