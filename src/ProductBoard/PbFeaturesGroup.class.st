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

{ #category : 'gt - actions' }
PbFeaturesGroup >> gtActionArchiveAllFor: anAction [
	<gtAction>
	self client ifNil: [ ^ anAction noAction ].
	self items ifEmpty: [ ^ anAction noAction ].
	^ anAction button
		priority: 5;
		icon: BrGlamorousVectorIcons cancel;
		tooltip: 'Archive all features';
		action: [ :aButton |
			| count |
			count := 0.
			self items do: [ :f |
				f archived ~= true ifTrue: [
					self client archiveFeature: f.
					f archived: true.
					count := count + 1 ] ].
			aButton phlow spawnObject: ('Archived ', count asString, ' features') ]
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

{ #category : 'gt - views' }
PbFeaturesGroup >> gtViewReleaseRoadmapFor: aView [
	<gtView>
	| stateOrder |
	self client ifNil: [ ^ aView empty ].
	stateOrder := #('completed' 'in-progress' 'upcoming').
	^ aView columnedTree
		title: 'Release roadmap';
		priority: 7;
		items: [
			| mapping releaseIds relevantReleases groupIds |
			mapping := self releaseToFeatureIds.
			releaseIds := mapping keys asSet.
			relevantReleases := self client activeReleases select: [ :r | releaseIds includes: r id ].
			groupIds := (relevantReleases collect: [ :r | r releaseGroupId ] thenSelect: #notNil) asSet.
			self client releaseGroups items 
				select: [ :rg | (groupIds includes: rg id) and: [ rg archived ~= true ] ] ];
		children: [ :item |
			(item isKindOf: PbReleaseGroup)
				ifTrue: [
					| mapping releases |
					mapping := self releaseToFeatureIds.
					releases := self client activeReleases select: [ :r | 
						r releaseGroupId = item id and: [ mapping includesKey: r id ] ].
					releases sorted: [ :a :b |
						| aIdx bIdx |
						aIdx := stateOrder indexOf: (a state ifNil: [ '' ]) ifAbsent: [ 99 ].
						bIdx := stateOrder indexOf: (b state ifNil: [ '' ]) ifAbsent: [ 99 ].
						aIdx = bIdx
							ifTrue: [ 
								(a state = 'completed')
									ifTrue: [ a name <= b name ]
									ifFalse: [ a name >= b name ] ]
							ifFalse: [ aIdx < bIdx ] ] ]
				ifFalse: [
					(item isKindOf: PbRelease)
						ifTrue: [
							| fIds |
							fIds := self releaseToFeatureIds at: item id ifAbsent: [ #() ].
							self items select: [ :f | fIds includes: f id ] ]
						ifFalse: [ #() ] ] ];
		column: 'Name' text: [ :item | item name ] weight: 1;
		column: 'Status' text: [ :item |
			(item isKindOf: PbFeature)
				ifTrue: [ item status ifNil: [ '' ] ifNotNil: [ :s | s name ifNil: [ '' ] ] ]
				ifFalse: [
					(item isKindOf: PbRelease)
						ifTrue: [ item state ifNil: [ '' ] ]
						ifFalse: [ '' ] ] ] weight: 0.25;
		column: 'Timeframe' text: [ :item |
			((item respondsTo: #timeframe) and: [ item timeframe notNil ])
				ifTrue: [ item timeframe gtDisplayString ]
				ifFalse: [ '' ] ] weight: 0.3
]

{ #category : 'board' }
PbFeaturesGroup >> pipelineOrder [
	"Ordered status pipeline for kanban board"
	^ #('Idea' 'Discovery' 'Candidate' 'Planned' 'Requirement Planning' 'In progress' 'Testing' 'Released' 'Launched' 'On Hold' 'Blocked' 'Archived')
]

{ #category : 'accessing' }
PbFeaturesGroup >> releaseToFeatureIds [
	"Dictionary mapping releaseId -> Set of feature ids in this group"
	| featureIds result |
	featureIds := (self items collect: #id) asSet.
	result := Dictionary new.
	self client featureReleaseAssignments do: [ :a |
		| fId rId |
		fId := a at: 'feature' ifPresent: [ :f | f at: 'id' ifAbsent: [ nil ] ] ifAbsent: [ nil ].
		rId := a at: 'release' ifPresent: [ :r | r at: 'id' ifAbsent: [ nil ] ] ifAbsent: [ nil ].
		(fId notNil and: [ rId notNil and: [ featureIds includes: fId ] ]) ifTrue: [
			(result at: rId ifAbsentPut: [ Set new ]) add: fId ] ].
	^ result
]
