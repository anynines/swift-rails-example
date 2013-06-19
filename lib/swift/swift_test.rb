require 'json'

module Swift
  class SwiftTest
    
    def initialize
      @storage = Storage.new(fog_credentials_from_cf_swift_credentials(get_swift_credentials_hash))
    end


    # the test consists of 3 sub-tasks:
    # 1) create a directory
    # 2) upload an example file
    # 3) delete the example file again
    # the test prints out a directory listing after performing each sub-task
    # the sub-tasks are encapsulated within methods below
    def perform_test
      out_hash = Hash.new

      dirname = create_test_directory

      out_hash[:dirname] = dirname
      out_hash[:list_before] = list_directory_string dirname

      file = upload_example_file dirname

      out_hash[:file_url] = "#{file.public_url}"
      out_hash[:list_after] = list_directory_string dirname

      delete_example_file file, dirname
      
      out_hash[:list_after_delete] = list_directory_string dirname

      out_hash
    end

    # sub-methods for performing the test

    # creates a test directory on the swift server
    # returns the name of the test directory
    def create_test_directory
      dirname = "fog-swift-test-#{Time.now.to_i}"
      puts "Creating Directory #{dirname}"
      @storage.create_dir(dirname)
      dirname
    end

    # returns a string with a listing of the files within
    # the directory with the given name
    def list_directory_string(dirname)
      "#{@storage.list_dir(dirname)}"
    end

    # uploads an example file (public/404.html) to the given directory
    # returns the file descriptor for the uploaded file
    def upload_example_file(dirname)
      file_location = Rails.root.to_s + "/public/404.html"

      puts "Uploading file"
      file = @storage.upload_file dirname, file_location, "404.html"
    end

    # deletes the file referenced by the given file descriptor
    # in the given directory on swift
    def delete_example_file (file, dirname)
      puts "Deleting the file again"
      @storage.delete_file file.key, dirname
    end

    # reads the swift credentials from the environment variable
    # returns a hash with the credentials delivered by the VCAP_SERVICES env variable
    def get_swift_credentials_hash
      vcap_services_env_str = ENV["VCAP_SERVICES"]
      vcap_services_hash = hash = JSON.parse vcap_services_env_str
      swift_credentials_hash = vcap_services_hash["swift-1.0"].first["credentials"]
    end

    # creates a valid fog configuration hash from the credentials retrieved from the
    # swift service.
    def fog_credentials_from_cf_swift_credentials(cf_swift_credentials)
      {
          :provider => 'HP',
          :hp_access_key => cf_swift_credentials["user_name"],
          :hp_secret_key => cf_swift_credentials["password"],
          :hp_tenant_id => cf_swift_credentials["tenant_id"],
          :hp_auth_uri =>  cf_swift_credentials["authentication_uri"],
          :hp_use_upass_auth_style => true,
          :hp_avl_zone => cf_swift_credentials["availability_zone"],
          :hp_auth_version => cf_swift_credentials["authentication_version"].to_sym
      }
    end

  end
end