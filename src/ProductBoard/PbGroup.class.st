Class {
	#name : 'PbGroup',
	#superclass : 'Object',
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#instVars : [
		'client'
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
