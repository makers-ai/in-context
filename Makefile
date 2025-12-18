.PHONY: analyze

analyze:
	@echo "Formatting code..."
	@find lib/* -name "*.dart" ! -name "*.mocks.dart" ! -name "firebase_options*.dart" ! -name "*.freezed.dart" ! -name "*.g.dart" ! -name "*.gr.dart" ! -name "*.config.dart" ! -path '*/generated/*' | xargs dart --disable-analytics format  $(PARAMS)
	@flutter analyze --no-pub