## Libraries

The main libraries for audio functionality are [record](https://pub.dev/packages/record) for recording and [just_audio](https://pub.dev/packages/just_audio) for playback.

## Need to fix

I have been testing the app in Safari and Chrome for web browsers.

* **Audio file not sending to Open API in correct format** -- this happens in either Chrome or Safari but checking the network tab when you send a file off for transcription will result in an incorrect format error.
* **Saving locally on mobile web** -- If possible on mobile web we want to have the share drawer come in from the bottom to save the audio file locally
* **Send audio_type to database** -- Send the type of audio (article, journal, etc) with the transcription
* **UI and Additional screens** -- Kyle can walk through these screens
* **Test with longer audio recordings**

## Misc notes

Much of the base code comes from the examples from the Record and Just Audio plugins.

Loading the audio file from blob storage on mobile web as an audio source was proving to be problematic. Since we have to transform the blob url into bytes in order to send to OpenAI anyways, we use the [StreamAudioSource](https://github.com/ryanheise/just_audio/issues/187#issuecomment-787423071) solution.

I believe there are issues with Safari and wav files -- I think I got these mixed up when switching between wav and mp3 when trying to debug why web mobile was not sending the audio file. (A global search of "wav" will show you related files)

Potentially related to safari on ios issue: https://community.openai.com/t/whisper-api-cannot-read-files-correctly/93420/3?page=2