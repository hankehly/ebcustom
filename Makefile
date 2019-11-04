deploy:
	npm run build -- --mode production
	eb deploy
