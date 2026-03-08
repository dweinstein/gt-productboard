Class {
	#name : 'PbEntity',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'client'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'instance creation' }
PbEntity class >> from: aDictionary [
	| entity |
	aDictionary ifNil: [ ^ nil ].
	(aDictionary isKindOf: self) ifTrue: [ ^ aDictionary ].
	entity := self new.
	entity from: aDictionary.
	^ entity
]

{ #category : 'accessing' }
PbEntity class >> serializationProperties [
	^ #()
]

{ #category : 'accessing' }
PbEntity >> client [
	^ client
]

{ #category : 'accessing' }
PbEntity >> client: anObject [
	client := anObject
]

{ #category : 'serialization' }
PbEntity >> deserializeTime: anObject [
	anObject ifNil: [ ^ nil ].
	(anObject isKindOf: DateAndTime) ifTrue: [ ^ anObject ].
	(anObject isKindOf: Number) ifTrue: [ ^ DateAndTime fromUnixTime: anObject ].
	(anObject isKindOf: String) ifTrue: [ 
		^ [ DateAndTime fromString: anObject ] on: Error do: [ anObject ] ].
	^ anObject
]

{ #category : 'as yet unclassified' }
PbEntity >> from: aDictionary [
	self rawData: aDictionary.

	self class serializationProperties
		do: [ :aPair | 
			self
				perform: (aPair value , ':') asSymbol
				withArguments: {aDictionary at: aPair key ifAbsent: [ nil ]} ]
]

{ #category : 'gt - actions' }
PbEntity >> gtActionViewRichTextFor: anAction [
	<gtAction>
	(self respondsTo: #description) ifFalse: [ ^ anAction noAction ].
	(self description isNil or: [ self description isEmpty ]) ifTrue: [ ^ anAction noAction ].
	^ anAction button
		priority: 3;
		icon: BrGlamorousVectorIcons browse;
		tooltip: 'View rich text description';
		action: [ :aButton | 
			| webView styledHtml container |
			styledHtml := '<html><head><style>
body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 14px; color: #333; padding: 16px; line-height: 1.6; }
h1 { font-size: 20px; } h2 { font-size: 17px; } h3 { font-size: 15px; }
a { color: #0066cc; }
ul, ol { padding-left: 24px; }
</style></head><body>', self description, '</body></html>'.
			webView := GtWebViewElement new.
			webView html: styledHtml.
			webView matchParent.
			container := BlElement new.
			container layout: BlLinearLayout vertical.
			container matchParent.
			container addChild: webView.
			container when: BlElementRemovedFromSceneGraphEvent do: [ :e |
				webView webView privateEnsureRelease ].
			aButton phlow spawnObject: container ]
]

{ #category : 'accessing' }
PbEntity >> gtViewRawDataFor: aView [
	<gtView>
	self rawData ifNil: [^ aView empty ].

	^ aView forward
		title: 'Raw data';
		priority: 10;
		object: [ self rawData ];
		view: #gtItemsFor:
]

{ #category : 'as yet unclassified' }
PbEntity >> merge: anotherEntity [
	self rawData: anotherEntity rawData.

	self class serializationProperties
		do: [ :aPair | 
			| aValue |
			aValue := anotherEntity perform: aPair value.
			aValue
				ifNotNil: [ self perform: (aPair value , ':') asSymbol withArguments: {aValue} ] ]
]

{ #category : 'as yet unclassified' }
PbEntity >> rawData [
	^ rawData
]

{ #category : 'as yet unclassified' }
PbEntity >> rawData: aDictionary [
	rawData := aDictionary
]

{ #category : 'accessing' }
PbEntity >> serialize [
	^ (self class serializationProperties
		collect: [ :aPair | aPair key -> (self perform: aPair value) ]) asDictionary
		reject: #isNil
]
