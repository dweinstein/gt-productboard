Class {
	#name : 'PbFeature',
	#superclass : 'PbEntity',
	#instVars : [
		'description',
		'createdAt',
		'updatedAt',
		'name',
		'owner',
		'status',
		'id',
		'type',
		'timeframe',
		'archived',
		'parent',
		'links',
		'lastHealthUpdate'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'serialization' }
PbFeature class >> serializationProperties [
	^ {#id -> #id.
		#name -> #name.
		#description -> #description.
		#createdAt -> #createdAt.
		#updatedAt -> #updatedAt.
		#owner -> #owner.
		#status -> #status.
		#type -> #type.
		#timeframe -> #timeframe.
		#archived -> #archived.
		#parent -> #parent.
		#links -> #links.
		#lastHealthUpdate -> #lastHealthUpdate}
]

{ #category : 'accessing' }
PbFeature >> archived [
	^ archived
]

{ #category : 'accessing' }
PbFeature >> archived: anObject [
	archived := anObject
]

{ #category : 'views' }
PbFeature >> buildCardElement [
	^ PbCardElement for: self
]

{ #category : 'accessing' }
PbFeature >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
PbFeature >> createdAt: aValue [
	createdAt := self deserializeTime: aValue
]

{ #category : 'accessing' }
PbFeature >> description [
	^ description
]

{ #category : 'accessing' }
PbFeature >> description: anObject [
	description := anObject
]

{ #category : 'accessing' }
PbFeature >> descriptionText [
	"Strip HTML tags from description for plain text display"
	| text |
	description ifNil: [ ^ '' ].
	text := description copyReplaceAll: '<br>' with: String cr.
	text := text copyReplaceAll: '<br/>' with: String cr.
	text := text copyReplaceAll: '</p>' with: String cr.
	text := text copyReplaceAll: '</li>' with: String cr.
	^ text copyWithRegex: '<[^>]*>' matchesReplacedWith: ''
]

{ #category : 'views' }
PbFeature >> detailItems [
	| items |
	items := OrderedCollection new.
	items add: { 'Name' . name ifNil: [ '' ] }.
	items add: { 'Type' . type ifNil: [ '' ] }.
	items add: { 'Status' . status ifNil: [ 'unset' ] . status }.
	items add: { 'Owner' . owner ifNil: [ 'unassigned' ] . owner }.
	items add: { 'Timeframe' . timeframe ifNil: [ 'none' ] . timeframe }.
	items add: { 'Archived' . (archived ifNil: [ false ]) gtColoredText . archived }.
	items add: { 'Created' . createdAt ifNotNil: [ :d | d asStringYMDHM ] ifNil: [ '' ] . createdAt }.
	items add: { 'Updated' . updatedAt ifNotNil: [ :d | d asStringYMDHM ] ifNil: [ '' ] . updatedAt }.
	lastHealthUpdate ifNotNil: [ :d |
		items add: { 'Last health update' . d asStringYMDHM . d } ].
	parent ifNotNil: [ 
		| componentId |
		componentId := (parent at: 'component' ifAbsent: [ nil ]) 
			ifNotNil: [ :c | c at: 'id' ifAbsent: [ parent gtDisplayString ] ]
			ifNil: [ parent gtDisplayString ].
		items add: { 'Component' . componentId . parent } ].
	items add: { 'ID' . id ifNil: [ '' ] }.
	self htmlUrl ifNotNil: [ :url | items add: { 'ProductBoard' . url . url } ].
	^ items
]

{ #category : 'views' }
PbFeature >> gtActionOpenInBrowserFor: anAction [
	<gtAction>
	self htmlUrl ifNil: [ ^ anAction noAction ].
	^ anAction button
		priority: 1;
		icon: BrGlamorousVectorIcons browse;
		tooltip: 'Open in ProductBoard';
		action: [ WebBrowser openOn: self htmlUrl ]
]

{ #category : 'views' }
PbFeature >> gtCardFor: aView [
	<gtView>
	^ aView explicit
		title: 'Card';
		priority: 0;
		stencil: [ self buildCardElement ]
]

{ #category : 'views' }
PbFeature >> gtDescriptionFor: aView [
	<gtView>
	(description isNil or: [ description isEmpty ]) ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'Description';
		priority: 2;
		text: [ self descriptionText ]
]

{ #category : 'printing' }
PbFeature >> gtDisplayOn: stream [
	stream nextPutAll: (name ifNil: [ 'Unnamed feature' ])
]

{ #category : 'views' }
PbFeature >> gtFeatureFor: aView [
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
PbFeature >> htmlUrl [
	"URL to open this feature in ProductBoard"
	links ifNil: [ ^ nil ].
	^ links at: 'html' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
PbFeature >> id [
	^ id
]

{ #category : 'accessing' }
PbFeature >> id: anObject [
	id := anObject
]

{ #category : 'accessing' }
PbFeature >> lastHealthUpdate [
	^ lastHealthUpdate
]

{ #category : 'accessing' }
PbFeature >> lastHealthUpdate: anObject [
	lastHealthUpdate := self deserializeTime: anObject
]

{ #category : 'accessing' }
PbFeature >> links [
	^ links
]

{ #category : 'accessing' }
PbFeature >> links: anObject [
	links := anObject
]

{ #category : 'accessing' }
PbFeature >> name [
	^ name
]

{ #category : 'accessing' }
PbFeature >> name: anObject [
	name := anObject
]

{ #category : 'accessing' }
PbFeature >> owner [
	^ owner
]

{ #category : 'accessing' }
PbFeature >> owner: anObject [
	owner := PbOwner from: anObject
]

{ #category : 'accessing' }
PbFeature >> parent [
	^ parent
]

{ #category : 'accessing' }
PbFeature >> parent: anObject [
	parent := anObject
]

{ #category : 'accessing' }
PbFeature >> status [
	^ status
]

{ #category : 'accessing' }
PbFeature >> status: anObject [
	status := PbStatus from: anObject
]

{ #category : 'accessing' }
PbFeature >> timeframe [
	^ timeframe
]

{ #category : 'accessing' }
PbFeature >> timeframe: anObject [
	timeframe := PbTimeframe from: anObject
]

{ #category : 'accessing' }
PbFeature >> type [
	^ type
]

{ #category : 'accessing' }
PbFeature >> type: anObject [
	type := anObject
]

{ #category : 'accessing' }
PbFeature >> updatedAt [
	^ updatedAt
]

{ #category : 'accessing' }
PbFeature >> updatedAt: anObject [
	updatedAt := self deserializeTime: anObject
]
