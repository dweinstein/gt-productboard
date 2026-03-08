Class {
	#name : 'PbError',
	#superclass : 'Error',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'instance creation' }
PbError class >> from: anObject [
	"anObject can be a dictionary with a 'message' key, or a string"
	| msg |
	msg := (anObject respondsTo: #at:ifAbsent:)
		ifTrue: [ anObject at: 'message' ifAbsent: [ anObject printString ] ]
		ifFalse: [ anObject printString ].
	^ self new messageText: msg
]

{ #category : 'views' }
PbError >> gtMessageTextFor: aView [
	<gtView>
	<gtExceptionDebuggingView>
	^ super gtMessageTextFor: aView
]
