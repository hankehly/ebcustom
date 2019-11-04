# Generate a requirements.txt file from poetry-lock.json
poetry run python requirements.py >requirements.txt

# Output HEAD sha to file named "HEAD"
SHA=$(git rev-parse HEAD)
echo $SHA >HEAD

# Build production assets
npm run build -- --mode production

# Upload assets to S3 with public-read access
aws s3 sync --acl public-read ./dist s3://octo-waffle/ebcustom/${SHA}/

# Deploy new app version to beanstalk
# Bundle includes HEAD file which tells us
# which assets to download
eb deploy
