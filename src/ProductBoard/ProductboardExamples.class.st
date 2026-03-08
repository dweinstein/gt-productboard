Class {
	#name : 'ProductboardExamples',
	#superclass : 'Object',
	#category : 'ProductBoard-Examples',
	#package : 'ProductBoard',
	#tag : 'Examples'
}

{ #category : 'examples' }
ProductboardExamples >> apiTokenExample [
	<gtExample>
	<noTest>
	| filePath token |
	filePath := FileLocator home / '.secrets' / 'productboard-token.txt'.
	token := filePath contents trimBoth.
	^ token
]

{ #category : 'examples' }
ProductboardExamples >> objectives [
	<gtExample>
	<noTest>
	| client |
	client := self simpleClient.
	self assert: client objectives isNotEmpty.
	^ client objectives
]

{ #category : 'examples' }
ProductboardExamples >> simpleClient [
	<gtExample>
	<noTest>
	| token |
	token := self apiTokenExample.
	^ PbClient withApiKeyFromFile
]

{ #category : 'examples' }
ProductboardExamples >> simpleExample [
	<gtExample>
	<noTest>
	| client |
	client := self simpleClient.
	self assert: client features size > 0.
	^ client
]
