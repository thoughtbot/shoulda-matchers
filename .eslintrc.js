module.exports = {
  "env": {
    "browser": true,
    "node": true,
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": 2017,
    "sourceType": "module",
    "ecmaFeatures": {
      "jsx": true,
      "experimentalObjectRestSpread": true,
    },
  },
  "plugins": [
    "prettier",
  ],
  "rules": {
    "prettier/prettier": "error",
  },
}
