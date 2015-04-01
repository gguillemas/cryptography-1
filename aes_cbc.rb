require "openssl"

CIPHERTEXT = "4ca00ff4c898d61e1edbf1800618fb2828a226d160dad07883d04e008a7897ee2e4b7465d5290d0c0e6c6822236e1daafb94ffe0c5da05d9476be028ad7c1d81"
KEY = "140b41b22a29beb4061bda66b6747e14"

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
aes.decrypt
aes.key = key
aes.padding = 0

previous_block = iv
plaintext = ""
blocks.each do |block|
	plain_block = aes.update(block) + aes.final
	plain_block = xor(plain_block, previous_block)
	previous_block = block
	plaintext += plain_block
end

puts plaintext 
