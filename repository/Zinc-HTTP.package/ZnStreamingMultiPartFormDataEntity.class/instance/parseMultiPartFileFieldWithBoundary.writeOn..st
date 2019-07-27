private
parseMultiPartFileFieldWithBoundary: aBoundary writeOn: writer
	| bufferSize buffer boundaryMarker done |
	"Can't simply use a larger buffer as we don't want to read past a boundary,
	those bytes will belong to the next part"
	bufferSize := aBoundary size.
	buffer := ZnRingBuffer on: (ByteArray new: bufferSize).
	boundaryMarker := aBoundary first.
	done := false.
	[ stream atEnd
		or: [
			"#next:into: answers a copy of the buffer if not enough bytes could be read"
				stream
					next: bufferSize
					into: buffer.
				[ done or: [
					(buffer
						indexOf: boundaryMarker
						ifAbsent: [ nil ])
							ifNotNil: [ :boundaryCandidateIndex |
								(boundaryCandidateIndex = 1 and: [ 
									buffer ~= aBoundary ])
										ifTrue: [
											"Not a boundary, proceed"
											true ]
										ifFalse: [
											"Write all the bytes that we know are not part of a boundary"
											1
												to: boundaryCandidateIndex - 1
												do: [ :index | writer nextPut: (buffer at: index) ].
											"Move the rest of the buffer to the beginning of the buffer"
											buffer moveStartTo: boundaryCandidateIndex.
											
											"Fill the rest of the buffer"
											stream
												next: boundaryCandidateIndex - 1
												into: buffer
												startingAt: bufferSize - boundaryCandidateIndex + 2.
											"If the candidate was really the first token of the boundary
											then we now have loaded the full boundary into the buffer.
											If not we have to check for the next boundary candidate as
											we might have loaded the next boundary partially."
											done := buffer = aBoundary ] ]
							ifNil: [ true ] ] ] whileFalse.
					done ] ] whileFalse: [
						writer nextPutAll: buffer ]