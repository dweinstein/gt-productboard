Class {
	#name : 'PbBoardElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'items',
		'bucketBlock',
		'bucketOrder',
		'groupClass'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'bucketing' }
PbBoardElement class >> bucketNameFor: anItem today: today [
	"Classify an item into Now / Next / Later / Done / No timeframe"
	anItem archived = true ifTrue: [ ^ 'Done' ].
	(anItem timeframe isNil or: [ anItem timeframe startDate isNil ])
		ifTrue: [ ^ 'No timeframe' ].
	(anItem timeframe endDate notNil and: [ anItem timeframe endDate < today ])
		ifTrue: [ ^ 'Done' ].
	anItem timeframe startDate <= today
		ifTrue: [ ^ 'Now' ].
	(anItem timeframe startDate - today) days < 90
		ifTrue: [ ^ 'Next' ].
	^ 'Later'
]

{ #category : 'instance creation' }
PbBoardElement class >> byStatus: aCollection order: anArray groupClass: aClass [
	^ self
		items: aCollection
		bucketBy: [ :item | item status ifNil: [ 'No status' ] ifNotNil: [ :s | s name ifNil: [ 'No status' ] ] ]
		order: anArray
		groupClass: aClass
]

{ #category : 'instance creation' }
PbBoardElement class >> items: aCollection bucketBy: aBlock order: anArray groupClass: aClass [
	^ self new
		items: aCollection;
		bucketBlock: aBlock;
		bucketOrder: anArray;
		groupClass: aClass;
		build
]

{ #category : 'instance creation' }
PbBoardElement class >> nowNextLater: aCollection groupClass: aClass [
	^ self
		items: aCollection
		bucketBy: [ :item | self bucketNameFor: item today: Date today ]
		order: #('Now' 'Next' 'Later' 'Done' 'No timeframe')
		groupClass: aClass
]

{ #category : 'accessing' }
PbBoardElement >> bucketBlock: aBlock [
	bucketBlock := aBlock
]

{ #category : 'accessing' }
PbBoardElement >> bucketOrder: anArray [
	bucketOrder := anArray
]

{ #category : 'building' }
PbBoardElement >> build [
	| grouped |
	self matchParent.
	self padding: (BlInsets all: 8).
	
	grouped := items groupedBy: bucketBlock.
	
	"Add columns in specified order"
	bucketOrder do: [ :name |
		| columnItems |
		columnItems := grouped at: name ifAbsent: [ #() ].
		columnItems ifNotEmpty: [
			self addChild: (self buildColumnFor: name items: columnItems) ] ].
	
	"Add any buckets not in the order"
	grouped keysAndValuesDo: [ :name :columnItems |
		(bucketOrder includes: name) ifFalse: [
			self addChild: (self buildColumnFor: name items: columnItems) ] ].
	
	^ self
]

{ #category : 'building' }
PbBoardElement >> buildColumnFor: columnName items: columnItems [
	| column group |
	group := groupClass withAll: columnItems.
	
	column := BrVerticalPane new.
	column matchParent.
	column margin: (BlInsets all: 4).
	column background: (self columnBackgroundFor: columnName).
	column padding: (BlInsets all: 6).
	column geometry: (BlRoundedRectangleGeometry cornerRadius: 8).
	
	column addChild: (self buildHeaderFor: columnName count: columnItems size group: group).
	column addChild: (self buildListFor: columnItems).
	
	^ column
]

{ #category : 'building' }
PbBoardElement >> buildHeaderFor: columnName count: count group: aGroup [
	| header titleText countLabel |
	header := BrHorizontalPane new.
	header fitContent.
	header hMatchParent.
	header padding: (BlInsets bottom: 4).
	header when: BlClickEvent do: [ :e | header phlow spawnObject: aGroup ].
	
	titleText := columnName asRopedText bold.
	header addChild: (BrLabel new
		text: titleText;
		aptitude: (BrGlamorousLabelAptitude new fontSize: 13);
		hMatchParent).
	
	countLabel := BrLabel new
		text: (count asString asRopedText foreground: Color gray);
		aptitude: (BrGlamorousLabelAptitude new fontSize: 12).
	header addChild: countLabel.
	
	^ header
]

{ #category : 'building' }
PbBoardElement >> buildListFor: columnItems [
	| list |
	list := BrSimpleList new.
	list matchParent.
	list stencil: [ :each :anIndex |
		| card |
		card := PbCardElement compactFor: each.
		card when: BlClickEvent do: [ :e | card phlow spawnObject: each ].
		card ].
	list items: columnItems.
	^ list
]

{ #category : 'building' }
PbBoardElement >> columnBackgroundFor: columnName [
	"Subtle background tint per bucket name"
	columnName = 'Now' ifTrue: [ ^ Color green darker alpha: 0.15 ].
	columnName = 'Next' ifTrue: [ ^ Color blue alpha: 0.1 ].
	columnName = 'Later' ifTrue: [ ^ Color gray alpha: 0.08 ].
	columnName = 'In progress' ifTrue: [ ^ Color blue alpha: 0.1 ].
	columnName = 'Done' ifTrue: [ ^ Color green darker alpha: 0.1 ].
	columnName = 'Released' ifTrue: [ ^ Color green darker alpha: 0.1 ].
	columnName = 'Launched' ifTrue: [ ^ Color green darker alpha: 0.1 ].
	columnName = 'Blocked' ifTrue: [ ^ Color red alpha: 0.08 ].
	columnName = 'On Hold' ifTrue: [ ^ Color orange alpha: 0.08 ].
	^ Color gray alpha: 0.05
]

{ #category : 'accessing' }
PbBoardElement >> groupClass: aClass [
	groupClass := aClass
]

{ #category : 'accessing' }
PbBoardElement >> items: aCollection [
	items := aCollection
]
