private
parseMultiPartFileFieldWithMimePart: aMimePart boundary: aBoundary decodeWith: aBlock
	| fullBoundary file |
	fullBoundary := String crlf asByteArray copyWithAll: aBoundary.
	file := ZnConstants defaultTempDirectory / UUID new asString.
	file binaryWriteStreamDo: [ :writer |
		self
			parseMultiPartFieldWithoutLengthWithBoundary: fullBoundary
			writeOn: writer ].
	
	aBlock
		value: aMimePart
		value: file pathString