#!/usr/bin/ruby

class String
	def to_c
		return self.to_i(16).chr
	end
end

class Encoder

	def random_vals(size)
		vals = Array.new(size)
		for i in 0...size do
			r = rand(0..256)
			while vals.include?(r)
				r = rand(1...256)
			end
			h = "0x%02x" % [r]

			vals[i] = h
		end

		return vals
	end

	def get_bytes(bytes)
		bs = `echo -n #{bytes} | hexdump -e '16/1 "0x%02x"' | sed 's/0x  //g'`
		return bs.scan(/.{4}/)
	end

	def get_unique_bytes(bytes)
		return get_bytes(bytes).uniq
	end

	def generate_asm(str)
		ib = get_bytes(str)
		ub = get_unique_bytes(str)
		rb = random_vals(ub.length * 3)
		eb = []

		smap = Hash.new
	
		itr = 0
		for i in 0...ub.length do
			set = []
			for j in itr...itr + 3 do
				set.push(rb[j])
			end
			itr += 3
			smap[ub[i]] = set
		end

		return calc_primes(ib, smap)
	end

	def calc_primes(ib, smap)
		emap = []
		ebs = []
		for i in 0...ib.length do
			cmap = smap[ib[i]]
			maps = []
			r = rand(0..2)
			p0 = -1
			p1 = -1
			ps = ib[i].to_i(16)
			ebs.push(cmap[r])
			if r == 0
				p0 = cmap[1].to_i(16)
				p1 = cmap[2].to_i(16)
			elsif r == 1
				p0 = cmap[0].to_i(16)
				p1 = cmap[2].to_i(16)
			elsif r == 2
				p0 = cmap[0].to_i(16)
				p1 = cmap[1].to_i(16)
			end
			part = sprintf("0x%02x", (p0 ^ p1).to_s(16).to_i(16))
			sp = ps ^ p0 ^ p1
	
			prime = sprintf("0x%02x", sp.to_s(16).to_i(16))
	
			for j in 0...cmap.length do
				maps.push(cmap[j])
			end
			maps.push(part)
			maps.push(prime)

			emap.push(maps)
		end
	
		emap.push(ebs)
		return emap.uniq
	end

	def print_encoded(bytes)
		bytes.each do |b|
			c = b.to_c
			if c.match?(/[[:print:][:punct:]]/) || c == "\n"
				print c
			else
				print "."
			end
		end
		puts
	end
end

class Decoder
	
	def decode(bytes, map)
		bytes.each do |byte|
			map.each do |m|
				if m.include?(byte)
					p0 = m[0].to_i(16)
					p1 = m[1].to_i(16)
					p2 = m[2].to_i(16)
					b = byte.to_i(16)

					key = p0 ^ p1 ^ p2
					kp = sprintf("0x%02x", (key ^ b).to_s(16).to_i(16))
					if (kp == m[3])
						prt = m[3].to_i(16)
						prm = m[4].to_i(16)
						
						o = prt ^ prm
						co = sprintf("0x%02x", o.to_s(16).to_i(16)).to_c
						print(co)
					end
				end
			end
		end
		puts
	end
end

str = ARGV[0]

enc = Encoder.new
ec = enc.generate_asm(str)
bytes = ec.pop

enc.print_encoded(bytes)

dec = Decoder.new
dec.decode(bytes, ec)
