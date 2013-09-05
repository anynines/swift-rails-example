require 'json'

module Swift
  class SwiftTest
    
    def initialize
      env_hash = fog_credentials_from_cf_swift_credentials(get_swift_credentials_hash)
      @storage = Storage.new(env_hash[:fog], env_hash[:account_meta_key])
    end


    # the test consists of 3 sub-tasks:
    # 1) create a public and a private directory
    # 2) upload one example file to the public directory and one to the private directory
    # the test prints out a directory listing after performing each sub-task
    # the sub-tasks are encapsulated within methods below
    def perform_test
      out_hash = Hash.new

      # create private and public test directories
      dirname_private = create_private_test_directory
      dirname_public = create_public_test_directory

      out_hash[:dirname_private] = dirname_private
      out_hash[:dirname_public] = dirname_public

      # upload files
      public_file = upload_example_file_1 dirname_public
      private_file = upload_example_file_2 dirname_private

      # list file urls
      out_hash[:private_file_temp_url] = generate_temp_url private_file
      out_hash[:public_file_url] = "#{public_file.public_url}"

      # list directory contents
      out_hash[:directory_contents_public] = list_directory_string dirname_public
      out_hash[:directory_contents_private] = list_directory_string dirname_private

      out_hash
    end

    # --------------------------------------------------------------------------
    # sub-methods for performing the test --------------------------------------
    # --------------------------------------------------------------------------

    # directory functions -------------------------------------

    # creates a directory with the given name on swift
    def create_swift_directory(dirname)
      puts "Creating Directory #{dirname}"
      dir = @storage.create_dir(dirname)
      { :dirname => dirname, :dir => dir }
    end

    # creates a private test directory on the swift server
    # returns the name of the test directory
    def create_private_test_directory
      dirname = "fog-swift-test-#{Time.now.to_i}"
      create_swift_directory dirname
      return dirname
    end

    # creates a public test directory on the swift server
    def create_public_test_directory
      dirname = "fog-swift-test-public-#{Time.now.to_i}"
      ha = create_swift_directory dirname
      @storage.make_directory_public ha[:dir]
      return ha[:dirname]
    end

    # returns a string with a listing of the files within
    # the directory with the given name
    def list_directory_string(dirname)
      "#{@storage.list_dir(dirname)}"
    end


    # file interaction -------------------------------------

    # uploads the file on the given location to the given directory
    # returns the file descriptor for the uploaded file
    def upload_file(file_location, file_name, dirname)
      puts "Uploading file"
      file = @storage.upload_file dirname, file_location, file_name
    end

    # uploads the picture.jpg file to the given directory
    def upload_example_file_1(dirname)
      file_location = Rails.root.to_s + "/public/picture.jpg"
      upload_file file_location, "picture.jpg", dirname
    end

    # uploads the public/swift_test.html file to the given directory
    def upload_example_file_2(dirname)
      file_location = Rails.root.to_s + "/public/swift_test.html"
      upload_file file_location, "swift_test.html", dirname
    end

    # deletes the file referenced by the given file descriptor
    # in the given directory on swift
    def delete_example_file (file, dirname)
      puts "Deleting the file: #{file.inspect} from directory #{dirname}"
      @storage.delete_file file.key, dirname
    end

    # generates a temporary url for the given file
    # returns a url as string
    def generate_temp_url(file)
      @storage.create_temp_url file
    end

    # fog swift configuration ----------------------------

    # reads the swift credentials from the environment variable
    # returns a hash with the credentials delivered by the VCAP_SERVICES env variable
    def get_swift_credentials_hash
      vcap_services_env_str   = ENV["VCAP_SERVICES"]
      raise "please set ENV variable VCAP_SERVICES" unless vcap_services_env_str
      vcap_services_hash      = JSON.parse vcap_services_env_str
      swift_credentials_hash  = vcap_services_hash["swift-1.0"].first["credentials"]
    end

    # creates a valid fog configuration hash from the credentials retrieved from the
    # swift service.
    # the hash consists of 2 main keys:
    # :fog - the fog credentials hash
    # :account_meta_key - the swift account meta key for generating temporary urls
    def fog_credentials_from_cf_swift_credentials(cf_swift_credentials)

      fog_hash = {
          :provider => 'HP',
          :hp_access_key => cf_swift_credentials["user_name"],
          :hp_secret_key => cf_swift_credentials["password"],
          :hp_tenant_id => cf_swift_credentials["tenant_id"],
          :hp_auth_uri =>  cf_swift_credentials["authentication_uri"],
          :hp_use_upass_auth_style => true,
          :hp_avl_zone => cf_swift_credentials["availability_zone"],
          :hp_auth_version => cf_swift_credentials["authentication_version"].to_sym,
      }
      ha = { :fog => fog_hash, :account_meta_key => cf_swift_credentials["account_meta_key"] }
    end

  end
end