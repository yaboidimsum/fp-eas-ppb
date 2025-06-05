# Splash Screen Implementation Guide

This document provides steps to complete the splash screen setup for your Recipe App.

## 1. Enable Developer Mode on Windows

To handle symlinks required for Flutter plugins:

1. Press Win + I to open Settings
2. Go to Privacy & Security > For developers
3. Turn on Developer Mode
4. Restart your computer if prompted

## 2. Create a Splash Image

Create your splash image and save it as `splash_logo.png` in the `assets/images` folder. The image should be:

-   Square (e.g., 512x512 pixels)
-   Simple with minimal details
-   Clear at small sizes
-   PNG format with transparency

You can create this with any image editor like Photoshop, GIMP, or even Canva.

## 3. Generate Native Splash Screens

Run this command to generate the splash screen assets:

```bash
cd c:/Users/reyna/kuliah/ppb/.fp/fp-eas-ppb
dart run flutter_native_splash:create
```

This will:

-   Generate the necessary splash screen files for Android and iOS
-   Configure the splash screen according to your `flutter_native_splash.yaml` file
-   Create any needed resources files

## 4. Test the Splash Screen

Run your app to test the splash screen:

```bash
flutter run
```

The splash screen should display:

1. The native splash screen (generated from flutter_native_splash)
2. A smooth transition to your app's first screen
3. The custom splash widget animation we added

## 5. Troubleshooting

If you encounter issues:

-   **Splash screen not showing**: Check that the image path is correct and the file exists
-   **Flickering**: Adjust the transition timing in the SplashScreenWidget
-   **Image too small/large**: Resize your image and regenerate the splash screen

## 6. Additional Customization (Optional)

-   Adjust colors in `flutter_native_splash.yaml`
-   Modify the `SplashScreenWidget` animation duration
-   Add a logo animation for more visual appeal
