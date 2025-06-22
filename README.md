# Apprende flashcards application

## Core Features

### Deck Management
- Create, edit, and delete decks - Organize your learning materials into customizable collections of flashcards.
- Organize decks into groups for better management - Group related decks together to maintain a structured learning environment.
- Set deck options:
  - Daily card limit - Control how many cards you review each day to maintain a sustainable learning pace.
  - New cards daily limit - Manage the introduction of new cards to prevent overwhelming your learning schedule.
  - Maximum review interval - Set the longest time between reviews to ensure consistent learning progress.
- Deck sharing and collaboration:
  - Share decks with other users - Distribute your learning materials with students, colleagues, or study groups.
  - Grant read-only access to decks - Allow others to use your decks while maintaining control over modifications.
  - Revoke access to shared decks - Remove access when collaboration is no longer needed.
  - View list of users with access to your decks - Keep track of who has access to your learning materials.

### Card Creation
- Create single-sided and double-sided cards - Choose between simple question-answer cards or bidirectional learning cards.
- Generate cards from text input - Paste any text content and let the AI analyze it to create relevant flashcards, extracting key concepts and their explanations.
- Quick card creation mode for rapid entry - Capture new words or concepts on the go with a streamlined single-word/phrase input. These quick notes are stored in a dedicated inbox where you can later transform them into proper flashcards by adding the second side (definition, explanation, or translation). Perfect for reading sessions when you want to quickly note unfamiliar terms without interrupting your flow.
- Edit existing cards - Modify card content, format, or settings at any time.
- Move cards between decks - Reorganize your learning materials by transferring cards between different decks.
- Delete cards - Remove unnecessary or outdated cards from your collection.

### Review System
- Spaced repetition system (FSRS) for optimal learning - Advanced algorithm that adapts to your learning patterns to maximize retention.
- Review cards based on:
  - New cards - Start learning fresh content
  - Learning cards - Reinforce recently introduced concepts
  - Review cards - Maintain knowledge of well-learned material
  - Relearning cards - Recover forgotten information
- Track review progress per card and deck - Monitor your learning journey with detailed progress indicators.
- Review cards by:
  - Individual deck - Focus on specific topics
  - Deck group - Study related subjects together
  - All decks - Comprehensive review of all materials
- Record review ratings and time spent - Analyze your learning efficiency and identify areas for improvement.

### Statistics and Progress Tracking
- View review statistics:
  - Number of cards reviewed - Track your daily and overall learning activity.
  - Time spent reviewing - Monitor your study time to maintain a balanced learning schedule.
  - Success rate - Measure your learning effectiveness and identify challenging areas.
- Track progress by:
  - Individual deck - Monitor performance in specific subjects.
  - Deck group - Evaluate progress across related topics.
  - Overall progress - Get a comprehensive view of your learning journey.
- Share statistics with other users (e.g., teachers, parents) - Enable others to monitor and support your learning progress.
- Visual representation of progress through charts - Easily understand your learning patterns through intuitive graphs and visualizations.

### Collaboration Features
- User roles and permissions:
  - Deck owner - Full control over deck content and sharing settings.
  - Collaborator with read access - View and use shared decks without modification rights.
  - Statistics viewer - Monitor learning progress without access to deck content.
- Share decks with other users - Enable collaborative learning environments.
- Share progress statistics - Allow mentors or teachers to track learning outcomes.
- Manage access permissions - Control who can view or use your learning materials.
- View shared decks from other users - Access learning materials shared by collaborators.

## Technical Features

### Data Management
- Firebase Firestore for data storage - Reliable and scalable cloud database for storing all application data.
- Real-time synchronization - Instant updates across all devices and users.
- Offline support - Continue learning even without internet connection.
- Secure access control through Firebase Rules - Protect user data with robust security measures.

### User Interface
- Modern, responsive design - Clean and intuitive interface that works on any device.
- Intuitive navigation - Easy access to all features with minimal learning curve.
- Dark/light theme support - Choose your preferred visual style for comfortable learning.
- Mobile-first approach - Optimized experience for learning on the go.

## Future Features

### LLM Integration
- AI-powered card creation suggestions - Get intelligent recommendations for card content based on your learning goals.
- Automated deck generation from text - Transform any text material into a structured set of flashcards.
- Answer evaluation and feedback - Receive AI-powered assessment of your answers and personalized improvement suggestions.

### Marketplace
- Deck marketplace for sharing and selling decks - Create and distribute premium learning materials.
- Subscription system for premium features - Access advanced features and exclusive content through subscription plans.

## Deployment

### Automated Deployment (Recommended)

The app uses GitHub Actions for automated deployment to Firebase Hosting. Each merge to the main branch triggers:

- ✅ Automated testing
- ✅ Version bumping
- ✅ Firebase Hosting deployment
- ✅ Remote Config updates
- ✅ Deployment notifications

**Setup**: Run `./setup_github_actions.sh` and follow `GITHUB_SETUP.md`

**Live Site**: https://flashcards-521f0.web.app

### Manual Deployment

For manual deployments, see `DEPLOYMENT_WORKFLOW.md` for detailed instructions.

Region: europe-central2

Deployable artifacts:
- Flutter Web to Firebase hosting - Web application accessible from any browser.
- Functions to Firebase Functions - Serverless backend for handling complex operations.
- Indexes and rules to Firebase Firestore - Optimized database structure for efficient queries.
- Storage rules to Firebase Storage - Secure file storage for learning materials.

Future deployments:
- Android binary - Native mobile application for Android devices.
- iOS binary - Native mobile application for iOS devices.

### Marketplace and subscriptions

- [ ] Offer deck in the
  marketplace (https://medium.com/codingmountain-blog/flutter-in-app-purchase-00111a48a1e9)
- [ ] Subscription https://medium.com/codingmountain-blog/flutter-in-app-purchase-00111a48a1e9
- [ ]