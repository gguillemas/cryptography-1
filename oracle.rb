require 'net/http'

URL = "http://crypto-class.appspot.com/po?er="
CHARACTERS = " etaoinsrhldcumfpgwybvkxjqzETAOINSRHLDCUMFPGWYBVKXJQZ"
CIPHERTEXT = "f20bdba6ff29eed7b046d1df9fb7000058b1ffb4210a580f748b4ac714c001bd4a61044426fb515dad3f21f18aa577c0bdf302936266926ff37dbf7035d5eeb4"

def xor(s1, s2)
	return s1.bytes.zip(s2.bytes).map{|x,y| (x^y).chr}.join.rjust(s1.length, '0')
end

blocks = [CIPHERTEXT].pack("H*").scan(/.{16}/m)

plaintext = Hash.new("")

blocks.each_with_index do |block, b|
	i = 1
	while i <= 16 do
		padding = (i.chr * i)
		padding = padding.rjust(16, "\x00")
		j = 0
		error = "403"
		
		while error == "403" do
			guess = CHARACTERS[j] + ("\x00" * (i-1))
			guess = guess.rjust(16, "\x00")

			puts "PADDING BLOCK = " + padding.unpack("H*")[0]
			puts "GUESS BLOCK = " + guess.unpack("H*")[0]
			puts "ORIGINAL BLOCK = " + block.unpack("H*")[0]
			
			candidate = xor(blocks[b], guess)
			candidate = xor(candidate, padding)
			puts "CANDIDATE BLOCK = " + candidate.unpack("H*")[0]
			token = (blocks[0...b].join + candidate + blocks[b+1]).unpack("H*")[0]

			uri = URI.parse(URL + token)
			http = Net::HTTP.new(uri.host, uri.port)
			response = http.request(Net::HTTP::Get.new(uri.request_uri))
			error = response.code
			puts "HTTP CODE = " + error
			puts

			if error == "404" then
				plaintext[block] += CHARACTERS[j]
				blocks[b] = xor(blocks[b], guess)
				puts "The plaintext so far is: "
				plaintext.each do |block, message| print message.reverse end
				puts
				puts
			end
			j += 1
		end
		i += 1
	end
end
