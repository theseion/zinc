private
parseMultiPartFileFieldWithMimePart: aMimePart boundary: aBoundary decodeWith: aBlock
	| fullBoundary file |
	fullBoundary := String crlf asByteArray copyWithAll: aBoundary.
	file := ZnConstants defaultTempDirectory / UUID new asString.
	file parent children size > 1 ifTrue: [ file parent deleteAllChildren  ].
	file binaryWriteStreamDo: [ :writer |
		self
			parseMultiPartFileFieldWithBoundary: fullBoundary
			writeOn: writer ].
	
	aBlock
		value: aMimePart
		value: file pathString