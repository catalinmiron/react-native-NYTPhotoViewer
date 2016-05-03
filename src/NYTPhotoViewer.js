import { DeviceEventEmitter, NativeModules } from 'react-native';
import Promise from 'bluebird';
import EventEmitter from 'events';
import Symbol from 'es6-symbol';


const NYTPhotoViewerManager = NativeModules.NYTPhotoViewerManager;
const singleton             = Symbol();
const singletonEnforcer     = Symbol();

export default class NYTPhotoViewer extends EventEmitter {

  static ACTION_BUTTON_PRESS = 'NYTPhotoViewer:ActionButtonPress';
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

  static async showPhotoViewer() {
    return await NYTPhotoViewer.instance.doShowPhotoViewer();
  }

  static hideActionButton() {
    NYTPhotoViewerManager.hideActionButton();
  }

  static showActionButton(options) {
    NYTPhotoViewerManager.showActionButton(options || {});
  }

  static async displayPhotoAtIndex(index) {
    return await NYTPhotoViewer.instance.doDisplayPhotoAtIndex(index);
  }

  static async displayPhotoWithSource(source) {
    return await NYTPhotoViewer.instance.doDisplayPhotoWithSource(source);
  }

  static async addPhotos(sources) {
    return await NYTPhotoViewer.instance.doAddPhotos(sources);
  }

  static async clearPhotos() {
    return await NYTPhotoViewer.instance.doClearPhotos();
  }

  static async indexOfPhoto(source) {
    return await NYTPhotoViewer.instance.doIndexOfPhoto(source);
  }

  static async photoAtIndex(index) {
    return await NYTPhotoViewer.instance.doPhotoAtIndex(index);
  }

  static async removePhotos(sources) {
    return await NYTPhotoViewer.instance.doRemovePhotos(sources);
  }

  static async updatePhotoAtIndex(index, source) {
    return await NYTPhotoViewer.instance.doUpdatePhotoAtIndex(index, source);
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
    this.handlePhotoViewerActionButtonPress = this.handlePhotoViewerActionButtonPress.bind(this);
    DeviceEventEmitter.addListener(NYTPhotoViewer.ACTION_BUTTON_PRESS, this.handlePhotoViewerActionButtonPress);
    DeviceEventEmitter.addListener(NYTPhotoViewer.DISMISSED, this.handlePhotoViewerDismissed);
  }

  doShowPhotoViewer() {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.showPhotoViewer((error) => {
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

  doDisplayPhotoAtIndex(index) {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.displayPhotoAtIndex(index, (error) => {
        if (!error) {
          return resolve();
        }
        reject(error);
      });
    });
  }

  doDisplayPhotoWithSource(source) {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.displayPhotoWithSource(source, (error) => {
        if (!error) {
          return resolve();
        }
        reject(error);
      });
    });
  }

  doAddPhotos(sources) {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.addPhotos(sources, (error) => {
        if (!error) {
          return resolve();
        }
        reject(error);
      });
    });
  }

  doClearPhotos() {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.clearPhotos((error) => {
        if (!error) {
          return resolve();
        }
        reject(error);
      });
    });
  }

  doIndexOfPhoto(source) {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.indexOfPhoto(source, (error, index) => {
        if (!error) {
          return resolve(index);
        }
        reject(error);
      });
    });
  }

  doPhotoAtIndex(index) {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.photoAtIndex(index, (error, source) => {
        if (!error) {
          return resolve(source);
        }
        reject(error);
      });
    });
  }

  doRemovePhotos(sources) {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.removePhotos(sources, (error) => {
        if (!error) {
          return resolve();
        }
        reject(error);
      });
    });
  }

  doUpdatePhotoAtIndex(index, source) {
    return new Promise((resolve, reject) => {
      NYTPhotoViewerManager.updatePhotoAtIndex(index, source, (error) => {
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

  handlePhotoViewerActionButtonPress(event) {
    this.emit(NYTPhotoViewer.ACTION_BUTTON_PRESS, event.index);
  }
}
