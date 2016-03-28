import React, { Component, NativeModules, requireNativeComponent } from 'react-native';
import Promise from 'bluebird';

const NYTPhotoViewerManager = NativeModules.NYTPhotoViewerManager;

console.log('NativeModules:', NativeModules);

export default class NYTPhotoViewer extends Component {
  static async hidePhotoViewer() {
    return await doHidePhotoViewer()
  }

  static async showPhotoViewer(source) {

    return await doShowPhotoViewer(source)
  }
}

function doShowPhotoViewer(source) {
  return new Promise((resolve, reject) => {
    NYTPhotoViewerManager.showPhotoViewer(source, (error) => {
      if (!error) {
        return resolve();
      }
      reject(error);
    });
  });
}

function doHidePhotoViewer() {
  return new Promise((resolve, reject) => {
    NYTPhotoViewerManager.hidePhotoViewer((error) => {
      if (!error) {
        return resolve();
      }
      reject(error);
    });
  });
}
