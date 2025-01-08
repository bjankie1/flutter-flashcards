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

- view statistics (e.g. parent)
- access all decks
- modify and add decks

### Classrooms

Classrooms are managed by a teacher who can also delegate the management to other users.
Teacher can add decks to a classroom and group them into categories.
Person can join a classroom having an access to all decks defined there.
Classroom shows separate statistics for a user and teacher.

## Roadmap

### Basics

- [x] Reviews page
  - [x] Select single deck
- [x] Image upload
- [ ] Grouping decks into categories e.g. multiple history lessons for grade 6
  - [ ] Show categories in decks list
  - [ ] Show categories in study page - learn category
  - [ ] Represent categories in statistics
- [ ] Input provided answer with comparison again expectation
- [x] Statistics page details https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md:
  - [x] Cards reviews per day per deck - pie chart
  - [x] Time spent per deck pie chart
  - [x] Time spent stats: average per card, 95th percentile, etc.
  - [x] Reviews per hour of the day - histogram also bar chart with hours on horizontal axis
- [ ] Batch upload
  - [ ] CSV
  - [ ] Anki
- [ ] Improved navigation with deep links
- [ ] Android version
  - [ ] MVE: study, list of decks, stats
  - [ ] Later: Edit decks and cards, collaboration
- [ ] iOS version
- [x] Basic localization support
- [x] widget with locale selector
- [x] persist locale selection in a cookie or something like that
- [x] persist locale selection in user settings
- [x] Left bar for decks -> navigate to cards.
- [x] Dedicated learning view

### Communities

- [ ] Share decks with other users
- [ ] Share stats with parents

### Marketplace and subscriptions

- [ ] Offer deck in the marketplace (https://medium.com/codingmountain-blog/flutter-in-app-purchase-00111a48a1e9)
- [ ] Subscription https://medium.com/codingmountain-blog/flutter-in-app-purchase-00111a48a1e9
- [ ]
