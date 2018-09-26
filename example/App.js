import React from 'react';
import { Platform, Animated, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { Megacool, MegacoolPreview } from './megacool';

const styles = {
    fill: {
        flex: 1,
        alignSelf: 'stretch',
    },
    center: {
        alignItems: 'center',
        justifyContent: 'center',
    },
    box: {
        width: 50,
        height: 50,
    },
    button: {
        marginVertical: 4,
        padding: 16,
        backgroundColor: '#ddd',
        borderRadius: 4,
        alignItems: 'center',
        justifyContent: 'center',
    },
};

export default class App extends React.Component {

    state = { 
        isShowingPreview: false,
        isRecording: false,
    };

    megacool = null;
    opacity = new Animated.Value(0);

    componentDidMount() {
        Animated.loop( 
            Animated.timing(this.opacity, {
                toValue: 1,
                duration: 1000,
                useNativeDriver: true,
            }),
        ).start();
    }

    render() {
        return (
            <View style={{ ...styles.fill, padding: 20 }}>
                <View style={{ flexDirection: 'row' }}>
                    <View style={{ ...styles.center, flex: 1 }}>
                        <Text>Recording{'\n'}</Text>
                        <Megacool
                            ref={(ref) => this.megacool = ref}
                            style={{ ...styles.box, backgroundColor: 'red' }}
                            onStartedRecording={() => this.setState({ isRecording: true })}
                            onStoppedRecording={() => this.setState({ isRecording: false })}
                            onPreview={() => console.warn('preview')}
                            sharingText="Tjena kex!"
                            frameRate={15}
                            playbackFrameRate={3}
                            maxFrames={5 * 20}
                            lastFrameDelay={0}
                        >
                            <Animated.View style={{ ...styles.fill, backgroundColor: 'yellow', opacity: this.opacity.interpolate({
                                inputRange: [0, 0.5, 1],
                                outputRange: [0.8, 0, 0.8],
                            }) }}/>
                        </Megacool>
                    </View>
                    <View style={{ ...styles.center, flex: 1 }}>
                        <Text>Replay{'\n'}</Text>
                        <View style={{ ...styles.box, backgroundColor: '#eee' }}>
                            { this.state.isShowingPreview && <MegacoolPreview style={styles.fill} /> }
                        </View>
                    </View>
                </View>

                <View style={{ flex: 1 }} />

                <View style={{ ...styles.center, padding: 10, width: '100%' }}>  
                    { !!this.state.isRecording && <Text>Recording...</Text>}
                    { !!this.state.isShowingPreview && <Text>Showing preview...</Text>}
                </View>

                <View style={{ flex: 1 }} />

                { !this.state.isRecording && 
                <TouchableOpacity style={styles.button} onPress={() => this.megacool.startRecording()} >
                    <Text>Start recording </Text>
                </TouchableOpacity>
                }
                
                { !!this.state.isRecording && 
                <TouchableOpacity style={styles.button} onPress={() => this.megacool.stopRecording()} >
                    <Text>Stop recording</Text>
                </TouchableOpacity>
                }
                
                { !this.state.isShowingPreview && 
                <TouchableOpacity style={styles.button} onPress={() => this.setState({ isShowingPreview: true })} >
                    <Text>Show preview</Text>
                </TouchableOpacity>
                }
                
                { !!this.state.isShowingPreview && 
                <TouchableOpacity style={styles.button} onPress={() => this.setState({ isShowingPreview: false})} >
                    <Text>Hide preview</Text>
                </TouchableOpacity>
                }

                <TouchableOpacity style={styles.button} onPress={() => this.megacool.presentShare()} >
                    <Text>Share</Text>
                </TouchableOpacity>

                <TouchableOpacity style={styles.button} onPress={() => this.megacool.saveVideoToCameraRoll()} >
                    <Text>Save to camera roll</Text>
                </TouchableOpacity>
            </View>
        );
    }

}
