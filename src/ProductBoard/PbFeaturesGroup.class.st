Class {
	#name : 'PbFeaturesGroup',
	#superclass : 'PbGroup',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'accessing' }
PbFeaturesGroup class >> itemClass [
	^ PbFeature
]

{ #category : 'building' }
PbFeaturesGroup >> buildBoardElement [
	^ PbBoardElement
		byStatus: self items
		order: self pipelineOrder
		groupClass: PbFeaturesGroup
]

{ #category : 'building' }
PbFeaturesGroup >> buildNowNextLaterElement [
	^ PbBoardElement
		nowNextLater: self items
		groupClass: PbFeaturesGroup
]

{ #category : 'views' }
PbFeaturesGroup >> gtViewBoardFor: aView [
	<gtView>
	self items ifEmpty: [ ^ aView empty ].
	^ aView explicit
		title: 'Board';
		priority: 3;
		stencil: [ self buildBoardElement ]
]

{ #category : 'gt-extensions' }
PbFeaturesGroup >> gtViewByStatusFor: aView [
	<gtView>
	self items ifEmpty: [ ^ aView empty ].
	^ aView columnedList
		title: 'By status';
		priority: 5;
		items: [ 
			| grouped result |
			grouped := self items groupedBy: [ :each | each status gtDisplayString ].
			result := OrderedCollection new.
			grouped keysAndValuesDo: [ :statusName :items |
				result add: (statusName -> items) ].
			result sorted: [ :a :b | a value size > b value size ] ];
		column: 'Status' text: [ :assoc | assoc key ] weight: 0.3;
		column: 'Count' text: [ :assoc | assoc value size ] weight: 0.2;
		column: 'Features' text: [ :assoc |
			', ' join: (assoc value collect: #name) ] weight: 0.5;
		send: [ :assoc | PbFeaturesGroup withAll: assoc value ]
]

{ #category : 'views' }
PbFeaturesGroup >> gtViewFeaturesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Features';
		priority: 1;
		items: [ self items sorted: [ :a :b | 
			(a updatedAt ifNil: [ a createdAt ifNil: [ DateAndTime epoch ] ]) > 
			(b updatedAt ifNil: [ b createdAt ifNil: [ DateAndTime epoch ] ]) ] ];
		column: 'Name' text: #name;
		column: 'Status' text: [ :elem | elem status gtDisplayString ] weight: 0.2;
		column: 'Owner' text: [ :elem | elem owner gtDisplayString ] weight: 0.25;
		column: 'Updated' text: [ :elem | elem updatedAt gtDisplayString ] weight: 0.25
]

{ #category : 'views' }
PbFeaturesGroup >> gtViewNowNextLaterFor: aView [
	<gtView>
	self items ifEmpty: [ ^ aView empty ].
	^ aView explicit
		title: 'Now / Next / Later';
		priority: 4;
		stencil: [ self buildNowNextLaterElement ]
]

{ #category : 'as yet unclassified' }
PbFeaturesGroup >> gtViewOwnersFor: aView [
	"<gtView>"
	^ aView columnedList
		title: 'Owners';
		priority: 1;
		items: [ self items groupedBy: [:e | e owner email ] ];
		column: 'ID' text: #id;
		column: 'Name' text: #name;
		column: 'Description'
			text: #description
			weight: 0.5;
		column: 'Created at'
			text: #createdAt
			weight: 0.5;
		column: 'Owner'
			text: [ :elem | elem owner email ]
			weight: 0.5;
		column: 'Status'
			text: [ :elem | elem status name ]
			weight: 0.5
]

{ #category : 'board' }
PbFeaturesGroup >> pipelineOrder [
	"Ordered status pipeline for kanban board"
	^ #('Idea' 'Discovery' 'Candidate' 'Planned' 'Requirement Planning' 'In progress' 'Testing' 'Released' 'Launched' 'On Hold' 'Blocked' 'Archived')
]
