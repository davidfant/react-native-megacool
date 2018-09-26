import { AppRegistry } from 'react-native';
import App from './App';
import { Megacool } from './megacool';

Megacool.init('YOUR_API_KEY');

AppRegistry.registerComponent('Megacool', () => App);
