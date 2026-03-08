Class {
	#name : 'PbClient',
	#superclass : 'Object',
	#instVars : [
		'baseUrl',
		'apiKey',
		'features',
		'objectives',
		'releases',
		'releaseGroups',
		'featureReleaseAssignments'
	],
	#classVars : [
		'ApiKeyFile'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'accessing' }
PbClient class >> apiKeyFile [
	^ ApiKeyFile
]

{ #category : 'accessing' }
PbClient class >> apiKeyFile: aFile [
	ApiKeyFile := aFile
]

{ #category : 'accessing' }
PbClient class >> apiKeyFileContents [
	^ ApiKeyFile contents trimBoth
]

{ #category : 'accessing' }
PbClient class >> defaultApiKeyFile [
	^ FileLocator home / '.secrets' / 'productboard-token.txt'
]

{ #category : 'accessing' }
PbClient class >> initialize [
	ApiKeyFile := self defaultApiKeyFile
]

{ #category : 'accessing' }
PbClient class >> withApiKeyFromClipboard [
	^ self new apiKey: Clipboard clipboardText
]

{ #category : 'accessing' }
PbClient class >> withApiKeyFromFile [
	^ self new apiKey: self apiKeyFileContents
]

{ #category : 'accessing' }
PbClient >> activeReleases [
	"Releases that are not archived and whose release group is not archived"
	| archivedGroupIds |
	archivedGroupIds := (self releaseGroups items select: [ :rg | rg archived = true ]) collect: #id.
	^ self releases items reject: [ :r | 
		r archived = true or: [ archivedGroupIds includes: r releaseGroupId ] ]
]

{ #category : 'as yet unclassified' }
PbClient >> apiKey [
	^ apiKey
]

{ #category : 'accessing' }
PbClient >> apiKey: anApiKey [
	apiKey := anApiKey
]

{ #category : 'accessing' }
PbClient >> baseUrl [
	^ baseUrl
]

{ #category : 'accessing' }
PbClient >> baseUrl: anObject [
	baseUrl := anObject asZnUrl
]

{ #category : 'building' }
PbClient >> buildQuarterlyRadarElement [
	| radar allItems launchedSet inProgressSet |
	radar := self quarterlyReleaseRadar.
	allItems := OrderedCollection new.
	radar valuesDo: [ :v | allItems addAll: v ].
	allItems ifEmpty: [ ^ BrLabel new text: 'No releases found'; aptitude: BrGlamorousLabelAptitude new ].
	
	launchedSet := radar at: 'Launched This Quarter'.
	inProgressSet := radar at: 'In Progress'.
	
	^ PbBoardElement
		items: allItems
		bucketBy: [ :item |
			(launchedSet includes: item)
				ifTrue: [ 'Launched This Quarter' ]
				ifFalse: [
					(inProgressSet includes: item)
						ifTrue: [ 'In Progress' ]
						ifFalse: [ 'Coming Soon' ] ] ]
		order: #('Launched This Quarter' 'In Progress' 'Coming Soon')
		groupClass: PbReleasesGroup
]

{ #category : 'private' }
PbClient >> checkForErrors: aResponse [
	((aResponse respondsTo: #includesKey:) and: [
		(aResponse includesKey: 'error') and: [
			((aResponse at: 'error') respondsTo: #includesKey:) and: [
				(aResponse at: 'error') includesKey: 'message' ] ] ])
		ifTrue: [ ^ (PbError from: (aResponse at: 'error')) signal ].
	^ aResponse
]

{ #category : 'default' }
PbClient >> defaultBaseUrl [
	^ 'https://api.productboard.com' asZnUrl
]

{ #category : 'accessing' }
PbClient >> delete: aUrl [
	| aClient |
	aClient := self initializeClient.
	aClient url: self baseUrl / aUrl.
	
	aClient entity: nil.

	^ self checkForErrors: aClient delete
]

{ #category : 'accessing' }
PbClient >> featureReleaseAssignments [
	^ featureReleaseAssignments ifNil: [ 
		featureReleaseAssignments := self listFeatureReleaseAssignments ]
]

{ #category : 'accessing' }
PbClient >> featureReleaseAssignments: anObject [
	featureReleaseAssignments := anObject
]

{ #category : 'accessing' }
PbClient >> features [
	^ features ifNil: [ features := self listFeatures ]
]

{ #category : 'accessing' }
PbClient >> features: anObject [
	features := anObject
]

{ #category : 'api - roadmap' }
PbClient >> featuresByReleaseId [
	"Dictionary mapping releaseId -> OrderedCollection of PbFeature.
	Built from feature-release assignments joined with features."
	| result featuresById |
	result := Dictionary new.
	featuresById := Dictionary new.
	self features items do: [ :f | featuresById at: f id put: f ].
	self featureReleaseAssignments do: [ :assignment |
		| featureId releaseId featureLink releaseLink feature |
		featureLink := assignment at: 'feature' ifAbsent: [ nil ].
		releaseLink := assignment at: 'release' ifAbsent: [ nil ].
		featureId := featureLink ifNotNil: [ featureLink at: 'id' ifAbsent: [ nil ] ].
		releaseId := releaseLink ifNotNil: [ releaseLink at: 'id' ifAbsent: [ nil ] ].
		(featureId notNil and: [ releaseId notNil ]) ifTrue: [
			feature := featuresById at: featureId ifAbsent: [ nil ].
			feature ifNotNil: [
				(result at: releaseId ifAbsentPut: [ OrderedCollection new ]) add: feature ] ] ].
	^ result
]

{ #category : 'api - roadmap' }
PbClient >> featuresForReleaseGroup: aReleaseGroup [
	"Given a PbReleaseGroup, collect all features from all its releases."
	| groupReleases featuresByRelease allFeatures |
	featuresByRelease := self featuresByReleaseId.
	groupReleases := self releasesByGroupId at: aReleaseGroup id ifAbsent: [ #() ].
	allFeatures := OrderedCollection new.
	groupReleases do: [ :rel |
		allFeatures addAll: (featuresByRelease at: rel id ifAbsent: [ #() ]) ].
	^ allFeatures
]

{ #category : 'accessing' }
PbClient >> get: aUrl [
	^ self get: aUrl withParams: {}
]

{ #category : 'accessing' }
PbClient >> get: aUrl withParams: aListOfAssocs [
	| aClient |
	aClient := self initializeClient.
	aClient url: self baseUrl / aUrl.
	aListOfAssocs do: [ :aPair | aClient queryAt: aPair key put: aPair value ].

	aClient entity: nil.

	^ self checkForErrors: aClient get
]

{ #category : 'accessing' }
PbClient >> getUrl: anAbsoluteUrl [
	"Fetch a fully-qualified URL. Used for following pagination links."
	| aClient |
	aClient := self initializeClient.
	aClient url: anAbsoluteUrl asZnUrl.
	aClient entity: nil.
	^ self checkForErrors: aClient get
]

{ #category : 'views' }
PbClient >> gtByOwnerFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'By owner';
		priority: 5;
		items: [
			| allItems grouped result |
			allItems := OrderedCollection new.
			self features items do: [ :f | allItems add: f ].
			self objectives items do: [ :o | allItems add: o ].
			grouped := allItems groupedBy: [ :item | item owner ifNil: [ 'Unassigned' ] ifNotNil: [ :o | o gtDisplayString ] ].
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
		column: 'Type' text: [ :each |
			(each isKindOf: Association)
				ifTrue: [ | feats objs |
					feats := (each value count: [ :i | i isKindOf: PbFeature ]).
					objs := (each value count: [ :i | i isKindOf: PbObjective ]).
					feats asString, ' features, ', objs asString, ' objectives' ]
				ifFalse: [ (each isKindOf: PbObjective) ifTrue: [ 'Objective' ] ifFalse: [ 'Feature' ] ] ] weight: 0.35;
		column: 'Status' text: [ :each |
			(each isKindOf: Association)
				ifTrue: [ '' ]
				ifFalse: [ each status gtDisplayString ] ] weight: 0.2;
		send: [ :each |
			(each isKindOf: Association)
				ifTrue: [
					| feats |
					feats := each value select: [ :i | i isKindOf: PbFeature ].
					feats size = each value size
						ifTrue: [ PbFeaturesGroup withAll: feats ]
						ifFalse: [
							| objs |
							objs := each value select: [ :i | i isKindOf: PbObjective ].
							objs size = each value size
								ifTrue: [ PbObjectivesGroup withAll: objs ]
								ifFalse: [ each value ] ] ]
				ifFalse: [ each ] ]
]

{ #category : 'accessing' }
PbClient >> gtFeaturesFor: aView [
	<gtView>
	^ aView forward
		title: 'Features';
		priority: 1;
		object: [ self features ];
		view: #gtViewFeaturesFor:
]

{ #category : 'views' }
PbClient >> gtObjectivesFor: aView [
	<gtView>
	^ aView forward
		title: 'Objectives';
		priority: 2;
		object: [ self objectives ];
		view: #gtViewObjectivesFor:
]

{ #category : 'views' }
PbClient >> gtQuarterlyRadarFor: aView [
	<gtView>
	^ aView explicit
		title: 'Release radar';
		priority: 3;
		stencil: [ self buildQuarterlyRadarElement ]
]

{ #category : 'views' }
PbClient >> gtRecentlyChangedFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Recently changed';
		priority: 6;
		items: [
			| items |
			items := OrderedCollection new.
			self features items do: [ :f |
				f updatedAt ifNotNil: [ items add: f ] ].
			self objectives items do: [ :o |
				o updatedAt ifNotNil: [ items add: o ] ].
			items sort: [ :a :b | a updatedAt > b updatedAt ].
			items first: (items size min: 50) ];
		column: 'Updated' text: [ :item | 
			| ago |
			ago := DateAndTime now - item updatedAt.
			ago days > 0 
				ifTrue: [ ago days asString, 'd ago' ]
				ifFalse: [ ago hours asString, 'h ago' ] ] weight: 0.15;
		column: 'Type' text: [ :item | 
			(item isKindOf: PbObjective) 
				ifTrue: [ 'Objective' ] 
				ifFalse: [ 'Feature' ] ] weight: 0.12;
		column: 'Name' text: #name weight: 0.4;
		column: 'Status' text: [ :item | item status gtDisplayString ] weight: 0.15;
		column: 'Owner' text: [ :item | item owner gtDisplayString ] weight: 0.18
]

{ #category : 'views' }
PbClient >> gtReleaseGroupsFor: aView [
	<gtView>
	^ aView forward
		title: 'Release groups';
		priority: 9;
		object: [ self releaseGroups ];
		view: #gtViewReleaseGroupsFor:
]

{ #category : 'views' }
PbClient >> gtReleaseRoadmapFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'Release roadmap';
		priority: 4;
		items: [ self releaseGroups items reject: [ :rg | rg archived = true ] ];
		children: [ :item |
			(item isKindOf: PbReleaseGroup)
				ifTrue: [ self releasesByGroupId at: item id ifAbsent: [ #() ] ]
				ifFalse: [
					(item isKindOf: PbRelease)
						ifTrue: [ self featuresByReleaseId at: item id ifAbsent: [ #() ] ]
						ifFalse: [ #() ] ] ];
		column: 'Name' text: [ :item | item name ] weight: 1;
		column: 'Status' text: [ :item |
			(item isKindOf: PbFeature)
				ifTrue: [ item status ifNil: [ '' ] ifNotNil: [ :s | s name ifNil: [ '' ] ] ]
				ifFalse: [
					(item isKindOf: PbRelease)
						ifTrue: [ item state ifNil: [ '' ] ]
						ifFalse: [ '' ] ] ] weight: 0.25;
		column: 'Owner' text: [ :item |
			((item respondsTo: #owner) and: [ item owner notNil ])
				ifTrue: [ item owner gtDisplayString ]
				ifFalse: [ '' ] ] weight: 0.3;
		column: 'Timeframe' text: [ :item |
			((item respondsTo: #timeframe) and: [ item timeframe notNil ])
				ifTrue: [ item timeframe gtDisplayString ]
				ifFalse: [ '' ] ] weight: 0.3
]

{ #category : 'views' }
PbClient >> gtReleasesFor: aView [
	<gtView>
	^ aView forward
		title: 'Releases';
		priority: 8;
		object: [ PbReleasesGroup withAll: self activeReleases ];
		view: #gtViewReleasesFor:
]

{ #category : 'as yet unclassified' }
PbClient >> gtSpotterForFeature: aSearch [
	<gtSearch>
	^ aSearch list
		title: 'Features';
		priority: 9;
		items: [ self listFeatures ];
		itemsLimit: Float infinity;
		itemName: #name;
		sendCategory: [ :aCategory :aStep :thisSearch | PbFeaturesGroup withAll: aCategory items contents ];
		filterBySubstring
]

{ #category : 'as yet unclassified' }
PbClient >> gtSpotterForObjective: aSearch [
	<gtSearch>
	^ aSearch list
		title: 'Objectives';
		priority: 9;
		items: [ self listObjectives ];
		itemsLimit: Float infinity;
		itemName: #name;
		sendCategory: [ :aCategory :aStep :thisSearch | PbObjectivesGroup withAll: aCategory items contents ];
		filterBySubstring
]

{ #category : 'views' }
PbClient >> gtStuckItemsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Stuck items';
		priority: 7;
		items: [
			| threshold items |
			threshold := DateAndTime now - 14 days.
			items := OrderedCollection new.
			self features items do: [ :f |
				(f updatedAt isNotNil and: [
					(f updatedAt < threshold) and: [
						f archived ~= true ] ])
					ifTrue: [ items add: f ] ].
			self objectives items do: [ :o |
				(o updatedAt isNotNil and: [
					(o updatedAt < threshold) and: [
						(o state ~= 'done') and: [
							o archived ~= true ] ] ])
					ifTrue: [ items add: o ] ].
			items sort: [ :a :b | a updatedAt < b updatedAt ].
			items ];
		column: 'Days stuck' text: [ :item | 
			((DateAndTime now - item updatedAt) days) asString, 'd' ] weight: 0.1;
		column: 'Type' text: [ :item |
			(item isKindOf: PbObjective)
				ifTrue: [ 'Objective' ]
				ifFalse: [ 'Feature' ] ] weight: 0.1;
		column: 'Name' text: #name weight: 0.4;
		column: 'Status' text: [ :item | item status gtDisplayString ] weight: 0.15;
		column: 'Owner' text: [ :item | item owner gtDisplayString ] weight: 0.25
]

{ #category : 'accessing' }
PbClient >> initialize [
	super initialize.

	self baseUrl: self defaultBaseUrl
]

{ #category : 'accessing' }
PbClient >> initializeClient [
	| aClient |
	aClient := ZnClient new.
	aClient forJsonREST.
	aClient headerAt: 'user-agent' put: 'PBAPIClient'.
	aClient headerAt: 'X-Version' put: '1'.
	aClient timeout: 60.
	aClient setBearerAuthentication: apiKey.
	"aClient beOneShot."
	^ aClient
]

{ #category : 'api' }
PbClient >> listFeatureReleaseAssignments [
	^ PbListFeatureReleaseAssignmentsAPIClient new
		client: self;
		perform
]

{ #category : 'accessing' }
PbClient >> listFeatures [
	^ PbListFeaturesAPIClient new
		client: self;
		perform
]

{ #category : 'as yet unclassified' }
PbClient >> listObjectives [
	^ PbListObjectivesAPIClient new
		client: self;
		perform
]

{ #category : 'api' }
PbClient >> listReleaseGroups [
	^ PbListReleaseGroupsAPIClient new
		client: self;
		perform
]

{ #category : 'api' }
PbClient >> listReleases [
	^ PbListReleasesAPIClient new
		client: self;
		perform
]

{ #category : 'accessing' }
PbClient >> objectives [
	^ objectives ifNil: [ objectives := self listObjectives ]
]

{ #category : 'accessing' }
PbClient >> objectives: anObject [
	objectives := anObject
]

{ #category : 'accessing' }
PbClient >> post: aString withEntity: anEntity [
	| aClient |
	aClient := self initializeClient.
	aClient url: self baseUrl / aString.

	aClient contents: anEntity.

	^ self checkForErrors: aClient post
]

{ #category : 'accessing' }
PbClient >> postFile: aString withEntity: anEntity [
	| aClient |
	aClient := self initializeClient.
	aClient url: self baseUrl / aString.

	aClient entity: anEntity.

	^ self checkForErrors: aClient post
]

{ #category : 'accessing' }
PbClient >> quarterlyReleaseRadar [
	"Returns a dictionary of release buckets for stakeholder reporting:
	 - Launched This Quarter: completed releases with endDate in current quarter
	 - In Progress: currently in-progress releases
	 - Coming Soon: upcoming releases"
	| today quarterStart quarterEnd launched inProgress comingSoon all |
	today := Date today.
	quarterStart := Date year: today year month: ((today monthIndex - 1) // 3 * 3 + 1) day: 1.
	quarterEnd := (Date year: today year month: ((today monthIndex - 1) // 3 * 3 + 3) day: 1) daysInMonth.
	quarterEnd := Date year: today year month: ((today monthIndex - 1) // 3 * 3 + 3) day: quarterEnd.
	
	all := self activeReleases.
	
	launched := all select: [ :r |
		r state = 'completed' and: [
			r timeframe notNil and: [
				r timeframe endDate notNil and: [
					(r timeframe endDate >= quarterStart) and: [ r timeframe endDate <= quarterEnd ] ] ] ] ].
	
	inProgress := all select: [ :r | r state = 'in-progress' ].
	
	comingSoon := all select: [ :r | r state = 'upcoming' ].
	
	^ { 'Launched This Quarter' -> launched . 'In Progress' -> inProgress . 'Coming Soon' -> comingSoon } asOrderedDictionary
]

{ #category : 'accessing' }
PbClient >> releaseGroups [
	^ releaseGroups ifNil: [ releaseGroups := self listReleaseGroups ]
]

{ #category : 'accessing' }
PbClient >> releaseGroups: anObject [
	releaseGroups := anObject
]

{ #category : 'accessing' }
PbClient >> releases [
	^ releases ifNil: [ releases := self listReleases ]
]

{ #category : 'accessing' }
PbClient >> releases: anObject [
	releases := anObject
]

{ #category : 'api - roadmap' }
PbClient >> releasesByGroupId [
	"Dictionary mapping groupId -> OrderedCollection of PbRelease.
	Built from releases that have a releaseGroupId."
	| result |
	result := Dictionary new.
	self releases items do: [ :rel |
		| groupId |
		groupId := rel releaseGroupId.
		groupId ifNotNil: [
			(result at: groupId ifAbsentPut: [ OrderedCollection new ]) add: rel ] ].
	^ result
]
