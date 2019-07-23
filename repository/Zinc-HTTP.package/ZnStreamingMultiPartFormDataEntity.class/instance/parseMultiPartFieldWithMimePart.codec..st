private
parseMultiPartFieldWithMimePart: aMimePart codec: aCodec
	| reader |
	reader := (aMimePart entityReaderOn: stream)
		binary;
		yourself.
	aMimePart entity: reader readEntity.
	
	^ aMimePart hasEntity
		ifTrue: [ aCodec decode: aMimePart fieldValueString ]
		ifFalse: [ String new ]