#!/bin/bash
firebase emulators:start --only firestore &  # Start emulator in the background
sleep 5  # Give the emulator time to start (adjust as needed)
flutter test --start-paused  # Run tests (now paused)

# In a separate terminal, unpause the tests after confirming the emulator is running.
#  Type 'c' in that terminal.
