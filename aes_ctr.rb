require "openssl"

CIPHERTEXT = "770b80259ec33beb2561358a9f2dc617e46218c0a53cbeca695ae45faa8952aa0e311bde9d4e01726d3184c34451"
KEY = "36f18357be4dbd77f050515c73fcf9f2"

def xor(s1, s2)
	length = s1.unpack("H*").length
	s1 = s1.unpack("H*")[0].to_i(16)
	s2 = s2.unpack("H*")[0].to_i(16)
	return [(s1 ^ s2).to_s(16).rjust(length, '0')].pack("H*")
end  

iv = [CIPHERTEXT].pack("H*")[0..15]
ciphertext = [CIPHERTEXT].pack("H*")[16..-1]
blocks = ciphertext.chars.each_slice(16).map(&:join)

key = [KEY].pack("H*")

aes = OpenSSL::Cipher::Cipher.new("AES-128-ECB")
aes.encrypt
aes.key = key
aes.padding = 0

plaintext = ""
ctr = iv
blocks.each do |block|
	if block.length < 16 then
		block = [block.unpack("H*")[0].ljust(32, '0')].pack("H*")
	end
	decrypter = aes.update(ctr) + aes.final
	plain_block = xor(decrypter, block)
	plaintext += plain_block
	ctr = [(ctr.unpack("H*")[0].to_i(16) + 1).to_s(16)].pack("H*")
end

puts plaintext 
