.PHONY: protos clean

protos:
	buf lint
	buf generate
	cd packages/cedar; dart format .

clean:
	rm -rf packages/cedar/lib/src/proto
