const path              = require('path');
const webpack           = require('webpack');
const merge             = require('webpack-merge');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

console.log('Starting webpack process...');

// Determine build env by npm command options
const TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'production' : 'development';
const TARGET_COMMAND = process.env.npm_lifecycle_event;
const ENV = {
  'port': process.env.PORT || 8080,
  'host': process.env.HOST || 'localhost',
  'title': process.env.TITLE || 'Example app',
  'publicPath': process.env.PUBLIC_PATH || '/elm-evil-sendmsg/',
};

// Common webpack config
const entry =
  { "index":
    [ path.join( __dirname, "src/index.js")
    ]
  };

const commonConfig = {

  output: {
    path: path.resolve(__dirname, '../doc/'),
    filename: '[name].js',
    publicPath: ENV.publicPath,
  },

  entry,

  resolve: {
    extensions: ['.js', '.elm'],
    modules: [
      'node_modules'
    ],
  },

  module: {
    rules: [
      {
        test: /\.(eot|ttf|woff|woff2|svg)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              outputPath: 'static/',
            },
          }
        ]
      },
      {
        test: /\.(jpg|jpeg|png)$/,
        use: 'url-loader'
      },
    ]
  },

  plugins: [
    new HtmlWebpackPlugin({
      chunks: ['index'],
      template: 'src/index.html',
      inject:   'body',
      filename: 'index.html',
      data: ENV,
      hash: true,
      minify: {
        collapseInlineTagWhitespace: true,
        collapseWhitespace: true,
        html5: true,
        removeComments: true,
      },
    }),

    // Inject variables to JS file.
    new webpack.DefinePlugin({
      'process.env':
        Object.keys(ENV).reduce((o, k) =>
          merge(o, {
            [k]: JSON.stringify(ENV[k]),
          }), {}
        ),
    }),

    new CopyWebpackPlugin([
    ]),
  ],
}

// Settings for `npm start`
if (TARGET_ENV === 'development') {
  console.log('Serving locally...');

  const elmHandler = (test, dir) =>
    ( { test: test
      , exclude: [/elm-stuff/, /node_modules/]
      , use:
          [ { loader: 'elm-hot-loader'
            }
          , { loader: 'elm-webpack-loader'
            , options:
              { verbose: true
              , warn: true
              , debug: true
              , cwd: dir
              }
            }
          ]
      }
    )

  module.exports = merge(commonConfig, {

    devServer: {
      contentBase: 'src',
      inline: true,
      port: ENV.port,
      host: ENV.host,
    },

    module: {
      rules:
        [ { test: /.*\.elm$/
          , exclude: [/elm-stuff/, /node_modules/]
          , use:
              [ { loader: 'elm-hot-loader'
                }
              , { loader: 'elm-webpack-loader'
                , options:
                  { verbose: true
                  , warn: true
                  // , debug: true
                  }
                }
              ]
          }
        , { test: /\.(css|scss)$/
          , use:
            [ 'style-loader'
            , { 'loader': 'css-loader'
              }
            , { 'loader': 'sass-loader'
              }
            , 'postcss-loader'
            ]
          }
        ]
    }
  });
}

// Settings for `npm run build`.
if (TARGET_ENV === 'production') {
  console.log('Building for prod...');
  const elmHandler = (test, dir) =>
    ( { test: test
      , exclude: [/elm-stuff/, /node_modules/]
      , use:
          [ { loader: 'elm-webpack-loader'
            , options:
              { verbose: true
              , warn: true
              // , debug: true
              , cwd: dir
              }
            }
          ]
      }
    );

  module.exports = merge(commonConfig, {

    module: {
      rules:
        [ { test: /.*\.elm$/
          , exclude: [/elm-stuff/, /node_modules/]
          , use:
            [ { loader: 'elm-webpack-loader'
              , options:
                { verbose: true
                , warn: true
                // , debug: true
                }
              }
            ]
          }
        , { test: /\.(css|scss)$/
          , use: ExtractTextPlugin.extract(
            { fallback: 'style-loader'
            , use:
              [ { 'loader': 'css-loader'
                }
              , { 'loader': 'sass-loader'
                }
              , 'postcss-loader'
              ]
            })
          }
        ]
    },

    plugins: [
      // Extract CSS into a separate file
      new ExtractTextPlugin({
        filename: '[name].css',
        allChunks: true
      }),

      // Minify & mangle JS/CSS
      new webpack.optimize.UglifyJsPlugin({
          minimize:   true,
          compressor: { warnings: false }
          // mangle:  true
      }),
    ]
  });
}
