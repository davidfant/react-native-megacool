import * as React from 'react';
import { 
	PermissionsAndroid, View, Platform, NativeModules, 
	requireNativeComponent, findNodeHandle,
} from 'react-native';

const RNMegacool: any = requireNativeComponent('RNMegacool');

interface MegacoolProps {

	/**
		Edit the default sharing text to make it more personal and customized for each place you use it.
	*/
	sharingText?: string;

	/**
		Set numbers of frames to record per second. Recommended range: 1 - 10. The default is 10:
	*/
	frameRate?: number;

	/**
		Set the number of frames per second when playing the GIF. The default is 10 frames / second. 
		The GIF will be exported with this frame rate and it doesn't affect the recording frame rate.
	*/
	playbackFrameRate?: number;

	/**
		Max number of frames to record, default is 50 frames.
	*/
	maxFrames?: number;

	/**
		Set a delay (in milliseconds) for the last frame of the GIF. The default is 1 second 
		to give a natural break before the GIF loops again.
	*/
	lastFrameDelay?: number;

	onStartedRecording?: () => void;
	onStoppedRecording?: () => void;
	onStartedSharing?: () => void;

}

// Wrap a native callback and return the value for the key
const wrap = (f, key: string = null) => !f ? undefined : (ev) => f(!!key ? ev.nativeEvent[key] : ev.nativeEvent);

interface State {
	url: string;
}

export class Megacool extends React.Component<MegacoolProps, State> {

	state: State = { url: null };
	view: View;

  	static init(apiKey: string) { this.runCommand('init', [apiKey]); }

	startRecording() { return this.runCommand('startRecording'); }
	stopRecording() { return this.runCommand('stopRecording'); }
	hidePreview() { return  this.runCommand('hidePreview'); }
	presentTrackedShare() { return this.runCommand('presentTrackedShare'); }
	
	async presentShare() { 
		const url = await this.videoUrl();
		return this.runCommand('presentShare', [url]);
	}

	async saveImageToCameraRoll() { 
		const url = await this.videoUrl();
		await this.requestSavePermission();
		return this.runCommand('saveImageToCameraRoll', [url]);
	}

	async saveVideoToCameraRoll() { 
		const url = await this.videoUrl();
		await this.requestSavePermission();
		return this.runCommand('saveVideoToCameraRoll', [url]);
	}

	async videoUrl(): Promise<string> {
		if (!!this.state.url) return this.state.url;
		const url = await this.runCommand('videoUrl');
		this.setState({ url });
		return url;
	}

	// Handling in Android is absolute bullshit... It's slightly nicer by using
	// React Native's AndroidPermissions native module. But still embarrassingly ugly
	private async requestSavePermission() {
		if (Platform.OS !== 'android') return;

		const granted = await PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE);
  		if (granted !== PermissionsAndroid.RESULTS.GRANTED) {
  			throw new Error('Saving to camera permission not granted')
  		}
	}

	private handle() { return findNodeHandle(this.view); }
	private runCommand(name: string, args: any[] = []) { return Megacool.runCommand(name, [this.handle(), ...args]); }
	private static runCommand(name: string, args: any[] = []) { return NativeModules.RNMegacoolManager[name](...args); }

	render() {
		return (
			<RNMegacool 
				ref={(ref) => this.view = ref}
				{...this.props}
			/>
		);
	}

}
