Class {
	#name : 'PbReleaseGroup',
	#superclass : 'PbEntity',
	#instVars : [
		'id',
		'name',
		'description',
		'archived',
		'links'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'serialization' }
PbReleaseGroup class >> serializationProperties [
	^ {#id -> #id.
		#name -> #name.
		#description -> #description.
		#archived -> #archived.
		#links -> #links}
]

{ #category : 'accessing' }
PbReleaseGroup >> archived [
	^ archived
]

{ #category : 'accessing' }
PbReleaseGroup >> archived: anObject [
	archived := anObject
]

{ #category : 'accessing' }
PbReleaseGroup >> description [
	^ description
]

{ #category : 'accessing' }
PbReleaseGroup >> description: anObject [
	description := anObject
]

{ #category : 'accessing' }
PbReleaseGroup >> descriptionText [
	"Strip HTML tags from description for plain text display"
	| text |
	description ifNil: [ ^ '' ].
	text := description copyReplaceAll: '<br>' with: String cr.
	text := text copyReplaceAll: '<br/>' with: String cr.
	text := text copyReplaceAll: '</p>' with: String cr.
	text := text copyReplaceAll: '</li>' with: String cr.
	^ text copyWithRegex: '<[^>]*>' matchesReplacedWith: ''
]

{ #category : 'accessing' }
PbReleaseGroup >> detailItems [
	| items |
	items := OrderedCollection new.
	items add: { 'Name' . name ifNil: [ '' ] }.
	items add: { 'Archived' . (archived ifNil: [ false ]) gtColoredText . archived }.
	items add: { 'ID' . id ifNil: [ '' ] }.
	description ifNotNil: [ :d |
		| excerpt |
		excerpt := self descriptionText.
		excerpt size > 80 ifTrue: [ excerpt := (excerpt first: 80) , '...' ].
		items add: { 'Description' . excerpt } ].
	^ items
]

{ #category : 'gt views' }
PbReleaseGroup >> gtDescriptionFor: aView [
	<gtView>
	(description isNil or: [ description isEmpty ]) ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'Description';
		priority: 2;
		text: [ self descriptionText ]
]

{ #category : 'printing' }
PbReleaseGroup >> gtDisplayOn: stream [
	stream nextPutAll: (name ifNil: [ 'Unnamed release group' ])
]

{ #category : 'gt views' }
PbReleaseGroup >> gtReleaseGroupFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ self detailItems ];
		column: 'Property' text: #first weight: 0.3;
		column: 'Value' text: #second weight: 0.7
]

{ #category : 'accessing' }
PbReleaseGroup >> id [
	^ id
]

{ #category : 'accessing' }
PbReleaseGroup >> id: anObject [
	id := anObject
]

{ #category : 'accessing' }
PbReleaseGroup >> links [
	^ links
]

{ #category : 'accessing' }
PbReleaseGroup >> links: anObject [
	links := anObject
]

{ #category : 'accessing' }
PbReleaseGroup >> name [
	^ name
]

{ #category : 'accessing' }
PbReleaseGroup >> name: anObject [
	name := anObject
]
