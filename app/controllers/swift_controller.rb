class SwiftController < ApplicationController
  
  # create a directory, write a file, delete it again, show output
  def test_swift
      stest = ::Swift::SwiftTest.new
      @hash = stest.perform_test
  end
  
  # just show the environment variables
  def read_environment

  end
end
