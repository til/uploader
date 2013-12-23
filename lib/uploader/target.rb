module Uploader
  class Target
    attr_accessor :dir, :id, :filename

    def initialize(dir: dir, id: id)
      self.dir = Pathname(dir)
      self.id = id
      self.filename = 'unknown'
    end

    def file
      @file ||= unfinished_path.open('w').tap {|f| f.sync = true }
    end

    def path
      dir.join([id, number, filename].join('_'))
    end

    def unfinished_path
      dir.join(['unfinished', id, number, filename].join('_'))
    end

    def write(data)
      file.write data
    end

    def number
      highest = Dir.glob(dir.join("#{id}_*").to_s)
        .reject {|entry| entry.start_with?('unfinished_') }
        .map {|entry| entry.split('_')[1].to_i }
        .max || 0

      (highest + 1).to_s.rjust(2, '0')
    end

    def finish
      file.close
      unfinished_path.rename(path)
    end

    def abort
      unfinished_path.delete
    end
  end
end
