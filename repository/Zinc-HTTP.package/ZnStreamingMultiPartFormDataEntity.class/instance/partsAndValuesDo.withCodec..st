private
partsAndValuesDo: aBlock withCodec: aCodec
	| fullBoundary |
	fullBoundary := '--' asByteArray, self getBoundary.
	"Sometimes there is whitespace in front of the first boundary"
	(stream match: fullBoundary) ifFalse: [ self error ].
	"Skip CRLF"
	stream skip: 2.

	[ stream atEnd ] whileFalse: [
		| part |
		part := ZnMimePart new
			headers: (ZnHeaders readFrom: stream);
			yourself.
		part fileName isEmptyOrNil
			ifTrue: [
				aBlock
					value: part
					value: (self
						parseMultiPartFieldWithMimePart: part
						codec: aCodec) ]
			ifFalse: [
				aBlock
					value: part
					value: (self
						parseMultiPartFileFieldWithMimePart: part
						boundary: fullBoundary) ].
		"Skip crlf"
		stream atEnd ifFalse: [
			stream skip: 2 ] ]