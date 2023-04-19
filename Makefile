build: build-heroku-22

build-heroku-22:
	@echo "Building nginx in Docker for heroku-22..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-22" -w /buildpack heroku/heroku:22-build scripts/build_nginx /buildpack/bin/nginx-heroku-22

shell:
	@echo "Opening heroku-22 shell..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-22" -e "PORT=5000" -w /buildpack heroku/heroku:22-build bash
