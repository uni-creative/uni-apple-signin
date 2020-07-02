declare module "@capacitor/core" {
  interface PluginRegistry {
    UniAppleSignIn: UniAppleSignInPlugin;
  }
}

export interface UniAppleSignInPlugin {
  echo(options: { value: string }): Promise<{value: string}>;
}
