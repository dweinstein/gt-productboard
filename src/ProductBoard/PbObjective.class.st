Class {
	#name : 'PbObjective',
	#superclass : 'PbEntity',
	#instVars : [
		'description',
		'createdAt',
		'name',
		'owner',
		'status',
		'id',
		'level',
		'timeframe',
		'archived',
		'links',
		'updatedAt',
		'parent',
		'state'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'serialization' }
PbObjective class >> serializationProperties [
	^ {#id -> #id.
		#name -> #name.
		#description -> #description.
		#createdAt -> #createdAt.
		#updatedAt -> #updatedAt.
		#parent -> #parent.
		#links -> #links.
		#timeframe -> #timeframe.
		#owner -> #owner.
		#archived -> #archived.
		#state -> #state.
		#status -> #status}
]

{ #category : 'accessing' }
PbObjective >> archived [
	^ archived
]

{ #category : 'accessing' }
PbObjective >> archived: anObject [
	archived := anObject
]

{ #category : 'views' }
PbObjective >> buildCardElement [
	^ PbCardElement for: self
]

{ #category : 'accessing' }
PbObjective >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
PbObjective >> createdAt: aValue [
	createdAt := self deserializeTime: aValue
]

{ #category : 'accessing' }
PbObjective >> description [
	^ description
]

{ #category : 'accessing' }
PbObjective >> description: anObject [
	description := anObject
]

{ #category : 'accessing' }
PbObjective >> descriptionText [
	"Strip HTML tags from description for plain text display"
	| text |
	description ifNil: [ ^ '' ].
	text := description copyReplaceAll: '<br>' with: String cr.
	text := text copyReplaceAll: '<br/>' with: String cr.
	text := text copyReplaceAll: '</p>' with: String cr.
	text := text copyReplaceAll: '</li>' with: String cr.
	^ (text reject: [ :c | false ]) 
		copyWithRegex: '<[^>]*>' matchesReplacedWith: ''
]

{ #category : 'views' }
PbObjective >> detailItems [
	| items |
	items := OrderedCollection new.
	items add: { 'Name' . name ifNil: [ '' ] }.
	items add: { 'Status' . status ifNil: [ 'unset' ] . status }.
	items add: { 'State' . state ifNil: [ 'unset' ] }.
	items add: { 'Owner' . owner ifNil: [ 'unassigned' ] . owner }.
	items add: { 'Timeframe' . timeframe ifNil: [ 'none' ] . timeframe }.
	timeframe ifNotNil: [
		timeframe startDate ifNotNil: [ :d | items add: { 'Start date' . d printString . d } ].
		timeframe endDate ifNotNil: [ :d | items add: { 'End date' . d printString . d } ].
		timeframe durationInDays ifNotNil: [ :d | items add: { 'Duration' . d asString, ' days' } ] ].
	items add: { 'Archived' . (archived ifNil: [ false ]) gtColoredText . archived }.
	items add: { 'Created' . createdAt ifNotNil: [ :d | d asStringYMDHM ] ifNil: [ '' ] . createdAt }.
	items add: { 'Updated' . updatedAt ifNotNil: [ :d | d asStringYMDHM ] ifNil: [ '' ] . updatedAt }.
	parent ifNotNil: [
		items add: { 'Parent' . parent at: 'id' ifAbsent: [ parent gtDisplayString ] . parent } ].
	items add: { 'ID' . id ifNil: [ '' ] }.
	self htmlUrl ifNotNil: [ :url | items add: { 'ProductBoard' . url . url } ].
	^ items
]

{ #category : 'views' }
PbObjective >> gtActionOpenInBrowserFor: anAction [
	<gtAction>
	self htmlUrl ifNil: [ ^ anAction noAction ].
	^ anAction button
		priority: 1;
		icon: BrGlamorousVectorIcons browse;
		tooltip: 'Open in ProductBoard';
		action: [ WebBrowser openOn: self htmlUrl ]
]

{ #category : 'views' }
PbObjective >> gtCardFor: aView [
	<gtView>
	^ aView explicit
		title: 'Card';
		priority: 0;
		stencil: [ self buildCardElement ]
]

{ #category : 'views' }
PbObjective >> gtDescriptionFor: aView [
	<gtView>
	(description isNil or: [ description isEmpty ]) ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'Description';
		priority: 2;
		text: [ self descriptionText ]
]

{ #category : 'printing' }
PbObjective >> gtDisplayOn: stream [
	stream nextPutAll: (name ifNil: [ 'Unnamed objective' ])
]

{ #category : 'views' }
PbObjective >> gtObjectiveFor: aView [
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
PbObjective >> htmlUrl [
	"URL to open this objective in ProductBoard"
	links ifNil: [ ^ nil ].
	^ links at: 'html' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
PbObjective >> id [
	^ id
]

{ #category : 'accessing' }
PbObjective >> id: anObject [
	id := anObject
]

{ #category : 'accessing' }
PbObjective >> level [
	^ level
]

{ #category : 'accessing' }
PbObjective >> level: anObject [
	level := anObject
]

{ #category : 'accessing' }
PbObjective >> links [
	^ links
]

{ #category : 'accessing' }
PbObjective >> links: anObject [
	links := anObject
]

{ #category : 'accessing' }
PbObjective >> name [
	^ name
]

{ #category : 'accessing' }
PbObjective >> name: anObject [
	name := anObject
]

{ #category : 'accessing' }
PbObjective >> owner [
	^ owner
]

{ #category : 'accessing' }
PbObjective >> owner: anObject [
	owner := PbOwner from: anObject
]

{ #category : 'accessing' }
PbObjective >> parent [
	^ parent
]

{ #category : 'accessing' }
PbObjective >> parent: anObject [
	parent := anObject
]

{ #category : 'accessing' }
PbObjective >> state [
	^ state
]

{ #category : 'accessing' }
PbObjective >> state: anObject [
	state := anObject
]

{ #category : 'accessing' }
PbObjective >> status [
	^ status
]

{ #category : 'accessing' }
PbObjective >> status: anObject [
	status := PbStatus from: anObject
]

{ #category : 'accessing' }
PbObjective >> timeframe [
	^ timeframe
]

{ #category : 'accessing' }
PbObjective >> timeframe: anObject [
	timeframe := PbTimeframe from: anObject
]

{ #category : 'accessing' }
PbObjective >> updatedAt [
	^ updatedAt
]

{ #category : 'accessing' }
PbObjective >> updatedAt: aValue [
	updatedAt := self deserializeTime: aValue
]
