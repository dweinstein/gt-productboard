Class {
	#name : 'PbCardElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'entity',
		'compact'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'instance creation' }
PbCardElement class >> compactFor: anEntity [
	^ self new entity: anEntity; compact: true; build
]

{ #category : 'instance creation' }
PbCardElement class >> for: anEntity [
	^ self new entity: anEntity; compact: false; build
]

{ #category : 'accessing' }
PbCardElement >> accentColor [
	"Derive an accent color from the entity's status or state"
	| s |
	"Try status name first"
	s := (entity respondsTo: #status) 
		ifTrue: [ entity status ifNotNil: [ :st | st name ] ] 
		ifFalse: [ nil ].
	s ifNil: [
		"Fall back to state for objectives"
		s := (entity respondsTo: #state) 
			ifTrue: [ entity state ] 
			ifFalse: [ nil ] ].
	s ifNil: [ ^ Color gray ].
	"Status pipeline colors"
	s = 'Idea' ifTrue: [ ^ Color fromHexString: '9b59b6' ].
	s = 'Discovery' ifTrue: [ ^ Color fromHexString: '3498db' ].
	s = 'Candidate' ifTrue: [ ^ Color fromHexString: '2980b9' ].
	s = 'Planned' ifTrue: [ ^ Color fromHexString: 'e67e22' ].
	s = 'Requirement Planning' ifTrue: [ ^ Color fromHexString: 'e67e22' ].
	s = 'In progress' ifTrue: [ ^ Color fromHexString: 'f39c12' ].
	s = 'In Progress' ifTrue: [ ^ Color fromHexString: 'f39c12' ].
	s = 'Testing' ifTrue: [ ^ Color fromHexString: '1abc9c' ].
	s = 'Released' ifTrue: [ ^ Color fromHexString: '27ae60' ].
	s = 'Launched' ifTrue: [ ^ Color fromHexString: '2ecc71' ].
	s = 'On Hold' ifTrue: [ ^ Color fromHexString: '95a5a6' ].
	s = 'Blocked' ifTrue: [ ^ Color fromHexString: 'e74c3c' ].
	s = 'Archived' ifTrue: [ ^ Color fromHexString: 'bdc3c7' ].
	s = 'Upcoming' ifTrue: [ ^ Color fromHexString: '3498db' ].
	s = 'Done' ifTrue: [ ^ Color fromHexString: '27ae60' ].
	"State colors for objectives"
	s = 'on_track' ifTrue: [ ^ Color fromHexString: '27ae60' ].
	s = 'at_risk' ifTrue: [ ^ Color fromHexString: 'e67e22' ].
	s = 'off_track' ifTrue: [ ^ Color fromHexString: 'e74c3c' ].
	^ Color gray
]

{ #category : 'building' }
PbCardElement >> build [
	| radius shadowAlpha |
	radius := self isCompact ifTrue: [ 4 ] ifFalse: [ 8 ].
	shadowAlpha := self isCompact ifTrue: [ 0.12 ] ifFalse: [ 0.2 ].
	self hMatchParent; vFitContent.
	self isCompact
		ifTrue: [ self margin: (BlInsets top: 2 bottom: 2) ]
		ifFalse: [ self margin: (BlInsets all: 20) ].
	self background: Color white.
	self geometry: (BlRoundedRectangleGeometry cornerRadius: radius).
	self addAptitude: (BrShadowAptitude new color: (Color gray alpha: shadowAlpha)).
	self isCompact ifFalse: [
		self border: (BlBorder paint: (Color fromHexString: 'e8e8e8') width: 1) ].
	self addChild: self buildStripe.
	self addChild: self buildContent.
	^ self
]

{ #category : 'building' }
PbCardElement >> buildBottomRow [
	| row ownerName fontSize dotSize topMargin |
	ownerName := ((entity respondsTo: #owner) ifTrue: [ entity owner ] ifFalse: [ nil ])
		ifNil: [ 'Unassigned' ] ifNotNil: [ :o | o gtDisplayString ].
	fontSize := self isCompact ifTrue: [ 11 ] ifFalse: [ 12 ].
	dotSize := self isCompact ifTrue: [ 6@6 ] ifFalse: [ 8@8 ].
	topMargin := self isCompact ifTrue: [ 2 ] ifFalse: [ 0 ].
	row := BrHorizontalPane new hMatchParent; vFitContent; alignCenterLeft.
	row margin: (BlInsets top: topMargin).
	row addChild: (BlElement new
		size: dotSize;
		geometry: BlCircleGeometry new;
		background: (Color fromHexString: '7f8c8d');
		margin: (BlInsets right: 4)).
	row addChild: (BrLabel new
		text: (ownerName asRopedText foreground: (Color fromHexString: '555555'));
		aptitude: (BrGlamorousLabelAptitude new fontSize: fontSize);
		hMatchParent).
	self isCompact ifFalse: [
		self buildTimeframeLabel ifNotNil: [ :el | row addChild: el ] ].
	^ row
]

{ #category : 'building' }
PbCardElement >> buildContent [
	| content |
	content := BrVerticalPane new.
	content hMatchParent; vFitContent.
	self isCompact
		ifTrue: [ content padding: (BlInsets top: 6 left: 8 bottom: 6 right: 8) ]
		ifFalse: [ content padding: (BlInsets top: 16 left: 16 bottom: 16 right: 16) ].
	content addChild: self buildTopRow.
	content addChild: self buildName.
	self isCompact ifFalse: [
		self buildExcerpt ifNotNil: [ :el | content addChild: el ].
		content addChild: self buildDivider ].
	content addChild: self buildBottomRow.
	^ content
]

{ #category : 'building' }
PbCardElement >> buildDivider [
	^ BlElement new
		constraintsDo: [ :c | c horizontal matchParent. c vertical exact: 1 ];
		background: (Color fromHexString: 'eeeeee');
		margin: (BlInsets top: 12 bottom: 10)
]

{ #category : 'building' }
PbCardElement >> buildExcerpt [
	| text excerpt ropedText label |
	(entity respondsTo: #descriptionText) ifFalse: [ ^ nil ].
	text := entity descriptionText.
	(text isNil or: [ text isEmpty ]) ifTrue: [ ^ nil ].
	excerpt := text copyFrom: 1 to: (text size min: 500).
	excerpt size >= 500 ifTrue: [ excerpt := excerpt, '...' ].
	ropedText := excerpt asRopedText.
	ropedText foreground: (Color fromHexString: '555555').
	ropedText fontSize: 13.
	label := BrEditor new
		text: ropedText;
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithSelection;
		hMatchParent;
		vFitContentLimited;
		margin: (BlInsets top: 8).
	^ label
]

{ #category : 'building' }
PbCardElement >> buildName [
	| text fontSize topMargin |
	fontSize := self isCompact ifTrue: [ 13 ] ifFalse: [ 15 ].
	topMargin := self isCompact ifTrue: [ 2 ] ifFalse: [ 8 ].
	text := (entity name ifNil: [ 'Untitled' ]) asRopedText.
	text fontSize: fontSize.
	text foreground: (Color fromHexString: '1a1a1a').
	^ BrLabel new
		text: text;
		aptitude: BrGlamorousLabelAptitude new;
		margin: (BlInsets top: topMargin)
]

{ #category : 'building' }
PbCardElement >> buildStatusBadge [
	| statusName badgeColor text badge fontSize |
	statusName := (entity respondsTo: #status)
		ifTrue: [ entity status ifNil: [ nil ] ifNotNil: [ :s | s name ] ]
		ifFalse: [ nil ].
	statusName ifNil: [ statusName := (entity respondsTo: #state) ifTrue: [ entity state ] ifFalse: [ nil ] ].
	statusName ifNil: [ ^ BlElement new size: 0@0 ].
	badgeColor := self accentColor alpha: 0.15.
	fontSize := self isCompact ifTrue: [ 10 ] ifFalse: [ 11 ].
	text := statusName asRopedText foreground: self accentColor.
	text fontSize: fontSize.
	badge := BrLabel new text: text; aptitude: BrGlamorousLabelAptitude new.
	badge background: badgeColor.
	badge geometry: (BlRoundedRectangleGeometry cornerRadius: 4).
	badge padding: (BlInsets top: 2 left: 6 bottom: 2 right: 6).
	badge margin: (BlInsets right: 6).
	^ badge
]

{ #category : 'building' }
PbCardElement >> buildStripe [
	| stripe width cornerSize |
	width := self isCompact ifTrue: [ 3 ] ifFalse: [ 5 ].
	cornerSize := self isCompact ifTrue: [ 4 ] ifFalse: [ 8 ].
	stripe := BlElement new.
	stripe constraintsDo: [ :c |
		c horizontal exact: width.
		c vertical matchParent ].
	stripe background: self accentColor.
	stripe geometry: (BlRoundedRectangleGeometry cornerRadii: 
		(BlCornerRadii new topLeft: cornerSize; bottomLeft: cornerSize; topRight: 0; bottomRight: 0; yourself)).
	^ stripe
]

{ #category : 'building' }
PbCardElement >> buildTimeframeLabel [
	| tf |
	(entity respondsTo: #timeframe) ifFalse: [ ^ nil ].
	tf := entity timeframe.
	(tf isNil or: [ tf startDate isNil ]) ifTrue: [ ^ nil ].
	^ BrLabel new
		text: (tf gtDisplayString asRopedText foreground: (Color fromHexString: '999999'));
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11)
]

{ #category : 'building' }
PbCardElement >> buildTopRow [
	| row |
	row := BrHorizontalPane new hMatchParent; vFitContent; alignCenterLeft.
	row addChild: self buildStatusBadge.
	self buildTypeLabel ifNotNil: [ :el | row addChild: el ].
	^ row
]

{ #category : 'building' }
PbCardElement >> buildTypeLabel [
	| typeName |
	typeName := (entity respondsTo: #type) ifTrue: [ entity type ] ifFalse: [ nil ].
	typeName ifNil: [
		typeName := (entity respondsTo: #state) ifTrue: [ entity state ] ifFalse: [ nil ] ].
	typeName ifNil: [ ^ nil ].
	^ BrLabel new
		text: (typeName asRopedText foreground: (Color fromHexString: 'aaaaaa'));
		aptitude: (BrGlamorousLabelAptitude new fontSize: 10);
		margin: (BlInsets left: 8)
]

{ #category : 'accessing' }
PbCardElement >> compact: aBoolean [
	compact := aBoolean
]

{ #category : 'accessing' }
PbCardElement >> entity [
	^ entity
]

{ #category : 'accessing' }
PbCardElement >> entity: anEntity [
	entity := anEntity
]

{ #category : 'testing' }
PbCardElement >> isCompact [
	^ compact ifNil: [ false ]
]
