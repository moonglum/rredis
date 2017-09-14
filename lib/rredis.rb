require "rredis/version"

module RRedis
  class Connection
    attr_reader :engine
    attr_reader :socket

    def initialize(engine, socket)
      @engine = engine
      @socket = socket
    end

    def self.connect(engine, socket)
      self.new(engine, socket).handle_connection
    end

    def handle_connection
      loop do
        request_parser = RRedis::Deserializer.new(socket)
        request = request_parser.deserialize

        break if request.nil?

        response = engine.execute(request)

        response_writer = RRedis::Serializer.new(socket)
        response_writer.serialize(response)
      end
    end
  end

  class Deserializer
    ARRAY = /\*(\d+)\r\n/
    BULK_STRING = /\$(\d+)\r\n/

    def initialize(stream)
      @stream = stream
      @request = []
    end

    def deserialize
      @request = read
    end

    private

    def read
      case @stream.gets
      when ARRAY then read_array($1.to_i)
      when BULK_STRING then read_bulk_string($1.to_i)
      end
    end

    def read_array(length)
      length.times.map { read }
    end

    def read_bulk_string(length)
      line = @stream.gets
      line[0...length]
    end
  end

  class Engine
    def initialize
      @state = {}
    end

    def execute(command)
      case command.shift.upcase
      when "GET" then get(*command)
      when "SET" then set(*command)
      end
    end

    def get(key)
      @state[key]
    end

    def set(key, value)
      @state[key] = value
      :OK
    end
  end

  class Serializer
    def initialize(output)
      @output = output
    end

    def serialize(message)
      case message
      when Symbol then write_simple_string(message)
      when String then write_bulk_string(message)
      end
    end

    private

    def write_simple_string(message)
      @output.write("+#{message}\r\n")
    end

    def write_bulk_string(message)
      @output.write("$#{message.length}\r\n")
      @output.write("#{message}\r\n")
    end
  end
end
