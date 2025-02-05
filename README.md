# flutter_flashcards

## LLM features

There is a potential of leveraging LLM features in areas of cards creation and evaluation.

Some potential features include:

- suggest answer when creating cards
- create a deck based on a text such as an uploaded PDF or Google Doc
- evaluate answer input

## Collaboration features

### Collaborators

User can add multiple other users as collaborators.
Collaborator can be granted permissions to:

- view statistics (e.g. parent, teacher)
- access all decks
- modify and add decks

#### Document structure:

The document structure needs to enable the following operations effectively:

Granting user:

- fetch all shared resources including the receiving user information.
- Revoke grant for single resource.

Receiving user:

- fetch all shared resources including the granting user information.
- secure access to shared resources based on the grant collection structure.

Therefore both the resource identifier and receiving user need to be part of the document path.

The structure proposal:

`sharing/{userId}/resourceType/{resourceId}/grantedTo/{receivingUserId}`

where `resourceType` sub-collection is one of:

- `sharedDecks` - read-only access to decks. `resourceId = deckId`
- `sharedStats` - access to progress statistics (`reviewLog`) of the user.
  `resourceId = 'stats'`

Documents need to include the following field to enable querying:

- `grantedTo` - receiving userId

It will not be possible to fetch information for single resource (ia. deck) due to Firebase
limitation of such structure. At the same time it will be possible to fetch all grants of a user
which is sufficient.
It will be also possible to fetch information for the receiving user using `collectionGroup`
query.

**Operations execution:**

Granting user - fetch all shared resources:

```
collection: sharing/{userId}/sharedDecks
collection: sharing/{userId}/sharedStats
```

Receiving user:

```
collectionGroup: sharedDecks {grantedTo == userId}
security rule:
  read: decks/{userId}/userDecks/{deckId} if exists(shared/$(userId)/sharedDecks/$(deckId)/grantedTo/{request.auth.uid})
  write: shared/{userId}/sharedDecks/{deckId} if isAuthor(userId) && ownDeck(deckId)

collectionGroup: sharedStats {grantedTo == userId}
security rule: 
```

### Classrooms

Classrooms are managed by a teacher who can also delegate the management to other users.
Teacher can add decks to a classroom and group them into categories.
Person can join a classroom having an access to all decks defined there.
Classroom shows separate statistics for a user and teacher.

## Open issues

https://github.com/bjankie1/flutter-flashcards/issues?q=is%3Aopen+is%3Aissue

## Deployment

Region: europe-central2

Deployable artifacts:

- Flutter Web to Firebase hosting
- Functions to Firebase Functions
- Indexes and rules to Firebase firestore
- Storage rules to Firebase Storage

In future:

- Android binary
- iOS binary

### Marketplace and subscriptions

- [ ] Offer deck in the
  marketplace (https://medium.com/codingmountain-blog/flutter-in-app-purchase-00111a48a1e9)
- [ ] Subscription https://medium.com/codingmountain-blog/flutter-in-app-purchase-00111a48a1e9
- [ ]