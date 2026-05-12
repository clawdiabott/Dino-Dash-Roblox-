.PHONY: test validate dry-run-claw

test:
	python3 -m unittest discover -s tests -v

validate:
	python3 -m unittest discover -s tests -v
	python3 -m json.tool experiences.json >/dev/null

dry-run-claw:
	python3 tools/publish_place.py claw-machine --dry-run
