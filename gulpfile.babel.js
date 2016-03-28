gulp //-------------------------------------------------------------------------------
// Requires
//-------------------------------------------------------------------------------

import gulp from 'gulp';
import babel from 'gulp-babel';
import eslint from 'gulp-eslint';
import recipe from 'gulp-recipe';
import sourcemaps from 'gulp-sourcemaps';
import util from 'gulp-util';
import del from 'del';
import jest from 'jest-cli';
import Promise from 'bluebird';


//-------------------------------------------------------------------------------
// Gulp Properties
//-------------------------------------------------------------------------------

const sources = {
  babel: [
    'src/**',
    '!**/tests/**'
  ]
};


//-------------------------------------------------------------------------------
// Gulp Tasks
//-------------------------------------------------------------------------------

gulp.task('default', ['prod']);

gulp.task('prod', ['babel']);

gulp.task('dev', ['babel', 'lint', 'babel-watch', 'lint-watch']);

gulp.task('test', ['lint', 'jest']);

gulp.task('babel', () => {
  return gulp.src(sources.babel)
    .pipe(sourcemaps.init({
      loadMaps: true
    }))
    .pipe(babel({
      presets: ['es2015', 'stage-2']
    }))
    .pipe(sourcemaps.write('./'))
    .pipe(gulp.dest('./dist'))
    .on('error', (error) => {
      util.log(error);
    });
});

gulp.task('lint', recipe.get('eslint', [
  '**/*.js',
  '!node_modules/**',
  '!dist/**'
]));

gulp.task('jest', () => {
  return runJest({
    scriptPreprocessor: '<rootDir>/node_modules/babel-jest',
    unmockedModulePathPatterns: [
      'immutable',
      'lodash',
      'is-equal',
      'reduce-reducers'
    ],
    testPathIgnorePatterns: [
      '/node_modules/',
      '/.nvm/'
    ],
    testFileExtensions: [
      'js'
    ],
    moduleFileExtensions: [
      'js'
    ],
    modulePathIgnorePatterns: [
      '/node_modules/',
      '/.nvm/'
    ]
  });
});

gulp.task('clean', () => {
  return del([
    'dist'
  ]);
});


//-------------------------------------------------------------------------------
// Gulp Watchers
//-------------------------------------------------------------------------------

gulp.task('babel-watch', function() {
  gulp.watch(sources.babel, ['babel']);
});

gulp.task('lint-watch', function() {
  const lintAndPrint = eslint();
  lintAndPrint.pipe(eslint.formatEach());

  return gulp.watch('src/**/*.js', function (event) {
    if (event.type !== 'deleted') {
      gulp.src(event.path)
        .pipe(lintAndPrint, {end: false})
        .on('error', function (error) {
          util.log(error);
        });
    }
  });
});


//-------------------------------------------------------------------------------
// Helper Functions
//-------------------------------------------------------------------------------

function runJest(options) {
  return new Promise((resolve, reject) => {
    options = options || {};
    options.rootDir = options.rootDir || process.cwd();
    jest.runCLI({
      config: options
    }, options.rootDir, (success) => {
      if (!success) {
        reject(new util.PluginError('gulp-jest', {message: 'Tests Failed'}));
      } else {
        resolve();
      }
    });
  });
}
