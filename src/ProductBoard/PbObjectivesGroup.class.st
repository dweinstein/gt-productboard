Class {
	#name : 'PbObjectivesGroup',
	#superclass : 'PbGroup',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'accessing' }
PbObjectivesGroup class >> itemClass [
	^ PbObjective
]

{ #category : 'building' }
PbObjectivesGroup >> buildBoardElement [
	^ PbBoardElement
		nowNextLater: self items
		groupClass: PbObjectivesGroup
]

{ #category : 'timeline' }
PbObjectivesGroup >> buildTimelineCardFor: anObjective [
	| card nameLabel timeLabel stateColor |
	stateColor := (anObjective state = 'on_track') 
		ifTrue: [ Color green darker ] 
		ifFalse: [ (anObjective state = 'at_risk')
			ifTrue: [ Color orange ]
			ifFalse: [ (anObjective state = 'off_track')
				ifTrue: [ Color red ]
				ifFalse: [ Color gray ] ] ].
	
	card := BrHorizontalPane new.
	card hMatchParent.
	card vFitContent.
	card padding: (BlInsets all: 8).
	card margin: (BlInsets top: 2 left: 8 bottom: 2 right: 0).
	card background: Color white.
	card geometry: (BlRoundedRectangleGeometry cornerRadius: 4).
	card addAptitude: (BrShadowAptitude new color: (Color gray alpha: 0.12)).
	card alignCenterLeft.
	
	"State indicator dot"
	card addChild: (BlElement new
		size: 10 @ 10;
		geometry: BlCircleGeometry new;
		background: stateColor;
		margin: (BlInsets right: 8)).
	
	nameLabel := BrLabel new
		text: anObjective name;
		aptitude: (BrGlamorousLabelAptitude new fontSize: 12);
		hMatchParent.
	card addChild: nameLabel.
	
	timeLabel := BrLabel new
		text: (anObjective timeframe gtDisplayString asRopedText foreground: Color gray);
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11).
	card addChild: timeLabel.
	
	anObjective archived = true ifTrue: [
		card addChild: (BrLabel new
			text: ('archived' asRopedText italic foreground: Color gray);
			aptitude: (BrGlamorousLabelAptitude new fontSize: 10);
			margin: (BlInsets left: 6)) ].
	
	card when: BlClickEvent do: [ :e | card phlow spawnObject: anObjective ].
	^ card
]

{ #category : 'building' }
PbObjectivesGroup >> buildTimelineElement [
	| active sorted pane grouped quarters |
	active := self items reject: [ :o | o archived = true ].
	sorted := (active select: [ :o | o timeframe notNil and: [ o timeframe startDate notNil ] ])
		sorted: [ :a :b | a timeframe startDate < b timeframe startDate ].
	sorted ifEmpty: [ 
		^ BrLabel new 
			text: 'No objectives with timeframes'; 
			aptitude: BrGlamorousLabelAptitude new ].
	
	pane := BrVerticalPane new.
	pane matchParent.
	pane padding: (BlInsets all: 12).
	
	grouped := sorted groupedBy: [ :o | 
		| sd |
		sd := o timeframe startDate.
		'Q', ((sd monthIndex - 1 // 3) + 1) asString, ' ', sd year asString ].
	quarters := grouped keys sorted.
	
	quarters do: [ :q |
		| items quarterPane header |
		items := grouped at: q.
		
		quarterPane := BrVerticalPane new.
		quarterPane hMatchParent.
		quarterPane vFitContent.
		quarterPane margin: (BlInsets top: 4 bottom: 8).
		
		header := BrLabel new
			text: (q asRopedText bold fontSize: 14);
			aptitude: BrGlamorousLabelAptitude new;
			margin: (BlInsets top: 0 left: 4 bottom: 4 right: 0).
		quarterPane addChild: header.
		
		items do: [ :obj |
			quarterPane addChild: (self buildTimelineCardFor: obj) ].
		
		pane addChild: quarterPane ].
	
	^ pane asScrollableElement
]

{ #category : 'views' }
PbObjectivesGroup >> gtViewBoardFor: aView [
	<gtView>
	self items ifEmpty: [ ^ aView empty ].
	^ aView explicit
		title: 'Board';
		priority: 3;
		stencil: [ self buildBoardElement ]
]

{ #category : 'gt-views' }
PbObjectivesGroup >> gtViewByOwnerFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'By owner';
		priority: 7;
		items: [
			| grouped result |
			grouped := self items groupedBy: [ :o | o owner ifNil: [ 'Unassigned' ] ifNotNil: [ :ow | ow gtDisplayString ] ].
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
		column: 'State' text: [ :each |
			(each isKindOf: Association)
				ifTrue: [ '' ]
				ifFalse: [ each state ifNil: [ 'unset' ] ] ] weight: 0.25;
		column: 'Timeframe' text: [ :each |
			(each isKindOf: Association)
				ifTrue: [ '' ]
				ifFalse: [ each timeframe ifNil: [ '' ] ifNotNil: [ :t | t gtDisplayString ] ] ] weight: 0.3;
		send: [ :each |
			(each isKindOf: Association)
				ifTrue: [ PbObjectivesGroup withAll: each value label: each key ]
				ifFalse: [ each ] ]
]

{ #category : 'gt-extensions' }
PbObjectivesGroup >> gtViewByStateFor: aView [
	<gtView>
	self items ifEmpty: [ ^ aView empty ].
	^ aView columnedList
		title: 'By state';
		priority: 5;
		items: [ 
			| grouped result |
			grouped := self items groupedBy: [ :each | each state ifNil: [ 'unset' ] ].
			result := OrderedCollection new.
			grouped keysAndValuesDo: [ :state :items |
				result add: (state -> items) ].
			result sorted: [ :a :b | a key < b key ] ];
		column: 'State' text: [ :assoc | assoc key ] weight: 0.3;
		column: 'Count' text: [ :assoc | assoc value size ] weight: 0.2;
		column: 'Objectives' text: [ :assoc | 
			', ' join: (assoc value collect: #name) ] weight: 0.5;
		send: [ :assoc | self class withAll: assoc value ]
]

{ #category : 'gt-extensions' }
PbObjectivesGroup >> gtViewByTimeframeFor: aView [
	<gtView>
	self items ifEmpty: [ ^ aView empty ].
	^ aView columnedList
		title: 'By timeframe';
		priority: 6;
		items: [ 
			| grouped result |
			grouped := self items groupedBy: [ :each | each timeframe ifNil: [ 'unset' ] ].
			result := OrderedCollection new.
			grouped keysAndValuesDo: [ :tf :items |
				result add: (tf -> items) ].
			result sorted: [ :a :b | a key asString < b key asString ] ];
		column: 'Timeframe' text: [ :assoc | assoc key gtDisplayString ] weight: 0.3;
		column: 'Count' text: [ :assoc | assoc value size ] weight: 0.2;
		column: 'Objectives' text: [ :assoc |
			', ' join: (assoc value collect: #name) ] weight: 0.5;
		send: [ :assoc | self class withAll: assoc value ]
]

{ #category : 'views' }
PbObjectivesGroup >> gtViewObjectivesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Objectives';
		priority: 1;
		items: [ (self items reject: [ :each | each archived = true ]) sorted: [ :a :b |
			(a updatedAt ifNil: [ DateAndTime epoch ]) > (b updatedAt ifNil: [ DateAndTime epoch ]) ] ];
		column: 'Name' text: #name;
		column: 'State' text: [ :item | item state ifNil: [ 'unset' ] ] weight: 0.2;
		column: 'Owner' text: [ :item | item owner gtDisplayString ] weight: 0.3;
		column: 'Timeframe' text: [ :item | item timeframe gtDisplayString ] weight: 0.3;
		column: 'Updated' text: [ :item | item updatedAt gtDisplayString ] weight: 0.25
]

{ #category : 'views' }
PbObjectivesGroup >> gtViewTimelineFor: aView [
	<gtView>
	self items ifEmpty: [ ^ aView empty ].
	^ aView explicit
		title: 'Timeline';
		priority: 4;
		stencil: [ self buildTimelineElement ]
]
