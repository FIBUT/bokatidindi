const path    = require("path")
const webpack = require("webpack")

// Extracts CSS into .css file
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

// Removes exported JavaScript files from CSS-only entries
// in this example, entry.custom will create a corresponding empty custom.js file
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts');

// Our minimiser
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");

module.exports = {
    mode: "production",
    devtool: "source-map",
    entry: {
        application: [
            "./app/javascript/application.js",
            "./app/assets/stylesheets/application.scss",
        ],
    },
    output: {
        path: path.resolve(__dirname, "app/assets/builds"),
    },
    module: {
        rules: [
            {
                test: /\.scss$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    "css-loader",
                    "sass-loader",
                ],
            },
            {
                test: /\.svg$/,
                type: "asset",
                use: [
                    "svgo-loader",
                ],
            },
        ],
    },
    optimization: {
        minimize: true,
        minimizer: [
            new CssMinimizerPlugin({
                minimizerOptions: {
                    preset: [ "default",
                        {
                            reduceIdents: true,
                        },
                    ],
                },
            }),
        ]
    },
    plugins: [
        new MiniCssExtractPlugin(),
    ],
}
