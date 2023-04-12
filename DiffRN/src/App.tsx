import React from 'react';
import { store } from './store/index';
import CoinScreen from './features/Coin/CoinScreen';
import { Provider } from 'react-redux';
import {
  SafeAreaProvider,
  SafeAreaInsetsContext
} from 'react-native-safe-area-context';

const App = (): JSX.Element => {
  return (
    <Provider store={store}>
      <SafeAreaProvider>
        <SafeAreaInsetsContext.Consumer>
          {() => (
            <>
              <CoinScreen />
            </>
          )}
        </SafeAreaInsetsContext.Consumer>
      </SafeAreaProvider>
    </Provider>
  );
};

export default App;
