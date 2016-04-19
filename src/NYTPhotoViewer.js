import { DeviceEventEmitter, NativeModules } from 'react-native';
import Promise from 'bluebird';
import EventEmitter from 'events';
import Symbol from 'es6-symbol';


const NYTPhotoViewerManager = NativeModules.NYTPhotoViewerManager;
const singleton             = Symbol();
const singletonEnforcer     = Symbol();

export default class NYTPhotoViewer extends EventEmitter {

  static DISMISSED = 'NYTPhotoViewer:Dismissed';

  static addListener(eventType, listener) {
    return NYTPhotoViewer.instance.addListener(eventType, listener);
  }

  static on(eventType, listener) {
    return NYTPhotoViewer.instance.addListener(eventType, listener);
  }

  static once(eventType, listener) {
    return NYTPhotoViewer.instance.once(eventType, listener);
  }

  static removeListener(eventType, listener) {
    return NYTPhotoViewer.instance.removeListener(eventType, listener);
  }

  static async hidePhotoViewer() {
    return await NYTPhotoViewer.instance.doHidePhotoViewer();
  }

  static async showPhotoViewer(source) {
    return await NYTPhotoViewer.instance.doShowPhotoViewer(source);
  }

  static hideActionButton() {
    NYTPhotoViewerManager.hideActionButton();
  }

  static showActionButton() {
    NYTPhotoViewerManager.showActionButton();
  }

  static get instance() {
    if (!this[singleton]) {
      this[singleton] = new NYTPhotoViewer(singletonEnforcer);
    }
    return this[singleton];
  }

  constructor(enforcer) {
    if (enforcer != singletonEnforcer) {
      throw new Error('CannotConstructSingleton');
    }
    super();
    this.handlePhotoViewerDismissed = this.handlePhotoViewerDismissed.bind(this);
    DeviceEventEmitter.addListener(NYTPhotoViewer.DISMISSED, this.handlePhotoViewerDismissed);
  }

  doShowPhotoViewer(source) {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.showPhotoViewer(source, (error) => {
        if (!error) {
          return resolve();
        }
        reject(error);
      });
    });
  }

  doHidePhotoViewer() {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.hidePhotoViewer((error) => {
        if (!error) {
          return resolve();
        }
        reject(error);
      });
    });
  }

  handlePhotoViewerDismissed() {
    this.emit(NYTPhotoViewer.DISMISSED);
  }
}


