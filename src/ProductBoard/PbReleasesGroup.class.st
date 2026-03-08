Class {
	#name : 'PbReleasesGroup',
	#superclass : 'PbGroup',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'accessing' }
PbReleasesGroup class >> itemClass [
	^ PbRelease
]

{ #category : 'ui' }
PbReleasesGroup >> buildBoardElement [
	^ PbBoardElement
		items: self items
		bucketBy: [ :item | item state ifNil: [ 'No state' ] ]
		order: self stateOrder
		groupClass: PbReleasesGroup
]

{ #category : 'gt views' }
PbReleasesGroup >> gtViewBoardFor: aView [
	<gtView>
	self items ifEmpty: [ ^ aView empty ].
	^ aView explicit
		title: 'Board';
		priority: 3;
		stencil: [ self buildBoardElement ]
]

{ #category : 'gt views' }
PbReleasesGroup >> gtViewByGroupFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'By Release Group';
		priority: 5;
		items: [ 
			| grouped |
			grouped := self items groupedBy: [ :r | r releaseGroupId ifNil: [ '(none)' ] ].
			grouped associations sorted: [ :a :b | a key < b key ] ];
		children: [ :item |
			item isAssociation
				ifTrue: [ item value ]
				ifFalse: [ #() ] ];
		column: 'Name' text: [ :item |
			item isAssociation
				ifTrue: [ 'Group: ', item key ]
				ifFalse: [ item name ] ];
		column: 'State' text: [ :item |
			item isAssociation
				ifTrue: [ '' ]
				ifFalse: [ item state ifNil: [ '' ] ] ] weight: 0.2
]

{ #category : 'gt views' }
PbReleasesGroup >> gtViewReleasesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Releases';
		priority: 1;
		items: [ self items sorted: [ :a :b | 
			| aIndex bIndex |
			aIndex := self stateOrder indexOf: (a state ifNil: [ '' ]) ifAbsent: [ 99 ].
			bIndex := self stateOrder indexOf: (b state ifNil: [ '' ]) ifAbsent: [ 99 ].
			aIndex = bIndex
				ifTrue: [ a name asLowercase < b name asLowercase ]
				ifFalse: [ aIndex < bIndex ] ] ];
		column: 'Name' text: #name;
		column: 'State' text: [ :item | item state ifNil: [ 'unset' ] ] weight: 0.2;
		column: 'Timeframe' text: [ :item | item timeframe gtDisplayString ] weight: 0.3;
		column: 'Archived' text: [ :item | item archived ifNil: [ false ] ] weight: 0.15
]

{ #category : 'accessing' }
PbReleasesGroup >> stateOrder [
	"Ordered states for sorting and board display"
	^ #('upcoming' 'in-progress' 'completed')
]
