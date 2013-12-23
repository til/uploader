module AcceptanceSpecHelper
  def self.included(base)
    base.before(:all) { create_secret; start_test_server }
    base.after(:all)  { stop_test_server; remove_secret  }
    base.before(:each) { create_upload_dir }
    base.after(:each) { remove_upload_dir }
  end

  def start_test_server
    delete_test_log
    @pid = spawn(
      *%W[ruby bin/uploader --environment test --port 9001 --log log/test.log],
      err: test_log.to_s, out: test_log.to_s)
    wait_for_test_server
  end

  def create_socket
    TCPSocket.new('localhost', 9001)
  end

  def wait_for_test_server
    waited = 0
    begin
      create_socket.close
    rescue Errno::ECONNREFUSED
      sleep 0.1
      waited += 0.1
      raise "wait_for_test_server failed, check #{test_log}" if waited > 1
      retry
    end
  end

  def create_upload_dir
    upload_dir.mkdir
  end

  def remove_upload_dir
    FileUtils.rm_rf(upload_dir)
  end

  def stop_test_server
    Process.kill('INT', @pid) if @pid
    Process.wait
  end

  def upload_dir
    Pathname.new('uploads-test')
  end

  private

  def delete_test_log
    test_log.tap { |f| f.delete if f.exist? }
  end

  def test_log
    Pathname('log/test.log')
  end

  def create_secret
    secret_file.open('w') { |f| f.puts('ff409b4a090039c18b5df5f538931ba9') }
  end

  def remove_secret
    secret_file.delete
  end

  def secret_file
    Pathname.pwd.join('config/secret-test.txt')
  end
end
