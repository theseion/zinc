private
parseMultiPartFileFieldWithMimePart: aMimePart boundary: aBoundary
	| fullBoundary file |
	fullBoundary := String crlf asByteArray copyWithAll: aBoundary.
	file := ZnConstants defaultTempDirectory / UUID new asString.
	file parent children size > 1 ifTrue: [ file parent deleteAllChildren  ].
	file binaryWriteStreamDo: [ :writer |
		self
			parseMultiPartFileFieldWithBoundary: fullBoundary
			writeOn: writer ].
	
	^ WAExternalFile new
		contentType: aMimePart contentType printString;
		fileName: aMimePart fileName;
		filePath: file pathString;
		yourself