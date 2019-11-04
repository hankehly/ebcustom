const BundleTracker = require("webpack-bundle-tracker");

module.exports = {
    configureWebpack: {
        plugins: [
            new BundleTracker({
                path: __dirname,
                filename: "./webpack-stats.json"
            })
        ]
    },
    transpileDependencies: [
        "vuetify"
    ]
};