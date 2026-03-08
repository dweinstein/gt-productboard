Class {
	#name : 'PbRelease',
	#superclass : 'PbEntity',
	#instVars : [
		'id',
		'name',
		'description',
		'archived',
		'releaseGroup',
		'timeframe',
		'state',
		'links'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'serialization' }
PbRelease class >> serializationProperties [
	^ {#id -> #id.
		#name -> #name.
		#description -> #description.
		#archived -> #archived.
		#releaseGroup -> #releaseGroup.
		#timeframe -> #timeframe.
		#state -> #state.
		#links -> #links}
]

{ #category : 'accessing' }
PbRelease >> archived [
	^ archived
]

{ #category : 'accessing' }
PbRelease >> archived: anObject [
	archived := anObject
]

{ #category : 'ui' }
PbRelease >> buildCardElement [
	^ PbCardElement for: self
]

{ #category : 'accessing' }
PbRelease >> description [
	^ description
]

{ #category : 'accessing' }
PbRelease >> description: anObject [
	description := anObject
]

{ #category : 'accessing' }
PbRelease >> descriptionText [
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
PbRelease >> detailItems [
	| items |
	items := OrderedCollection new.
	items add: { 'Name' . name ifNil: [ '' ] }.
	items add: { 'State' . state ifNil: [ 'unset' ] }.
	items add: { 'Timeframe' . timeframe ifNil: [ 'none' ] . timeframe }.
	timeframe ifNotNil: [
		timeframe startDate ifNotNil: [ :d | items add: { 'Start date' . d printString . d } ].
		timeframe endDate ifNotNil: [ :d | items add: { 'End date' . d printString . d } ].
		timeframe durationInDays ifNotNil: [ :d | items add: { 'Duration' . d asString, ' days' } ] ].
	items add: { 'Archived' . (archived ifNil: [ false ]) gtColoredText . archived }.
	self releaseGroupId ifNotNil: [ :rgId |
		items add: { 'Release Group' . rgId . releaseGroup } ].
	items add: { 'ID' . id ifNil: [ '' ] }.
	^ items
]

{ #category : 'gt views' }
PbRelease >> gtCardFor: aView [
	<gtView>
	^ aView explicit
		title: 'Card';
		priority: 0;
		stencil: [ self buildCardElement ]
]

{ #category : 'gt views' }
PbRelease >> gtDescriptionFor: aView [
	<gtView>
	(description isNil or: [ description isEmpty ]) ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'Description';
		priority: 2;
		text: [ self descriptionText ]
]

{ #category : 'printing' }
PbRelease >> gtDisplayOn: stream [
	stream nextPutAll: (name ifNil: [ 'Unnamed release' ])
]

{ #category : 'gt views' }
PbRelease >> gtReleaseFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ self detailItems ];
		column: 'Property' text: #first weight: 0.3;
		column: 'Value' text: #second weight: 0.7;
		send: #last
]

{ #category : 'accessing' }
PbRelease >> id [
	^ id
]

{ #category : 'accessing' }
PbRelease >> id: anObject [
	id := anObject
]

{ #category : 'accessing' }
PbRelease >> links [
	^ links
]

{ #category : 'accessing' }
PbRelease >> links: anObject [
	links := anObject
]

{ #category : 'accessing' }
PbRelease >> name [
	^ name
]

{ #category : 'accessing' }
PbRelease >> name: anObject [
	name := anObject
]

{ #category : 'accessing' }
PbRelease >> owner [
	"Releases do not have owners"
	^ nil
]

{ #category : 'accessing' }
PbRelease >> releaseGroup [
	^ releaseGroup
]

{ #category : 'accessing' }
PbRelease >> releaseGroup: anObject [
	"Store the raw dictionary for now; can wrap later when release groups are loaded"
	releaseGroup := anObject
]

{ #category : 'accessing' }
PbRelease >> releaseGroupId [
	"Extract the release group ID from the raw dictionary"
	releaseGroup ifNil: [ ^ nil ].
	^ releaseGroup at: 'id' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
PbRelease >> state [
	^ state
]

{ #category : 'accessing' }
PbRelease >> state: anObject [
	state := anObject
]

{ #category : 'accessing' }
PbRelease >> status [
	"Wrap state as a PbStatus so PbCardElement can use it"
	state ifNil: [ ^ nil ].
	^ PbStatus from: (Dictionary new at: 'name' put: state; yourself)
]

{ #category : 'accessing' }
PbRelease >> timeframe [
	^ timeframe
]

{ #category : 'accessing' }
PbRelease >> timeframe: anObject [
	timeframe := PbTimeframe from: anObject
]

{ #category : 'accessing' }
PbRelease >> type [
	^ 'release'
]
