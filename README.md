# Apprende flashcards application

## Core Features

### Deck Management
- Create, edit, and delete decks - Organize your learning materials into customizable collections of flashcards.
- Organize decks into groups for better management - Group related decks together to maintain a structured learning environment.
- Set deck options:
  - Daily card limit - Control how many cards you review each day to maintain a sustainable learning pace.
  - New cards daily limit - Manage the introduction of new cards to prevent overwhelming your learning schedule.
  - Maximum review interval - Set the longest time between reviews to ensure consistent learning progress.
- **Deck configuration and customization**:
  - **Card generation guidelines** - Define how AI should generate cards for this specific deck:
    - Front card description - Specify what should appear on the front of cards (e.g., "Show the English word", "Display the mathematical formula")
    - Back card description - Define what should appear on the back of cards (e.g., "Show the Polish translation", "Display the solution steps")
    - Explanation description - Configure what additional explanations should include (e.g., "Include usage examples", "Add pronunciation guide")
  - **Collapsible interface** - Guidelines are hidden by default and can be expanded when needed, keeping the interface clean
  - **Real-time updates** - Changes to guidelines are saved immediately and applied to all future card generation
  - **Context-aware generation** - Guidelines are automatically passed to AI prompts when generating cards from text, reviewing provisionary cards, or creating new cards
- **Multi-language support** - Deck descriptions in any language are automatically translated to English before being sent to AI, ensuring consistent and effective card generation regardless of the user's native language
- Deck sharing and collaboration:
  - Share decks with other users - Distribute your learning materials with students, colleagues, or study groups.
  - Grant read-only access to decks - Allow others to use your decks while maintaining control over modifications.
  - Revoke access to shared decks - Remove access when collaboration is no longer needed.
  - View list of users with access to your decks - Keep track of who has access to your learning materials.

### Card Creation
- Create single-sided and double-sided cards - Choose between simple question-answer cards or bidirectional learning cards.
- Generate cards from text input - Paste any text content and let the AI analyze it to create relevant flashcards, extracting key concepts and their explanations.
- **Deck-specific card generation guidelines** - Define custom instructions for how cards should be generated for each deck:
  - **Front of card description** - Specify what content should appear on the front of cards (e.g., "Show the English word", "Display the mathematical formula", "Present the historical event name")
  - **Back of card description** - Define what should appear on the back of cards (e.g., "Show the Polish translation", "Display the solution steps", "Present the detailed explanation")
  - **Answer explanation description** - Configure what additional explanations should include (e.g., "Include usage examples", "Add pronunciation guide", "Provide historical context")
  - These guidelines are automatically applied when generating cards from text, reviewing provisionary cards, or creating new cards in the deck
  
### Card Proposal Review System

Quick card creation mode for rapid entry - Capture new words or concepts on the go with a streamlined single-word/phrase input. These quick notes are stored in a dedicated inbox where you can later transform them into proper flashcards by adding the second side (definition, explanation, or translation). Perfect for reading sessions when you want to quickly note unfamiliar terms without interrupting your flow.

  The Card Proposal Review System provides an intuitive interface for transforming quick notes into properly structured flashcards with AI assistance.
  
  **UI Elements and Functionality**:
  
  **Card Proposal Display**:
  - **Proposal Tags**: A horizontal row of deletable tags showing all available card proposals (e.g., "grasa", "celdo", "fiszka")
  - **Active Proposal Highlight**: The currently selected proposal is highlighted in green
  - **Card Proposal Area**: A prominent green rectangular area displaying the current proposal text in large, bold font
  
  **Mode Selection Controls**:
  - **Answer Toggle**: A gray switch with a document icon that controls the card generation mode
    - **ON (Question Mode)**: The proposal is treated as a question (front of the card)
    - **OFF (Answer Mode)**: The proposal is treated as an answer (back of the card)
  - **Double Sided Toggle**: A green switch with bidirectional arrows that enables double-sided card creation
  
  **Deck Selection**:
  - **Deck Dropdown**: A text input field showing the selected deck name (e.g., "Hiszpański")
  - **Deck Guidelines**: Automatically applies the selected deck's card generation guidelines to AI content generation
  
  **Content Input Fields**:
  - **Question Field**: Large text input area for the front of the card content
  - **Answer Field**: Large text input area for the back of the card content
  - **Explanation Field**: Large text input area for additional explanatory content (optional)
  - **Inline Editing**: All fields support inline editing with save/cancel buttons that appear when text is modified
  - **Auto-Generation**: Content is automatically generated based on the selected mode and deck guidelines
  - **Smart Generation Triggers**: 
    - When in "Question" mode: Saving changes to the question field triggers answer and explanation generation
    - When in "Answer" mode: Saving changes to the answer field triggers question and explanation generation
    - Generation includes answer/question text and explanation text based on deck's explanation description
  
  **Action Buttons**:
  - **Discard**: Red circular button with 'X' icon to permanently remove the current proposal
  - **Later**: Green circular button with 'Z' icon to snooze the proposal for later review
  - **Save and Add Next**: Gray button with save icon to finalize the card and proceed to the next proposal (enabled when all required fields are filled)
  
  **Empty State Messages**:
  - **No Cards Available**: When there are no provisionary cards to review, displays a meaningful message with an inbox icon explaining that no quick notes are waiting to be turned into flashcards
  - **All Cards Reviewed**: When all provisionary cards have been processed (finalized or discarded), displays a success message with a checkmark icon congratulating the user and explaining that the cards are ready for learning
  
  **Generation Logic**:
  - **Question Mode** (switch on): 
    - Proposal text → "Question" field
    - AI generates answer → "Answer" field using deck's back card description guidelines
  - **Answer Mode** (switch off): 
    - Proposal text → "Answer" field
    - AI generates question → "Question" field using deck's front card description guidelines (with descriptions flipped)
  
  **Smart Features**:
  - **Context-Aware Generation**: AI considers deck category, name, description, and custom guidelines
  - **Real-Time Updates**: Content generation happens automatically when switching modes or selecting decks
  - **Validation**: Save button is only enabled when all required fields (question, answer, deck) are completed
  - **Progress Tracking**: Visual indicators show generation status and completion state
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

