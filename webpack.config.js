// Borrowed from:
// * <https://github.com/grassdog/middleman-webpack>
// * <https://github.com/mcmire/mcmire.me>

const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const CleanPlugin = require("clean-webpack-plugin");
const bourbon = require("bourbon");

const TMP_PATH = ".tmp";
const PUBLIC_PATH = "assets";
const JAVASCRIPTS_PATH = "javascripts";
const STYLESHEETS_PATH = "stylesheets";
const IMAGES_PATH = "images";
const FONTS_PATH = "fonts";

const NODE_MODULES = path.resolve(__dirname, "node_modules");
const TMP_DIR = path.resolve(__dirname, TMP_PATH);
const CONTEXT_DIR = path.resolve(__dirname, "assets");
const JAVASCRIPTS_DIR = path.resolve(CONTEXT_DIR, JAVASCRIPTS_PATH);
const STYLESHEETS_DIR = path.resolve(CONTEXT_DIR, STYLESHEETS_PATH);
const ENV = process.env.NODE_ENV || "development";

function determineDevtool() {
  if (ENV === "development") {
    // The external source map options, such as this one, works in Firefox —
    // the inline source map options don't work
    return "cheap-module-source-map";
  } else {
    return "source-map";
  }
}

function shouldRelyOnSourceMap() {
  return true;
}

function determinePlugins() {
  const plugins = [
    new CleanPlugin([TMP_PATH]),
    new MiniCssExtractPlugin({
      filename: path.join(PUBLIC_PATH, STYLESHEETS_PATH, "bundle.css")
    })
  ];

  if (ENV === "production") {
    plugins.push(
      new UglifyJsPlugin({
        sourceMap: shouldRelyOnSourceMap(),
        uglifyOptions: { mangle: false }
      }),
      new OptimizeCSSAssetsPlugin({})
    );
  }

  return plugins;
}

const postcssLoader = {
  loader: "postcss-loader",
  options: {
    sourceMap: shouldRelyOnSourceMap(),
    plugins: function() {
      return [require("autoprefixer")];
    }
  }
};

const cssExtractionLoader = { loader: MiniCssExtractPlugin.loader };
/*
  ENV === "development"
    ? "style-loader"
    : {
        loader: MiniCssExtractPlugin.loader,
        //options: {
          //outputPath: path.join(PUBLIC_PATH, STYLESHEETS_PATH)
        //}
      };
*/

const config = {
  mode: ENV,
  devtool: determineDevtool(),
  context: CONTEXT_DIR,
  entry: { bundle: "./" + path.join(JAVASCRIPTS_PATH, "index.js") },
  resolve: {
    modules: [JAVASCRIPTS_DIR, STYLESHEETS_DIR, "node_modules"],
    extensions: [".js", ".css", ".scss"]
  },
  output: {
    path: path.resolve(TMP_DIR, "dist"),
    filename: path.join(PUBLIC_PATH, JAVASCRIPTS_PATH, "[name].js")
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: NODE_MODULES,
        use: "babel-loader"
      },
      {
        test: /\.css$/,
        use: [cssExtractionLoader, "css-loader"]
      },
      {
        test: /\.(scss|sass)$/,
        exclude: NODE_MODULES,
        use: [
          cssExtractionLoader,
          {
            loader: "css-loader",
            options: {
              sourceMap: shouldRelyOnSourceMap()
            }
          },
          {
            loader: "resolve-url-loader",
            options: {
              sourceMap: shouldRelyOnSourceMap()
            }
          },
          postcssLoader,
          {
            loader: "sass-loader",
            options: {
              sourceMap: shouldRelyOnSourceMap(),
              includePaths: [bourbon.includePaths]
            }
          }
        ]
      },
      {
        test: /\.(eot|otf|ttf|woff|woff2)$/,
        exclude: NODE_MODULES,
        loader: "file-loader",
        options: {
          name: "[name]-[hash].[ext]",
          outputPath: path.join(PUBLIC_PATH, FONTS_PATH, "/")
        }
      },
      {
        test: /\.(png|jpg|svg)$/,
        exclude: NODE_MODULES,
        loader: "file-loader",
        options: {
          name: "[name]-[hash].[ext]",
          publicPath: "../images",
          outputPath: path.join(PUBLIC_PATH, IMAGES_PATH, "/")
        }
      }
    ]
  },
  plugins: determinePlugins()
};

module.exports = config;
