require 'base64'
require 'zlib'

module Pheme
  module Compression
    def compress(body)
      gz = Zlib::GzipWriter.new(StringIO.new)
      gz << body
      Base64.encode64(gz.close.string)
    end

    def decompress(body)
      return Zlib::GzipReader.new(StringIO.new(Base64.decode64(body))).read if gzip?(body)

      body
    end

    private

    # https://tools.ietf.org/html/rfc1952#page-6
    GZIP_MAGIC_NUMBER = "\037\213".unpack('n').freeze

    def gzip?(body)
      # Decode the first 4 bytes to compare with magic number
      Base64.decode64(body[0..4]).unpack('n') == GZIP_MAGIC_NUMBER
    end
  end
end
