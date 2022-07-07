  const path    = require("path")
  const webpack = require("webpack")
  
  // Extracts CSS into .css file
  const MiniCssExtractPlugin = require('mini-css-extract-plugin');
  // Removes exported JavaScript files from CSS-only entries
  // in this example, entry.custom will create a corresponding empty custom.js file
  const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts');
  
  module.exports = {
    mode: "production",
    devtool: "source-map",
    entry: {
      application: [
        "./app/javascript/application.js",
        "./app/assets/stylesheets/application.scss",
      ],
      custom: './app/assets/stylesheets/custom.scss'
    },
    output: {
      filename: "[name].js",
      sourceMapFilename: "[file].map",
      path: path.resolve(__dirname, "app/assets/builds"),
    },
    module: {
      rules: [{
        test: /\.scss$/,
        use: [
          {
            loader: "style-loader" // creates style nodes from JS strings
          },
          {
            loader: "css-loader" // translates CSS into CommonJS
          },
          {
            loader: "sass-loader" // compiles Sass to CSS
          },
        ]
      }
    ]
  },
  resolve: {
    // Add additional file types
    extensions: ['.js', '.jsx', '.scss', '.css'],
  },
  plugins: [
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin(),
  ],
}