#### Action Buttons Widget
The ActionButtons widget provides quick access to card creation and review functionality through a segmented control interface in the app bar.

**Placement and Layout**:
- **Desktop Layout**: Positioned in the app bar between the title and locale selection, before the theme toggle
- **Mobile Layout**: Positioned in the app bar after the theme toggle, before the user menu
- **Responsive Behavior**: Automatically adapts to screen size constraints using LayoutBuilder

**Visual Design and Styling**:
- **Container Specifications**:
  - Height: 36 pixels (optimized to align with other app bar segmented buttons)
  - Border radius: 18 pixels (proportional to container height)
  - Background: Theme surface color with subtle outline border (20% opacity)
  - Shape: Rounded rectangle with consistent border styling

- **Button Layout**:
  - Horizontal row layout with mainAxisSize.min for compact sizing
  - Two distinct button sections separated by a vertical divider
  - Left button: Quick add card (larger with text label)
  - Right button: Review provisionary cards (icon-only with badge)

**Quick Add Card Button (Left Section)**:
- **Content**: Icon (add_box, 20px) + text label ("Quick add card")
- **Styling**: 
  - Height: 36px (matching container)
  - Padding: 16px horizontal
  - Border radius: 18px (top-left and bottom-left corners only)
  - Material ink effects for touch feedback
- **Functionality**: Opens modal bottom sheet with ProvisionaryCardAdd widget
- **Accessibility**: Full touch target with clear visual feedback

**Review Provisionary Cards Button (Right Section)**:
- **Content**: Checklist icon (20px) with optional badge count
- **Styling**:
  - Fixed width: 48px for consistent icon-only appearance
  - Height: 36px (matching container)
  - Padding: 10px all sides
  - Border radius: 18px (top-right and bottom-right corners only)
  - Icon color: Theme onSurface color (dimmed to 50% opacity when no cards available)
- **Badge System**:
  - Position: Top-right corner (6px from edges)
  - Background: Theme error color
  - Border radius: 8px
  - Minimum size: 16x16px
  - Text: Provisionary cards count in white, 10px font, bold weight
  - Only displays when provisionary cards count > 0
- **Functionality**: 
  - Enabled: Navigates to quick cards review page when cards are available
  - Disabled: No action when no provisionary cards exist
- **Visual States**: Icon opacity changes based on card availability

**Divider Element**:
- **Position**: Between the two button sections
- **Styling**: 1px width, 24px height, theme outline color with 20% opacity
- **Purpose**: Visual separation between distinct actions

**Loading and Error States**:
- **Loading State**: 120px width, 40px height container with centered CircularProgressIndicator (2px stroke)
- **Error State**: 120px width, 40px height container with error_outline icon
- **Async Handling**: Properly handles provisionary cards data loading states

**Theme Integration**:
- **Dynamic Colors**: All colors adapt to current theme (light/dark mode)
- **Consistent Styling**: Matches Material Design segmented button patterns
- **Accessibility**: Proper contrast ratios and touch target sizes

**Testing Requirements**:
- **Widget Testing**: Comprehensive test coverage for rendering, interaction, and styling
- **Mock Implementation**: Uses mock widgets to avoid web-specific import issues in test environment
- **Test Coverage**: 
  - Widget rendering and structure verification
  - Icon and text presence validation
  - Layout and styling property checks
  - Touch interaction testing
  - Badge display logic testing

## Future Features

### LLM Integration
- AI-powered card creation suggestions - Get intelligent recommendations for card content based on your learning goals.
- **Deck-aware card generation** - AI automatically considers deck-specific guidelines when generating cards:
  - Front/back card descriptions are passed to AI prompts to ensure consistent card structure
  - Explanation descriptions guide AI to include relevant additional information
  - Guidelines are applied across all generation methods (text input, provisionary cards, batch generation)
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