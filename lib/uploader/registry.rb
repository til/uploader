module Uploader
  class Registry
    def initialize
      @entries = {}
    end

    def put(entry)
      @entries[entry.id] = entry
    end

    def fetch(id)
      @entries.fetch(id)
    end

    def uploads
      @entries.values
    end

    def active_upload_count
      @entries.values.select(&:in_progress?).size
    end
  end
end
