tests
testWriteReadBinary
	| input bytes parts entity |
	input := (ZnStreamingMultiPartFormDataEntity new)
		addPart: (ZnMimePart fieldName: 'extra' value: 'my-extra');
		addPart: (ZnMimePart fieldName: 'info' value: 'my-info');
		addPart: (ZnMimePart fieldName: 'file' fileName: 'foo.txt' entity: (ZnEntity text: 'Zinc HTTP Components'));
		addPart: (ZnMimePart fieldName: 'afterfile' value: 'afterfile', String crlf, 'foo');
		yourself.
	self assert: input contentLength notNil.
	self assert: input contentLength > 0.
	self assert: (input contentType matches: ZnMimeType multiPartFormData).
	bytes := ByteArray streamContents: [ :stream | input writeOn: stream ].
	parts := ZnMultiValueDictionary new.
	entity := ZnStreamingMultiPartFormDataEntity new
		readBinaryFrom: bytes readStream;
		contentType: input contentType;
		yourself.
	entity
		partsDecodeWith: [ :znMimePart |
			parts
				at: znMimePart fieldName
				put: (znMimePart hasEntity
					ifTrue: [ znMimePart fieldValueString ]
					ifFalse: [ String new ]) ]
		decodeFilesWith: [ :znMimePart :filePath | 
			parts
				at: znMimePart fileName
				add: znMimePart -> filePath ].
	self assert: parts size equals: 4.
	self assert: (parts at: 'extra') equals: 'my-extra'.
	self assert: (parts at: 'info') equals: 'my-info'.
	self assert: (parts at: 'foo.txt') key fileName equals: 'foo.txt'.
	self assert: (parts at: 'foo.txt') value asFileReference contents equals: 'Zinc HTTP Components'.
	self assert: (parts at: 'afterfile') equals: 'afterfile', String crlf, 'foo'