module Swift
  class Storage
    
    def initialize(fog_options = {
         :provider => 'HP',
         :hp_access_key => "admin",
         :hp_secret_key => "yourpwd",
         :hp_tenant_id => "d4e1c14691d841f6b53a24b6c4c42a0e",
         :hp_auth_uri =>  'https://auth.hydranodes.de:5000/v2.0/',
         :hp_use_upass_auth_style => true,
         :hp_avl_zone => 'nova',
         :hp_auth_version => :v2
      })
        
      @connection = Fog::Storage.new(fog_options)
    end
  
    def c
      @connection
    end

    def print_directories
      # Retrieve directories and fetch their content
      puts "Retrieving directories..."
      @connection.directories.each do |dir|
        p dir.files
      end
      puts "-" * 30
    end
  
    def create_dir(dir)
      puts "Creating dir #{dir}..."
      dir = @connection.directories.create(:key => dir)
      puts "done."
      dir
    end
    
    def list_dir(dir)
      str = String.new
      
      dir = @connection.directories.get(dir)
      if dir then
        str = dir.files.to_s
      else
        str = "#{dir} directory wasn't found"
      end
      
      str
    end
    
    def upload_file(swift_dir, file_loc, swift_file_key)
      file = nil
      # Upload
      test_dir = @connection.directories.get(swift_dir)
      if test_dir then
        file = test_dir.files.create(:key => swift_file_key, :body => File.open(file_loc))      
      else
         puts "\nWarning: #{dir} does not exist.\n"
      end    
      file
    end

    def delete_file(id, dir = test)
      file = @connection.directories.get(dir).files.get(id)
      file.destroy
    end

  end
end