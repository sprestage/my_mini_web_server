require 'socket'
require 'uri'

WEB_ROOT = './public'

CONTENT_TYPE_MAPPING = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}

DEFAULT_CONTENT_TYPE = 'application/octet-stream'

def content_type(path)
  ext = File.extname(path).split(".").last
  CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end

def requested_file(request_line, naughty)
  request_uri   = request_line.split(" ")[1]
  path          = URI.unescape(URI(request_uri).path)

  clean = []

  parts = path.split("/")

  parts.each do |part|
    next if part.empty? || part == '.'
    if part == '..'
      clean.pop
      naughty << "TSK!  "
    else
      clean << part
    end
  end

  if naughty != ""
    naughty << "Very naughty of you to try to get into my system.\r\n"
  end

  File.join(WEB_ROOT, *clean)
end

server = TCPServer.new('localhost', 2345)

loop do
  socket  = server.accept
  request_line = socket.gets
  naughty = ""

  STDERR.puts request_line

  path = requested_file(request_line, naughty)

  path = File.join(path, 'index.html') if File.directory?(path)

  if File.exist?(path) && !File.directory?(path)
    File.open(path, "rb") do |file|
      socket.print  "HTTP/1.1 200 OK\r\n" +
                    "Content-Type: #{content_type(file)}\r\n" +
                    "Content-Length: #{file.size + naughty.size}\r\n" +
                    "Connection: close\r\n"

      socket.print  "\r\n"

      socket.print naughty

      IO.copy_stream(file, socket)
    end
  else
    message = "File not found\n"

    socket.print  "HTTP/1.1 404 Not Fount\r\n" +
                  "Content-Type: text/plain\r\n" +
                  "Content-Length: #{message.size + naughty.size}\r\n" +
                  "Connection: close\r\n"

    socket.print  "\r\n"

    socket.print naughty
    socket.print message
  end

  socket.close

  # response = "Bon Jour, mes petite enfants!\n"

  # socket.print  "HTTP/1.1 200 OK\r\n" +
  #               "Content-Type: text/plain\r\n" +
  #               "Content-Length: #{response.bytesize}\r\n" +
  #               "Connection: close\r\n"

  # socket.print "\r\n"

  # socket.print response

  # socket.close
end




