Class {
	#name : 'PbReleaseGroup',
	#superclass : 'PbEntity',
	#instVars : [
		'id',
		'name',
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
PbReleaseGroup >> assignedFeatures [
	"All features across all releases in this group."
	| theClient |
	theClient := self client.
	theClient ifNil: [ ^ #() ].
	^ theClient featuresForReleaseGroup: self
]

{ #category : 'accessing' }
PbReleaseGroup >> assignedReleases [
	"Releases that belong to this group, looked up through the client."
	| theClient |
	theClient := self client.
	theClient ifNil: [ ^ #() ].
	^ theClient releasesByGroupId at: self id ifAbsent: [ #() ]
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

{ #category : 'accessing' }
PbReleaseGroup >> featuresGroup [
	"Wrap assigned features in a PbFeaturesGroup for view reuse"
	self client ifNil: [ ^ PbFeaturesGroup new ].
	^ PbFeaturesGroup withAll: self assignedFeatures
]

{ #category : 'actions' }
PbReleaseGroup >> gtActionOpenInBrowserFor: anAction [
	<gtAction>
	self htmlUrl ifNil: [ ^ anAction noAction ].
	^ anAction button
		priority: 1;
		icon: BrGlamorousVectorIcons browse;
		tooltip: 'Open in ProductBoard';
		action: [ WebBrowser openOn: self htmlUrl ]
]

{ #category : 'views' }
PbReleaseGroup >> gtBoardFor: aView [
	<gtView>
	self client ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Board';
		priority: 7;
		object: [ self featuresGroup ];
		view: #gtViewBoardFor:
]

{ #category : 'views' }
PbReleaseGroup >> gtByOwnerFor: aView [
	<gtView>
	self client ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'By owner';
		priority: 5;
		object: [ self featuresGroup ];
		view: #gtViewByOwnerFor:
]

{ #category : 'views' }
PbReleaseGroup >> gtByStatusFor: aView [
	<gtView>
	self client ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'By status';
		priority: 6;
		object: [ self featuresGroup ];
		view: #gtViewByStatusFor:
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

{ #category : 'views' }
PbReleaseGroup >> gtFeaturesFor: aView [
	<gtView>
	self client ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Features';
		priority: 4;
		object: [ PbFeaturesGroup withAll: self assignedFeatures ];
		view: #gtViewFeaturesFor:
]

{ #category : 'views' }
PbReleaseGroup >> gtNowNextLaterFor: aView [
	<gtView>
	self client ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Now / Next / Later';
		priority: 8;
		object: [ self featuresGroup ];
		view: #gtViewNowNextLaterFor:
]

{ #category : 'views' }
PbReleaseGroup >> gtReleaseGroupFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ self detailItems ];
		column: 'Property' text: #first weight: 0.3;
		column: 'Value' text: #second weight: 0.7;
		send: #last
]

{ #category : 'views' }
PbReleaseGroup >> gtReleasesFor: aView [
	<gtView>
	self client ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Releases';
		priority: 3;
		object: [ PbReleasesGroup withAll: self assignedReleases ];
		view: #gtViewReleasesFor:
]

{ #category : 'accessing' }
PbReleaseGroup >> htmlUrl [
	"URL to open this release group in ProductBoard"
	links ifNil: [ ^ nil ].
	^ links at: 'html' ifAbsent: [ nil ]
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
