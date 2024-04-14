PACKAGES ?= $(filter-out local/ scripts/, $(wildcard */))
TARGET   ?= ${HOME}

ROOT_DIR  := $(shell dirname -- $(realpath $(firstword $(MAKEFILE_LIST))))
LOCAL_DIR := $(ROOT_DIR)/local
STOW      := $(LOCAL_DIR)/stow/bin/stow
STOW_VER  := stow-2.4.0

STOW_CMD = $(STOW) \
	   --dir=$(ROOT_DIR) \
	   --target=$(TARGET) \
	   --restow \
	   --adopt \
	   --verbose

all: | install_stow install

install: | backup stow

intall_stow:
	if [ ! -f $(STOW) ]; then \
		wget http://mirror.freedif.org/GNU/stow/$(STOW_VER).tar.gz -P $(LOCAL_DIR) \
			&& tar -C $(LOCAL_DIR) -xf $(LOCAL_DIR)/$(STOW_VER).tar.gz \
			&& cd $(LOCAL_DIR)/$(STOW_VER) \
			&& ./configure --prefix $(LOCAL_DIR)/stow \
			&& make install \
			&& rm -rf $(LOCAL_DIR)/stow-* ; \
	fi
stow:
	@echo 'Applying stow...'
	@$(foreach package, $(PACKAGES), $(STOW_CMD) $(package);)

unstow:
	@echo 'Deleting'

.PHONY: all backup install install_stow stow unstow
