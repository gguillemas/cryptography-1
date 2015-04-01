require "openssl"

KILOBYTE = 1024
FILE = "files/challenge.mp4"

class File
  def each_block(block_size=KILOBYTE)
    yield read(block_size) until eof?
  end
end

blocks = []
open(FILE, "rb") do |f|
  f.each_block() {|block| blocks << block}
end

hash = ""
blocks.reverse.each do |block|
	hash = Digest::SHA256.hexdigest(block + [hash].pack("H*"))
end

puts hash
