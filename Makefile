deploy:
	# Output HEAD sha to file named "HEAD"
	git rev-parse HEAD > HEAD

	# Build production assets
	npm run build -- --mode production

	# Upload assets to S3
	aws s3 sync ./dist s3://octo-waffle/ebcustom/$(cat ./HEAD)/

	# Deploy new app version to beanstalk
	# Bundle includes HEAD file which tells us
	# which assets to download
	eb deploy
example:
	# $ make example foo=bar
	# >>> I say foo, you say 'bar'
	echo "I say foo, you say '$(foo)'"