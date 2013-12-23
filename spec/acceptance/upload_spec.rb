require 'rspec'
require 'net/http'
require 'pathname'
require 'open-uri'
require 'json'
require 'acceptance/acceptance_spec_helper'

describe 'Upload files' do
  include AcceptanceSpecHelper

  it 'Upload multiple files concurrently' do
    post_first_half_of_file_1
    post_first_half_of_file_2

    progress_is_at_50_percent

    post_second_half_of_file_1
    post_second_half_of_file_2

    progress_is_at_100_percent

    both_files_exist_in_upload_directory
  end

  it 'Upload wrong filetype' do
    post_file_of_wrong_type
    progress_shows_error
    no_file_was_added_to_upload_directory
  end

  it 'Cancel upload' do
    post_first_half_of_file_1
    upload_dir_has_unfinished_file
    close_connection
    no_file_was_added_to_upload_directory
  end

  class Request
    LF = "\r\n"
    attr_reader :id, :filename

    def initialize(id: 1, filename: nil)
      @id = id
      @filename = filename || { 1 => 'one.mp3', 2 => 'two.mp3' }.fetch(id)
    end

    def halfs
      cut = full.size / 2
      [full[0..cut], full[(cut + 1)..-1]]
    end

    def data
      case id
      when 1
        'a' *  500 * 1024
      when 2
        'b' * 1000 * 1024
      end
    end

    def full
      @full ||= [headers.join(LF), body].join(LF * 2)
    end

    private

    def headers
      [
        "POST /#{id}?token=#{token} HTTP/1.1",
        "Content-Length: #{body.size}",
        "Content-Type: multipart/form-data; boundary=#{boundary}",
      ]
    end

    def token
      {
        1 => 'b71f881d6e6b8270e23e3078e5ca88bfb0ed157f',
        2 => 'e1a4b3b1f647bea63591edeff2216a1dbd20f4e2',
      }.fetch(id)
    end

    def body
      [boundary_start, body_headers, '', data, boundary_stop, ''].join(LF)
    end

    def body_headers
      [
        "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"",
        "Content-Type: audio/mp3",
      ]
    end

    def boundary
      "----WebKitFormBoundaryFKSW8WnqQTXT9Wgc"
    end

    def boundary_start
      "--#{boundary}"
    end

    def boundary_stop
      "--#{boundary}--"
    end
  end

  let(:token_1) { 'b71f881d6e6b8270e23e3078e5ca88bfb0ed157f' }
  let(:request_1) { Request.new(id: 1) }
  let(:request_2) { Request.new(id: 2) }

  def post_first_half_of_file_1
    @one = create_socket
    @one.write request_1.halfs.first
    @one.flush
  end

  def post_first_half_of_file_2
    @two = create_socket
    @two.write request_2.halfs.first
    @two.flush
  end

  def post_second_half_of_file_1
    @one.write request_1.halfs.last
    @one.sysread(1024)
  end

  def post_second_half_of_file_2
    @two.write request_2.halfs.last
    @two.sysread(1024)
  end

  def post_file_of_wrong_type
    socket = create_socket
    socket.write Request.new(filename: 'foo.pdf').full
    socket.flush
  rescue Errno::EPIPE
    # Sometimes the connection gets reset before it can finish
  end

  def close_connection
    @one.close
  end

  def progress_is_at_50_percent
    response = open("http://localhost:9001/1/progress.json?token=#{token_1}").read
    JSON.parse(response)['percentage'].should be_within(0.1).of(0.5)
  end

  def progress_is_at_100_percent
    response = open("http://localhost:9001/1/progress.json?token=#{token_1}").read
    response = JSON.parse(response)
    response['percentage'].should eq(1.0)
    response['message'].should match(/Upload finished successfully/)
  end

  def progress_shows_error
    response = open("http://localhost:9001/1/progress.json?token=#{token_1}").read
    JSON.parse(response)['inProgress'].should be_false
  end

  def both_files_exist_in_upload_directory
    upload_dir.join('1_01_one.mp3').read.should eq(request_1.data)
    upload_dir.join('2_01_two.mp3').read.should eq(request_2.data)
  end

  def upload_dir_has_unfinished_file
    sleep 0.05
    upload_dir.children.map(&:basename).map(&:to_s)
      .should include('unfinished_1_01_one.mp3')
  end

  def no_file_was_added_to_upload_directory
    sleep 0.05
    upload_dir.children.should be_empty
  end
end
