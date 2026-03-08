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

{ #category : 'views' }
PbFeaturesGroup >> gtViewByOwnerFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'By owner';
		priority: 5;
		items: [
			| grouped result |
			grouped := self items groupedBy: [ :f | f owner ifNil: [ 'Unassigned' ] ifNotNil: [ :o | o gtDisplayString ] ].
			result := OrderedCollection new.
			grouped keysAndValuesDo: [ :ownerName :items |
				result add: (ownerName -> items) ].
			result sorted: [ :a :b | a value size > b value size ] ];
		children: [ :each |
			(each isKindOf: Association)
				ifTrue: [ each value ]
				ifFalse: [ #() ] ];
		column: 'Name' text: [ :each |
			(each isKindOf: Association)
				ifTrue: [ each key, ' (', each value size asString, ')' ]
				ifFalse: [ each name ] ];
		column: 'Status' text: [ :each |
			(each isKindOf: Association)
				ifTrue: [ '' ]
				ifFalse: [ each status ifNil: [ '' ] ifNotNil: [ :s | s name ifNil: [ '' ] ] ] ] weight: 0.25;
		column: 'Timeframe' text: [ :each |
			(each isKindOf: Association)
				ifTrue: [ '' ]
				ifFalse: [ each timeframe ifNil: [ '' ] ifNotNil: [ :t | t gtDisplayString ] ] ] weight: 0.3;
		send: [ :each |
			(each isKindOf: Association)
				ifTrue: [ PbFeaturesGroup withAll: each value ]
				ifFalse: [ each ] ]
]

{ #category : 'views' }
PbFeaturesGroup >> gtViewByStatusFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'By status';
		priority: 2;
		items: [
			| grouped result |
			grouped := self items groupedBy: [ :f | f status ifNil: [ 'No status' ] ifNotNil: [ :s | s name ifNil: [ 'No status' ] ] ].
			result := OrderedCollection new.
			grouped keysAndValuesDo: [ :statusName :items |
				result add: (statusName -> items) ].
			result sorted: [ :a :b | a value size > b value size ] ];
		children: [ :each |
			(each isKindOf: Association)
				ifTrue: [ each value ]
				ifFalse: [ #() ] ];
		column: 'Name' text: [ :each |
			(each isKindOf: Association)
				ifTrue: [ each key, ' (', each value size asString, ')' ]
				ifFalse: [ each name ] ];
		column: 'Owner' text: [ :each |
			(each isKindOf: Association)
				ifTrue: [ '' ]
				ifFalse: [ each owner ifNil: [ '' ] ifNotNil: [ :o | o gtDisplayString ] ] ] weight: 0.3;
		send: [ :each |
			(each isKindOf: Association)
				ifTrue: [ PbFeaturesGroup withAll: each value ]
				ifFalse: [ each ] ]
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

{ #category : 'board' }
PbFeaturesGroup >> pipelineOrder [
	"Ordered status pipeline for kanban board"
	^ #('Idea' 'Discovery' 'Candidate' 'Planned' 'Requirement Planning' 'In progress' 'Testing' 'Released' 'Launched' 'On Hold' 'Blocked' 'Archived')
]
