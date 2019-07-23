private
partsDecodeWith: aDecoderBlock decodeFilesWith: aFileDecoderBlock
	| fullBoundary endBoundary |
	fullBoundary := '--' asByteArray, self getBoundary.
	endBoundary := fullBoundary asString, '--'.
	"Sometimes there is whitespace in front of the first boundary"
	(stream match: fullBoundary) ifFalse: [ self error ].
	"Skip CRLF"
	stream skip: 2.

	[ stream atEnd ] whileFalse: [
		| part |
		part := ZnMimePart new
			headers: (ZnHeaders readFrom: stream);
			yourself.
		"The final boundary may be read as a header when
		the last part was not a file part"
		(part headers includesKey: endBoundary) ifFalse: [
			(part fileName isEmptyOrNil not or: [
				part contentType notNil and: [
					part contentType isBinary ] ])
						ifFalse: [
							self
								parseMultiPartFieldWithMimePart: part
								decodeWith: aDecoderBlock ]
						ifTrue: [
							self
								parseMultiPartFileFieldWithMimePart: part
								boundary: fullBoundary
								decodeWith: aFileDecoderBlock ] ].
		"Skip crlf"
		stream atEnd ifFalse: [
			stream skip: 2 ] ]