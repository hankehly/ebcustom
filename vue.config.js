const AWS = require("aws-sdk");
// const BundleTracker = require("webpack-bundle-tracker");
const S3Plugin = require('webpack-s3-plugin');
const exec = require('child_process').exec;

const gitsha = (path, callback) => {
    exec('git rev-parse --short HEAD', {cwd: path}, (error, stdout, stderr) => {
        if (error) {
            return callback(error, stderr.trim());
        }
        callback(null, stdout.trim())
    });
};

module.exports = {
    filenameHashing: false,
    configureWebpack: {
        plugins: [
            // new BundleTracker({
            //     path: __dirname,
            //     filename: "./webpack-stats.json"
            // }),
            new S3Plugin({
                s3Options: {
                    credentials: new AWS.SharedIniFileCredentials({profile: "default"})
                },
                s3UploadOptions: {
                    Bucket: "octo-waffle",
                },
                basePathTransform: () => {
                    return new Promise((resolve, reject) => {
                        gitsha(__dirname, function (error, output) {
                            if (error) {
                                reject(error);
                            } else {
                                resolve(`ebcustom-${output}`);
                            }
                        });
                    });
                },
            })
        ]
    },
    transpileDependencies: [
        "vuetify"
    ]
};