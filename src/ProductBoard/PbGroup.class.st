Class {
	#name : 'PbGroup',
	#superclass : 'Object',
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#instVars : [
		'client',
		'label'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'instance creation' }
PbGroup class >> from: aList [
	^ self
		withAll: ((aList at: 'data') collect: [ :aModel | self itemClass from: aModel ])
]

{ #category : 'accessing' }
PbGroup class >> itemClass [
	^ self subclassResponsibility
]

{ #category : 'instance creation' }
PbGroup class >> withAll: aCollection [
	^ self new 
		initializeWith: aCollection
]

{ #category : 'instance creation' }
PbGroup class >> withAll: aCollection label: aString [
	^ (self withAll: aCollection)
		label: aString;
		yourself
]

{ #category : 'accessing' }
PbGroup >> client [
	^ client
]

{ #category : 'accessing' }
PbGroup >> client: anObject [
	client := anObject.
	items ifNotNil: [
		items do: [ :each |
			(each respondsTo: #client:) ifTrue: [ each client: anObject ] ] ]
]

{ #category : 'copying' }
PbGroup >> copyContextTo: aGroup [
	aGroup client: client.
	aGroup label: label
]

{ #category : 'printing' }
PbGroup >> gtDisplayOn: aStream [
	label ifNotNil: [ 
		aStream nextPutAll: label; nextPutAll: ' — ' ].
	aStream 
		print: self size;
		nextPutAll: ' items'
]

{ #category : 'accessing' }
PbGroup >> label [
	^ label
]

{ #category : 'accessing' }
PbGroup >> label: aString [
	label := aString
]

{ #category : 'enumerating' }
PbGroup >> reject: aBlock [
	| result |
	result := self species withAll: (self items reject: aBlock).
	self copyContextTo: result.
	^ result
]

{ #category : 'enumerating' }
PbGroup >> select: aBlock [
	| result |
	result := self species withAll: (self items select: aBlock).
	self copyContextTo: result.
	^ result
]
