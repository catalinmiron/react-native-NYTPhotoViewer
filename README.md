# react-native-NYTPhotoViewer
React native wrapper for the [NYTPhotoViewer iOS library]()

## Build Status

[![npm version](https://badge.fury.io/js/react-native-NYTPhotoViewer.svg)](https://badge.fury.io/js/react-native-NYTPhotoViewer)<br />
[![Build Status](https://travis-ci.org/sprightco/react-native-NYTPhotoViewer.svg)](https://travis-ci.org/sprightco/react-native-NYTPhotoViewer)<br />
[![NPM](https://nodei.co/npm/react-native-NYTPhotoViewer.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/react-native-NYTPhotoViewer/)


## Install

Run `npm install react-native-NYTPhotoViewer --save`


### iOS

1. In the XCode's "Project navigator", right click on your project's Libraries folder ➜ `Add Files to <...>`
2. Go to `node_modules` ➜ `react-native-NYTPhotoViewer` ➜ `ios` ➜ select `RCTNYTPhotoViewer.xcodeproj`
3. Add `RCTNYTPhotoViewer.a` to `Build Phases -> Link Binary With Libraries`

### CocoaPods

1. Add `pod 'react-native-NYTPhotoViewer', :path => '../node_modules/react-native-nytphotoviewer'` to your PodFile


## Usage (es6 example)

```javascript
import NYTPhotoViewer from 'react-native-nytphotoviewer';

class MyComponent extends React.Component {
  
  constructor(props) {
    super(props);
    this.onImagePress = this.onImagePress.bind(this);
    this.onPhotoViewerDismissed = this.onPhotoViewerDismissed.bind(this);
  }
  
  onImagePress() {
    NYTPhotoViewer.once(NYTPhotoViewer.DISMISSED, this.onPhotoViewerDismissed);
    NYTPhotoViewer.showPhotoViewer(this.props.urlOfImage)
      .then(() => {
        console.log('Photo viewer is now visible and image has loaded');
      });
  }
  
  onPhotoViewerDismissed() {
    console.log('PhotoViewer has been dismissed');
  }

  render() {
    return (
      <View>
        <TouchableHighlight
          onPress={this.onImagePress}
          activeOpacity={0.5}
          underlayColor='transparent'
        >
          <Image
            source={{uri: this.props.urlOfImage}}
          />
        </TouchableHighlight>
      </View>
    );
  }
}
```

## Events

- `addListener(eventType, function())`
eventType can be 'NYTPhotoViewer:Dismissed' which is fired when the PhotoViewer is dimissed


- `on(eventType, listener)`
Short cut for `addListener`


- `once(eventType, listener)`
Event listener fires once and then is removed.

- `removeListener(eventType, listener)`
Removes an event listener


## Functions

- `NYTPhotoViewer.showPhotoViewer(source):Promise`
`source` is a url to an image which is loaded by native module

Returns a Promise the is fulfilled when photoViewer is visible and image has been loaded.

Promise rejects if image fails to load.


- `NYTPhotoViewer.hidePhotoViewer():Promise`
Returns a Promise the is fulfilled when photoViewer is no longer visible.


- `NYTPhotoViewer.showActionButton()`
Show the action button in top right of NYTPhotoViewer (action button is visible by default)

- `NYTPhotoViewer.hideActionButton()`
Hide the action button.
