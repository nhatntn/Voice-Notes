## Problem 
Create a Voice Note application that records audio and transcribes it to text. Location information shall be captured for each note.

## Basic Functionality

- A user should be able to create a note by starting to record audio
- Notes should be created with the audio recording and transcribed using some ASR/Voice-to-Text service (e.g. Google ASR API or others of your choice)
- Users should be able to see a list of their notes
- Users should be able to select a note and view the transcribed text, playback the voice recording, and view any metadata that the note might have.
- Unit Test for these features is a MUST

## Software development principles, patterns & practices being applied
### Architecture concepts
* MVVM + Clean Architecture 
* Dependency Injection
### Programming paradigm
* Protocol-Oriented Programming
### Practices being applied
* Data Binding using Observable without 3rd party libraries 
* Flow Coordinator
* Storage with CoreData
* Using CocoaPod for GoogleAPIs integrations
* Using Speech-To-Text and Text-To-Speech Services
