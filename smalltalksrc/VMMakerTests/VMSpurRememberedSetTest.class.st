Class {
	#name : #VMSpurRememberedSetTest,
	#superclass : #VMSpurInitializedOldSpaceTest,
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #'tests - from old to new' }
VMSpurRememberedSetTest >> testFreeRememberedOldObjectShouldForgetIt [

	| oldObjectAddress rememberedObjectAddress |
	
	"Create a young object and reference it from the old object"
	oldObjectAddress := self newOldSpaceObjectWithSlots: 1.
	rememberedObjectAddress := self newZeroSizedObject.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: rememberedObjectAddress.
	
	self assert: (memory isRemembered: oldObjectAddress).
	
	memory freeObject: oldObjectAddress.
	
	self deny: (memory isRemembered: oldObjectAddress).

]

{ #category : #'tests - from old to perm' }
VMSpurRememberedSetTest >> testMoveToPermSpaceObjectWithOldObjectShouldNotUseNewRememberedSet [

	| oldObjectAddress permObjectAddress referencedOldObjectAddress |
	
	"Create a young object and reference it from perm object"
	oldObjectAddress := self newOldByteObjectOfSize: 1.
	referencedOldObjectAddress := self newOldSpaceObjectWithSlots: 0.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: referencedOldObjectAddress.
	
	self assert: memory fromOldSpaceRememberedSet rememberedSetSize equals: 0.
		
	permObjectAddress := memory moveToPermSpace: oldObjectAddress.
	
	self assert: memory fromOldSpaceRememberedSet rememberedSetSize equals: 0.

]

{ #category : #'tests - from perm to old' }
VMSpurRememberedSetTest >> testMoveToPermSpaceObjectWithOldObjectShouldRememberPermObject [

	| permObjectAddress oldObjectAddress referencedOldObjectAddress |

	"Create a young object and reference it from perm object"
	oldObjectAddress := self newOldSpaceObjectWithSlots: 1.
	referencedOldObjectAddress := self newOldSpaceObjectWithSlots: 0.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: referencedOldObjectAddress.
	
	self deny: (memory isRemembered: oldObjectAddress).
	self deny: (memory isRemembered: referencedOldObjectAddress).
	
	permObjectAddress := memory moveToPermSpace: oldObjectAddress.

	self assert: (memory isRemembered: permObjectAddress).
	self deny: (memory isRemembered: referencedOldObjectAddress).

]

{ #category : #'tests - from perm to old' }
VMSpurRememberedSetTest >> testMoveToPermSpaceObjectWithOldObjectShouldUpdateOldRememberedSet [

	| oldObjectAddress permObjectAddress referencedOldObjectAddress |
	
	"Create a young object and reference it from perm object"
	oldObjectAddress := self newOldSpaceObjectWithSlots: 1.
	referencedOldObjectAddress := self newOldSpaceObjectWithSlots: 0.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: referencedOldObjectAddress.
	
	self assert: memory fromPermSpaceRememberedSet rememberedSetSize equals: 0.
		
	permObjectAddress := memory moveToPermSpace: oldObjectAddress.
	
	self assert: memory fromPermSpaceRememberedSet rememberedSetSize equals: 1.
	self assert: (memory fromPermSpaceRememberedSet objectAt: 0) equals: permObjectAddress.

]

{ #category : #'tests - from perm to new' }
VMSpurRememberedSetTest >> testMoveToPermSpaceRememberedObjectShouldBeRememberedToo [

	| oldObjectAddress rememberedObjectAddress permObjectAddress |
	
	"Create a young object and reference it from the old object"
	oldObjectAddress := self newOldSpaceObjectWithSlots: 1.	
	rememberedObjectAddress := self newZeroSizedObject.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: rememberedObjectAddress.
		
	permObjectAddress := memory moveToPermSpace: oldObjectAddress.
	
	self deny: (memory isRemembered: oldObjectAddress).
	self assert: (memory isRemembered: permObjectAddress).

]

{ #category : #'tests - from perm to new' }
VMSpurRememberedSetTest >> testMoveToPermSpaceRememberedObjectShouldUpdateNewRememberedSet [

	| oldObjectAddress rememberedObjectAddress permObjectAddress |
	
	"Create a young object and reference it from the old object"
	oldObjectAddress := self newOldSpaceObjectWithSlots: 1.	
	rememberedObjectAddress := self newZeroSizedObject.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: rememberedObjectAddress.
	
	self assert: (memory fromOldSpaceRememberedSet objectAt: 0) equals: oldObjectAddress.
		
	permObjectAddress := memory moveToPermSpace: oldObjectAddress.
	
	self assert: (memory fromPermSpaceRememberedSet objectAt: 0) equals: permObjectAddress.

]

{ #category : #tests }
VMSpurRememberedSetTest >> testOldObjectIsNotRemembered [

	| oldObjectAddress |
	
	oldObjectAddress := self newOldSpaceObjectWithSlots: 0.
	self deny: (memory isRemembered: oldObjectAddress).
]

{ #category : #tests }
VMSpurRememberedSetTest >> testOverflowRememberedSetShouldMakeItGrow [

	| oldObjectRootAddress originalLimit youngObjectAddress |
	originalLimit := memory getFromOldSpaceRememberedSet rememberedSetLimit.

	"Create as many objects for the remembered set + 1"
	oldObjectRootAddress := self newOldSpaceObjectWithSlots: originalLimit + 1.
	1 to: originalLimit + 1 do: [ :i | 
		memory
			storePointer: i - 1
			ofObject: oldObjectRootAddress
			withValue: (self newObjectWithSlots: 1).
	].

	"Flush them to the old space"
	memory coInterpreter method: oldObjectRootAddress.
	memory flushNewSpace.
	
	"Make old objects reference a young object"
	youngObjectAddress := self newZeroSizedObject.
	1 to: originalLimit + 1 do: [ :i | | oldObjectAddress |
		oldObjectAddress := memory fetchPointer: i - 1 ofObject: oldObjectRootAddress.
		memory storePointer: 0
			ofObject: oldObjectAddress
			withValue: youngObjectAddress ].

	self assert: memory getFromOldSpaceRememberedSet rememberedSetLimit equals: originalLimit * 2
]

{ #category : #tests }
VMSpurRememberedSetTest >> testStoreOldObjectInOldObjectShouldNotRememberAnyone [

	| oldObjectAddress storedOldObjectAddress |

	"Create a old object and reference it from old object"
	storedOldObjectAddress := self newOldSpaceObjectWithSlots: 0.
	oldObjectAddress := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: storedOldObjectAddress.
	
	self deny: (memory isRemembered: oldObjectAddress).
	self deny: (memory isRemembered: storedOldObjectAddress).
]

{ #category : #'tests - from perm to old' }
VMSpurRememberedSetTest >> testStoreOldObjectInPermObjectShouldRememberPermObject [

	| permObjectAddress oldObjectAddress |

	"Create a old object and reference it from perm object"
	permObjectAddress := self newOldSpaceObjectWithSlots: 1.
	permObjectAddress := memory moveToPermSpace: permObjectAddress.
	
	oldObjectAddress := self newOldSpaceObjectWithSlots: 0.
	memory storePointer: 0 ofObject: permObjectAddress withValue: oldObjectAddress.
	
	self assert: (memory isRemembered: permObjectAddress).
	self deny: (memory isRemembered: oldObjectAddress).
]

{ #category : #tests }
VMSpurRememberedSetTest >> testStoreOldObjectInYoungObjectShouldNotRememberAnyone [

	| oldObjectAddress youngObjectAddress |

	"Create a old object and reference it from young object"
	oldObjectAddress := self newOldSpaceObjectWithSlots: 0.
	youngObjectAddress := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectAddress withValue: oldObjectAddress.
	
	self deny: (memory isRemembered: oldObjectAddress).
	self deny: (memory isRemembered: youngObjectAddress).
]

{ #category : #'tests - from old to perm' }
VMSpurRememberedSetTest >> testStorePermObjectInOldObjectShouldNotRememberAnyone [

	| permObjectAddress oldObjectAddress |

	"Create a perm object and reference it from old object"
	permObjectAddress := self newPermanentObjectWithSlots: 0.
	oldObjectAddress := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: permObjectAddress.
	
	self deny: (memory isRemembered: permObjectAddress).
	self deny: (memory isRemembered: oldObjectAddress).
]

{ #category : #'tests - from perm to perm' }
VMSpurRememberedSetTest >> testStorePermObjectInPermObjectShouldNotRememberAnyone [

	| permObjectAddress referencedPermObjectAddress |

	"Create a perm object and reference it from perm object"
	permObjectAddress := self newPermanentObjectWithSlots: 1.
	referencedPermObjectAddress := self newPermanentObjectWithSlots: 0.
	memory storePointer: 0 ofObject: permObjectAddress withValue: referencedPermObjectAddress.
	
	self deny: (memory isRemembered: permObjectAddress).
	self deny: (memory isRemembered: referencedPermObjectAddress).
]

{ #category : #'tests - from new to perm' }
VMSpurRememberedSetTest >> testStorePermObjectInYoungObjectShouldNotRememberAnyone [

	| permObjectAddress youngObjectAddress |

	"Create a perm object and reference it from young object"
	permObjectAddress := self newPermanentObjectWithSlots: 0.
	youngObjectAddress := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectAddress withValue: permObjectAddress.
	
	self deny: (memory isRemembered: permObjectAddress).
	self deny: (memory isRemembered: youngObjectAddress).
]

{ #category : #tests }
VMSpurRememberedSetTest >> testStoreYoungAndOldObjectInPermObjectShouldRememberPermObject [

	| permObjectAddress oldObjectAddress youngObjectAddress |

	"Create a old object and reference it from perm object"
	permObjectAddress := self newPermanentObjectWithSlots: 2.
	oldObjectAddress := self newOldSpaceObjectWithSlots: 0.
	youngObjectAddress := self newZeroSizedObject.
	memory storePointer: 0 ofObject: permObjectAddress withValue: youngObjectAddress.
	memory storePointer: 1 ofObject: permObjectAddress withValue: oldObjectAddress.

	"Check flags"	
	self assert: (memory isRemembered: permObjectAddress).
	self deny: (memory isRemembered: oldObjectAddress).
	self deny: (memory isRemembered: youngObjectAddress).

	"Check sets"	
	self assert: memory fromOldSpaceRememberedSet rememberedSetSize equals: 0.
	
	self assert: memory fromPermSpaceRememberedSet rememberedSetSize equals: 1.
	self assert: (memory fromPermSpaceRememberedSet objectAt: 0) equals: permObjectAddress.

]

{ #category : #tests }
VMSpurRememberedSetTest >> testStoreYoungObjectInOldObjectShouldRememberOldObject [

	| oldObjectAddress youngObjectAddress |
	
	"Create a young object and reference it from the old object"
	youngObjectAddress := self newZeroSizedObject.
	oldObjectAddress := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: youngObjectAddress.
	
	self assert: (memory isRemembered: oldObjectAddress).
	self deny: (memory isRemembered: youngObjectAddress).
]

{ #category : #tests }
VMSpurRememberedSetTest >> testStoreYoungObjectInPermObjectShouldRememberPermObject [

	| permObjectAddress youngObjectAddress |

	"Create a young object and reference it from perm object"
	youngObjectAddress := self newZeroSizedObject.
	permObjectAddress := self newPermanentByteObjectOfSize: 1.
	memory storePointer: 0 ofObject: permObjectAddress withValue: youngObjectAddress.
	
	self assert: (memory isRemembered: permObjectAddress).
	self deny: (memory isRemembered: youngObjectAddress).
]

{ #category : #tests }
VMSpurRememberedSetTest >> testStoreYoungObjectInYoungObjectShouldNotRememberAnyone [

	| youngObjectAddress storedYoungObjectAddress |
	
	"Create a young object and reference it from the young object"
	storedYoungObjectAddress := self newZeroSizedObject.
	youngObjectAddress := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectAddress withValue: storedYoungObjectAddress.
	
	self deny: (memory isRemembered: storedYoungObjectAddress).
	self deny: (memory isRemembered: youngObjectAddress).
]

{ #category : #tests }
VMSpurRememberedSetTest >> testYoungObjectIsNotRemembered [

	| newObjectAddress |
	newObjectAddress := self newObjectWithSlots: 1.

	self deny: (memory isRemembered: newObjectAddress).
]
