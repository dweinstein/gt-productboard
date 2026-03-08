Class {
	#name : 'ProductboardMockExamples',
	#superclass : 'Object',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'helpers' }
ProductboardMockExamples >> bucketNameFor: anItem today: today [
	"Delegate to PbBoardElement's bucketing logic"
	^ PbBoardElement bucketNameFor: anItem today: today
]

{ #category : 'examples - infrastructure' }
ProductboardMockExamples >> clientPropagation [
	<gtExample>
	"Verify that setting client on a group propagates to items"
	| group mockClient |
	group := self featuresGroup.
	mockClient := PbClient new.
	group client: mockClient.
	self assert: group client equals: mockClient.
	group items do: [ :each |
		self assert: each client equals: mockClient ].
	^ group
]

{ #category : 'examples - infrastructure' }
ProductboardMockExamples >> errorHandling [
	<gtExample>
	"Verify checkForErrors: passes clean responses and signals PbError for API errors"
	| client clean errorResponse caught |
	client := PbClient new.
	
	"Clean response passes through"
	clean := Dictionary new at: 'data' put: #(); yourself.
	self assert: (client checkForErrors: clean) equals: clean.
	
	"Non-dict passes through"
	self assert: (client checkForErrors: 'string') equals: 'string'.
	
	"Error response raises PbError"
	errorResponse := Dictionary new
		at: 'error' put: (Dictionary new at: 'message' put: 'Unauthorized'; yourself);
		yourself.
	caught := false.
	[ client checkForErrors: errorResponse ]
		on: PbError do: [ :e | caught := true.
			self assert: e messageText equals: 'Unauthorized' ].
	self assert: caught.
	
	^ client
]

{ #category : 'examples - entities' }
ProductboardMockExamples >> featureFromDictionary [
	<gtExample>
	| dict feature |
	dict := Dictionary new
		at: 'id' put: 'feat-1';
		at: 'name' put: 'Dark Mode';
		at: 'description' put: 'Add dark mode support';
		at: 'createdAt' put: '2025-06-15T10:30:00Z';
		at: 'owner' put: (Dictionary new at: 'email' put: 'bob@co.com'; at: 'name' put: 'Bob'; yourself);
		at: 'status' put: (Dictionary new at: 'id' put: 's1'; at: 'name' put: 'Planned'; yourself);
		yourself.
	feature := PbFeature from: dict.
	self assert: feature name equals: 'Dark Mode'.
	self assert: feature owner class equals: PbOwner.
	self assert: feature owner email equals: 'bob@co.com'.
	self assert: feature status class equals: PbStatus.
	self assert: feature status name equals: 'Planned'.
	self assert: feature createdAt class equals: DateAndTime.
	self assert: feature rawData isNotNil.
	^ feature
]

{ #category : 'examples - views' }
ProductboardMockExamples >> featuresByStatus [
	<gtExample>
	"Pipeline view: features grouped by status"
	| group grouped |
	group := self featuresGroup.
	grouped := group items groupedBy: [ :each | each status gtDisplayString ].
	self assert: grouped keys size equals: 3.
	self assert: (grouped at: 'Planned') size equals: 2.
	self assert: (grouped at: 'In Progress') size equals: 1.
	self assert: (grouped at: 'Done') size equals: 1.
	^ group
]

{ #category : 'examples - groups' }
ProductboardMockExamples >> featuresGroup [
	<gtExample>
	| response group |
	response := Dictionary new at: 'data' put: self sampleFeatureData; yourself.
	group := PbFeaturesGroup from: response.
	self assert: group size equals: 4.
	self assert: group first class equals: PbFeature.
	self assert: group first owner class equals: PbOwner.
	self assert: group first status class equals: PbStatus.
	^ group
]

{ #category : 'examples' }
ProductboardMockExamples >> featuresNowNextLater [
	<gtExample>
	"Board view: features bucketed into Now / Next / Later / Done / No timeframe"
	| response group today buckets |
	response := Dictionary new at: 'data' put: self sampleFeaturesWithTimeframes; yourself.
	group := PbFeaturesGroup from: response.
	self assert: group size equals: 6.
	
	"Verify timeframes deserialized correctly"
	self assert: (group items first timeframe isKindOf: PbTimeframe).
	self assert: group items first timeframe startDate notNil.
	
	"Verify bucketing"
	today := Date today.
	buckets := group items groupedBy: [ :f | self bucketNameFor: f today: today ].
	
	self assert: (buckets at: 'Now' ifAbsent: [ #() ]) size equals: 2.
	self assert: (buckets at: 'Next' ifAbsent: [ #() ]) size equals: 1.
	self assert: (buckets at: 'Later' ifAbsent: [ #() ]) size equals: 1.
	self assert: (buckets at: 'Done' ifAbsent: [ #() ]) size equals: 1.
	self assert: (buckets at: 'No timeframe' ifAbsent: [ #() ]) size equals: 1.
	
	"Verify board element builds"
	self assert: group buildNowNextLaterElement children size equals: 5.
	
	^ group
]

{ #category : 'examples - client' }
ProductboardMockExamples >> mockClient [
	<gtExample>
	"A PbClient with mock data injected — no API calls needed"
	| client |
	client := PbClient new.
	client features: self featuresGroup.
	client objectives: self objectivesGroup.
	self assert: client features size equals: 4.
	self assert: client objectives size equals: 4.
	^ client
]

{ #category : 'examples' }
ProductboardMockExamples >> objectiveFromDictionary [
	<gtExample>
	| dict obj |
	dict := Dictionary new
		at: 'id' put: 'obj-1';
		at: 'name' put: 'Improve Retention';
		at: 'state' put: 'on_track';
		at: 'timeframe' put: (Dictionary new at: 'startDate' put: '2025-04-01'; at: 'endDate' put: '2025-06-30'; at: 'granularity' put: 'quarter'; yourself);
		at: 'archived' put: false;
		at: 'createdAt' put: '2025-01-10T08:00:00Z';
		at: 'updatedAt' put: '2025-06-01T14:22:00Z';
		at: 'owner' put: (Dictionary new at: 'email' put: 'carol@co.com'; yourself);
		at: 'status' put: (Dictionary new at: 'name' put: 'Active'; yourself);
		yourself.
	obj := PbObjective from: dict.
	self assert: obj name equals: 'Improve Retention'.
	self assert: obj state equals: 'on_track'.
	self assert: obj timeframe class equals: PbTimeframe.
	self assert: obj timeframe startDate equals: (Date fromString: '2025-04-01').
	self assert: obj owner class equals: PbOwner.
	self assert: obj status class equals: PbStatus.
	self assert: obj createdAt class equals: DateAndTime.
	self assert: obj updatedAt class equals: DateAndTime.
	^ obj
]

{ #category : 'examples - views' }
ProductboardMockExamples >> objectivesByState [
	<gtExample>
	"Health check: objectives grouped by state"
	| group grouped |
	group := self objectivesGroup.
	grouped := group items groupedBy: [ :each | each state ifNil: [ 'unset' ] ].
	self assert: grouped keys size equals: 3.
	self assert: (grouped at: 'on_track') size equals: 2.
	self assert: (grouped at: 'at_risk') size equals: 1.
	self assert: (grouped at: 'off_track') size equals: 1.
	^ group
]

{ #category : 'examples' }
ProductboardMockExamples >> objectivesByTimeframe [
	<gtExample>
	"Quarterly breakdown: objectives grouped by timeframe"
	| group grouped |
	group := self objectivesGroup.
	grouped := group items groupedBy: [ :each | each timeframe ifNil: [ 'unset' ] ifNotNil: [ :tf | tf gtDisplayString ] ].
	self assert: grouped keys size equals: 2.
	self assert: (grouped at: 'April 2025 – June 2025 (quarter)') size equals: 2.
	self assert: (grouped at: 'July 2025 – September 2025 (quarter)') size equals: 2.
	^ group
]

{ #category : 'examples - groups' }
ProductboardMockExamples >> objectivesGroup [
	<gtExample>
	| response group |
	response := Dictionary new at: 'data' put: self sampleObjectiveData; yourself.
	group := PbObjectivesGroup from: response.
	self assert: group size equals: 4.
	self assert: group first class equals: PbObjective.
	self assert: group first owner class equals: PbOwner.
	self assert: group first updatedAt class equals: DateAndTime.
	^ group
]

{ #category : 'examples - value objects' }
ProductboardMockExamples >> ownerFromDictionary [
	<gtExample>
	| dict owner |
	dict := Dictionary new
		at: 'id' put: '123';
		at: 'email' put: 'alice@example.com';
		at: 'name' put: 'Alice';
		yourself.
	owner := PbOwner from: dict.
	self assert: owner class equals: PbOwner.
	self assert: owner email equals: 'alice@example.com'.
	self assert: owner name equals: 'Alice'.
	self assert: owner gtDisplayString equals: 'alice@example.com'.
	self assert: (PbOwner from: owner) == owner description: 'Idempotent'.
	^ owner
]

{ #category : 'examples - views' }
ProductboardMockExamples >> ownerWorkload [
	<gtExample>
	"All items grouped by owner email"
	| client allItems grouped |
	client := self mockClient.
	allItems := OrderedCollection new.
	client features items do: [ :f | allItems add: ('Feature' -> f) ].
	client objectives items do: [ :o | allItems add: ('Objective' -> o) ].
	grouped := allItems groupedBy: [ :assoc | assoc value owner gtDisplayString ].
	self assert: grouped keys size equals: 3.
	self assert: (grouped at: 'alice@co.com') size equals: 4.
	self assert: (grouped at: 'bob@co.com') size equals: 2.
	self assert: (grouped at: 'carol@co.com') size equals: 2.
	^ grouped
]

{ #category : 'examples - views' }
ProductboardMockExamples >> recentlyChanged [
	<gtExample>
	"Objectives sorted by updatedAt descending"
	| client recent |
	client := self mockClient.
	recent := (client objectives items
		select: [ :each | each updatedAt isNotNil ])
		sorted: [ :a :b | a updatedAt > b updatedAt ].
	self assert: recent isNotEmpty.
	self assert: recent first updatedAt >= recent last updatedAt.
	^ recent
]

{ #category : 'fixtures' }
ProductboardMockExamples >> sampleFeatureData [
	"Raw feature dictionaries for building test groups"
	^ {
		Dictionary new at: 'id' put: 'f1'; at: 'name' put: 'Dark Mode';
			at: 'status' put: (Dictionary new at: 'name' put: 'Planned'; yourself);
			at: 'owner' put: (Dictionary new at: 'email' put: 'alice@co.com'; yourself);
			at: 'createdAt' put: '2025-03-01T00:00:00Z'; yourself.
		Dictionary new at: 'id' put: 'f2'; at: 'name' put: 'Search';
			at: 'status' put: (Dictionary new at: 'name' put: 'In Progress'; yourself);
			at: 'owner' put: (Dictionary new at: 'email' put: 'bob@co.com'; yourself);
			at: 'createdAt' put: '2025-03-15T00:00:00Z'; yourself.
		Dictionary new at: 'id' put: 'f3'; at: 'name' put: 'Export CSV';
			at: 'status' put: (Dictionary new at: 'name' put: 'Planned'; yourself);
			at: 'owner' put: (Dictionary new at: 'email' put: 'alice@co.com'; yourself);
			at: 'createdAt' put: '2025-04-01T00:00:00Z'; yourself.
		Dictionary new at: 'id' put: 'f4'; at: 'name' put: 'Notifications';
			at: 'status' put: (Dictionary new at: 'name' put: 'Done'; yourself);
			at: 'owner' put: (Dictionary new at: 'email' put: 'carol@co.com'; yourself);
			at: 'createdAt' put: '2025-02-01T00:00:00Z'; yourself
	}
]

{ #category : 'fixtures' }
ProductboardMockExamples >> sampleFeaturesWithTimeframes [
	"Features spanning Now, Next, Later, Done, and No timeframe buckets"
	| today |
	today := Date today.
	^ {
		"Now - active timeframe"
		Dictionary new 
			at: 'id' put: 'ft1'; at: 'name' put: 'SSO Integration';
			at: 'description' put: '<p>Enable single sign-on via SAML and OIDC for enterprise customers. Includes IdP-initiated and SP-initiated flows with JIT provisioning.</p>';
			at: 'status' put: (Dictionary new at: 'name' put: 'In progress'; yourself);
			at: 'owner' put: (Dictionary new at: 'email' put: 'alice@co.com'; at: 'name' put: 'Alice'; yourself);
			at: 'timeframe' put: (Dictionary new 
				at: 'startDate' put: (today addDays: -15) yyyymmdd;
				at: 'endDate' put: (today addDays: 45) yyyymmdd;
				at: 'granularity' put: 'quarter'; yourself);
			at: 'createdAt' put: '2026-01-10T00:00:00Z';
			at: 'updatedAt' put: '2026-03-01T00:00:00Z'; yourself.
		Dictionary new
			at: 'id' put: 'ft2'; at: 'name' put: 'Audit Log';
			at: 'description' put: '<p>Comprehensive audit trail for all user and system actions. Searchable, filterable, and exportable for compliance reporting.</p>';
			at: 'status' put: (Dictionary new at: 'name' put: 'In progress'; yourself);
			at: 'owner' put: (Dictionary new at: 'email' put: 'bob@co.com'; at: 'name' put: 'Bob'; yourself);
			at: 'timeframe' put: (Dictionary new
				at: 'startDate' put: (today addDays: -30) yyyymmdd;
				at: 'endDate' put: (today addDays: 30) yyyymmdd;
				at: 'granularity' put: 'quarter'; yourself);
			at: 'createdAt' put: '2026-01-15T00:00:00Z';
			at: 'updatedAt' put: '2026-02-28T00:00:00Z'; yourself.
		"Next - starts within 90 days"
		Dictionary new
			at: 'id' put: 'ft3'; at: 'name' put: 'API v2 Migration';
			at: 'description' put: '<p>Migrate all public endpoints from v1 REST to v2 unified entity model. Deprecate legacy endpoints with a 6-month sunset window.</p>';
			at: 'status' put: (Dictionary new at: 'name' put: 'Planned'; yourself);
			at: 'owner' put: (Dictionary new at: 'email' put: 'alice@co.com'; at: 'name' put: 'Alice'; yourself);
			at: 'timeframe' put: (Dictionary new
				at: 'startDate' put: (today addDays: 30) yyyymmdd;
				at: 'endDate' put: (today addDays: 120) yyyymmdd;
				at: 'granularity' put: 'quarter'; yourself);
			at: 'createdAt' put: '2026-02-01T00:00:00Z';
			at: 'updatedAt' put: '2026-02-20T00:00:00Z'; yourself.
		"Later - starts 90+ days out"
		Dictionary new
			at: 'id' put: 'ft4'; at: 'name' put: 'Multi-tenancy';
			at: 'description' put: '<p>Full tenant isolation with per-tenant data partitioning, custom domains, and independent upgrade schedules for managed service customers.</p>';
			at: 'status' put: (Dictionary new at: 'name' put: 'Idea'; yourself);
			at: 'owner' put: (Dictionary new at: 'email' put: 'carol@co.com'; at: 'name' put: 'Carol'; yourself);
			at: 'timeframe' put: (Dictionary new
				at: 'startDate' put: (today addDays: 180) yyyymmdd;
				at: 'endDate' put: (today addDays: 270) yyyymmdd;
				at: 'granularity' put: 'quarter'; yourself);
			at: 'createdAt' put: '2026-02-05T00:00:00Z';
			at: 'updatedAt' put: '2026-02-10T00:00:00Z'; yourself.
		"Done - ended in the past"
		Dictionary new
			at: 'id' put: 'ft5'; at: 'name' put: 'Dark Mode';
			at: 'description' put: '<p>System-wide dark theme respecting OS preference with manual override. Covers all views including charts and code blocks.</p>';
			at: 'status' put: (Dictionary new at: 'name' put: 'Launched'; yourself);
			at: 'owner' put: (Dictionary new at: 'email' put: 'bob@co.com'; at: 'name' put: 'Bob'; yourself);
			at: 'timeframe' put: (Dictionary new
				at: 'startDate' put: (today addDays: -120) yyyymmdd;
				at: 'endDate' put: (today addDays: -30) yyyymmdd;
				at: 'granularity' put: 'quarter'; yourself);
			at: 'createdAt' put: '2025-10-01T00:00:00Z';
			at: 'updatedAt' put: '2026-01-15T00:00:00Z'; yourself.
		"No timeframe"
		Dictionary new
			at: 'id' put: 'ft6'; at: 'name' put: 'Webhooks v2';
			at: 'description' put: '<p>Event-driven webhook system with retry logic, payload signing, and a management UI for configuring endpoints and filtering events.</p>';
			at: 'status' put: (Dictionary new at: 'name' put: 'Candidate'; yourself);
			at: 'owner' put: (Dictionary new at: 'email' put: 'carol@co.com'; at: 'name' put: 'Carol'; yourself);
			at: 'createdAt' put: '2026-02-20T00:00:00Z';
			at: 'updatedAt' put: '2026-03-01T00:00:00Z'; yourself
	}
]

{ #category : 'fixtures' }
ProductboardMockExamples >> sampleObjectiveData [
	"Raw objective dictionaries for building test groups"
	^ {
		Dictionary new at: 'id' put: 'o1'; at: 'name' put: 'Improve Retention';
			at: 'state' put: 'on_track';
			at: 'timeframe' put: (Dictionary new at: 'startDate' put: '2025-04-01'; at: 'endDate' put: '2025-06-30'; at: 'granularity' put: 'quarter'; yourself);
			at: 'archived' put: false;
			at: 'owner' put: (Dictionary new at: 'email' put: 'alice@co.com'; yourself);
			at: 'status' put: (Dictionary new at: 'name' put: 'Active'; yourself);
			at: 'createdAt' put: '2025-01-01T00:00:00Z';
			at: 'updatedAt' put: DateAndTime now printString; yourself.
		Dictionary new at: 'id' put: 'o2'; at: 'name' put: 'Expand Market';
			at: 'state' put: 'at_risk';
			at: 'timeframe' put: (Dictionary new at: 'startDate' put: '2025-04-01'; at: 'endDate' put: '2025-06-30'; at: 'granularity' put: 'quarter'; yourself);
			at: 'archived' put: false;
			at: 'owner' put: (Dictionary new at: 'email' put: 'bob@co.com'; yourself);
			at: 'status' put: (Dictionary new at: 'name' put: 'Active'; yourself);
			at: 'createdAt' put: '2025-01-15T00:00:00Z';
			at: 'updatedAt' put: '2025-01-20T00:00:00Z'; yourself.
		Dictionary new at: 'id' put: 'o3'; at: 'name' put: 'Reduce Churn';
			at: 'state' put: 'off_track';
			at: 'timeframe' put: (Dictionary new at: 'startDate' put: '2025-07-01'; at: 'endDate' put: '2025-09-30'; at: 'granularity' put: 'quarter'; yourself);
			at: 'archived' put: false;
			at: 'owner' put: (Dictionary new at: 'email' put: 'alice@co.com'; yourself);
			at: 'status' put: (Dictionary new at: 'name' put: 'Active'; yourself);
			at: 'createdAt' put: '2025-02-01T00:00:00Z';
			at: 'updatedAt' put: '2024-11-01T00:00:00Z'; yourself.
		Dictionary new at: 'id' put: 'o4'; at: 'name' put: 'Scale Platform';
			at: 'state' put: 'on_track';
			at: 'timeframe' put: (Dictionary new at: 'startDate' put: '2025-07-01'; at: 'endDate' put: '2025-09-30'; at: 'granularity' put: 'quarter'; yourself);
			at: 'archived' put: false;
			at: 'owner' put: (Dictionary new at: 'email' put: 'carol@co.com'; yourself);
			at: 'status' put: (Dictionary new at: 'name' put: 'Active'; yourself);
			at: 'createdAt' put: '2025-03-01T00:00:00Z';
			at: 'updatedAt' put: '2025-06-01T00:00:00Z'; yourself
	}
]

{ #category : 'examples - value objects' }
ProductboardMockExamples >> statusFromDictionary [
	<gtExample>
	| dict status |
	dict := Dictionary new
		at: 'id' put: '456';
		at: 'name' put: 'In Progress';
		yourself.
	status := PbStatus from: dict.
	self assert: status class equals: PbStatus.
	self assert: status name equals: 'In Progress'.
	self assert: status gtDisplayString equals: 'In Progress'.
	^ status
]

{ #category : 'examples - views' }
ProductboardMockExamples >> stuckItems [
	<gtExample>
	"Items not updated in 14+ days, excluding done/archived"
	| client threshold stuck |
	client := self mockClient.
	threshold := DateAndTime now - 14 days.
	stuck := client objectives items select: [ :each |
		each updatedAt isNotNil and: [
			(each updatedAt < threshold) and: [
				(each state ~= 'done') and: [
					each archived ~= true ] ] ] ].
	self assert: stuck isNotEmpty.
	stuck do: [ :item |
		self assert: item state ~= 'done'.
		self assert: item updatedAt < threshold ].
	^ stuck
]

{ #category : 'examples - infrastructure' }
ProductboardMockExamples >> timestampDeserialization [
	<gtExample>
	"Verify that ISO 8601 strings, unix timestamps, and nil all parse correctly"
	| entity |
	entity := PbEntity new.
	self assert: (entity deserializeTime: nil) isNil.
	self assert: (entity deserializeTime: DateAndTime now) class equals: DateAndTime.
	self assert: (entity deserializeTime: 1700000000) class equals: DateAndTime.
	self assert: (entity deserializeTime: '2025-06-15T10:30:00Z') class equals: DateAndTime.
	self assert: (entity deserializeTime: 'not-a-date') equals: 'not-a-date'.
	^ entity
]
