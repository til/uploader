module Uploader
  class Parser
    attr_reader :boundary, :target

    def initialize(boundary, target)
      @boundary = boundary
      @target = target
      @header = ""
      @collecting_header = true
    end

    def data(data, &block)
      data = String(data)
      if collecting_header?
        @header << data
        if header_empty_line_pos
          process_header
          @collecting_header = false
          data(data.slice((header_empty_line_pos+4)..-1), &block)
        end
      else
        # we assume that the closing boundary will never be split
        # between chunks
        if closing_boundary_pos(data)
          yield(data.slice(0..(closing_boundary_pos(data)-1)))
        else
          yield(data)
        end
      end
    end

    private

    def collecting_header?
      @collecting_header
    end

    def process_header
      header = @header[0..header_empty_line_pos]
      content_disposition = header.split("\n")
        .detect {|line| line =~ /^Content-Disposition: / }
      target.filename = content_disposition && content_disposition[/filename="(.*)"/, 1]
    end

    def header_empty_line_pos
      @header =~ /\r\n\r\n/m
    end

    def closing_boundary_pos(data)
      data =~ /\r\n--#{boundary}--\r\n.*$/m
    end
  end
end
