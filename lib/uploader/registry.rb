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
  end
end
