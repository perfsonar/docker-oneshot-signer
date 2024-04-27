#
# Makefile for One-Shot Docker Builder
#
# Note that this is for development and container image builds.
#

# What should be tested.  This should be 'rpm' or 'deb'.
TEST_WITH := rpm


KEY := @./test-key/key
PASSPHRASE_FILE := ./test-key/passphrase


# ----- NO USER-SERVICEABLE PARTS BELOW THIS LINE -----

# What container to use/build

ifeq ($(TEST_WITH),rpm)
  CONTAINER_FROM := almalinux:latest
endif
ifeq ($(TEST_WITH),deb)
  CONTAINER_FROM := debian:latest
endif

ifndef CONTAINER_FROM
  $(error TEST_WITH should be 'rpm' or 'deb')
endif


# Which repository should be used for testing
TEST_REPO := ./test-repos/$(TEST_WITH)


# How to invoke Docker

ifneq ($(shell id -u),0)
  DOCKER=sudo docker
else
  DOCKER=docker
endif


default: run


# Where the build happens.

IMAGE := signer-test
CONTAINER_NAME := signer-test

default: run

BUILT := .built
ifdef CONTAINER_FROM
  IMAGE_ARG := --build-arg 'FROM=$(CONTAINER_FROM)'
endif
$(BUILT): prep Dockerfile Makefile
	$(DOCKER) build \
		$(IMAGE_ARG) \
		--tag $(IMAGE) \
		.
	touch $@
TO_CLEAN += $(BUILT)


TEST_DIR := ./test
$(TEST_DIR):
	rm -rf $@
	cp -r "$(TEST_REPO)" $@
TO_CLEAN += $(TEST_DIR)


image: $(BUILT)


SIGN_ARGS += \
	--name "$(CONTAINER_NAME)" \
	--container "$(IMAGE)" \
	--passphrase "@$(PASSPHRASE_FILE)" \
	"$(TEST_DIR)" "$(KEY)"

# Show the command to run the container (for debug)
command::
	./sign --command $(SIGN_ARGS)

RUN_DEPS := $(BUILT) $(BUILD_DIR) $(TEST_DIR)

# Run the container and exit
run: $(RUN_DEPS)
	./sign $(SIGN_ARGS)


# Run the container but don't exit (for debug)
persist: $(RUN_DEPS)
	./sign --no-halt $(SIGN_ARGS)


# Log into the persisted container
shell:
	$(DOCKER) exec -it "$(CONTAINER_NAME)" bash


# Stop the persisted container
halt:
	$(DOCKER) exec -it "$(CONTAINER_NAME)" halt


# Remove the container
rm:
	$(DOCKER) rm -f "$(CONTAINER_NAME)"


clean: rm
	make -C prep clean
	$(DOCKER) image rm -f "$(IMAGE)"
	rm -rf $(TO_CLEAN) *~
