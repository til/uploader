class Uploader::Route

  def initialize(env)
    @env = env
  end

  def type
    if path.nil?
      :root
    elsif path =~ /^(\d+)$/ && upload_id > 0
      if second == 'form'
        :form
      elsif second == 'progress.json'
        :progress_json
      else
        :upload
      end
    elsif path == 'status'
      second == 'active' ? :status_active : :status
    end
  end

  def upload_id
    path.to_i
  end

  def protected?
    [:progress, :progress_json, :upload].include?(type)
  end

  private

  def path
    @env['PATH_INFO'].split('/')[1]
  end

  def second
    @env['PATH_INFO'].split('/')[2]
  end
end
