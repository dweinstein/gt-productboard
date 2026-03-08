Class {
	#name : 'PbReleaseGroupsGroup',
	#superclass : 'PbGroup',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'accessing' }
PbReleaseGroupsGroup class >> itemClass [
	^ PbReleaseGroup
]

{ #category : 'gt views' }
PbReleaseGroupsGroup >> gtViewReleaseGroupsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Release Groups';
		priority: 1;
		items: [ self items sorted: [ :a :b | a name asLowercase < b name asLowercase ] ];
		column: 'Name' text: #name;
		column: 'Archived' text: [ :item | item archived ifNil: [ false ] ] weight: 0.2
]
