# gt-productboard

A [Glamorous Toolkit](https://gtoolkit.com/) client for the [ProductBoard](https://www.productboard.com/) product management platform. Provides domain objects, API clients, strategic views, and interactive kanban boards for exploring product data.

## Installation

```smalltalk
Metacello new
	repository: 'github://dweinstein/gt-productboard/src';
	baseline: 'Productboard';
	load
```

## Setup

Store your ProductBoard API token in `~/.secrets/productboard-token.txt`:

```bash
echo "your-api-token" > ~/.secrets/productboard-token.txt
```

Then create a client:

```smalltalk
client := PbClient withApiKeyFromFile.
```

Alternatively, create a client from clipboard contents:

```smalltalk
"Copy your API token to clipboard first"
client := PbClient withApiKeyFromClipboard.
```

Or set the key directly:

```smalltalk
client := PbClient new apiKey: 'pb_token_...'.
```

## Usage Examples

### Fetching Features and Objectives

Features and objectives are fetched lazily and cached. The API client handles cursor-based pagination automatically.

```smalltalk
client := PbClient withApiKeyFromFile.

"Get all features (auto-paginated)"
client features. "Returns a PbFeaturesGroup"
client features size.

"Get all objectives"
client objectives. "Returns a PbObjectivesGroup"
```

### Inspecting a Feature

Each `PbFeature` exposes status, owner, timeframe, and more:

```smalltalk
feature := client features first.
feature name.
feature status. "Returns a PbStatus"
feature owner. "Returns a PbOwner with email and name"
feature timeframe. "Returns a PbTimeframe with startDate, endDate, granularity"
feature description.
feature archived.
feature updatedAt.
```

### Filtering and Grouping

`PbFeaturesGroup` and `PbObjectivesGroup` extend `PbGroup`, which delegates 73 collection methods (`select:`, `collect:`, `groupedBy:`, etc.):

```smalltalk
"Features grouped by status"
client features items groupedBy: [ :each | each status gtDisplayString ].

"Only planned features"
planned := client features select: [ :f | f status name = 'Planned' ].

"Objectives grouped by state"
client objectives items groupedBy: [ :each | each state ].
```

### Now / Next / Later Bucketing

Bucket features by timeframe into strategic planning categories:

```smalltalk
features := client features.
today := Date today.
buckets := features items groupedBy: [ :f |
	f timeframe isNil
		ifTrue: [ 'No timeframe' ]
		ifFalse: [
			f status name = 'Done'
				ifTrue: [ 'Done' ]
				ifFalse: [
					f timeframe endDate < today
						ifTrue: [ 'Now' ]
						ifFalse: [
							f timeframe startDate <= (today + 90 days)
								ifTrue: [ 'Next' ]
								ifFalse: [ 'Later' ] ] ] ] ].
```

### Finding Stuck Items

Items not updated in 14+ days, excluding done/archived:

```smalltalk
threshold := DateAndTime now - 14 days.
stuck := client objectives items select: [ :each |
	each updatedAt isNotNil and: [
		(each updatedAt < threshold) and: [
			(each state ~= 'done') and: [
				each archived ~= true ] ] ] ].
```

### Owner Workload

Group all items across features and objectives by owner:

```smalltalk
allItems := OrderedCollection new.
client features items do: [ :f | allItems add: ('Feature' -> f) ].
client objectives items do: [ :o | allItems add: ('Objective' -> o) ].
grouped := allItems groupedBy: [ :assoc | assoc value owner gtDisplayString ].
```

### Recently Changed Objectives

```smalltalk
recent := (client objectives items
	select: [ :each | each updatedAt isNotNil ])
	sorted: [ :a :b | a updatedAt > b updatedAt ].
```

## GT Inspector Views

The package provides rich inspector views at every level. Inspect any object to see them.

### PbClient Views

| View | Description |
|------|-------------|
| Features | Columned list of all features |
| Objectives | Columned list of all objectives |
| Feature board | Kanban board of features by status |
| Objectives board | Kanban board of objectives by state |
| Now / Next / Later | Features bucketed by timeframe |
| By owner | All items grouped by owner |
| Recently changed | Items sorted by last update |
| Stuck items | Items not updated in 14+ days |
| Objectives by state | Grouped objective breakdown |
| Objectives by timeframe | Quarterly/monthly timeline |
| Objectives timeline | Visual timeline |

### PbFeaturesGroup Views

| View | Description |
|------|-------------|
| Features | Columned list |
| By status | Grouped by status |
| Board | Kanban board by status |
| Now / Next / Later | Strategic timeframe board |
| By owner | Grouped by owner |

### PbObjectivesGroup Views

| View | Description |
|------|-------------|
| Objectives | Columned list |
| By state | Grouped by state |
| Board | Kanban board by state |
| By timeframe | Quarterly breakdown |
| Timeline | Visual timeline |

### PbFeature / PbObjective Views

Individual entities have detail views including a card element, description, and an "Open in browser" action linking back to ProductBoard.

## Package Structure

| Layer | Classes | Purpose |
|-------|---------|---------|
| Domain | `PbEntity`, `PbFeature`, `PbObjective`, `PbOwner`, `PbStatus`, `PbTimeframe`, `PbInsightStore` | Value objects parsed from API JSON |
| Collections | `PbGroup`, `PbFeaturesGroup`, `PbObjectivesGroup` | Typed collections with 73 delegated methods + GT views |
| API | `PbClient`, `PbEndpointClient`, `PbListFeaturesAPIClient`, `PbListObjectivesAPIClient` | Auto-paginated REST client |
| UI | `PbCardElement`, `PbBoardElement` | Kanban cards and configurable column boards |
| Testing | `ProductboardExamples`, `ProductboardMockExamples` | 4 live + 17 offline executable examples |

## Examples

Run the executable examples in the GT inspector:

```smalltalk
"Live API examples (require token)"
ProductboardExamples new simpleClient.
ProductboardExamples new simpleExample.

"Offline mock examples (no API needed)"
ProductboardMockExamples new featuresByStatus.
ProductboardMockExamples new featuresNowNextLater.
ProductboardMockExamples new objectivesByState.
ProductboardMockExamples new stuckItems.
ProductboardMockExamples new ownerWorkload.
ProductboardMockExamples new recentlyChanged.
```
