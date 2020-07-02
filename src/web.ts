import { WebPlugin } from '@capacitor/core';
import { UniAppleSignInPlugin } from './definitions';

export class UniAppleSignInWeb extends WebPlugin implements UniAppleSignInPlugin {
  constructor() {
    super({
      name: 'UniAppleSignIn',
      platforms: ['web']
    });
  }

  async echo(options: { value: string }): Promise<{value: string}> {
    console.log('ECHO', options);
    return options;
  }
}

const UniAppleSignIn = new UniAppleSignInWeb();

export { UniAppleSignIn };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(UniAppleSignIn);
