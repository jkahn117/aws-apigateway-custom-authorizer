build-SupportLayer:
	@echo "Staring custom Makefile build"
	@echo "Bundle install from Gemfile"
	bundle install --path=$(ARTIFACTS_DIR)
	rm -rf $(ARTIFACTS_DIR)/ruby/2.7.0/cache && rm -rf $(ARTIFACTS_DIR)/ruby/2.7.0/bin
	mkdir $(ARTIFACTS_DIR)/ruby/gems
	mv $(ARTIFACTS_DIR)/ruby/2.7.0 $(ARTIFACTS_DIR)/ruby/gems
	@echo "Copy lib/ contents"
	mkdir $(ARTIFACTS_DIR)/ruby/lib
	pwd
	cp -r lib/* $(ARTIFACTS_DIR)/ruby/lib