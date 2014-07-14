require 'net/http'
module NetX
class HTTPUnix < Net::HTTP
  BufferedIO = ::Net::BufferedIO
  UNIX_REGEXP = %r{^unix://}i

  def initialize(address, port=nil)
    super(address, port)
    case address
    when UNIX_REGEXP
      @socket_type = 'unix'
      @address = address.sub(UNIX_REGEXP, '')
      @port = nil
    else
      @socket_type = 'inet'
    end
  end

  def connect
    if @socket_type == 'unix'
      connect_unix
    else
      super
    end
  end

  ##
  # connect_unix is an alternative implementation of Net::HTTP#connect specific
  # to the use case of using a Unix Domain Socket.
  def connect_unix
    D "opening connection to #{conn_address()}..."
    s = timeout(@open_timeout) { UNIXSocket.open(conn_address()) }
    D "opened"
    @socket = BufferedIO.new(s)
    @socket.read_timeout = @read_timeout
    @socket.continue_timeout = @continue_timeout
    @socket.debug_output = @debug_output
    on_connect
  end
end
end
