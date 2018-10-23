RaXOR - Random XOR encoder

The algorithm:

Encoding:

	Let B represent a byte

	The encoder maps 3 bytes as candidates for B:
		B -> { b0, b1, b2 }

	A map is made for every unique byte in the input

	Let EM represent a set of encoded maps
	Let EB represent a set of encoded bytes

	For each unique byte U:
		For each initial byte I:
			If I == U:
				Pick a random index r (0, 1, or 2) from U.map
				if r == 0
					byte p0 = U.map(1)
					byte p1 = U.map(2)
				else if r == 1
					byte p0 = U.map(0)
					byte p1 = U.map(2)
				else if r == 2
					byte p0 = U.map(0)
					byte p1 = U.map(1)


				Add U.map(r) (the chosen encoded value to represent I) to EB
			
				A partial key pk (calculated by p0 xor p1) is stored as well
	
				Byte I' is calculated by pk xor I and stored
	
				Note: A full key is calculated by U.map(0) xor U.map(1) xor U.map(2), but this is unnecessary for the encoder

				An encoded map e contains U.map(0), U.map(1), U.map(2), pk, and I'
				e is then added to EM

	Add EB to EM

EM contains everything needed to decode the bytes


Decoder:

	Assume the encoded byte set EB which represents the encoded version of the initial byte set is extracted and removed from EM
	Assume EM is passed to the decoder

	For each encoded byte E in EB:
		For each encoded map M in EM:
			if M contains E
				A full key fk is calculated from M(0) xor M(1) xor M(2)
				And a partial key pk is calculated from fk xor E
				if pk == M(3) -> M(3) is the partial key unique to a specific encoded byte
					calculate the original byte I by fk xor M(4) -> M(4) is I' of a specific encoded byte set


Notes:
This algorithm is easily reversable, but requires runtime/manual analysis of the decoding process
This algorithm can be expanded as well to allow for N possible bytes to represent a single byte

Let UBN represent the total number of unique bytes in an initial byte set to be encoded
N is limited by UBN * N < 256 and UBN * N >= 3
