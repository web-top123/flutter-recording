# salad_app

An audio recording app that transcribes your recording to text and emails you a Google doc link.

## Getting Started

### Environment Variables

To run this app locally you will need to get the Subapase API key from the project repo at [this link](https://supabase.com/dashboard/project/cijbetgzdgqkiilfskne/settings/api).

You will also need the OpenAI API key -- ask Kyle for this key.

### Running the app locally

To run on a web server where you can test on desktop and mobile web run the following command, your machine's IP address can be found in network settings:

`$ flutter run -d web-server --web-hostname <IP_ADDRESS> --web-port 8080 --dart-define API_KEY=<key_value> OPENAI_API_KEY=<key_value>`

If you want to test on your device make sure it is connected to the same network as your machine and go to http://<IP_ADDRESS>:8080

Flutter dev tools in VSCode is an excellent source for debugging and you can connect directly to your device with the Run and Debug. Once you point to your desired device run:

`$ flutter run --dart-define API_KEY=<key_value> OPENAI_API_KEY=<key_value>`

Setting up a local [launch config](https://dartcode.org/docs/launch-configuration/) for the above commands is recommended

### Important note on local development

It is not recommended to use the Simulator for testing this app -- the audio playback does not work properly and does not reflect what happens on an actual device.