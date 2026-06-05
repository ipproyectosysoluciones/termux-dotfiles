.PHONY: test lint install clean changelog release

test:
	bats --recursive tests/

lint:
	shellcheck scripts/**/*.sh

install:
	bash scripts/install.sh

clean:
	rm -rf test-results/
	rm -f shellcheck-report.txt

changelog:
	bash scripts/release.sh changelog

release:
	bash scripts/release.sh changelog && git push --tags
